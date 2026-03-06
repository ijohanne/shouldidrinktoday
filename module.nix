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
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.domain} = {
        forceSSL = true;
        enableACME = true;
        root = "${shouldidrinktoday-html}";
      };
    };
  };
}
