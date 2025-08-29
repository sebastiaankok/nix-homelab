{
  programs.nixvim = {
    plugins = {
      avante = {
        enable = true;
        settings = {
          provider = "openai"; # Use OpenAI-compatible provider for LM Studio
          openai = {
            endpoint = "https://lmstudio.${config.hostConfig.domainName}/v1"; # LM Studio's default endpoint with domain name from host config
            model = "qwen3-coder-30b-a3b-instruct";
            api_key_name = ""; # No API key needed for local LM Studio
            extra_request_body = {
              frequency_penalty = 0;
              presence_penalty = 0;
              temperature = 0.7;
              top_p = 1;
            };
          };
          mappings = {
            ask = "<leader>aa"; # Ask AI about code
            edit = "<leader>ae"; # Edit with AI
            refresh = "<leader>ar"; # Refresh AI response
            diff = {
              ours = "co";
              theirs = "ct";
              none = "c0";
              both = "cb";
              next = "]x";
              prev = "[x";
            };
          };
          behaviour = {
            auto_suggestions = false; # Enable auto-suggestions if preferred
            auto_apply = false; # Disable auto-applying changes
          };
          windows = {
            width = 30; # Sidebar width
            wrap = true; # Enable text wrapping
            sidebar_header = {
              align = "center";
              rounded = true;
            };
          };
          highlights = {
            diff = {
              current = "DiffText";
              incoming = "DiffAdd";
            };
          };
          diff = {
            autojump = true;
            debug = false;
            list_opener = "copen";
          };
          hints = {
            enabled = true;
          };
        };
      };
    };
  };
}
