require "nvchad.options"

local o = vim.o
local wo = vim.wo
local bo = vim.bo

-- 📌 Kinerja dan tampilan
vim.cmd [[ set ttyfast ]] -- biar scroll dan redraw makin cepat
o.lazyredraw = true       -- hindari redraw berlebihan saat exec macro
o.synmaxcol = 240         -- batas kolom syntax highlight

-- 🔹 Tampilan kursor & baris
o.cursorlineopt = "both"
wo.cursorline = true
wo.cursorcolumn = false

-- 🔹 Warna dan UI
o.termguicolors = true
o.signcolumn = "yes"
o.cmdheight = 1
o.laststatus = 3
o.background = "dark"

-- 🔹 Line Numbering
wo.number = true
wo.relativenumber = true
o.numberwidth = 2

-- 🔹 Indentasi
o.expandtab = true
o.smartindent = true
o.autoindent = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.breakindent = true

-- 🔹 Searching
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true

-- 🔹 Files
o.encoding = "utf-8"
o.fileencoding = "utf-8"
o.hidden = true
o.swapfile = false
o.backup = false
o.writebackup = false
o.undofile = true
local undodir = vim.fn.stdpath("cache") .. "/undo"
vim.fn.mkdir(undodir, "p")
o.undodir = undodir

-- 🔹 Scroll dan Navigation
o.scrolloff = 8
o.sidescrolloff = 8

-- 🔹 Split windows
o.splitbelow = true
o.splitright = true

-- 🔹 Completion
o.completeopt = "menuone,noselect"
o.pumheight = 10

-- 🔹 Folding (pakai Treesitter)
o.foldenable = true
o.foldlevelstart = 99
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"

-- 🔹 Clipboard & Mouse
o.clipboard = "unnamedplus"
o.mouse = "a"

-- 🔹 Timeouts
o.timeoutlen = 400
o.ttimeoutlen = 10
o.updatetime = 250

-- 🔹 UI tambahan
o.title = true
o.titlestring = "%F - NVIM"
wo.wrap = false
o.linebreak = true

-- 🔹 Wildmenu
o.wildmenu = true
o.wildmode = "longest:full,full"

-- 🔹 Auto reload file kalau berubah dari luar
o.autoread = true
vim.cmd [[
  autocmd FocusGained,BufEnter * checktime
]]

-- 🔹 Lebih aman saat close Neovim
vim.cmd [[
  autocmd BufWritePre * :%s/\s\+$//e ]]

-- 🔹 Emoji dan simbol
vim.cmd [[
  set encoding=utf-8
  set fileencodings=utf-8
]]


