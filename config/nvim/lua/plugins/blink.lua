return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = { "accept", "fallback" },
        ["<CR>"] = { "fallback" },
        ["<C-y>"] = { "select_and_accept" },
      },
    },
  },
}