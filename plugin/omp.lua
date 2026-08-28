if vim.g.loaded_omp_nvim then return end
vim.g.loaded_omp_nvim = true

local actions = {
  open = true,
  hide = true,
  toggle = true,
}

vim.api.nvim_create_user_command('Omp', function(opts)
  local action = opts.args ~= '' and opts.args or 'open'
  if not actions[action] then
    vim.notify('omp.nvim: unknown action: ' .. action, vim.log.levels.ERROR)
    return
  end

  require('omp')[action]()
end, {
  nargs = '?',
  complete = function()
    return { 'open', 'hide', 'toggle' }
  end,
  desc = 'Open, hide, or toggle the OMP floating terminal',
})
