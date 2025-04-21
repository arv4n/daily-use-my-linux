-- 📦 Minty Setup Lengkap
-- Buka Huefy & Shades dengan border
require("minty.huefy").open({ border = true })
require("minty.shades").open({ border = true })

-- 🔁 Auto-refresh highlight setelah pilih warna
vim.api.nvim_create_autocmd("User", {
  pattern = "MintyColorUpdated",
  callback = function()
    require("base46").load_all_highlights()
    vim.cmd("redraw!") -- Refresh UI
    pcall(vim.cmd, "LualineReload")    -- Optional: Reload lualine jika tersedia
    pcall(vim.cmd, "BufferLineReload") -- Optional: Reload bufferline jika tersedia
    vim.notify("🎨 Warna berhasil diperbarui dan UI disegarkan!", vim.log.levels.INFO)
  end,
})

-- 🎹 Keymaps: Buka Minty dengan cepat
vim.keymap.set("n", "<leader>mh", function()
  require("minty.huefy").open({ border = true })
end, { desc = "🟢 Buka Huefy (Minty)" })

vim.keymap.set("n", "<leader>ms", function()
  require("minty.shades").open({ border = true })
end, { desc = "🟣 Buka Shades (Minty)" })

-- 🎨 Perintah custom untuk ganti ke hijau muda favorit
local function set_green_theme()
  require("minty.huefy").set_color("#99c793")  -- Mint green
  vim.cmd("doautocmd User MintyColorUpdated")
end

vim.api.nvim_create_user_command("SetMintGreen", set_green_theme, {})

-- 🔍 (Opsional) Debug: tampilkan warna aktif saat update
vim.api.nvim_create_autocmd("User", {
  pattern = "MintyColorUpdated",
  callback = function()
    local current = require("minty").get_color()
    print("🌈 Warna aktif sekarang:", current)
  end,
})
