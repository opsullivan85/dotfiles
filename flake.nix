{
  description = "Owen's machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Not following nixpkgs here on purpose: it keeps us eligible for
    # noctalia's own Cachix binary cache (see nix.settings below) instead of
    # compiling its Qt/C++ core from source.
    noctalia.url = "github:noctalia-dev/noctalia";
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
