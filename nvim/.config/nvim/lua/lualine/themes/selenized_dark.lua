-- lualine theme: Selenized Dark, matching the colorscheme and Ghostty.
--
-- Hex values are the canonical sRGB ones from jan-warchol/selenized's
-- the-values.md (Ghostty's "Selenized Dark" uses the same). Hard-coded rather
-- than read from the colorscheme, because lualine loads at startup before
-- config/options.lua has applied a colorscheme, and so the bar stays right
-- even when the slate fallback is in use.
--
-- The mode pill carries the accent (blue normal, green insert, magenta visual,
-- red replace, yellow command, cyan terminal); b and c step down the three
-- Selenized background shades.

local c = {
  bg_0 = "#103c48",
  bg_1 = "#184956",
  bg_2 = "#2d5b69",
  dim_0 = "#72898f",
  fg_0 = "#adbcbc",
  fg_1 = "#cad8d9",
  red = "#fa5750",
  green = "#75b938",
  yellow = "#dbb32d",
  blue = "#4695f7",
  magenta = "#f275be",
  cyan = "#41c7b9",
}

local function mode(accent)
  return {
    a = { fg = c.bg_0, bg = accent, gui = "bold" },
    b = { fg = c.fg_1, bg = c.bg_2 },
    c = { fg = c.fg_0, bg = c.bg_1 },
  }
end

return {
  normal = mode(c.blue),
  insert = mode(c.green),
  visual = mode(c.magenta),
  replace = mode(c.red),
  command = mode(c.yellow),
  terminal = mode(c.cyan),
  inactive = {
    a = { fg = c.dim_0, bg = c.bg_1, gui = "bold" },
    b = { fg = c.dim_0, bg = c.bg_1 },
    c = { fg = c.dim_0, bg = c.bg_1 },
  },
}
