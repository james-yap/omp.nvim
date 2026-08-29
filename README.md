# omp.nvim

A small Neovim plugin that runs [Oh My Pi](https://github.com/can1357/oh-my-pi) in a persistent floating terminal.

The terminal session survives when its window is hidden. Reopening it restores terminal-normal mode and the saved view when applicable; otherwise it returns to terminal-input mode. The session is removed when OMP exits.

## Requirements

- Neovim 0.11 or newer
- `omp` available on `PATH`

## Installation

### `vim.pack`

```lua
vim.pack.add { 'https://github.com/james-yap/omp.nvim' }

require('omp').setup {
  keymaps = {
    open = 'gm',
    hide = '<C-q>',
  },
}
```

`open` is a normal-mode global keymap. `hide` is buffer-local to the OMP terminal and works in normal and terminal modes. Both are disabled by default so the plugin does not claim keys unless configured.

### lazy.nvim

```lua
{
  'james-yap/omp.nvim',
  config = function()
    require('omp').setup {
      keymaps = {
        open = 'gm',
        hide = '<C-q>',
      },
    }
  end,
}
```

## Configuration

The defaults are:

```lua
require('omp').setup {
  command = { 'omp' },
  keymaps = {
    open = nil,
    hide = nil,
  },
  window = {
    width = 0.9,
    height = 0.85,
    border = 'rounded',
    title = ' OMP ',
    title_pos = 'center',
  },
}
```

`width` and `height` are fractions of Neovim's current dimensions. The command starts in Neovim's current working directory. `COLORFGBG` is set from the current `background` option so nested terminal colors remain consistent.

## Commands

```vim
:Omp          " Open the OMP terminal
:Omp open     " Open or focus it
:Omp hide     " Hide it without stopping OMP
:Omp toggle   " Toggle its floating window
```

## Lua API

```lua
local omp = require 'omp'

omp.open()
omp.hide()
omp.toggle()
```

## License

MIT
