
-- 🌈 Background khusus diagnostic inline
vim.api.nvim_set_hl(0, "TinyInlineDiagnosticBackground", { bg = "#1e1e2e", blend = 10 })

require("tiny-inline-diagnostic").setup {
  signs = {
    left = "",                  -- segmen kiri
    right = "",                 -- segmen kanan
    diag = "●",                  -- bullet kecil
    arrow = "",                 -- arrow untuk penunjuk
    up_arrow = "",             -- panah ke atas
    vertical = "│",             -- garis vertikal
    vertical_end = "└",         -- akhir garis vertikal
    error = "",                -- error icon
    warn = "",                 -- warning icon
    info = "",                 -- info icon
    hint = "",                 -- hint icon
    success = "",              -- sukses
    search = "",               -- pencarian
    code = "",                 -- ikon kode
  },
  hi = {
    error = "DiagnosticError",
    warn = "DiagnosticWarn",
    info = "DiagnosticInfo",
    hint = "DiagnosticHint",
    arrow = "NonText",
    background = "#1e1e2e",
  },
  blend = {
    factor = 0.35,
  },
  options = {
    show_source = true,
    throttle = 10,
    softwrap = 30,
    multiple_diag_under_cursor = true,
    multilines = true,
    overflow = {
      mode = "wrap",
    },
    format = function(d)
      local icons = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "",
      }
      return string.format("%s  %s [%s]", icons[d.severity] or "●", d.message, d.source or "LSP")
    end,
    break_line = {
      enabled = true,
      after = 50,
    },
    virt_texts = {
      priority = 9999,
    },
  },
}


-- ⏯️ Toggle & Refresh Diagnostic Inline
vim.keymap.set("n", "<leader>td", function()
  require("tiny-inline-diagnostic").toggle()
end, { desc = " Toggle Tiny Inline Diagnostics" }) --  = Toggle

vim.keymap.set("n", "<leader>tr", function()
  require("tiny-inline-diagnostic").refresh()
  vim.notify(" Diagnostic diperbarui", vim.log.levels.INFO) --  = Refresh
end)

vim.keymap.set("n", "<leader>ts", function()
  local state = require("tiny-inline-diagnostic").is_enabled()
  vim.notify((state and "Aktif" or "Nonaktif") .. " Inline Diagnostic", vim.log.levels.INFO)
end)

-- 📡 Auto Enable di File Kode
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.lua", "*.py", "*.java", "*.js", "*.ts", "*.cpp", "*.go" },
  callback = function()
    require("tiny-inline-diagnostic").enable()
  end,
})

-- 🧠 Statistik Diagnostic
vim.api.nvim_create_user_command("DiagStats", function()
  local diags = vim.diagnostic.get(0)
  local count = { Error = 0, Warn = 0, Info = 0, Hint = 0 }
  for _, d in ipairs(diags) do
    local s = vim.diagnostic.severity[d.severity]
    count[s] = (count[s] or 0) + 1
  end
  vim.notify(" Diagnostic Stats:\n" ..
    " Error   : " .. count.Error .. "\n" ..
    " Warning : " .. count.Warn .. "\n" ..
    " Info    : " .. count.Info .. "\n" ..
    " Hint    : " .. count.Hint, vim.log.levels.INFO)
end, {})

-- ✔️ Notifikasi Setelah Save
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   callback = function()
--     local diags = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
--     if #diags > 0 then
--       vim.notify(" Masih ada error!", vim.log.levels.ERROR)
--     else
--       vim.notify(" Tidak ada error!", vim.log.levels.INFO)
--     end
--   end,
-- })

-- ❌ Nonaktifkan virtual_lines dari plugin lain
vim.diagnostic.config({ virtual_lines = false })

-- 🔥 Tampilkan hanya error pakai prefix icon
vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.ERROR },
    prefix = " ", -- Error Icon Nerd Font
  },
})

