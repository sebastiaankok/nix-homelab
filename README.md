# NixOS Homelab

This repository manages my personal NixOS homelab using flakes, enabling modularity, scalability, and ease of configuration across multiple machines.

## Install from GitHub
```bash
nixos-rebuild switch --flake github:sebastiaankok/nix-homelab#HOSTNAME
```

## Update a Host from Local Path

```bash
cd ~/nix-config
nixos-rebuild switch --flake . # This will automatically pick the configuration name based on the hostname
```

## Structure

- **`home/`**: User-specific configurations (currently unused).
- **`hosts/`**: Machine-specific configs:
  - `b660-i5-13600/`, `dell-i5-7300U/`.
- **`modules/`**: Reusable service and system modules:
  - **Containers**: Configs for `frigate/`, `home-assistant/`.
  - **Services**: Modules for `mosquitto/`, `plex/`, `prowlarr/`, `radarr/`, `sonarr/`, `sabnzbd/`, `zigbee2mqtt/`.
  - **System**: Configurations for `acme/` (SSL certificates), `restic/` (backup management).
- **`profiles/`**: Role-based configurations (e.g., `workstation.nix`) for sharing setups across hosts.
- **`flake.nix`**: Main configuration for defining hosts and services.
- **`flake.lock`**: Locks inputs for reproducibility.
- **`README.md`**: Documentation.

## Key Features

- **Modular Design**: Each service/container is a module, making it easy to manage per host.
- **Flake-powered**: Ensures declarative, reproducible setups across machines.
- **SOPS Integration**: Secure secrets management via encrypted files.
- **Restic Support**: Automated backup management with custom prune and backup arguments.

## Restoring Backups

### Local
```bash
restic -r /storage/backups/<app> restore --target <path> latest
```

### Backblaze B2
```bash
restic -r s3:s3.eu-central-003.backblazeb2.com/nixos-homelab/backups/<app> restore --target <path> latest
```

### Scaleway Glacier
[Scaleway glacier restore](https://www.scaleway.com/en/docs/storage/object/how-to/restore-an-object-from-glacier/)
```bash
restic -r s3:s3.nl-ams.scw.cloud/nixos-homelab/backups/<app> restore --target <path> latest
```

## Links & References

- [truxnell/dotfiles](https://github.com/truxnell/nix-config/)
```