# Memory Protection

macOS menu bar app that monitors process memory and kills processes exceeding a threshold.

## Project Structure

```
run                    # Python argparse - build/install/uninstall/start/stop/status
src/MemoryProtection/  # Swift Package Manager project
  Sources/MemoryProtection/
    MemoryProtectionApp.swift  # SwiftUI @main, MenuBarExtra
    ProcessMonitor.swift       # Polls every 5s, uses Darwin APIs
    ProcessTree.swift          # Leaf offender algorithm
    ProcessInfo.swift          # Data structures
    Configuration.swift        # UserDefaults for threshold
    AlertPresenter.swift       # NSAlert on kill
resources/
  MenuBarIcon.png              # Custom icon (generated)
  com.user.memoryprotection.plist  # LaunchAgent template
```

## Key Algorithm: Leaf Offender

When child process uses memory, parent appears to "have" that memory too. Kill only processes over threshold with NO descendants also over threshold.

Example: Terminal shows 90GB, Python (child) shows 75GB → kill only Python.

## Darwin Process APIs

```swift
proc_listallpids(nil, 0)           // Get process count
proc_listallpids(&pids, size)      // Fill PID array
proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &taskInfo, size)  // Memory info
proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &bsdInfo, size)   // Parent PID
proc_pidpath(pid, &buffer, size)   // Process path
proc_name(pid, &buffer, size)      // Process name (fallback)
```

## Gotchas

- **PROC_PIDPATHINFO_MAXSIZE**: Not available in Swift. Use hardcoded `4096`.
- **NSAlert.window**: Not Optional in newer AppKit. Don't use `if let`.
- **Menu bar icon size**: Set `nsImage.size = NSSize(width: 16, height: 16)` explicitly. Don't use SwiftUI `.frame()`.
- **Template image**: Set `nsImage.isTemplate = true` for light/dark mode adaptation.
- **App bundle**: SPM builds executable; wrap in `.app/Contents/MacOS/` + `Info.plist` with `LSUIElement = true`.

## Run Commands

```bash
./run build      # Idempotent - only rebuilds if sources newer than product
./run install    # build + copy to ~/Applications + LaunchAgent + load
./run uninstall  # Unload LaunchAgent, remove app
./run start      # Open app
./run stop       # pkill
./run status     # Show running state
```

## LaunchAgent

Location: `~/Library/LaunchAgents/com.user.memoryprotection.plist`
- `RunAtLoad: true` - starts on login
- `KeepAlive: true` - restarts if killed
