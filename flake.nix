{
  description = "LCM - Lightweight Communications and Marshalling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          lcmgen = pkgs.stdenv.mkDerivation {
            pname = "lcm-gen";
            version = "1.5.2";
            src = ./.;

            nativeBuildInputs = with pkgs; [ cmake pkg-config ];
            buildInputs = with pkgs; [ glib ];

            cmakeFlags = [
              "-DLCM_ENABLE_PYTHON=OFF"
              "-DLCM_ENABLE_JAVA=OFF"
              "-DLCM_ENABLE_LUA=OFF"
              "-DLCM_ENABLE_TESTS=OFF"
            ];

            buildPhase = ''
              make -j$NIX_BUILD_CORES lcm-gen
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp lcmgen/lcm-gen $out/bin/
            '';
          };

          default = self.packages.${system}.lcmgen;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cmake
            glib
            pkg-config
          ];
        };
      });
}
