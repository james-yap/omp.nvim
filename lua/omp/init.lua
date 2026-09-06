local M = {}

local defaults = {
  command = { 'omp' },
  keymaps = {
    open = nil,
    hide = nil,
    copy_path = 'gP',
    copy_path_with_position = 'gp',
  },
  window = {
    width = 0.9,
    height = 0.85,
    border = 'rounded',
    title = ' OMP ',
    title_pos = 'center',
  },
}

local config = vim.deepcopy(defaults)

local state = {
  buf = nil,
  win = nil,
  view = nil,
  terminal_normal = false,
}

local function valid_buf()
  return state.buf and vim.api.nvim_buf_is_valid(state.buf)
end

local function valid_win()
  return state.win and vim.api.nvim_win_is_valid(state.win)
end

local function float_config()
  local width = math.floor(vim.o.columns * config.window.width)
  local height = math.floor(vim.o.lines * config.window.height)

  return {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = config.window.border,
    title = config.window.title,
    title_pos = config.window.title_pos,
  }
end

vim.api.nvim_create_autocmd('VimResized', {
  callback = function()
    if valid_win() then
      vim.api.nvim_win_set_config(state.win, float_config())
    end
  end,
  desc = 'Resize OMP floating terminal',
})

local function style_float()
  if not valid_win() then return end

  vim.api.nvim_set_option_value(
    'winhighlight',
    'Normal:Normal,NormalFloat:Normal,FloatBorder:WinSeparator,FloatTitle:Normal',
    { win = state.win }
  )
end

function M.hide()
  if valid_win() then
    if vim.api.nvim_get_current_win() == state.win then
      state.terminal_normal = vim.api.nvim_get_mode().mode ~= 't'
      state.view = state.terminal_normal and vim.fn.winsaveview() or nil
    end
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

local function restore_state()
  style_float()
  if state.terminal_normal then
    if state.view then vim.fn.winrestview(state.view) end
  else
    vim.cmd 'startinsert'
  end
end

local function clear_state()
  M.hide()
  if valid_buf() then vim.api.nvim_buf_delete(state.buf, { force = true }) end
  state.buf = nil
  state.view = nil
  state.terminal_normal = false
end

local function path_with_position()
  local path = vim.fn.expand '%:p'
  local mode = vim.fn.mode()

  if mode == 'v' or mode == 'V' or mode == '\22' then
    local start_pos = vim.fn.getpos 'v'
    local end_pos = vim.fn.getpos '.'
    local start_row, start_col = start_pos[2], start_pos[3]
    local end_row, end_col = end_pos[2], end_pos[3]

    -- Normalize so the start position precedes the end position.
    if start_row > end_row or (start_row == end_row and start_col > end_col) then
      start_row, start_col, end_row, end_col = end_row, end_col, start_row, start_col
    end

    if mode == 'V' then
      return string.format('%s:L%d-L%d', path, start_row, end_row)
    elseif start_row == end_row then
      return string.format('%s:L%d:C%d-C%d', path, start_row, start_col, end_col)
    end
    return string.format('%s:L%d:C%d-L%d:C%d', path, start_row, start_col, end_row, end_col)
  end

  local cursor = vim.fn.getpos '.'
  return string.format('%s:L%d:C%d', path, cursor[2], cursor[3])
end

function M.copy_path_with_position()
  local result = path_with_position()
  vim.fn.setreg('+', result)
  vim.notify('Copied path+position to clipboard', vim.log.levels.INFO)
  return result
end

function M.copy_path()
  local path = vim.fn.expand '%:p'
  vim.fn.setreg('+', path)
  vim.notify('Copied file path to clipboard', vim.log.levels.INFO)
  return path
end

function M.open()
  if valid_win() then
    vim.api.nvim_set_current_win(state.win)
    style_float()
    vim.cmd 'startinsert'
    return
  end

  if valid_buf() then
    state.win = vim.api.nvim_open_win(state.buf, true, float_config())
    restore_state()
    return
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = 'hide'
  state.win = vim.api.nvim_open_win(state.buf, true, float_config())
  style_float()

  local colorfgbg = vim.o.background == 'light' and '0;15' or '15;0'
  local buf = state.buf
  local job = vim.fn.jobstart(config.command, {
    term = true,
    cwd = vim.fn.getcwd(),
    env = {
      COLORFGBG = colorfgbg,
    },
    on_exit = function()
      vim.schedule(function()
        if state.buf == buf then clear_state() end
      end)
    end,
  })

  if job <= 0 then
    clear_state()
    vim.notify('omp.nvim: failed to start OMP', vim.log.levels.ERROR)
    return
  end

  if config.keymaps.hide then
    vim.keymap.set({ 'n', 't' }, config.keymaps.hide, M.hide, {
      buffer = state.buf,
      silent = true,
      desc = 'Hide OMP float',
    })
  end

  vim.cmd 'startinsert'
end

function M.toggle()
  if valid_win() then
    M.hide()
  else
    M.open()
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})

  if config.keymaps.open then
    vim.keymap.set('n', config.keymaps.open, M.open, {
      desc = 'OMP floating terminal',
    })
  end

  if config.keymaps.copy_path then
    vim.keymap.set('n', config.keymaps.copy_path, M.copy_path, {
      desc = 'Copy current file path',
    })
  end

  if config.keymaps.copy_path_with_position then
    vim.keymap.set({ 'n', 'x' }, config.keymaps.copy_path_with_position, M.copy_path_with_position, {
      desc = 'Copy file path with range or position',
    })
  end
end

return M
