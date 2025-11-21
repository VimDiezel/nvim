-- if true then
--   return {}
-- end

return {
  "folke/noice.nvim",
  opts = {
    views = {
      cmdline_popup = {
        position = {
          row = "50%", -- Center vertically
          col = "50%", -- Center horizontally
        },
      },
    },
  },
}
