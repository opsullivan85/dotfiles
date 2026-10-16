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
  };

  outputs = inputs@{ self, nixpkgs, home-manager, noctalia, ... }: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/laptop/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.owen = import ./home/home.nix;
        }
      ];
    };
  };
}
