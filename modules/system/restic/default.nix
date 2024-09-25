{
  services.restic.backups = {
    gdrive = {
      user = "root";
      timerConfig = {
        OnCalendar = "04:00";
      };
      repository = "rclone:gdrive:/backups";
      initialize = true;
      passwordFile = "/var/lib/restic/gdrive-password";
      rcloneConfigFile = "/var/lib/restic/rclone.conf";

      paths = [ "/data" ];

      extraBackupArgs = [
        "--exclude=./nvr"
        "--exclude=./library/dl"
        "--exclude=./library/movies"
        "--exclude=./library/tv"
      ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 1"
        "--keep-monthly 3"
        "--keep-yearly 1"
      ];

    };
  };
}
