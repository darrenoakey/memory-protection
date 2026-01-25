import Foundation

// ##################################################################
// ProcessTree
// Builds parent-child relationships and finds leaf offender processes
struct ProcessTree {
    private let processes: [pid_t: ProcessInfoData]
    private let children: [pid_t: [pid_t]]

    // ##################################################################
    // init
    // Build the tree from a list of process info
    init(processes: [ProcessInfoData]) {
        var processMap: [pid_t: ProcessInfoData] = [:]
        var childMap: [pid_t: [pid_t]] = [:]

        for proc in processes {
            processMap[proc.pid] = proc
            childMap[proc.ppid, default: []].append(proc.pid)
        }

        self.processes = processMap
        self.children = childMap
    }

    // ##################################################################
    // findLeafOffenders
    // Find processes over threshold with no descendants also over threshold
    // These are the actual source of memory usage, not parents inheriting child memory
    func findLeafOffenders(thresholdBytes: UInt64) -> [ProcessInfoData] {
        let overThreshold = processes.values.filter { $0.memoryBytes >= thresholdBytes }
        let overThresholdPids = Set(overThreshold.map { $0.pid })

        var leafOffenders: [ProcessInfoData] = []

        for proc in overThreshold {
            if !hasDescendantOverThreshold(pid: proc.pid, thresholdPids: overThresholdPids) {
                leafOffenders.append(proc)
            }
        }

        return leafOffenders
    }

    // ##################################################################
    // hasDescendantOverThreshold
    // Recursively check if any descendant is in the over-threshold set
    private func hasDescendantOverThreshold(pid: pid_t, thresholdPids: Set<pid_t>) -> Bool {
        guard let childPids = children[pid] else { return false }

        for childPid in childPids {
            if thresholdPids.contains(childPid) {
                return true
            }
            if hasDescendantOverThreshold(pid: childPid, thresholdPids: thresholdPids) {
                return true
            }
        }

        return false
    }
}
