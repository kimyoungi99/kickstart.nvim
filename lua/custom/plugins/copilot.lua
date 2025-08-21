return {
  {
    'github/copilot.vim',
    lazy = false,
    config = function()
      -- Disable default Tab mapping
      vim.g.copilot_no_tab_map = false

      -- Set up custom keymaps
      -- vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
      --   expr = true,
      --   replace_keycodes = false
      -- })
      vim.keymap.set('i', '<C-]>', '<Plug>(copilot-next)', {})
      vim.keymap.set('i', '<C-[>', '<Plug>(copilot-previous)', {})

      -- Optional: Configure filetypes
      vim.g.copilot_filetypes = {
        ['*'] = true,
        ['TelescopePrompt'] = false,
      }
    end,
  },
}

