import AppKit
import Foundation

// ##################################################################
// AlertPresenter
// Shows alerts when processes are killed
struct AlertPresenter {
    // ##################################################################
    // showKillAlert
    // Display a centered alert about killed process(es)
    static func showKillAlert(killedProcesses: [ProcessInfoData]) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "Memory Protection: Process Terminated"

            let details = killedProcesses.map { proc in
                "\(proc.name) (PID \(proc.pid)) - \(proc.memoryDescription)"
            }.joined(separator: "\n")

            alert.informativeText = "The following process(es) exceeded the memory threshold and were terminated:\n\n\(details)"
            alert.addButton(withTitle: "OK")

            // Center the alert on the main screen
            let window = alert.window
            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame
                let windowFrame = window.frame
                let x = screenFrame.midX - windowFrame.width / 2
                let y = screenFrame.midY - windowFrame.height / 2
                window.setFrameOrigin(NSPoint(x: x, y: y))
            }

            alert.runModal()
        }
    }
}
