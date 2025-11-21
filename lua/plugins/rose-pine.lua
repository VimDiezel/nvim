return {
  -- add rose-pine
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        variant = "main", -- Options: 'main', 'moon', 'dawn'
        dark_variant = "main",
        styles = {
          transparency = true, -- Enable transparency
        },
        -- Adding the missing required fields
        dim_inactive_windows = false,
        extend_background_behind_borders = true,
        enable = {
          terminal = false,
          legacy_highlights = true,
          migrations = true,
        },
        -- These can be empty but need to be present
        palette = {},
        groups = {},
        highlight_groups = {},
        before_highlight = function() end,
      })
    end,
  },

  -- configure lazyvim to load rose-pine
  {
    "LazyVim/LazyVim",
    priority = 1000,
    opts = {
      colorscheme = "rose-pine",
    },
  },
}
