import Foundation

// ##################################################################
// ProcessInfo
// Data structure representing a running process with its memory usage
struct ProcessInfoData: Identifiable {
    let pid: pid_t
    let ppid: pid_t
    let name: String
    let memoryBytes: UInt64

    var id: pid_t { pid }

    var memoryGB: Double {
        Double(memoryBytes) / (1024 * 1024 * 1024)
    }

    var memoryDescription: String {
        String(format: "%.2f GB", memoryGB)
    }
}
