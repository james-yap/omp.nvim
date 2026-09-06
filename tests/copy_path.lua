local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.cmd 'runtime plugin/omp.lua'

require('omp').setup {
  keymaps = {
    copy_path = false,
    copy_path_with_position = false,
  },
}

assert(vim.fn.maparg('gp', 'n') == '', 'copy_path_with_position=false left gp mapped')
assert(vim.fn.maparg('gP', 'n') == '', 'copy_path=false left gP mapped')

require('omp').setup {}
assert(vim.fn.maparg('gp', 'n') ~= '', 'default gp keymap was not installed')
assert(vim.fn.maparg('gm', 'n') ~= '', 'default gm keymap was not installed')
assert(vim.fn.maparg('gP', 'n') ~= '', 'default gP keymap was not installed')

local omp = require 'omp'
local path = vim.fn.tempname() .. '.lua'
vim.fn.writefile({ 'aaaa', 'bbbb', 'cccc', 'dddd' }, path)
vim.cmd.edit(vim.fn.fnameescape(path))

local abs = vim.fn.fnamemodify(path, ':p')
vim.api.nvim_win_set_cursor(0, { 2, 2 })

assert(omp.copy_path() == abs, 'copy_path did not return the absolute path')
assert(
  omp.copy_path_with_position() == string.format('%s:L2:C3', abs),
  'cursor position format was wrong'
)

vim.api.nvim_win_set_cursor(0, { 2, 0 })
vim.cmd 'normal! v'
vim.api.nvim_win_set_cursor(0, { 2, 3 })
assert(
  omp.copy_path_with_position() == string.format('%s:L2:C1-C4', abs),
  'character visual format was wrong'
)
vim.cmd 'normal! \27'

vim.api.nvim_win_set_cursor(0, { 4, 0 })
vim.cmd 'normal! v'
vim.api.nvim_win_set_cursor(0, { 1, 1 })
assert(
  omp.copy_path_with_position() == string.format('%s:L1:C2-L4:C1', abs),
  'reversed visual range was not normalized'
)
vim.cmd 'normal! \27'

vim.api.nvim_win_set_cursor(0, { 2, 0 })
vim.cmd 'normal! Vj'
assert(
  omp.copy_path_with_position() == string.format('%s:L2-L3', abs),
  'linewise visual format was wrong'
)
vim.cmd 'normal! \27'

print 'omp.nvim copy_path test passed'
vim.cmd 'qa!'
