-- Claude Code / Codex CLI inside nvim, with file/selection/diagnostics context sending.
-- Under <leader>c because <leader>a is harpoon add.
local function cli(fn, arg)
  return function()
    require('sidekick.cli')[fn](arg)
  end
end

return {
  {
    'folke/sidekick.nvim',
    opts = { nes = { enabled = false } }, -- NES needs Copilot; not used
    keys = {
      { '<c-.>', cli 'focus', mode = { 'n', 't', 'i', 'x' }, desc = 'AI: focus CLI' },
      { '<leader>cc', cli('toggle', { name = 'claude', focus = true }), desc = 'AI: [C]laude Code' },
      { '<leader>cx', cli('toggle', { name = 'codex', focus = true }), desc = 'AI: Code[x]' },
      { '<leader>cs', cli 'select', desc = 'AI: [S]elect CLI' },
      { '<leader>cd', cli 'close', desc = 'AI: [D]etach CLI' },
      { '<leader>ct', cli('send', { msg = '{this}' }), mode = { 'n', 'x' }, desc = 'AI: send [T]his' },
      { '<leader>cf', cli('send', { msg = '{file}' }), desc = 'AI: send [F]ile' },
      { '<leader>cv', cli('send', { msg = '{selection}' }), mode = 'x', desc = 'AI: send [V]isual selection' },
      { '<leader>cp', cli 'prompt', mode = { 'n', 'x' }, desc = 'AI: [P]rompt picker' },
    },
  },
}
