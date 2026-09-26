return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        neocmake = {
          cmd = {
            vim.fn.stdpath("data")
              .. "/mason/packages/neocmakelsp/bin/neocmakelsp",
            "stdio",
          },
        },
      },
    },
  },
}