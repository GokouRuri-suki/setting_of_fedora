return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = function()
          local cmd = {
            "clangd",
            "--experimental-modules-support",
            "--background-index",
            "--header-insertion=never",
          }
          local clangpp = vim.fn.exepath("clang++")
          if clangpp ~= "" then
            table.insert(cmd, "--query-driver=" .. clangpp)
          end
          return { cmd = cmd }
        end,
      },
    },
  },
}