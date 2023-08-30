{
  description = "My personal flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      user = "welly";
      host = "nixos";
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        ${host} = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs host user; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs user pkgs; };
              home-manager.users.${user} = import ./home.nix;
            }
          ];
        };
      };
    };
}
