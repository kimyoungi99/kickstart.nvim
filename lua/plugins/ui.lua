return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha',
        transparent_background = true, -- match Ghostty background
        custom_highlights = function()
          return {
            NormalFloat = { bg = 'none' },
            FloatBorder = { bg = 'none' },
            SignColumn = { bg = 'none' },
          }
        end,
      }
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      delay = 0,
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>g', group = '[G]it' },
        { '<leader>c', group = '[C]ode / AI', mode = { 'n', 'x' } },
        { '<leader>j', group = '[J]ava' },
        { '<leader>l', group = '[L]SP / loclist' },
        { '<leader>q', group = '[Q]uickfix' },
      },
    },
  },

  { 'j-hui/fidget.nvim', event = 'LspAttach', opts = {} }, -- LSP progress (jdtls / kotlin-lsp indexing)

  { 'MeanderingProgrammer/render-markdown.nvim', ft = 'markdown', opts = {} },
}
