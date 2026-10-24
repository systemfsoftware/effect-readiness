{
  description = "effect-readiness toolchain — the formatter, runtimes and agent hooks the check chain shells out to";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # The release manifest (`nix/release-hashes.json`) rides this input, and the
 # default branch carries no such file: it lives on the release-hashes ref, so
 # the URL pins the rev core's own flake.lock proved (3bfedd853). Moving the
 # input means moving to another rev that carries `nix/release-hashes.json`;
 # the version and every per-target digest move with it in one step.
    comment-checker = {
      url = "github:systemfsoftware/comment-checker/3bfedd853c1d6dca666e65e71e9f8a31d47db336";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, comment-checker }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});
    in
    {
      packages = forEachSystem (pkgs:
        let
          dprint = pkgs.callPackage ./nix/dprint.nix { dprintConfig = ./dprint.json; };
          unwrapped = pkgs.callPackage ./nix/comment-checker.nix {
            hashes = "${comment-checker}/nix/release-hashes.json";
          };
          sandboxed = pkgs.callPackage ./nix/comment-checker-sandbox.nix {
            comment-checker = unwrapped;
          };
        in
        {
          inherit dprint;
          comment-checker = sandboxed;
          comment-checker-unwrapped = unwrapped;
          default = dprint;
        });

      devShells = forEachSystem (pkgs:
        let
          own = self.packages.${pkgs.stdenv.hostPlatform.system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              own.dprint
              own.comment-checker
              pkgs.codegraph
              pkgs.nodejs_24
              pkgs.pnpm_12
              pkgs.bun
            ];
          };
        });
    };
}
