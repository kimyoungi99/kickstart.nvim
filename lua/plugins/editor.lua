local exclude = { '*.class', '*.jar', '*.war', 'build', 'bin', 'node_modules' }

return {
  { -- picker, explorer, dashboard, notifier, indent guides, LSP word highlight, big-file guard
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {},
      quickfile = {},
      input = {},
      notifier = {},
      words = {},
      indent = { animate = { enabled = false } },
      explorer = {},
      dashboard = {
        sections = {
          { section = 'header' },
          { section = 'keys', gap = 1, padding = 1 },
          { icon = ' ', title = 'Recent Files', section = 'recent_files', cwd = true, indent = 2, padding = 1 },
          { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
          { section = 'startup' },
        },
      },
      picker = {
        sources = {
          files = { exclude = exclude },
          grep = { exclude = exclude },
          explorer = { win = { list = { keys = { ['\\'] = 'close' } } } },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { '<leader>f', function() Snacks.picker.files() end, desc = 'Find [F]iles' },
      { '<leader><leader>', function() Snacks.picker.buffers() end, desc = 'Find buffers' },
      { '<leader>/', function() Snacks.picker.lines() end, desc = 'Fuzzy search in buffer' },
      { '<leader>sh', function() Snacks.picker.help() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() Snacks.picker.keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>ss', function() Snacks.picker() end, desc = '[S]earch [S]elect picker' },
      { '<leader>sw', function() Snacks.picker.grep_word() end, desc = '[S]earch current [W]ord', mode = { 'n', 'x' } },
      { '<leader>st', function() Snacks.picker.grep() end, desc = '[S]earch [T]ext (grep)' },
      { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', function() Snacks.picker.resume() end, desc = '[S]earch [R]esume' },
      { '<leader>s.', function() Snacks.picker.recent() end, desc = '[S]earch recent files' },
      { '<leader>s/', function() Snacks.picker.grep_buffers() end, desc = '[S]earch [/] in open buffers' },
      { '<leader>sn', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, desc = '[S]earch [N]eovim config' },
      { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazy[g]it' },
      { '<leader>e', function() Snacks.explorer() end, desc = '[E]xplorer toggle' },
      { '<leader>E', function() Snacks.explorer.reveal() end, desc = '[E]xplorer reveal current' },
      { '\\', function() Snacks.explorer.reveal() end, desc = 'Explorer reveal' },
      {
        '<leader>ef',
        function()
          local explorer = Snacks.picker.get({ source = 'explorer' })[1]
          if explorer then explorer:focus() else Snacks.explorer() end
        end,
        desc = '[E]xplorer [F]ocus',
      },
    },
  },

  {
    'nvim-mini/mini.nvim',
    event = 'VeryLazy',
    config = function()
      require('mini.ai').setup { n_lines = 500 } -- va) yinq ci'
      require('mini.surround').setup() -- saiw) sd' sr)'
      require('mini.pairs').setup()
      require('mini.icons').setup()
      local statusline = require 'mini.statusline'
      statusline.setup()
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('harpoon'):setup()
    end,
    -- stylua: ignore
    keys = {
      { '<leader>a', function() require('harpoon'):list():add() end, desc = 'Harpoon [A]dd file' },
      { '<C-e>', function() local h = require 'harpoon' h.ui:toggle_quick_menu(h:list()) end, desc = 'Harpoon menu' },
      { '<leader>h', function() require('harpoon'):list():select(1) end, desc = 'Harpoon file 1' },
      { '<leader>t', function() require('harpoon'):list():select(2) end, desc = 'Harpoon file 2' },
      { '<leader>n', function() require('harpoon'):list():select(3) end, desc = 'Harpoon file 3' },
      { '<leader>s', function() require('harpoon'):list():select(4) end, desc = 'Harpoon file 4' },
      { '<C-S-P>', function() require('harpoon'):list():prev() end, desc = 'Harpoon previous' },
      { '<C-S-N>', function() require('harpoon'):list():next() end, desc = 'Harpoon next' },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame_opts = { delay = 100 },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gs.nav_hunk 'next'
          end
        end, 'Next git [c]hange')
        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gs.nav_hunk 'prev'
          end
        end, 'Previous git [c]hange')

        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'git [s]tage hunk')
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'git [r]eset hunk')
        map('n', '<leader>hs', gs.stage_hunk, 'git [s]tage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'git [r]eset hunk')
        map('n', '<leader>hS', gs.stage_buffer, 'git [S]tage buffer')
        map('n', '<leader>hu', gs.stage_hunk, 'git [u]ndo stage hunk')
        map('n', '<leader>hR', gs.reset_buffer, 'git [R]eset buffer')
        map('n', '<leader>hp', gs.preview_hunk, 'git [p]review hunk')
        map('n', '<leader>hb', function()
          gs.blame_line { full = true }
        end, 'git [b]lame line (full)')
        map('n', '<leader>hd', gs.diffthis, 'git [d]iff against index')
        map('n', '<leader>hD', function()
          gs.diffthis '@'
        end, 'git [D]iff against last commit')
        map('n', '<leader>gb', gs.toggle_current_line_blame, '[G]it [B]lame toggle (inline)')
        map('n', '<leader>gB', gs.blame, '[G]it [B]lame buffer')
        map('n', '<leader>tD', gs.preview_hunk_inline, '[T]oggle git show [D]eleted')
      end,
    },
  },

  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  { 'folke/persistence.nvim', event = 'BufReadPre', opts = {} }, -- per-cwd session; dashboard `s` restores it

  { -- project-wide search & replace (ripgrep)
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    opts = {},
    -- stylua: ignore
    keys = {
      { '<leader>sR', function() require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } } end, desc = '[S]earch and [R]eplace' },
      { '<leader>sR', function() require('grug-far').with_visual_selection() end, mode = 'x', desc = '[S]earch and [R]eplace selection' },
    },
  },
}
