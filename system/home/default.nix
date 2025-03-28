{
  pkgs,
  user,
  ...
}:
let
  utils = import ../utils { inherit pkgs; };
in
{
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.hjackson =
      { ... }:
      {
        home.stateVersion = "24.11"; # Please read the comment before changing.

        home.file = { 
            "./.vimrc".source = ./.vimrc;
            "./.inputrc".source = ./.inputrc;
            "./.bash_aliases".source = ./.bash_aliases;
        };

        home.sessionVariables = {
          EDITOR = "nvim";
        };

        home.packages =
          utils.makeScriptsFromDir ./bin
          ++ import ./packages-home.nix { inherit pkgs; };

        programs = {
          home-manager.enable = true;

          bash = {
            enable = true;
            profileExtra =
              # bash
              ''
                export BASH_SILENCE_DEPRECATION_WARNING=1
                if [ -d "$HOME/.local/bin" ]; then
                    PATH="$HOME/.local/bin:$PATH"
                fi
              '';
            bashrcExtra =
              builtins.readFile ./.bashrc
              +
                # bash
                ''
                  #annoying windows bell sound disable
                  bind 'set bell-style none'
                  # gui
                  if command -v ip &> /dev/null; then
                      export DISPLAY=$(ip route | awk '{print $3; exit}'):0
                  fi
                '';
          };

          neovim = {
            enable = true;
            viAlias = true;
            vimAlias = true;
            vimdiffAlias = true;
            withNodeJs = true;
          } // import ./packages-nvim.nix { inherit pkgs; };

          tmux = {
            enable = true;
            plugins = with pkgs; [
              tmuxPlugins.sensible
            ];
            extraConfig =
              ''
                set -g default-terminal "xterm-256color"
                set-option -ga terminal-overrides ",xterm-256color:Tc"
              ''
              + builtins.readFile ./.tmux.conf;
          };
        };

        xdg.configFile."nvim" = {
          recursive = true;
          source = ./nvim;
        };

        xdg.configFile."nvim/parser".source =
          let
            parsers = pkgs.symlinkJoin {
              name = "treesitter-parsers";
              paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
            };
          in
          "${parsers}/parser";
      };
  };
}
