![](banner.jpg)

# Memory Protection

A macOS menu bar app that monitors process memory usage and automatically terminates processes that exceed a configurable threshold.

## Purpose

Memory Protection runs quietly in your menu bar and watches for runaway processes that consume excessive memory. When a process exceeds your configured limit (default: 50GB), it automatically kills the offending process and shows you an alert. This prevents your Mac from grinding to a halt when a process goes haywire.

## Installation

```bash
./run install
```

This builds the app, installs it to `~/Applications`, configures it to start automatically at login, and launches it immediately.

## Usage

### Menu Bar Controls

Click the Memory Protection icon in your menu bar to:
- View and change the memory threshold
- See the current monitoring status

### Commands

| Command | Description |
|---------|-------------|
| `./run build` | Build the app |
| `./run install` | Build, install, and set up auto-start |
| `./run uninstall` | Remove the app and auto-start configuration |
| `./run start` | Start the app |
| `./run stop` | Stop the app |
| `./run status` | Show whether the app is running |

### Examples

**Install and start monitoring:**
```bash
./run install
```

**Check if the app is running:**
```bash
./run status
```

**Stop monitoring temporarily:**
```bash
./run stop
```

**Restart monitoring:**
```bash
./run start
```

**Completely remove the app:**
```bash
./run uninstall
```

**Force a rebuild and reinstall:**
```bash
./run install --force
```

## Requirements

- macOS 13.0 or later

## License

This project is licensed under [CC BY-NC 4.0](https://darren-static.waft.dev) - free to use and modify, but no commercial use without permission.
