{
  description = "avante.nvim nightly flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    avante = {
      url = "github:yetone/avante.nvim";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      avante,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        version = "nightly";
        src = avante;
        avante-nvim-lib = pkgs.rustPlatform.buildRustPackage {
          pname = "avante-nvim-lib";
          inherit version src;

          cargoHash = "sha256-p4AQu0pOT7PCPkrPy/Ot5yns+esw013PKeZKr8iJA8c=";

          nativeBuildInputs = [
            pkgs.pkg-config
          ];

          buildInputs = [
            pkgs.openssl
          ];

          buildFeatures = [ "luajit" ];

          checkFlags = [
            # Disabled because they access the network.
            "--skip=test_hf"
            "--skip=test_public_url"
            "--skip=test_roundtrip"
          ];
        };
      in
      {
        packages.default = pkgs.vimUtils.buildVimPlugin {
          pname = "avante-nvim";
          inherit version src;

          dependencies = with pkgs.vimPlugins; [
            dressing-nvim
            nui-nvim
            nvim-treesitter
            plenary-nvim
          ];

          postInstall =
            let
              ext = pkgs.stdenv.hostPlatform.extensions.sharedLibrary;
            in
            ''
              mkdir -p $out/build
              ln -s ${avante-nvim-lib}/lib/libavante_repo_map${ext} $out/build/avante_repo_map${ext}
              ln -s ${avante-nvim-lib}/lib/libavante_templates${ext} $out/build/avante_templates${ext}
              ln -s ${avante-nvim-lib}/lib/libavante_tokenizers${ext} $out/build/avante_tokenizers${ext}
            '';

          doInstallCheck = true;
          nvimRequireCheck = "avante";

          meta = {
            description = "Neovim plugin designed to emulate the behaviour of the Cursor AI IDE";
            homepage = "https://github.com/yetone/avante.nvim";
            license = pkgs.lib.licenses.asl20;
          };
        };

        overlay = final: prev: {
          vimPlugins.avante-nvim = self.packages.default;
        };
      }
    );
}
