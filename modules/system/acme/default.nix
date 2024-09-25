{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.hostConfig.system.acme;
in
{
  options.hostConfig.system.acme.enable = mkEnableOption "acme";

  config = mkIf cfg.enable {
    users.users.nginx = {
      isSystemUser = true;
      extraGroups = [ "acme" ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "domains@${config.hostConfig.domainName}";
      defaults.credentialFiles = {
        CLOUDFLARE_DNS_API_TOKEN_FILE = "/var/lib/secrets/acme/cloudflare-api-token";
      };

      certs."${config.hostConfig.domainName}" = {
        extraDomainNames = [
          "${config.hostConfig.domainName}"
          "*.${config.hostConfig.domainName}"
        ];
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
      };
    };
  };
}
