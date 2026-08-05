return {
  "altermo/ultimate-autopair.nvim",
  event = { "InsertEnter", "CmdlineEnter" },
  branch = "v0.6", --recommended as each new version will have breaking changes
  keys = {
    {
      "<leader>cp",
      function()
        require("ultimate-autopair").toggle()
      end,
      desc = "Toggle Autopair",
    },
  },
  opts = {
    --Config goes here
  },
}
