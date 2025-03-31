{
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;

        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate in diagnostics
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            gD = "references";
            gt = "type_definition";
            gi = "implementation";
            K = "hover";
            "<F2>" = "rename";
          };
        };

        servers = {
          bashls.enable = true;
          cmake.enable = true;
          dockerls.enable = true;
          nixd.enable = true;
          # python
          ruff_lsp.enable = true;
          pylsp = {
            enable = true;
            settings = {
              plugins = {
                jedi_completion.fuzzy = true;
              };
            };
          };
          gopls.enable = true;
          terraformls.enable = true;
          yamlls = {
            enable = true;
            extraOptions = {
              settings = {
                yaml = {
                  schemas = {
                    kubernetes = "*.yaml";
                    "http://json.schemastore.org/github-workflow" = ".github/workflows/*";
                    "http://json.schemastore.org/chart" = "Chart.{yml,yaml}";

                  };
                  validate = {
                    enable = true;
                  };
                };
              };
            };
          };
          jsonls.enable = true;
          html.enable = true;
          cssls.enable = true;
        };
      };
    };
  };
}
