-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.o.termguicolors = true

-- vim.opt.mouse = ""

vim.opt.wrap = true
vim.opt.scrollback = 10000 -- Set scrollback buffer

-- Set terminal cursor color to match your theme
vim.cmd([[
  autocmd TermOpen * highlight TermCursor guifg=#c4a7e7 guibg=#c4a7e7
]])
