
return {
  defaults = { lazy = true },

  install = {
    colorscheme = { "everblush", "tokyonight", "catppuccin", "nvchad" },
  },

  checker = {
    enabled = true,
    notify = false,
    frequency = 3600,
  },

  change_detection = {
    enabled = true,
    notify = false,
  },

  ui = {
    border = "rounded",
    size = { width = 0.9, height = 0.9 },
    wrap = true,
    pills = true,
title = " Lazy Plugin Manager",     -- Lightning bolt (cepat / power)

icons = {
  ft = "",
  lazy = "",
  loaded = "",
  not_loaded = "○",
  not_installed = "",
  cmd = "",
  config = "",
  event = "",
  plugin = "",
  runtime = "",
  source = "",
  start = "",
  task = "",
}

  },

  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin", "gzip", "netrw", "netrwPlugin", "netrwSettings",
        "netrwFileHandlers", "tar", "tarPlugin", "zip", "zipPlugin",
        "tutor", "rplugin", "synmenu", "optwin", "compiler", "ftplugin",
        "tohtml", "getscript", "getscriptPlugin", "logipat", "matchit",
        "rrhelper", "vimball", "vimballPlugin", "spellfile_plugin",
        "bugreport", "syntax",
      },
    },
  },
}

