-- ~/.config/nvim/lua/plugins/conform.lua

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" }, -- loads just before you'd need it (i.e. on save)
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = { "n", "v" },
			desc = "Format Buffer/Selection",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			python = { "ruff_format" }, -- or { "black" } if you installed that instead
			javascript = { "prettier" },
			typescript = { "prettier" },
			json = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
			-- fallback for any filetype not listed above: uses whatever the attached
			-- LSP server offers for formatting, if anything
			["_"] = { "trim_whitespace" },
		},
		-- format_on_save = {
		--   timeout_ms = 500,
		--   lsp_fallback = true,
		-- },
	},
}
