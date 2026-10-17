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

    nix4nvchad.url = "github:nix-community/nix4nvchad";
    nix4nvchad.inputs.nixpkgs.follows = "nixpkgs";

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

      # One NixOS host per hosts/<name>/ (system config) paired with
      # home/machines/<name>.nix (home-manager config for `user`).
      mkHost =
        {
          name,
          user ? "owen",
          system ? "x86_64-linux",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/${name}/configuration.nix
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
                # so hosts/<name>/configuration.nix and home/os/nixos/noctalia.nix read
                # the exact same values instead of each defining "gruvbox"
                # themselves.
                _module.args.theme = theme;

                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs theme; };
                home-manager.users.${user} = import ./home/machines/${name}.nix;
              }
            )
          ];
        };
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

      nixosConfigurations.laptop = mkHost { name = "laptop"; };

      # Reusable pieces for other flakes (e.g. the private work repo, see
      # docs/private-work.md). Machine files live in home/machines.
      # Every modules/<category>/<name>.nix is exported as <category>-<name>
      # (e.g. dev-rust), so a new module needs no edit here.
      homeModules =
        let
          inherit (nixpkgs) lib;
          categories = lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir ./modules));
          unitsIn =
            category:
            map (file: {
              name = "${category}-${lib.removeSuffix ".nix" file}";
              value = ./modules/${category}/${file};
            }) (lib.filter (lib.hasSuffix ".nix") (lib.attrNames (builtins.readDir ./modules/${category})));
        in
        {
          os-nixos = ./home/os/nixos;
          os-ubuntu = ./home/os/ubuntu;
        }
        // lib.listToAttrs (lib.concatMap unitsIn categories);

      # Standalone home-manager config with the args our modules expect
      # (`inputs`, `theme`) already wired up. Downstream flakes call this
      # instead of home-manager.lib.homeManagerConfiguration.
      lib.mkHome =
        {
          modules,
          system ? "x86_64-linux",
          extraSpecialArgs ? { },
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = {
            inherit inputs;
            theme = import ./theme.nix { pkgs = pkgsFor system; };
          }
          // extraSpecialArgs;
          inherit modules;
        };
    };
}
