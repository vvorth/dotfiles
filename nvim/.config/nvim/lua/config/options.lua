
-- Enable 24-bit color (Required for modern plugins like Noice to look good)
local function supports_truecolor()
  if vim.env.COLORTERM == "truecolor" or vim.env.COLORTERM == "24bit" then
    return true
  end

  if vim.env.TMUX then
    local ok, client_term = pcall(vim.fn.system, "tmux display-message -p '#{client_termname}'")
    if ok then
      client_term = vim.trim(client_term)
      if client_term == "linux" then return false end
      if client_term ~= "" then return true end
    end
  end

  -- bare console, or screen with `term screen.$TERM` in .screenrc
  if vim.env.TERM == "linux" or vim.env.TERM == "linux-basic" or vim.env.TERM:match("screen%.linux") then
    return false
  end

  return true
end

vim.opt.termguicolors = supports_truecolor()

vim.opt.guicursor = "n-v-c-i:block"

vim.opt.background = "dark"
-- Selenized Dark to match Ghostty (plugins/colorscheme.lua). The port only sets
-- gui colours, so without termguicolors (a bare console) it would render
-- uncoloured -- keep slate there, and if the plugin isn't installed yet.
if not (vim.o.termguicolors and pcall(vim.cmd.colorscheme, "selenized")) then
  vim.cmd.colorscheme("slate")
end

vim.opt.number = true         -- show line number
vim.opt.relativenumber = true

vim.opt.mouse = ""            -- disable mouse in all modes

-- lualine and snacks.notify replaces that
vim.opt.cmdheight = 0

vim.opt.scrolloff = 5         -- keep a few lines of context around the cursor

vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.tabstop = 4        -- Insert 4 spaces for a tab
vim.opt.shiftwidth = 4     -- Change the number of spaces inserted for indentation
vim.opt.softtabstop = 4    -- Makes the spaces feel like real tabs when editing

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- native natural completion
vim.opt.wildmenu = true          -- enable cmdline completion at all (on by default in Nvim, explicit anyway)
vim.opt.wildoptions = "pum"      -- render as a proper popup menu, not the old horizontal statusline list
vim.opt.wildcharm = 9            -- <Tab>'s termcode (Ctrl-I); lets you reference "the completion key" in mappings if needed later
vim.opt.wildignorecase = true    -- case-insensitive matching, like most shells default to
vim.opt.wildignore:append({ "*.o", "*.pyc", "*/.git/*", "*/node_modules/*" }) -- skip noise, like a shell's complete ignore-patterns

-- bash-style — Tab completes longest common prefix first,
-- a second Tab (once it's ambiguous) shows the full popup list
vim.opt.wildmode = "longest:full,full"

-- Over SSH, opening a browser/viewer on the remote host is useless (or just
-- errors), so `gx` shows the target instead. Local sessions keep the stock
-- vim.ui.open (open/xdg-open). Return nil, not a table: `gx` calls
-- :wait() on whatever comes back, and {} has no such method.
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  vim.ui.open = function(path)
    vim.notify("Open target: " .. path)
    return nil, nil
  end
end

-- treesitter folds
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"  -- native, no nvim-treesitter# prefix needed on 0.10+
vim.o.foldlevel = 99        -- start with everything UNfolded (0 would open every file fully collapsed, jarring)
vim.o.foldlevelstart = 99
vim.o.foldenable = true


