{ pkgs, ... }:

let
  marketplace = pkgs.vscode-utils.extensionFromVscodeMarketplace;
in

{
  # lua-language-server only understands Lua, so Luau (.luau, filetype already
  # detected by nvim) gets its own server, luau-lsp. stylua formats both.
  imports = [ ../tui/nvim/options.nix ];

  home.packages = with pkgs; [
    lua-language-server
    luau-lsp
    stylua
    luau # the standalone runner/REPL, for trying snippets
  ];

  dev.nvim = {
    lspServers = [
      "lua_ls"
      "luau_lsp"
    ];
    formatters = {
      lua = [ "stylua" ];
      luau = [ "stylua" ];
    };
    treesitter = [
      "luau"
    ];
    luaConfig = [
      ''
        -- luau-lsp takes type definitions as command-line flags, not settings. They are read from the
        -- project's .vscode/settings.json (the file VS Code reads), so one file configures both editors.
        local function luau_definitions(root)
          local ok, lines = pcall(vim.fn.readfile, root .. "/.vscode/settings.json")
          if not ok then return {} end
          local decoded, json = pcall(vim.json.decode, table.concat(lines, "\n"))
          if not decoded or type(json) ~= "table" then return {} end
          local flags = {}
          for name, path in pairs(json["luau-lsp.types.definitionFiles"] or {}) do
            if not vim.startswith(path, "/") then path = root .. "/" .. path end
            if vim.uv.fs_stat(path) then
              table.insert(flags, "--definitions:" .. name .. "=" .. path)
            end
          end
          return flags
        end

        vim.lsp.config("luau_lsp", {
          cmd = function(dispatchers, config)
            local root = config.root_dir or vim.fn.getcwd()
            local cmd = { "luau-lsp", "lsp" }
            vim.list_extend(cmd, luau_definitions(root))
            return vim.lsp.rpc.start(cmd, dispatchers, { cwd = root })
          end,
          -- Same as luau-lsp.platform.type in VS Code below: the server defaults to Roblox.
          settings = { ["luau-lsp"] = { platform = { type = "standard" } } },
        })
      ''
    ];
  };

  # No-op on machines without modules/gui/vscode.nix.
  programs.vscode.profiles.default = {
    extensions = [
      pkgs.vscode-extensions.sumneko.lua
      # Pinned to 1.69.0 to match the luau-lsp binary from nixpkgs.
      (marketplace {
        publisher = "JohnnyMorganz";
        name = "luau-lsp";
        version = "1.69.0";
        sha256 = "sha256-GOU4A2O+2pHRMIRVMKaV7Xi21Wrpk7AcNqxxQ3xUd7k=";
      })
      (marketplace {
        publisher = "JohnnyMorganz";
        name = "stylua";
        version = "1.7.2";
        sha256 = "sha256-l/znKp+myNqS8RYVAyBGn5Up9LfXs0HPUr1ZrV4CrKE=";
      })
    ];
    userSettings = {
      # Use the same server binaries as nvim instead of each extension's own download.
      "Lua.misc.executablePath" = "${pkgs.lua-language-server}/bin/lua-language-server";
      "luau-lsp.server.path" = "${pkgs.luau-lsp}/bin/luau-lsp";
      # The extension defaults to Roblox's globals and sourcemap; this is plain Luau.
      "luau-lsp.platform.type" = "standard";
      "stylua.searchBinaryInPATH" = true;
      # The Luau extension also claims *.lua, so pin it to sumneko's language.
      "files.associations"."*.lua" = "lua";
      "[lua]"."editor.defaultFormatter" = "JohnnyMorganz.stylua";
      "[luau]"."editor.defaultFormatter" = "JohnnyMorganz.stylua";
    };
  };
}
