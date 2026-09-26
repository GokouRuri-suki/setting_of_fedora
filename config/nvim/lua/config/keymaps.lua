-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- 中文键位提示：把 LazyVim 默认的英文快捷键描述替换为中文。
-- 因为 which-key 树和 `<Space>sk` 列表都读取 vim keymap 的 desc，
-- 这里只需用中文 desc 重建已有映射（保留动作与全部标志位），两处显示即同时汉化。
local zh = require("config.chinese")

local function tobool(v)
  return v == true or v == 1
end

-- 用中文 desc 重建一条已有映射，保留原动作与标志位。
-- 注意：`maparg.noremap` 对函数映射恒为 1、且区分不出「重映射别名」，
-- 所以当原映射是递归别名（noremap==0）时必须用 `remap=true` 重建，
-- 否则类似 `<leader>e -> <leader>fe` 的 shim 会失效（按下无反应）。
local function remap_desc(mode, lhs, desc)
  local km = vim.fn.maparg(lhs, mode, false, true)
  if not km or vim.tbl_isempty(km) then
    return
  end
  if (km.desc or "") == desc then
    return
  end
  local rhs = km.callback or km.rhs
  local opts = {
    desc = desc,
    silent = tobool(km.silent),
    nowait = tobool(km.nowait),
    expr = tobool(km.expr),
    replace_keycodes = km.replace_keycodes == 1,
  }
  if km.buffer and km.buffer ~= 0 then
    opts.buffer = km.buffer
  end
  if km.noremap == 0 then
    opts.remap = true
  else
    opts.noremap = true
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function apply()
  for lhs, desc in pairs(zh) do
    for _, m in ipairs({ "n", "x", "o" }) do
      pcall(remap_desc, m, lhs, desc)
    end
  end
end

-- 诊断：报告尚未被汉化的键（desc 仍是英文，或映射尚不存在），便于补齐 chinese.lua
local function report_missing(buf)
  local missing = {}
  for lhs, expected in pairs(zh) do
    local km = vim.fn.maparg(lhs, "n", false, true)
    if not km or vim.tbl_isempty(km) then
      missing[#missing + 1] = lhs .. "  (无映射)"
    elseif (km.desc or "") ~= expected then
      missing[#missing + 1] = lhs .. "  => " .. tostring(km.desc)
    end
  end
  local lines = { "未汉化键位 (" .. #missing .. " 个)" }
  vim.list_extend(lines, missing)
  if buf then
    vim.fn.writefile(lines, buf)
  else
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
  end
end

vim.api.nvim_create_user_command("LazyChineseCheck", function()
  report_missing()
end, {})

-- 在多个时点重复执行，确保插件懒加载后注册的 `<leader>` 键也能被汉化。
-- apply 幂等（desc 已等于目标则跳过），重复调用安全。
local augroup = vim.api.nvim_create_augroup("LazyChineseKeymaps", { clear = true })
local function schedule_apply()
  apply()
end

schedule_apply()
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = { "VeryLazy", "LazyVimKeymaps" },
  callback = apply,
})
-- 缓冲进入时重试，兜底懒加载插件晚注册的键位
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = apply,
})
-- 启动后延迟几次，覆盖较慢的插件注册
local stops = { 0.3, 1, 3 }
for _, s in ipairs(stops) do
  vim.defer_fn(apply, s * 1000)
end