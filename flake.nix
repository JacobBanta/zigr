{
  description = "Zig bindings for TIGR";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay.url = "github:mitchellh/zig-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
	  zig-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        linuxDeps = with pkgs; [
          libX11
          libGL
          libGLU
        ];

        darwinDeps = with pkgs; [
          apple-sdk_15
          libiconv
        ];
      in
      {
        devShells.default = pkgs.mkShell.override { stdenv = pkgs.stdenvNoCC; } {
          packages =
            [
              zig-overlay.packages.${system}.default
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux ([ pkgs.pkg-config ] ++ linuxDeps)
            ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin darwinDeps;

          env = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
            SDKROOT = "${pkgs.apple-sdk_15.sdkroot}";
          };

          shellHook = ''
            echo "ZIGR development shell"
            echo "Zig version: $(zig version)"
          '';
        };
      }
    );
}
