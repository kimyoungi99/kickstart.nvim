-- Servers enabled via nvim-lspconfig's lsp/*.lua configs. jdtls is started by ftplugin/java.lua.
-- tsc = TypeScript 7 native LSP: project's node_modules/.bin/tsc if >= 7, else Mason's.
local servers = { 'lua_ls', 'tsc', 'eslint', 'kotlin_lsp' }

local mason_tools = {
  'lua-language-server',
  'tsc',
  'eslint-lsp',
  'stylua',
  'prettierd',
  'jdtls',
  'java-debug-adapter',
  'java-test',
}

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim', opts = { ensure_installed = mason_tools } },
      'saghen/blink.cmp', -- registers completion capabilities via vim.lsp.config('*') before servers start
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local function map(keys, func, desc, mode)
            vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local pick = Snacks.picker

          map('<leader>lr', vim.lsp.buf.rename, '[R]ename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code [A]ction', { 'n', 'x' })
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gr', pick.lsp_references, '[G]oto [R]eferences')
          map('gi', pick.lsp_implementations, '[G]oto [I]mplementation')
          map('gd', pick.lsp_definitions, '[G]oto [D]efinition')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', pick.lsp_symbols, 'Document Symbols')
          map('gW', pick.lsp_workspace_symbols, 'Workspace Symbols')
          map('gt', pick.lsp_type_definitions, '[G]oto [T]ype Definition')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        },
        virtual_text = { source = 'if_many', spacing = 2 },
      }

      vim.lsp.config('lua_ls', {
        settings = { Lua = { completion = { callSnippet = 'Replace' } } },
      })
      vim.lsp.config('kotlin_lsp', { cmd = { 'kotlin-lsp', '--stdio' } }) -- brew's binary name
      vim.lsp.enable(servers)
    end,
  },

  { 'mfussenegger/nvim-jdtls', lazy = true }, -- required from ftplugin/java.lua

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
      },
    },
  },

  {
    'saghen/blink.cmp',
    version = '1.*',
    event = { 'InsertEnter', 'CmdlineEnter' },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'enter' },
      completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
      signature = { enabled = true },
    },
  },

  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>F',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = function()
      -- Prettier only where the project opted in; never fall back to tsserver/eslint formatting.
      local prettier = { 'prettierd', 'prettier', stop_after_first = true, lsp_format = 'never' }
      return {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- kotlin: format manually with <leader>F (whole-file reformat on save was too noisy/slow)
          local skip = { c = true, cpp = true, kotlin = true }
          if not skip[vim.bo[bufnr].filetype] then
            return { timeout_ms = 2000, lsp_format = 'fallback' }
          end
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          javascript = prettier,
          javascriptreact = prettier,
          typescript = prettier,
          typescriptreact = prettier,
          json = prettier,
          css = prettier,
          scss = prettier,
          markdown = { 'prettierd', 'prettier', stop_after_first = true },
        },
        formatters = {
          prettierd = { require_cwd = true },
          prettier = { require_cwd = true },
        },
      }
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- main branch does not support lazy-loading
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install {
        'bash',
        'c',
        'css',
        'diff',
        'dockerfile',
        'gitcommit',
        'html',
        'java',
        'javascript',
        'json',
        'kotlin',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'regex',
        'sql',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      } -- c/lua/query/vim/vimdoc/markdown ship with nvim, but nvim-treesitter's queries need its own parser versions
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        callback = function(ev)
          if not pcall(vim.treesitter.start, ev.buf) then
            return
          end
          local lang = vim.treesitter.language.get_lang(ev.match)
          if lang and vim.treesitter.query.get(lang, 'indents') then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
