-- ~/.config/nvim/lua/plugins/tf-docs.lua
--
-- Registry docs for the Terraform block under the cursor, at the provider
-- version pinned in .terraform.lock.hcl. Opens through vim.ui.open, so over
-- SSH it just shows the URL (see options.lua); gY copies it instead.

return {
  "mhiro2/tf-docs.nvim",
  main = "tf-docs",
  ft = { "terraform", "hcl" },
  cmd = { "TfDocOpen", "TfDocCopyUrl", "TfDocPeek", "TfDocList", "TfDocVersion", "TfDocDebug", "TfDocClearCache" },
  keys = {
    { "gK", "<cmd>TfDocOpen<cr>", ft = { "terraform", "hcl" }, desc = "Terraform: open docs" },
    { "gY", "<cmd>TfDocCopyUrl<cr>", ft = { "terraform", "hcl" }, desc = "Terraform: copy docs URL" },
    { "<leader>ct", "<cmd>TfDocList<cr>", ft = { "terraform", "hcl" }, desc = "Terraform: docs for block…" },
  },
  opts = {},
}
