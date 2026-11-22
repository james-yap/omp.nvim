local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)

local sent = {}
vim.api.nvim_ui_send = function(content) table.insert(sent, content) end

local transmit = '\27_Ga=T,U=1,q=2,i=7;QUJD\27\\'
local delete_one = '\27_Ga=d,d=I,i=7,q=2\27\\'
local delete_all = '\27_Ga=d,d=A,q=2\27\\'
local bare_delete = '\27_Ga=d,q=2\27\\'
local osc = '\27]0;title\7'

require('omp').setup {
  command = { 'printf', '%s', transmit .. osc .. delete_all .. bare_delete .. delete_one .. 'done' },
}
require('omp').open()

assert(vim.wait(1000, function() return #sent >= 2 end), 'Kitty graphics were not forwarded')
vim.wait(100)
assert(vim.deep_equal(sent, { transmit, delete_one }), 'unexpected forwarded sequences: ' .. vim.inspect(sent))

print 'omp.nvim kitty graphics test passed'
vim.cmd 'qa!'
