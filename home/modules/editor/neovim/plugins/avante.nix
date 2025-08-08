{
  programs.nixvim = {
    plugins = {
      avante = {
        enable = false;
        settings = {
          provider = "openai"; # Use OpenAI-compatible provider for LM Studio
          openai = {
            endpoint = "http://:1234/v1"; # LM Studio's default endpoint
            # model = "qwen3-coder-30b"; # Replace with your model name from LM Studio
            model = "openai/gpt-oss-20b";
            api_key_name = ""; # No API key needed for local LM Studio
            extra_request_body = {
              max_tokens = 4096; # Adjust based on model capabilities
              temperature = 0.7; # Adjust for desired randomness
            };
          };
          mappings = {
            ask = "<leader>aa"; # Ask AI about code
            edit = "<leader>ae"; # Edit with AI
            refresh = "<leader>ar"; # Refresh AI suggestions
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
            auto_suggestions = true; # Disable auto-suggestions if preferred
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
