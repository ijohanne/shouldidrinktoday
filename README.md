# shouldidrink.today

A NixOS module that serves the [shouldidrink.today](https://shouldidrink.today) website via nginx.

## Usage

Add this flake to your NixOS configuration:

```nix
{
  inputs.shouldidrinktoday.url = "github:ijohanne/shouldidrinktoday";

  outputs = { nixpkgs, shouldidrinktoday, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        shouldidrinktoday.nixosModules.default
        {
          services.shouldidrinktoday = {
            enable = true;
            domain = "shouldidrink.today";
            acme = true; # set to false to disable ACME/SSL
          };
        }
      ];
    };
  };
}
```

## Local development

```sh
direnv allow  # or: nix develop
serve         # serves the site at http://localhost:8080
```

## License

MIT
