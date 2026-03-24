# Backup Utility (BKU)

A lightweight, Git-inspired backup tool built entirely with Bash scripting. Developed for **Lab 1: Introduction to Linux Programming (Section 3.6)** at **Ho Chi Minh City University of Technology (HCMUT)**.

## Overview

BKU is designed to selectively back up source code files within a directory. Unlike traditional backup systems that copy entire files, BKU focuses on storing differences (**diffs**) to save space and provide a history of changes.

## Features

* **Selective Tracking**: Add specific files or all files in a folder to the tracking system.
* **Change Detection**: Use the `status` command to view line-by-line differences since the last commit.
* **Version History**: Maintain a chronological log of all actions and commits.
* **One-Step Restore**: Quickly revert files to their immediate previous version[
* **Automated Backups**: Schedule automatic commits using `cron` (Daily, Hourly, Weekly, or specific minute intervals).

## Installation

The system includes a `setup.sh` script to check for dependencies (`diff`, `cron`, `grep`, `sed`, `find`, `mkdir`) and install the utility to your system path.

1.  **Clone the repository** and navigate to the project folder.
2.  **Run the installer**:
    ```bash
    sudo ./setup.sh --install
    ```
    *This will install the tool as `bku` in `/usr/local/bin/`.*

3.  **To uninstall**:
    ```bash
    sudo ./setup.sh --uninstall
    ```

## Usage

BKU must be initialized within the "Root Folder" of your project before use.

### Basic Commands

| Command | Description |
| :--- | :--- |
| `bku init` | Initializes the `.bku` repository and metadata files. |
| `bku add [file]` | Tracks a specific file or all files if no name is provided. |
| `bku status [file]` | Shows changes (diffs) since the last commit. |
| `bku commit "msg" [file]` | Commits changes for a file (or all) with a message. |
| `bku history` | Displays the full commit history. |
| `bku restore [file]` | Reverts file(s) to the previous committed version. |
| `bku stop` | Removes the `.bku` folder and stops all scheduling. |

### Automation (Scheduling)

You can automate your backups using the following flags:
* `bku schedule --daily`: Every day at 00:00.
* `bku schedule --hourly`: At the top of every hour.
* `bku schedule --minute <1-59>`: At a specific minute interval.
* `bku schedule --off`: Disable all scheduled backups.

## Requirements

* **Operating System**: Linux (Ubuntu 16.04 or later recommended) or WSL.
* **Shell**: Bash.
* **Dependencies**: `diff`, `cron`, `grep`, `sed`, `find`. (The system will check these dependencies before installation)

## Credits

Developed as part of the Operating Systems course, Faculty of Computer Science & Engineering, **HCMC University of Technology**.
