# NixOS Homelab

This repository manages my personal NixOS homelab and using flakes, enabling modularity, scalability, and ease of configuration across multiple machines.

## Structure

- **`home/`**: User-specific configurations (currently unused).
- **`hosts/`**: Machine-specific configs:
  - `b660-i5-13600/`, `dell-i5-7300U/`, `m2macbook/`.
- **`modules/`**: Reusable service and system modules:
  - **Containers**: Configs for `frigate/`, `home-assistant/`.
  - **Services**: Modules for `mosquitto/`, `plex/`, `prowlarr/`, `radarr/`, `sonarr/`, `sabnzbd/`, `zigbee2mqtt/`.
  - **System**: Configurations for `acme/` (SSL certificates), `restic/` (backup management).
- **`profiles/`**: Role-based configurations (e.g., `server/`) for sharing setups across hosts.
- **`flake.nix`**: Main configuration for defining hosts and services.
- **`flake.lock`**: Locks inputs for reproducibility.
- **`README.md`**: Documentation.

## Key Features

- **Modular Design**: Each service/container is a module, making it easy to manage per host.
- **Flake-powered**: Ensures declarative, reproducible setups across machines.
- **SOPS Integration**: Secure secrets management via encrypted files.
- **Restic Support**: Automated backup management with custom prune and backup arguments.


## Restoring backups
`restic -r rclone:gdrive:/backups/<app> restore <latest> --target <path>`

## Links & References

- [truxnell/dotfiles](https://github.com//truxnell/nix-config/)
