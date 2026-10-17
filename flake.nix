{
  description = "Owen's machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Not following nixpkgs here on purpose, AND pinned to the "cachix"
    # branch rather than main: that's the only branch Noctalia's Cachix
    # cache actually guarantees prebuilt binaries for. main's latest commit
    # is not necessarily cached, which means compiling its Qt/C++ core
    # locally (slow). See nix.settings below for the cache itself.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      stylix,
      ...
    }:
    let
      # Standalone home-manager hosts (non-NixOS) need their own pkgs.
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      pkgs = pkgsFor "x86_64-linux";
    in
    {
      # `nix fmt` formats every .nix file in the repo.
      formatter.x86_64-linux = pkgs.nixfmt;

      # Everything the pre-commit hooks need (see .pre-commit-config.yaml and
      # scripts/in-devshell). Enter with `nix develop`; hooks also re-enter
      # it on their own, so you never have to.
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          pre-commit
          nixfmt
          statix
          deadnix
          ruff
          stylua
          shellcheck
        ];
      };

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/laptop/configuration.nix
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          (
            { pkgs, ... }:
            let
              theme = import ./theme.nix { inherit pkgs; };
            in
            {
              # Computed once here, handed to both the NixOS modules (as a
              # plain module arg) and home-manager modules (as a specialArg)
              # so hosts/laptop/configuration.nix and home/os/nixos/noctalia.nix read
              # the exact same values instead of each defining "gruvbox"
              # themselves.
              _module.args.theme = theme;

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs theme; };
              home-manager.users.owen = import ./home/machines/personal-laptop.nix;
            }
          )
        ];
      };

      # Work laptop (Ubuntu, standalone home-manager).
      homeConfigurations."owen@work-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = {
          inherit inputs;
          theme = import ./theme.nix { pkgs = pkgsFor "x86_64-linux"; };
        };
        modules = [ ./home/machines/work-laptop.nix ];
      };
    };
}
