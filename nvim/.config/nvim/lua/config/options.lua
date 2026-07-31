
-- Enable 24-bit color (Required for modern plugins like Noice to look good)
vim.opt.termguicolors = true
vim.opt.guicursor = "n-v-c-i:block"

vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.tabstop = 4        -- Insert 4 spaces for a tab
vim.opt.shiftwidth = 4     -- Change the number of spaces inserted for indentation
vim.opt.softtabstop = 4    -- Makes the spaces feel like real tabs when editing

-- native natural completion
vim.opt.wildmenu = true          -- enable cmdline completion at all (on by default in Nvim, explicit anyway)
vim.opt.wildoptions = "pum"      -- render as a proper popup menu, not the old horizontal statusline list
vim.opt.wildcharm = 9            -- <Tab>'s termcode (Ctrl-I); lets you reference "the completion key" in mappings if needed later
vim.opt.wildignorecase = true    -- case-insensitive matching, like most shells default to
vim.opt.wildignore:append({ "*.o", "*.pyc", "*/.git/*", "*/node_modules/*" }) -- skip noise, like a shell's complete ignore-patterns

-- bash-style — Tab completes longest common prefix first,
-- a second Tab (once it's ambiguous) shows the full popup list
vim.opt.wildmode = "longest:full,full"

-- show url instead of vim.ui.open
vim.ui.open = function(path)
  vim.notify("URL: " .. path)
  return {}, nil
end

-- treesitter folds
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"  -- native, no nvim-treesitter# prefix needed on 0.10+
vim.o.foldlevel = 99        -- start with everything UNfolded (0 would open every file fully collapsed, jarring)
vim.o.foldlevelstart = 99
vim.o.foldenable = true


