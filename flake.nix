{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  outputs =
    { nixpkgs, ... }:
    {
      packages.x86_64-linux.default =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          inherit (pkgs) lib;
          # Emscripten 3.1.64 requires Binaryen 119's --no-stack-ir option.
          emscripten = pkgs.emscripten.override {
            binaryen = pkgs.binaryen.overrideAttrs {
              version = "119";
              src = pkgs.fetchFromGitHub {
                owner = "WebAssembly";
                repo = "binaryen";
                rev = "version_119";
                sha256 = "1q2c2f31rsh2c56pph5xsg3k850vyzxldikqkszskqlnf0vyv195";
              };
              doCheck = false;
            };
          };
          sources = lib.mapAttrs (_: spec: pkgs.fetchFromGitHub spec) {
            ogg = {
              owner = "xiph";
              repo = "ogg";
              rev = "v1.3.5";
              sha256 = "1jxnh8skfw7xqq7qsrwbxivja6ryw59daf7q8yskfdiskyg3cxya";
            };
            vorbis = {
              owner = "xiph";
              repo = "vorbis";
              rev = "v1.3.7";
              sha256 = "0ml91vxfjhad7di457jqvfyjssjfhggmaisyw2xxwr0v341xnaf8";
            };
            openssl = {
              owner = "openssl";
              repo = "openssl";
              rev = "openssl-3.3.0";
              sha256 = "1lzjc0cjylg4qix42lqjzs4jydn20y9nzgmf3gliv2ya50qgl7wa";
            };
            zlib = {
              owner = "madler";
              repo = "zlib";
              rev = "v1.3.1";
              sha256 = "12r98gay98w6vd1m6v1xw6k3yzc4yb7r3x6h5zjw6hbr4dcwnhsf";
            };
            curl = {
              owner = "curl";
              repo = "curl";
              rev = "curl-8_8_0";
              sha256 = "064wdipyz24qzgq6h8nzy3pk4qybf5l3g08yp9r2l9w3r69plc1j";
            };
            jpeg = {
              owner = "libjpeg-turbo";
              repo = "libjpeg-turbo";
              rev = "3.0.3";
              sha256 = "0whin01ab2wj4fgsylvli7lr0kjcg3a77spkliyk5cpqaxlhjv63";
            };
            png = {
              owner = "pnggroup";
              repo = "libpng";
              rev = "v1.6.43";
              sha256 = "0fv97xl79yhk35k076i9m067adl2ngpdmwmidy488slm7gqlr39j";
            };
            freetype = {
              owner = "freetype";
              repo = "freetype";
              rev = "VER-2-13-2";
              sha256 = "06amlgpjhzzdmqfnz9017vqzligb2ksxr8k4w0zbjalf37rn93r2";
            };
            harfbuzz = {
              owner = "harfbuzz";
              repo = "harfbuzz";
              rev = "8.5.0";
              sha256 = "1vddy52xkb1ba2rwfwz2v8aa1ry21ysfylaib84i79sfc7f1yyp2";
            };
          };
          ports = {
            sdl2 = {
              url = "https://github.com/libsdl-org/SDL/archive/release-2.28.4.zip";
              sha512 = "8dd593fd7d8660efdeb53b7d1706f5743eb68491a29eb0cf0c028d8f8b8a7945c0dc5bf1117b5e4e871d7622be277c0838d08cc6eabdecb563000dfcc0c94639";
            };
            sdl2_mixer = {
              url = "https://github.com/libsdl-org/SDL_mixer/archive/release-2.8.0.zip";
              sha512 = "494ccd74540f74e717f7e4f1dc7f96398c0f4b1883ab00c4a76b0c7239bd2c185cb4358a35ef47819c49e7c14dac7c37b98a29c7b5237478121571f5e7ac4dfc";
            };
            ogg = {
              url = "https://github.com/emscripten-ports/ogg/archive/version_1.zip";
              sha512 = "929e8d6003c06ae09593021b83323c8f1f54532b67b8ba189f4aedce52c25dc182bac474de5392c46ad5b0dea5a24928e4ede1492d52f4dd5cd58eea9be4dba7";
            };
            vorbis = {
              url = "https://github.com/emscripten-ports/vorbis/archive/version_1.zip";
              sha512 = "99bee75beb662f8520bbb18ad6dbf8590d30eb3a7360899f0ac4764ca72fe8013da37c9df21e525f9d2dc5632827d4b4cea558cbc938e7fbed0c41a29a7a2dc5";
            };
          };
          tools = with pkgs; [
            emscripten
            cmake
            pkg-config-unwrapped
            autoconf
            automake
            libtool
            gnumake
            python3
            perl
            git
            ninja
            which
          ];
          libraries = pkgs.stdenv.mkDerivation {
            name = "supertuxkart-wasm-libraries";
            src = ./wasm/build_deps.sh;
            dontUnpack = true;
            dontConfigure = true;
            nativeBuildInputs = tools;
            buildPhase = ''
              export HOME=$TMPDIR
              export EM_CACHE=$TMPDIR/em-cache
              export EMCC_CORES=$NIX_BUILD_CORES
              mkdir -p wasm/build wasm/prefix/include wasm/prefix/lib
              cp $src wasm/build_deps.sh
              ${lib.concatStringsSep "\n" (
                lib.mapAttrsToList (name: src: ''
                  cp -r ${src} wasm/build/${name}
                '') sources
              )}
              chmod -R u+w wasm
              patchShebangs wasm
              bash wasm/build_deps.sh
            '';
            installPhase = ''
              cp -r wasm/prefix $out
              substituteInPlace $out/lib/pkgconfig/*.pc $out/lib/*.la \
                --replace-quiet /build/wasm/prefix "$out"
            '';
            dontStrip = true;
          };
          assets = pkgs.fetchsvn {
            url = "https://svn.code.sf.net/p/supertuxkart/code/stk-assets";
            rev = "18621";
            sha256 = "sha256-iqQSezGu0tecA53qhrtYA77SLj28WUUCcL4ZCJbK5C8=";
          };
          assetBundle = pkgs.stdenv.mkDerivation {
            name = "supertuxkart-high-textures";
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./data
                ./android/generate_assets.sh
                ./wasm/pack_assets.sh
              ];
            };
            nativeBuildInputs = with pkgs; [
              imagemagick
              vorbis-tools
              pngquant
              unzip
              util-linux
            ];
            dontConfigure = true;
            buildPhase = ''
              export OMP_NUM_THREADS=$NIX_BUILD_CORES
              patchShebangs android wasm
              bash wasm/pack_assets.sh ${assets}
            '';
            installPhase = ''
              mkdir -p $out
              cp wasm/web/game/data_high.tar.gz.* $out/
            '';
          };
        in
        pkgs.stdenv.mkDerivation {
          pname = "supertuxkart-web";
          version = "1.5";
          src = ./.;
          nativeBuildInputs = tools ++ [ pkgs.unzip ];
          dontConfigure = true;
          buildPhase = ''
            export HOME=$TMPDIR
            export EM_CACHE=$TMPDIR/em-cache
            export EM_PORTS=$TMPDIR/em-ports
            export EMCC_CORES=$NIX_BUILD_CORES
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: spec: ''
                mkdir -p "$EM_PORTS/${name}"
                unzip -q ${pkgs.fetchurl spec} -d "$EM_PORTS/${name}"
                echo '${spec.url}' > "$EM_PORTS/${name}/.emscripten_url"
              '') ports
            )}
            cp -r ${libraries} wasm/prefix
            chmod -R u+w wasm/prefix
            export PKG_CONFIG_PATH="$PWD/wasm/prefix/lib/pkgconfig"
            patchShebangs wasm android data
            embuilder.py build sdl2
            bash wasm/build.sh Release
            cp ${assetBundle}/* wasm/web/game/
          '';
          installPhase = ''
            mkdir -p $out
            cp -r wasm/web/. $out/
            if find "$out" -type f -size +25M | grep .; then
              echo "Static asset exceeds Cloudflare's 25 MiB limit" >&2
              exit 1
            fi
            test "$(find "$out" -type f | wc -l)" -le 20000
          '';
          dontStrip = true;
        };
    };
}
