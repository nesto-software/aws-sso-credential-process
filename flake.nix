{
  description = "The aws-sso-credential-process tool";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  # TODO: remove the workaround for https://github.com/nix-community/poetry2nix/pull/1329
  # we also use a fork for aws-sso-credential-process to adapt to pyproject.toml syntax changes
  # we also pin the python version to 3.9 for aws-sso-credential-process
  # we further forked the poetry2nix fork to add pack the legacyPackages flake output
  inputs.poetry2nix = {
    url = "github:nesto-software/poetry2nix?ref=new-bootstrap-fixes";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, poetry2nix }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          aws-sso-credential-process = pkgs.callPackage ./pkgs { poetry2nix = poetry2nix.legacyPackages.${system}; };
        });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      nixosModules = import ./modules;
    };
}
