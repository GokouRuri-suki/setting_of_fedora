return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          mode = { "n", "x" },
          { "<leader><tab>", group = "标签页" },
          { "<leader>c", group = "代码" },
          { "<leader>d", group = "调试" },
          { "<leader>dp", group = "性能分析" },
          { "<leader>f", group = "文件/查找" },
          { "<leader>g", group = "Git" },
          { "<leader>gh", group = "代码块" },
          { "<leader>q", group = "退出/会话" },
          { "<leader>s", group = "搜索" },
          { "<leader>u", group = "界面" },
          { "<leader>x", group = "诊断/快速修复" },
          { "<leader>b", group = "缓冲区" },
          { "<leader>w", group = "窗口" },
          { "[", group = "上一个" },
          { "]", group = "下一个" },
          { "g", group = "跳转" },
          { "gs", group = "环绕" },
          { "z", group = "折叠" },
        },
      },
    },
  },
  {
    "snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
    ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗
    ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║
    ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║
    ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║
    ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
          ]],
          keys = {
            { icon = " ", key = "f", desc = "查找文件", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "新建文件", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "查找文本", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "最近文件", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "打开配置", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "恢复会话", section = "session" },
            { icon = " ", key = "x", desc = "Lazy 扩展", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy 插件", action = ":Lazy" },
            { icon = " ", key = "q", desc = "退出", action = ":qa" },
          },
        },
      },
    },
  },
}