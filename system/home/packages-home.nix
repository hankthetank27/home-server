{ pkgs }:

with pkgs;
[
  tree-sitter

  #lsp
  nil
  lua-language-server
  bash-language-server

  #fmt
  stylua
  nixfmt-rfc-style
]
