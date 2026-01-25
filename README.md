# Memory Protection

A macOS menu bar app that monitors process memory usage and kills processes exceeding a configurable threshold.

## Features

- Sits in the menu bar with minimal footprint
- Configurable memory threshold (default: 50GB)
- Kills the actual offending process, not parent processes
- Shows alert when a process is terminated
- Runs at startup via LaunchAgent

## Installation

```bash
./run install
```

This will:
1. Build the app (if needed)
2. Install to ~/Applications
3. Set up auto-start via LaunchAgent
4. Start the app

## Commands

```bash
./run build      # Build the app
./run install    # Build, install, and set up auto-start
./run uninstall  # Remove app and auto-start
./run start      # Start the app
./run stop       # Stop the app
./run status     # Show running status
```

## How It Works

The app polls all processes every 5 seconds and checks their physical memory footprint. When a process exceeds the threshold, it uses the "leaf offender" algorithm:

1. Build a process tree (parent-child relationships)
2. Find all processes over the threshold
3. Kill only "leaf offenders" - processes over threshold with no descendants also over threshold

This ensures that if Python uses 75GB and Terminal shows 90GB (because it's the parent), only Python gets killed - not Terminal.

## Configuration

Click the menu bar icon to change the memory threshold. The setting persists across restarts.

## Requirements

- macOS 13.0 or later
- Swift 5.9 or later
