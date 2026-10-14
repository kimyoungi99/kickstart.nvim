-- Requires Neovim 0.12+. Plugins live in lua/plugins/*.lua, Java LSP in ftplugin/java.lua.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true -- Ghostty ships Nerd Font symbols

-- Unused remote-plugin providers (each one costs startup time)
for _, p in ipairs { 'python3', 'perl', 'ruby', 'node' } do
  vim.g['loaded_' .. p .. '_provider'] = 0
end

-- [[ Options ]]
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.winborder = 'rounded'
require('vim._core.ui2').enable {} -- built-in msg/cmdline UI: no "Press ENTER" prompts (experimental)

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true
vim.o.undodir = vim.env.HOME .. '/.vim/undodir'

-- [[ Keymaps ]]
local map = vim.keymap.set
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic [Q]uickfix list' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })

map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")
map('x', '<leader>p', [["_dP]])
map({ 'n', 'v' }, '<leader>y', [["+y]])
map('n', '<leader>Y', [["+Y]])
map({ 'n', 'v' }, '<leader>d', '"_d')

map('n', '<leader>qn', '<cmd>cnext<CR>zz', { desc = 'Quickfix next' })
map('n', '<leader>qp', '<cmd>cprev<CR>zz', { desc = 'Quickfix prev' })
map('n', '<leader>ln', '<cmd>lnext<CR>zz', { desc = 'Loclist next' })
map('n', '<leader>lp', '<cmd>lprev<CR>zz', { desc = 'Loclist prev' })

map('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>')

-- [[ Autocmds ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ lazy.nvim ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  install = { colorscheme = { 'catppuccin' } },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = { 'gzip', 'netrwPlugin', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' },
    },
  },
})
