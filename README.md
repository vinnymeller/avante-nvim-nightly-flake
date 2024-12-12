# Usage

[avante.nvim](https://github.com/yetone/avante.nvim) hasn't been getting updated frequently enough for my taste in nixpkgs so this checks a few times a day to update it as needed

Ex:

```nix
  programs.neovim = {
    plugins = [
      inputs.avante-nvim-nightly-flake.packages.${pkgs.system}.default
    ];
  }
```

You probably want to update this flake's `nixpkgs` and `flake-utils` inputs to follow your main flake's:

```nix
  avante-nvim = {
    url = "github:vinnymeller/avante-nvim-nightly-flake";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };
  };
```
