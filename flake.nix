{
  description = "libgit2 - Git linkable library with full HTTPS and SSH support";

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
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "libgit2";
          version = "1.9.0";

          src = ./.;

          nativeBuildInputs = with pkgs; [ cmake pkg-config ];
          buildInputs = with pkgs; [ openssl libssh2 zlib pcre2 ];

          cmakeFlags = [
            "-DBUILD_SHARED_LIBS=OFF"
            "-DBUILD_TESTS=OFF"
            "-DBUILD_CLI=OFF"
            "-DUSE_HTTPS=OpenSSL"
            "-DUSE_SSH=ON"
            "-DUSE_SHA1=CollisionDetection"
            "-DUSE_SHA256=OpenSSL"
          ];

          installPhase = ''
            mkdir -p $out/lib
            mkdir -p $out/include
            cp libgit2.a $out/lib/
            cp -r include/git2 $out/include/
            cp include/git2.h $out/include/
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cmake
            pkg-config
            gcc
            openssl
            libssh2
            zlib
            pcre2
          ];

          shellHook = ''
            echo "=== libgit2 build environment ==="
            echo "Run: mkdir build && cd build && cmake .. && cmake --build ."
          '';
        };
      });
}