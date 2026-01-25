import Darwin
import Foundation

// ##################################################################
// ProcessMonitor
// Polls running processes and kills those exceeding memory threshold
final class ProcessMonitor: ObservableObject {
    private var timer: Timer?
    private let configuration: Configuration
    private let pollInterval: TimeInterval = 5.0

    @Published var lastCheckTime: Date?
    @Published var processCount: Int = 0

    // ##################################################################
    // init
    // Create monitor with configuration reference
    init(configuration: Configuration) {
        self.configuration = configuration
    }

    // ##################################################################
    // start
    // Begin polling for memory-heavy processes
    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.checkProcesses()
        }
        // Run immediately on start
        checkProcesses()
    }

    // ##################################################################
    // stop
    // Stop polling
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // ##################################################################
    // checkProcesses
    // Get all processes, find leaf offenders, kill them
    private func checkProcesses() {
        let processes = getAllProcesses()
        processCount = processes.count
        lastCheckTime = Date()

        let tree = ProcessTree(processes: processes)
        let offenders = tree.findLeafOffenders(thresholdBytes: configuration.thresholdBytes)

        if !offenders.isEmpty {
            killProcesses(offenders)
            AlertPresenter.showKillAlert(killedProcesses: offenders)
        }
    }

    // ##################################################################
    // getAllProcesses
    // Use Darwin APIs to enumerate all processes with memory info
    private func getAllProcesses() -> [ProcessInfoData] {
        var processes: [ProcessInfoData] = []

        // Get the number of processes
        var numPids = proc_listallpids(nil, 0)
        guard numPids > 0 else { return processes }

        // Allocate buffer for PIDs
        var pids = [pid_t](repeating: 0, count: Int(numPids))
        numPids = proc_listallpids(&pids, Int32(MemoryLayout<pid_t>.size * Int(numPids)))
        guard numPids > 0 else { return processes }

        let pidCount = Int(numPids) / MemoryLayout<pid_t>.size

        for i in 0..<pidCount {
            let pid = pids[i]
            guard pid > 0 else { continue }

            if let procInfo = getProcessInfo(pid: pid) {
                processes.append(procInfo)
            }
        }

        return processes
    }

    // ##################################################################
    // getProcessInfo
    // Get detailed info for a single process
    private func getProcessInfo(pid: pid_t) -> ProcessInfoData? {
        // Get process name (MAXPATHLEN * 4 = 4096, matching PROC_PIDPATHINFO_MAXSIZE)
        var pathBuffer = [CChar](repeating: 0, count: 4096)
        let pathLen = proc_pidpath(pid, &pathBuffer, UInt32(pathBuffer.count))
        let name: String
        if pathLen > 0 {
            let fullPath = String(cString: pathBuffer)
            name = (fullPath as NSString).lastPathComponent
        } else {
            // Fallback: try to get name from proc_name
            var nameBuffer = [CChar](repeating: 0, count: Int(MAXCOMLEN) + 1)
            proc_name(pid, &nameBuffer, UInt32(nameBuffer.count))
            name = String(cString: nameBuffer)
        }

        guard !name.isEmpty else { return nil }

        // Get task info for memory usage
        var taskInfo = proc_taskinfo()
        let taskInfoSize = Int32(MemoryLayout<proc_taskinfo>.size)
        let result = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &taskInfo, taskInfoSize)

        guard result == taskInfoSize else { return nil }

        // Get parent PID
        var bsdInfo = proc_bsdinfo()
        let bsdInfoSize = Int32(MemoryLayout<proc_bsdinfo>.size)
        let bsdResult = proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &bsdInfo, bsdInfoSize)

        let ppid: pid_t
        if bsdResult == bsdInfoSize {
            ppid = pid_t(bsdInfo.pbi_ppid)
        } else {
            ppid = 0
        }

        // Use resident size as physical memory footprint
        let memoryBytes = taskInfo.pti_resident_size

        return ProcessInfoData(
            pid: pid,
            ppid: ppid,
            name: name,
            memoryBytes: memoryBytes
        )
    }

    // ##################################################################
    // killProcesses
    // Send SIGKILL to each process
    private func killProcesses(_ processes: [ProcessInfoData]) {
        for proc in processes {
            kill(proc.pid, SIGKILL)
        }
    }
}
