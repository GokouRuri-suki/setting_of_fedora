local timer = vim.uv.new_timer()
local function save()
  timer:stop()
  timer:start(500, 0, function()
    vim.schedule(function()
      if vim.bo.modified and not vim.bo.readonly and vim.fn.bufname("%") ~= "" then
        local has_err = #vim.diagnostic.get(0, {
          severity = vim.diagnostic.severity.ERROR,
        }) > 0
        if has_err then
          vim.b.autoformat = false
          vim.cmd("update")
          vim.b.autoformat = nil
        else
          vim.cmd("update")
        end
      end
    end)
  end)
end

local g = vim.api.nvim_create_augroup("AutoSave", { clear = true })
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  group = g,
  callback = save,
})