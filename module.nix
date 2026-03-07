{ shouldidrinktoday-html }:

{ config, lib, pkgs, ... }:

let
  cfg = config.services.shouldidrinktoday;

  htmlRoot = if cfg.analytics.plausible.enable then
    pkgs.runCommand "shouldidrinktoday-html" { } ''
      cp -r ${shouldidrinktoday-html} $out
      chmod -R u+w $out
      substituteInPlace $out/index.html \
        --replace-fail '</head>' '<script defer data-domain="${cfg.analytics.plausible.domain}" src="${cfg.analytics.plausible.scriptUrl}"></script>
</head>'
    ''
  else
    shouldidrinktoday-html;
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

    acmeRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Override the ACME webroot. Set to null when using DNS-01 validation. Only applies when acme is enabled.";
    };

    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional domains that redirect to the main domain, served on the same virtual host.";
    };

    analytics.plausible = {
      enable = lib.mkEnableOption "Plausible analytics";

      domain = lib.mkOption {
        type = lib.types.str;
        default = cfg.domain;
        description = "The data-domain attribute for the Plausible script. Defaults to the virtualhost domain.";
      };

      scriptUrl = lib.mkOption {
        type = lib.types.str;
        default = "https://analytics.unixpimps.net/js/script.js";
        description = "URL to the Plausible analytics script.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.domain} = {
        forceSSL = cfg.acme;
        enableACME = cfg.acme;
        root = "${htmlRoot}";
        serverAliases = cfg.extraDomains;
        extraConfig = lib.mkIf (cfg.extraDomains != [ ]) ''
          if ($host != "${cfg.domain}") {
            return 301 $scheme://${cfg.domain}$request_uri;
          }
        '';
      } // lib.optionalAttrs cfg.acme {
        acmeRoot = cfg.acmeRoot;
      };
    };

    security.acme.certs = lib.mkIf (cfg.acme && cfg.extraDomains != [ ]) {
      ${cfg.domain}.extraDomainNames = cfg.extraDomains;
    };
  };
}
