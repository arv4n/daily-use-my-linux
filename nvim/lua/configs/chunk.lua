require("hlchunk").setup({
  chunk = {
    enable = true,
    notify = true,
    use_treesitter = true,
    support_filetypes = {
      "*.lua", "*.py", "*.js", "*.ts", "*.java", "*.rs", "*.go", "*.c", "*.cpp", "*.html", "*.json", "*.css", "*.sh"
    },
    chars = {
      horizontal_line = "─",
      vertical_line = "│",
      left_top = "┌",
      left_bottom = "└",
      right_arrow = "─",
    },
    style = {
      { fg = "#FFDB58"		 }, -- everblush coral pink
      { fg = "#9dd1dc" }, -- everblush soft cyan
    },
  },



  indent = {
    enable = true,
    chars = { "│" },
    style = {
      { fg = "#5c5c5c" }, -- soft gray for indent guides
    },
    exclude_filetypes = {
      "help", "dashboard", "neo-tree", "lazy", "mason", "toggleterm",
    },
  },

  line_num = {
    enable = true,
    style = "#c7b0ec", -- pastel purple
  },

  blank = {
    enable = true,
    chars = {
      "⋅", -- Middle dot character for space visualization
    },
    style = {
      { fg = "#3c3c3c" }, -- darker subtle gray
    },
  },
})
