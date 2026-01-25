import AppKit
import SwiftUI

// ##################################################################
// MemoryProtectionApp
// Main application entry point with menu bar presence
@main
struct MemoryProtectionApp: App {
    @StateObject private var configuration = Configuration()
    @StateObject private var monitor: ProcessMonitor

    init() {
        let config = Configuration()
        _configuration = StateObject(wrappedValue: config)
        _monitor = StateObject(wrappedValue: ProcessMonitor(configuration: config))
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(configuration: configuration, monitor: monitor)
        } label: {
            MenuBarIcon()
        }
        .menuBarExtraStyle(.window)
    }
}

// ##################################################################
// MenuBarIcon
// Custom icon loaded from app bundle resources
struct MenuBarIcon: View {
    var body: some View {
        if let iconPath = Bundle.main.path(forResource: "MenuBarIcon", ofType: "png"),
           let nsImage = NSImage(contentsOfFile: iconPath) {
            // Set as template image for proper light/dark mode handling
            nsImage.isTemplate = true
            return AnyView(
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            )
        } else {
            // Fallback to system symbol
            return AnyView(Image(systemName: "memorychip"))
        }
    }
}

// ##################################################################
// MenuBarView
// Content shown when clicking the menu bar icon
struct MenuBarView: View {
    @ObservedObject var configuration: Configuration
    @ObservedObject var monitor: ProcessMonitor
    @State private var thresholdText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memory Protection")
                .font(.headline)

            Divider()

            HStack {
                Text("Threshold:")
                TextField("GB", text: $thresholdText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .onSubmit {
                        if let value = Int(thresholdText), value > 0 {
                            configuration.thresholdGB = value
                        }
                        thresholdText = "\(configuration.thresholdGB)"
                    }
                Text("GB")
            }

            if let lastCheck = monitor.lastCheckTime {
                Text("Last check: \(lastCheck.formatted(date: .omitted, time: .standard))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Monitoring \(monitor.processCount) processes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
        .frame(width: 220)
        .onAppear {
            thresholdText = "\(configuration.thresholdGB)"
            monitor.start()
        }
    }
}
