{ pkgs, ... }:
with pkgs;

{
  plugins = with pkgs.vimPlugins; [
    lazy-nvim
  ];

  extraLuaConfig =
    let
      plugins = with pkgs.vimPlugins; [
        # autocomplete
        nvim-cmp
        cmp-buffer
        cmp-path
        cmp-cmdline

        #lsp
        nvim-lspconfig
        cmp-nvim-lsp

        # conform formatting
        conform-nvim

        # oil FS
        oil-nvim
        nvim-web-devicons

        # treesitter
        # grammar config is in  host/*/config/home.nix @ xdg.configFile."nvim/parser"
        nvim-treesitter

        # telescope-nvim
        telescope-fzf-native-nvim
        telescope-nvim
        plenary-nvim

        nvim-autopairs # not in use

        lualine-nvim

        vim-fugitive

        vim-surround

        vim-repeat

        vim-commentary

        undotree

        # color
        melange-nvim

        vim-tmux-navigator
      ];

      mkEntryFromDrv =
        drv:
        if pkgs.lib.isDerivation drv then
          {
            name = "${pkgs.lib.getName drv}";
            path = drv;
          }
        else
          drv;
      lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
    in
    # lua
    ''
      require("config");
      require("lazy").setup({
        defaults = {
          lazy = false,
        },
        dev = {
          path = "${lazyPath}",
          patterns = { "" },
          fallback = true,
        },
        spec = {
          { import = "plugins" },
        },
        install = {
          -- Safeguard in case we forget to install a plugin with Nix
          missing = false,
        },
      });
    '';
}
