-- ~/.config/nvim/lua/config/unmatched-brackets.lua
--
-- Highlights brackets/delimiters that are missing their pair, buffer-wide,
-- using treesitter's own error recovery instead of a dedicated plugin: when a
-- bracket has no match, the parser marks that region as an ERROR node or
-- inserts a MISSING node for the token it expected but never found. We just
-- paint those regions.

local M = {}

local ns = vim.api.nvim_create_namespace("unmatched_brackets")
local enabled = true
local timers = {}

local function set_hl()
  vim.api.nvim_set_hl(0, "UnmatchedBracket", { link = "Error", default = true })
end
set_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

local function walk(bufnr, node)
  if not node:has_error() then
    return
  end
  if node:type() == "ERROR" or node:missing() then
    local sr, sc, er, ec = node:range()
    if sr == er and sc == ec then
      ec = ec + 1 -- zero-width MISSING nodes still need a visible cell
    end
    vim.api.nvim_buf_set_extmark(bufnr, ns, sr, sc, {
      end_row = er,
      end_col = ec,
      strict = false, -- ranges at EOF/EOL can land past the last valid column; clamp instead of erroring
      hl_group = "UnmatchedBracket",
      priority = 200,
    })
  end
  for child in node:iter_children() do
    walk(bufnr, child)
  end
end

local function refresh(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  if not enabled then
    return
  end
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return
  end
  parser:parse(true)
  parser:for_each_tree(function(tstree)
    walk(bufnr, tstree:root())
  end)
end

local function schedule_refresh(bufnr)
  if timers[bufnr] then
    timers[bufnr]:stop()
  end
  timers[bufnr] = vim.defer_fn(function()
    timers[bufnr] = nil
    refresh(bufnr)
  end, 200)
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "BufEnter" }, {
  callback = function(args)
    schedule_refresh(args.buf)
  end,
})

function M.toggle()
  enabled = not enabled
  refresh(vim.api.nvim_get_current_buf())
  vim.notify("Unmatched bracket highlight: " .. (enabled and "on" or "off"))
end

return M
