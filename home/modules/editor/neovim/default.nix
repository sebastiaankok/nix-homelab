{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>w";
        action = ":%s/\\s\\+$//e<CR>";
        options.silent = false;
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = ":lua vim.lsp.buf.code_action()<CR>";
        options.silent = false;
      }
      {
        mode = "v"; # Visual mode
        key = "<Tab>";
        action = ">gv";
        options.silent = true;
      }
      # Indent selection to the left with Shift+Tab
      {
        mode = "v"; # Visual mode
        key = "<S-Tab>";
        action = "<gv";
        options.silent = true;
      }
      # Copy to clipboard with visual + a
      {
        mode = "v";
        key = "a";
        action = ":w !pbcopy<CR>";
        options.silent = true;
      }
      # Switch window with TAB instead of ctrl+w
      {
        mode = "n";
        key = "<Tab>";
        action = "<C-w>w";
        options.silent = true;
      }
      # Switch window with shift + TAB instead of shift+ctrl+w
      {
        mode = "n";
        key = "<S-Tab>";
        action = "<C-w>W";
        options.silent = true;
      }
    ];
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    colorschemes.catppuccin.enable = true;
    # colorschemes.gruvbox.enable = true;
    # colorschemes.gruvbox.settings.italics = false;
    # colorschemes.gruvbox.settings = {
    #   italic = {
    #     strings = false;
    #     operators = false;
    #     comments = false;
    #   };
    # };

    luaLoader.enable = true;

    opts = {
      splitbelow = true;
      splitright = true;

      number = true; # Show line numbers
      updatetime = 100; # Faster completion
      tabstop =
        2; # Number of spaces a <Tab> in the text stands for (local to buffer)
      shiftwidth =
        2; # Number of spaces used for each step of (auto)indent (local to buffer)
      softtabstop =
        0; # If non-zero, number of spaces to insert for a <Tab> (local to buffer)
      expandtab =
        true; # Expand <Tab> to spaces in Insert mode (local to buffer)
      autoindent = true; # Do clever autoindenting

      # disable mouse
      mouse = "";

      # Folding
      foldlevel =
        99; # Folds with a level higher than this number will be closed
    };

    highlight.ExtraWhitespace.bg = "#FF5C57";
    match.ExtraWhitespace = "\\s\\+$";

    # Example on how to change settings for certain files.
    autoCmd = [
      {
        event = "FileType";
        pattern = "nix";
        command = "setlocal tabstop=2 shiftwidth=2";
      }
      {
        event = "FileType";
        pattern = "helm";
        command = "LspRestart";
      }
    ];
  };
  imports = [
    ./completion.nix
    ./plugins/lsp.nix
    ./plugins/gitsigns.nix
    ./plugins/autopairs.nix
    ./plugins/colorizer.nix
    ./plugins/treesitter.nix
    ./plugins/which-key.nix
    ./plugins/neo-tree.nix
    ./plugins/telescope.nix
    ./plugins/efm.nix
    ./plugins/gitblame.nix
    ./plugins/lualine.nix
    ./plugins/conform.nix
    ./plugins/trouble.nix
    ./plugins/markview.nix
    ./plugins/avante.nix
  ];

}
