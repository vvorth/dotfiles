-- ~/.config/nvim/lua/plugins/snacks-scroll.lua
--
-- Despite the file name this configures all of snacks.nvim: smooth scroll,
-- notifier, picker (+ explorer sidebar), indent guides, images, terminal.

-- <C-h/j/k/l> inside the explorer. snacks draws the explorer's list and input
-- as *floating* windows over a real sidebar split (the "snacks_layout_box"
-- window; win_gettype() of the list is "popup"). From a float, `wincmd h`
-- does not fail at the screen edge, it jumps to the editor window, so
-- vim-tmux-navigator concludes it moved inside vim and never hands the key to
-- tmux: <C-h> from the explorer landed in the editor, same as <C-l>, and the
-- tmux pane to the left was unreachable (verified on nvim 0.12 / tmux 3.4).
-- So these actions ask the question from the sidebar split instead: is there
-- a vim window in that direction? Go there. Otherwise hand over to tmux, like
-- the navigator does from a normal split.
local function explorer_nav(dir)
  local tmux_flag = { h = "L", j = "D", k = "U", l = "R" }
  return function(picker)
    local box = picker.layout and picker.layout.root and picker.layout.root.win
    if not (box and vim.api.nvim_win_is_valid(box)) then
      box = vim.api.nvim_get_current_win()
    end
    -- winnr(dir) answers with the current window when nothing lies that way
    local target = vim.api.nvim_win_call(box, function()
      return vim.fn.win_getid(vim.fn.winnr(dir))
    end)
    if target ~= box and vim.api.nvim_win_is_valid(target) then
      vim.api.nvim_set_current_win(target)
    elseif vim.env.TMUX then
      vim.fn.system({ "tmux", "select-pane", "-" .. tmux_flag[dir] })
    end
  end
end

-- <C-t> in the explorer list: a file opens in a new tab (the picker's stock
-- "tab" action, which the explorer routes through its own confirm), a closed
-- folder expands, an open folder is left alone.
local function explorer_tab(picker, item)
  if not item then
    return
  elseif item.dir then
    if not item.open then
      picker:action("confirm")
    end
  else
    picker:action("tab")
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    scroll = {
      animate = {
        duration = { step = 10, total = 200 },
        easing = "linear",
      },
    },
    notifier = { enabled = true, timeout = 3000 },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          actions = {
            nav_left = explorer_nav("h"),
            nav_down = explorer_nav("j"),
            nav_up = explorer_nav("k"),
            nav_right = explorer_nav("l"),
            explorer_tab = explorer_tab,
          },
          win = {
            -- the file list: where <leader>e puts you (Normal mode)
            list = {
              keys = {
                ["<C-h>"] = "nav_left",
                ["<C-j>"] = "nav_down", -- was list_down; j/k still do that
                ["<C-k>"] = "nav_up",
                ["<C-l>"] = "nav_right",
                ["<C-t>"] = "explorer_tab", -- was "terminal"
              },
            },
            -- the filter prompt above the list (Insert mode while typing).
            -- <C-j>/<C-k> stay list_down/list_up here so the list can be
            -- walked while filtering.
            input = {
              keys = {
                ["<C-h>"] = { "nav_left", mode = "n" },
                ["<C-l>"] = { "nav_right", mode = "n" },
                ["<Esc>"] = { "close", mode = { "i", "n" } },
                ["<C-c>"] = { "close", mode = { "i", "n" } },
              },
            },
          },
        },
      },
    },
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    indent = { enabled = true },
    explorer = { enabled = true },
    statuscolumn = { enabled = true },
    image = { enabled = true, math = { enabled = false } },
    -- disabled
    input = { enabled = false },
  },
  keys = {
    { "<leader>ug", function() Snacks.toggle.indent():toggle() end, desc = "Toggle Indent Guides" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live Grep" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    -- "what was that key again" pickers
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Find Keymap" },
    { "<leader>fc", function() Snacks.picker.commands() end, desc = "Find Command" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Find Help Tag" },
    { "<leader>bf", function() Snacks.picker.buffers() end, desc = "Find Buffer" },
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>un",  function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer (toggle)" },
    { "<leader>ut", function() Snacks.terminal() end, desc = "Toggle Terminal" },
  },
}
