{
  description = "Should I Drink Today - nginx vhost module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    shouldidrinktoday-html = {
      url = "git+ssh://delirium.unixpimps.net/var/www/shouldidrink.today/html";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, shouldidrinktoday-html }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in
    {
      nixosModules.default = import ./module.nix { inherit shouldidrinktoday-html; };

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          serve = pkgs.writeShellScriptBin "serve" ''
            echo "Serving shouldidrink.today at http://localhost:8080"
            ${pkgs.nodePackages.http-server}/bin/http-server ${shouldidrinktoday-html} -p 8080
          '';
        in
        {
          default = pkgs.mkShell {
            packages = [ serve ];
          };
        });
    };
}
