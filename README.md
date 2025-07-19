# FortiRepair

**Version:** 1.0

A macOS utility script for automated FortiGate network route management and repair.

## Requirements

- macOS system
- Root privileges
- FortiGate network environment

## Installation

1. Download or clone this repository
2. Place both `fortiRepair.sh` and `routes.list` in your preferred directory (recommended: `/opt/fortiRepair/`)
3. Ensure the script has executable permissions:
   ```bash
   sudo chmod +x /opt/fortiRepair/fortiRepair.sh
   ```

## Manual Usage

Run the script manually with root privileges:

```bash
sudo /opt/fortiRepair/fortiRepair.sh
```

## Automatic Execution Setup

To run fortiRepair automatically using macOS Launch Daemons:

### 1. Install the Launch Daemon

Place the `local.fortiRepair.plist` file in the Launch Daemons directory:

```bash
sudo cp local.fortiRepair.plist /Library/LaunchDaemons/
```

### 2. Configure the Daemon

Edit `/Library/LaunchDaemons/local.fortiRepair.plist` to match your setup:

- **ProgramArguments**: Update the script path if you placed it somewhere other than `/opt/fortiRepair/`
- **StartInterval**: Set the execution interval in seconds (e.g., 300 for 5 minutes)

### 3. Register with launchd

Load and enable the daemon:

```bash
sudo launchctl load -w /Library/LaunchDaemons/local.fortiRepair.plist
```

### 4. Uninstall (Optional)

To permanently remove the automatic execution:

```bash
sudo launchctl unload -w /Library/LaunchDaemons/local.fortiRepair.plist
sudo rm /Library/LaunchDaemons/local.fortiRepair.plist
```

## Files

- `fortiRepair.sh` - Main repair script
- `routes.list` - Route configuration file
- `local.fortiRepair.plist` - Launch Daemon configuration

## Important Notes

- This script must be run with root privileges
- Ensure both `fortiRepair.sh` and `routes.list` are in the same directory
- Test the script manually before setting up automatic execution
- Monitor system logs for any execution errors when running automatically

## Troubleshooting

- Verify file permissions if the script fails to execute
- Check `/var/log/system.log` for Launch Daemon related messages
- Ensure the paths in `local.fortiRepair.plist` match your actual file locations

## License

[Add your license information here]

## Contributing

[Add contribution guidelines here]
