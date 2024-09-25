{ lib, config, pkgs, ... }:
with lib;
{
  # build a restic restore set for both local and remote
  sops.secrets."rclone-config" = {
    sopsFile = ./secrets.sops.yaml;
  };

  sops.secrets."restic-repo-password" = {
    sopsFile = ./secrets.sops.yaml;
  };

  lib.hostConfig.mkRestic = options: (
    let
      excludePath = if builtins.hasAttr "excludePath" options then options.excludePath else [ ];
      timerConfig = {
        OnCalendar = "02:15";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
      initialize = true;
    in
    {

      # gdrive backup
      "gdrive-${options.app}" = {
        inherit pruneOpts timerConfig initialize;
        paths = options.paths;
        rcloneConfigFile = config.sops.secrets."rclone-config".path;
        passwordFile = config.sops.secrets."restic-repo-password".path;
        repository = "rclone:gdrive:/backups/${options.app}";
        exclude = excludePath;
      };
    }
  );

}
