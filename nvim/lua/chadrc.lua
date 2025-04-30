---@type ChadrcConfig
local M = {}

-- 🌈 Background khusus diagnostic inline
vim.api.nvim_set_hl(0, "TinyInlineDiagnosticBackground", { bg = "#1e1e2e", blend = 10 })

require("tiny-inline-diagnostic").setup {
  signs = {
    left = "",
    right = "",
    diag = "●",
    arrow = "",
    up_arrow = "",
    vertical = "│",
    vertical_end = "└",
    error = "",
    warn = "",
    info = "",
    hint = "",
    success = "",
    search = "",
    code = "",
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

vim.keymap.set("n", "<leader>td", function()
  require("tiny-inline-diagnostic").toggle()
end, { desc = " Toggle Tiny Inline Diagnostics" })

vim.keymap.set("n", "<leader>tr", function()
  require("tiny-inline-diagnostic").refresh()
  vim.notify(" Diagnostic diperbarui", vim.log.levels.INFO)
end)

vim.keymap.set("n", "<leader>ts", function()
  local state = require("tiny-inline-diagnostic").is_enabled()
  vim.notify((state and "Aktif" or "Nonaktif") .. " Inline Diagnostic", vim.log.levels.INFO)
end)

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.lua", "*.py", "*.java", "*.js", "*.ts", "*.cpp", "*.go" },
  callback = function()
    require("tiny-inline-diagnostic").enable()
  end,
})

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

vim.diagnostic.config({
  virtual_lines = false,
  virtual_text = {
    severity = { min = vim.diagnostic.severity.ERROR },
    prefix = " ",
  },
})

-- ✨ Custom global notify (hitam + border kuning)
-- Simpan original notify
-- local original_notify = vim.notify

-- vim.notify = function(msg, level, opts)
--   opts = opts or {}
--
--   if level == vim.log.levels.ERROR then
--     opts.title = opts.title or " ERROR"
--     opts.timeout = opts.timeout or 5000
--     opts.icon = "🌈 "
--     opts.on_open = function(win)
--       vim.api.nvim_win_set_config(win, { border = "rounded" })
--       vim.api.nvim_set_hl(0, "NotifyErrorBorder", { fg = "#ECBE7B", bg = "#000000" })
--       vim.api.nvim_set_hl(0, "NotifyErrorBody", { fg = "#ffffff", bg = "#000000" })
--     end
--     opts.highlight = "NotifyErrorBody"
--     opts.border = "rounded"
--   end
--
--   original_notify(msg, level, opts)
-- end

-- Konfigurasi LSP & diagnostics style

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "shadow",
    source = true,
    header = " Diagnostics",
    prefix = "➤ ",
  },
})

vim.cmd [[
  highlight! DiagnosticError guifg=#FF6C6B
  highlight! DiagnosticWarn  guifg=#ECBE7B
  highlight! DiagnosticInfo  guifg=#51AFEF
  highlight! DiagnosticHint  guifg=#98BE65

  highlight! DiagnosticUnderlineError gui=undercurl guisp=#FF6C6B
  highlight! DiagnosticUnderlineWarn  gui=undercurl guisp=#ECBE7B
  highlight! DiagnosticUnderlineInfo  gui=undercurl guisp=#51AFEF
  highlight! DiagnosticUnderlineHint  gui=undercurl guisp=#98BE65
]]
--
-- local signs = {
--   Error = "",
--   Warn  = "",
--   Hint  = "",
--   Info  = "",
-- }



vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
    },
  },
})



vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.open_float(nil, { focusable = true, border = "rounded" })
end, { desc = "Show diagnostics in floating window" })

-- 🟦 Tema & UI NvChad
M.base46 = {
  theme = "everblush",
  integrations = { "dap" },
}

M.ui = {
  statusline = {
    theme = "vscode_colored",
    separator_style = "round",
  },
  ident = {
    enable = true,
  },
  hl_override = {
    NvimTreeNormal = { bg = "#141b1e" },
    NvimTreeNormalNC = { bg = "#141b1e" },
    NvimTreeWinSeparator = { bg = "#141b1e", fg = "#141b1e" },
    WinSeparator = { bg = "#141b1e" },
    NavicSeparator = { bg = "#ffffff" },
    BufferLineSeparator = { bg = "#141b1e" },
    WhichKeySeparator = { bg = "#141b1e" },
    BufferLineSeparatorVisible = { bg = "#141b1e" },
    BufferLineSeparatorSelected = { bg = "#141b1e" },
    LineNr = { bg = "#141b1e" },
    NvimTreeOpenedFolderName = { bg = "#141b1e" },
    DapUILineNumber = { bg = "#141b1e" },
    BufferLineBackground = { bg = "#141b1e" },
    BufferLineBufferSelected = { bg = "#141b1e" },
    BufferLineBufferVisible = { bg = "#141b1e" },
    BufferLineCloseButton = { bg = "#141b1e" },
    BufferLineCloseButtonSelected = { bg = "#141b1e" },
  },
  nvdash = {
    load_on_startup = true,
  },
  tabufline = {
    enabled = false,
    show_numbers = true,
  },
  cmp = {
    style = "atom",
    abbr_maxwidth = 50,
    completion = {
      keyword_length = 2,
      completeopt = "menu,menuone,noselect",
      autocomplete = true,
    },
  },
}

return M -- ✅ Letakkan ini di paling bawah hanya sekali
