# runpad.nvim

runpad.nvim is a Neovim plugin that provides a flexible runpad buffer for quick code evaluation and experimentation. It supports multiple programming languages and allows you to create, evaluate, and manage runpad buffers easily.

## Features

- Create a new runpad buffer for supported filetypes (Lua, Python, R, JavaScript).
- Evaluate the content of the runpad buffer.
- Clear or close the runpad buffer.
- Toggle a default runpad buffer.

## Installation

Use [Lazy.nvim](https://github.com/folke/lazy.nvim) to install runpad.nvim. Add the following to your Lazy.nvim configuration:

```lua
{
  'walkingshamrock/runpad.nvim',
  config = function()
    -- Optional: Add any plugin-specific configuration here
  end
}
```

## Commands

- `:RunpadOpen <filetype>`: Open a new runpad buffer with the specified filetype.
- `:RunpadEval`: Evaluate the content of the current runpad buffer.
- `:RunpadClear`: Clear the content of the current runpad buffer.
- `:RunpadClose`: Close the current runpad buffer.
- `:RunpadToggle`: Toggle the visibility of the default runpad buffer.

## Usage

1. Open a runpad buffer for a specific filetype:
   ```vim
   :RunpadOpen lua
   ```

2. Write some code in the buffer and evaluate it:
   ```vim
   :RunpadEval
   ```

3. Clear or close the buffer when done:
   ```vim
   :RunpadClear
   :RunpadClose
   ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
