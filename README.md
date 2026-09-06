# omp.nvim

A small Neovim plugin that runs [Oh My Pi](https://github.com/can1357/oh-my-pi) in a persistent floating terminal.

## Requirements

- Neovim 0.11 or newer
- `omp` available on `PATH`

## Installation

`width` and `height` are fractions of Neovim's current dimensions. The command starts in Neovim's current working directory. `COLORFGBG` is set from the current `background` option so nested terminal colors remain consistent.

### `vim.pack`

```lua
vim.pack.add { 'https://github.com/james-yap/omp.nvim' }

require('omp').setup {
  command = { 'omp' },
  keymaps = {
    open = 'gm',
    hide = '<C-q>',
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
```

### lazy.nvim

```lua
{
  'james-yap/omp.nvim',
  config = function()
    require('omp').setup {
      command = { 'omp' },
      keymaps = {
        open = 'gm',
        hide = '<C-q>',
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
  end,
}
```

## Default keymaps

| Keys | Mode | What it does |
| --- | --- | --- |
| `gm` | normal | Open or focus the OMP float |
| `<C-q>` | normal and terminal, buffer-local | Hide the float without stopping OMP |
| `gp` | normal, visual | Copy the absolute file path plus cursor position or visual range to the clipboard (`+` register) |
| `gP` | normal | Copy only the absolute file path to the clipboard |
| `<C-\><C-n>` | terminal | Escape into a visual-like mode in the terminal buffer. Neovim builtin; see `:help terminal-input` |

`gp` and `gP` override Vim's built-in put-and-leave-cursor-after mappings. Set any keymap option to `false` to disable it.

Clipboard strings use this format so you can paste them into OMP:

- Cursor: `/abs/path/file.lua:L12:C4`
- Linewise visual (`V`): `/abs/path/file.lua:L3-L10`
- Character visual, one line: `/abs/path/file.lua:L12:C4-C20`
- Character or block visual, many lines: `/abs/path/file.lua:L3:C1-L10:C8`

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
omp.copy_path()                 -- absolute path
omp.copy_path_with_position()   -- path plus :L / :C range
```

## License

MIT
