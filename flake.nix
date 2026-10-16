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

  outputs = inputs@{ self, nixpkgs, home-manager, noctalia, stylix, ... }: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/laptop/configuration.nix
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        ({ pkgs, ... }:
          let
            theme = import ./theme.nix { inherit pkgs; };
          in
          {
            # Computed once here, handed to both the NixOS modules (as a
            # plain module arg) and home-manager modules (as a specialArg)
            # so hosts/laptop/configuration.nix and home/noctalia.nix read
            # the exact same values instead of each defining "gruvbox"
            # themselves.
            _module.args.theme = theme;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs theme; };
            home-manager.users.owen = import ./home/home.nix;
          })
      ];
    };
  };
}
