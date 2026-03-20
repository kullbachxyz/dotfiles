-- Leader key
vim.g.mapleader = " "
-- Enable truecolor BEFORE plugins
vim.opt.termguicolors = true
-- ===== lazy.nvim bootstrap =====
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- ===== Plugins =====
-- Suppress colorizer deprecation warning (suppress_deprecation flag is broken upstream)
local orig_notify = vim.notify
vim.notify = function(msg, ...)
  if type(msg) == "string" and msg:find("colorizer") and msg:find("deprecat") then
    return
  end
  orig_notify(msg, ...)
end

require("lazy").setup({
-- Completion + LSP (nvim 0.11 native vim.lsp.config, no lspconfig plugin needed)
{
  "hrsh7th/nvim-cmp",
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"]      = cmp.mapping.confirm({ select = true }),
        ["<C-e>"]     = cmp.mapping.abort(),
      }),
      sources = { { name = "nvim_lsp" } },
    })
    local caps = require("cmp_nvim_lsp").default_capabilities()
    vim.lsp.config("bashls", {
      cmd          = { "bash-language-server", "start" },
      filetypes    = { "sh", "bash" },
      capabilities = caps,
    })
    vim.lsp.enable("bashls")
  end,
},
-- Treesitter
{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  main = "nvim-treesitter",
  opts = {
    ensure_installed = { "bash", "c", "lua", "markdown", "html", "css", "yaml" },
    highlight = { enable = true },
    indent    = { enable = true },
  },
},
-- Statusline
{
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "auto",
      component_separators = "|",
      section_separators   = "",
    },
  },
},
-- Fuzzy finder
{
  "ibhagwan/fzf-lua",
  config = function()
    local fzf = require("fzf-lua")
    vim.keymap.set("n", "<leader>ff", fzf.files,  { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
  end,
},
{
  "catgoose/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup({
      filetypes = { "*" },
      user_default_options = {
        names = true,
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        AARRGGBB = true,
        css = true,
        css_fn = true,
      },
    })
  end,
}
})

vim.notify = orig_notify
-- ===== Sensible defaults =====
local o = vim.opt
-- Include Vim spell files (from vim-spell-de etc.)
o.rtp:append("/usr/share/vim/vimfiles")
-- Line numbers
o.number = true
o.relativenumber = true
-- Indentation
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
-- UI
o.cursorline = true
o.wrap = true
o.scrolloff = 4
o.signcolumn = "yes"
o.splitright = true
o.splitbelow = true
-- Search
o.ignorecase = true
o.smartcase = true
o.hlsearch = false
-- Misc
o.mouse = "a"
o.clipboard = "unnamedplus"
o.undofile = true
o.updatetime = 250
-- ===== Transparency =====
local function set_transparent_bg()
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
end
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_transparent_bg,
})
set_transparent_bg()
-- ===== Spellcheck =====
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit", "tex" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "de,en_us"
  end,
})
-- Custom spell dictionary
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/custom.utf-8.add"
-- ===== Keymaps =====
-- Toggle spellcheck
vim.keymap.set("n", "<leader>st", function()
  vim.opt_local.spell = not vim.opt_local.spell:get()
end, { desc = "Toggle spellcheck" })
-- Spell navigation
vim.keymap.set("n", "<leader>sn", "]s", { remap = true, desc = "Next misspelling" })
vim.keymap.set("n", "<leader>sp", "[s", { remap = true, desc = "Prev misspelling" })
vim.keymap.set("n", "<leader>ss", "z=", { remap = true, desc = "Spell suggestions" })
vim.keymap.set("n", "<leader>sa", "zg", { remap = true, desc = "Add word to dictionary" })
vim.keymap.set("n", "<leader>sw", "zw", { remap = true, desc = "Mark word as wrong" })
-- ===== LSP keymaps (active when a language server attaches) =====
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
    end
    map("gd",         vim.lsp.buf.definition,     "Go to definition")
    map("K",          vim.lsp.buf.hover,           "Hover docs")
    map("<leader>rn", vim.lsp.buf.rename,          "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action,     "Code action")
    map("[d",         vim.diagnostic.goto_prev,    "Prev diagnostic")
    map("]d",         vim.diagnostic.goto_next,    "Next diagnostic")
  end,
})
