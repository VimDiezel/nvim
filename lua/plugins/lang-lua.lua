return {
  -- Stop Mason from managing lua_ls and stylua
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.lua_ls = {
        mason = false,
        cmd = { "lua-language-server" },
      }
      return opts
    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_installation = false,
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        stylua = {
          command = "stylua",
        },
      },
    },
  },
}
