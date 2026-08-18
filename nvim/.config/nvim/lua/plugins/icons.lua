return {
  {
    "nvim-mini/mini.icons",
    opts = { mock_nvim_web_devicons = true },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
    version = false,
    config = function()
      require("mini.icons").setup()
    end,
  },
}
