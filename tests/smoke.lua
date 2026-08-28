local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.cmd 'runtime plugin/omp.lua'

assert(vim.fn.exists ':Omp' == 2, ':Omp was not registered')

local command = vim.env.OMP_NVIM_TEST_REAL and { 'omp' }
  or { vim.o.shell, '-c', 'printf omp.nvim-smoke; sleep 10' }

require('omp').setup {
  command = command,
  keymaps = {
    open = '<leader>oa',
    hide = '<C-q>',
  },
}

vim.cmd 'Omp open'
assert(vim.wait(1000, function() return vim.bo.buftype == 'terminal' end), 'terminal did not start')

local first_buf = vim.api.nvim_get_current_buf()
local first_win = vim.api.nvim_get_current_win()
local win_config = vim.api.nvim_win_get_config(first_win)
assert(win_config.relative == 'editor', 'OMP did not open in an editor-relative float')
assert(vim.fn.maparg('<leader>oa', 'n') ~= '', 'open keymap was not installed')
assert(vim.fn.maparg('<C-q>', 't') ~= '', 'hide keymap was not installed')

vim.cmd 'Omp hide'
assert(not vim.api.nvim_win_is_valid(first_win), 'hide left the float open')
assert(vim.api.nvim_buf_is_valid(first_buf), 'hide deleted the terminal session')

vim.cmd 'Omp open'
assert(vim.api.nvim_get_current_buf() == first_buf, 'open did not reuse the terminal session')
local reopened_win = vim.api.nvim_get_current_win()

vim.cmd 'Omp toggle'
assert(not vim.api.nvim_win_is_valid(reopened_win), 'toggle did not hide the float')
assert(vim.api.nvim_buf_is_valid(first_buf), 'toggle deleted the terminal session')

vim.api.nvim_buf_delete(first_buf, { force = true })
print 'omp.nvim smoke test passed'
vim.cmd 'qa!'
