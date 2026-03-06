{ shouldidrinktoday-html }:

{ config, lib, pkgs, ... }:

let
  cfg = config.services.shouldidrinktoday;
in
{
  options.services.shouldidrinktoday = {
    enable = lib.mkEnableOption "Should I Drink Today website";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "shouldidrink.today";
      description = "Domain name for the virtual host.";
    };

    acme = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable ACME/Let's Encrypt and force SSL.";
    };

    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional domains that redirect to the main domain, served on the same virtual host.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.domain} = {
        forceSSL = cfg.acme;
        enableACME = cfg.acme;
        root = "${shouldidrinktoday-html}";
        serverAliases = cfg.extraDomains;
        extraConfig = lib.mkIf (cfg.extraDomains != [ ]) ''
          if ($host != "${cfg.domain}") {
            return 301 $scheme://${cfg.domain}$request_uri;
          }
        '';
      };
    };

    security.acme.certs = lib.mkIf (cfg.acme && cfg.extraDomains != [ ]) {
      ${cfg.domain}.extraDomainNames = cfg.extraDomains;
    };
  };
}
