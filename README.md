# NixOS Homelab

This repository manages my personal NixOS homelab and using flakes, enabling modularity, scalability, and ease of configuration across multiple machines.

## Install from github
```bash
nixos-rebuild switch --flake github:sebastiaankok/nix-homelab#HOSTNAME
```

## Update a host from local path

```bash
cd ~/nix-config
nixos-rebuild switch --flake . # This will automatically pick the configuration name based on the hostname
```

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

### Backblaze B2
- `restic -r s3:s3.eu-central-003.backblazeb2.com/nixos-homelab/backups/<app> restore --target <path> latest`

### Scaleway Glacier
[Scaleway glacier restore](https://www.scaleway.com/en/docs/storage/object/how-to/restore-an-object-from-glacier/)
- `restic -r s3:s3.nl-ams.scw.cloud/nixos-homelab/backups/<app> restore --target <path> latest`


## Links & References

- [truxnell/dotfiles](https://github.com//truxnell/nix-config/)
