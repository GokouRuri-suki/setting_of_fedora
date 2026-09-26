return {
  {
    "nvim-mini/mini.files",
    init = function()
      local add_maps = function(buf)
        local fs = require("mini.files")

        local function focused_path()
          local entry = fs.get_fs_entry()
          return entry and entry.path or nil
        end

        local function origin_dir(path)
          if vim.fn.isdirectory(path) == 1 then
            return path
          end
          return vim.fn.fnamemodify(path, ":h")
        end

        vim.keymap.set("n", "R", function()
          local path = focused_path()
          if not path then
            return
          end
          local base = vim.fn.fnamemodify(path, ":t")
          local new = vim.fn.input("重命名: ", base)
          new = new:gsub("^%s+", ""):gsub("%s+$", "")
          if new == "" then
            return
          end
          local to = vim.fn.fnamemodify(path, ":h") .. "/" .. new
          vim.fn.rename(path, to)
          fs.refresh()
          vim.api.nvim_exec_autocmds("User", {
            pattern = "MiniFilesActionRename",
            data = { from = path, to = to },
          })
        end, { buffer = buf, desc = "重命名" })

        vim.keymap.set("n", "C", function()
          local path = focused_path()
          if not path then
            return
          end
          local nm = vim.fn.input("新建 (末尾 / 表示目录): ")
          nm = nm:gsub("^%s+", ""):gsub("%s+$", "")
          if nm == "" then
            return
          end
          local target = origin_dir(path) .. "/" .. nm
          if vim.endswith(target, "/") then
            vim.fn.mkdir(target, "p")
          else
            vim.fn.writefile({}, target)
          end
          fs.refresh()
        end, { buffer = buf, desc = "创建文件/目录" })

        vim.keymap.set("n", "dd", function()
          local path = focused_path()
          if not path then
            return
          end
          local choice = vim.fn.confirm("删除 " .. path .. " ?", "&是\n&取消")
          if choice ~= 1 then
            return
          end
          if vim.fn.isdirectory(path) == 1 then
            vim.fn.delete(path, "rf")
          else
            vim.fn.delete(path)
          end
          fs.refresh()
        end, { buffer = buf, desc = "删除" })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          add_maps(args.data.buf_id)
        end,
      })
    end,
  },
}