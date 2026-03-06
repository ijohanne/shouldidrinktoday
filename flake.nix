{
  description = "Should I Drink Today - nginx vhost module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    shouldidrinktoday-html = {
      url = "git+ssh://delirium.unixpimps.net/var/www/shouldidrink.today/html";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, shouldidrinktoday-html }: {
    nixosModules.default = import ./module.nix { inherit shouldidrinktoday-html; };
  };
}
