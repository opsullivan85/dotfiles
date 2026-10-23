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

    jn.url = "github:joereynolds/jn";
    jn.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      stylix,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Standalone home-manager hosts (non-NixOS) need their own pkgs, and the
      # per-system outputs below use it too. NixOS hosts ignore this: with
      # useGlobalPkgs they share the system's pkgs, whose allowUnfree is set
      # in hosts/<name>/configuration.nix.
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
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
                theme = import ./lib/theme.nix { inherit pkgs; };
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
      formatter = forAllSystems (system: (pkgsFor system).nixfmt);

      # Everything the pre-commit hooks need (see .pre-commit-config.yaml and
      # scripts/in-devshell). Enter with `nix develop`; hooks also re-enter
      # it on their own, so you never have to.
      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          packages = with pkgsFor system; [
            pre-commit
            nixfmt
            statix
            deadnix
            ruff
            stylua
            shellcheck
          ];
        };
      });

      # Custom CLI tools: one directory per tool in tools/<name>/, whose
      # default.nix is a callPackage function using whatever builder suits the
      # language (writeShellApplication, writers.writePython3Bin,
      # rustPlatform.buildRustPackage, ...). Discovered automatically; run one
      # with `nix run .#<name>`, install it via a modules/ wrapper.
      packages = forAllSystems (
        system:
        nixpkgs.lib.mapAttrs (name: _: (pkgsFor system).callPackage ./tools/${name} { }) (
          nixpkgs.lib.filterAttrs (_: t: t == "directory") (builtins.readDir ./tools)
        )
      );

      # `nix flake check` builds these (and pre-push runs it), so a config or
      # tool that evaluates but doesn't build is caught before pushing.
      checks.x86_64-linux = inputs.self.packages.x86_64-linux // {
        laptop = inputs.self.nixosConfigurations.laptop.config.system.build.toplevel;
      };

      nixosConfigurations.laptop = mkHost { name = "laptop"; };

      # Reusable pieces for other flakes (e.g. the private work repo, see
      # docs/private-work.md). Machine files live in home/machines.
      # Every modules/<category>/<name>.nix, and every modules/<category>/<name>/
      # holding a default.nix, is exported as <category>-<name> (e.g. dev-rust,
      # tui-nvim), so a new module needs no edit here.
      homeModules =
        let
          inherit (nixpkgs) lib;
          categories = lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir ./modules));
          unitsIn =
            category:
            lib.concatLists (
              lib.mapAttrsToList (
                entry: type:
                if type == "directory" && builtins.pathExists ./modules/${category}/${entry}/default.nix then
                  [
                    {
                      name = "${category}-${entry}";
                      value = ./modules/${category}/${entry};
                    }
                  ]
                else if type == "regular" && lib.hasSuffix ".nix" entry then
                  [
                    {
                      name = "${category}-${lib.removeSuffix ".nix" entry}";
                      value = ./modules/${category}/${entry};
                    }
                  ]
                else
                  [ ]
              ) (builtins.readDir ./modules/${category})
            );
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
            theme = import ./lib/theme.nix { pkgs = pkgsFor system; };
          }
          // extraSpecialArgs;
          inherit modules;
        };
    };
}
