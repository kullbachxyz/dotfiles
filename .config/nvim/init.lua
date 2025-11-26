-- ~/.config/nvim/init.lua

-- vim-plug block (still using it from Lua)
vim.cmd [[
  call plug#begin('~/.local/share/nvim/plugged')
  Plug 'norcalli/nvim-colorizer.lua'
  call plug#end()
]]

-- Truecolor for nice colors & plugins
vim.opt.termguicolors = true

-- ===== Sensible defaults =====
local o = vim.opt

-- Line numbers
o.number = true            -- absolute line number on the current line
o.relativenumber = true    -- relative numbers on the other lines

-- Indentation
o.expandtab = true         -- tabs -> spaces
o.shiftwidth = 2           -- indentation size
o.tabstop = 2              -- how many spaces a <Tab> shows as
o.smartindent = true

-- UI tweaks
o.cursorline = true        -- highlight current line
o.wrap = false             -- no soft wrapping
o.scrolloff = 4            -- keep some context lines above/below cursor
o.signcolumn = "yes"       -- always show sign column

-- Search
o.ignorecase = true
o.smartcase = true
o.hlsearch = false

-- Misc
o.mouse = "a"              -- enable mouse
o.clipboard = "unnamedplus" -- use system clipboard

-- ===== Transparency =====
-- This assumes your terminal emulator itself is set to be transparent
vim.cmd [[
  augroup TransparentBackground
    autocmd!
    " main window
    autocmd ColorScheme * highlight Normal       ctermbg=none guibg=none
    " floating windows
    autocmd ColorScheme * highlight NormalFloat  ctermbg=none guibg=none
    " sign column (git signs, diagnostics, etc.)
    autocmd ColorScheme * highlight SignColumn   ctermbg=none guibg=none
  augroup END
]]

-- apply once on startup too (in case no :colorscheme is run)
vim.cmd [[
  highlight Normal       ctermbg=none guibg=none
  highlight NormalFloat  ctermbg=none guibg=none
  highlight SignColumn   ctermbg=none guibg=none
]]

-- ===== Colorizer =====
require("colorizer").setup()

