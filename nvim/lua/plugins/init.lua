return {

-- Plugin untuk paste image
{ "HakonHarnes/img-clip.nvim" },              -- Support for image pasting

-- Optional Plugins for File Selection
{ "echasnovski/mini.pick" },                  -- File selector with mini.pick
-- Plugin lainnya
{ "nvim-treesitter/nvim-treesitter" },        -- Syntax highlighting
{ "stevearc/dressing.nvim" },                -- UI enhancements
{ "nvim-lua/plenary.nvim" },                 -- Utility library
{ "MunifTanjim/nui.nvim" },                  -- UI framework
{ "nvim-tree/nvim-web-devicons" },           -- File icons
{ "ibhagwan/fzf-lua" },                      -- File searching with fzf
{ "nvim-telescope/telescope.nvim" },         -- Fuzzy finder and file search

{
  "onsails/lspkind.nvim",
},


-- Autocompletion and Snippets
{ "hrsh7th/nvim-cmp" },                      -- Main autocompletion plugin
{ "hrsh7th/cmp-buffer" },                    -- Autocomplete from buffer
{ "hrsh7th/cmp-path" },                      -- Autocomplete file paths
{ "hrsh7th/cmp-nvim-lsp" },                  -- LSP integration for autocompletion
{ "hrsh7th/cmp-calc" },                      -- Autocompletion for calculations
{ "hrsh7th/cmp-vsnip" },                     -- Snippet support with vsnip
{ "hrsh7th/cmp-nvim-lua" },                  -- Autocompletion for Lua
{ "hrsh7th/cmp-emoji" },                     -- Autocompletion for emojis
{ "hrsh7th/cmp-cmdline" },                   -- Autocompletion for the command line
{ "saadparwaiz1/cmp_luasnip" },              -- Luasnip support for nvim-cmp
{ "hrsh7th/cmp-nvim-lsp-signature-help" },  -- LSP signature help
-------------

  {
  "github/copilot.vim",

    event= "InsertEnter",
    priority = 1000, -- Supaya load lebih awal (optional)
  config = function()
    -- Nonaktifkan tab map default agar tidak bentrok dengan keymap lainnya
    vim.g.copilot_no_tab_map = true

    -- Keymap untuk menerima saran dari Copilot dengan <C-J>
    vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', {
      expr = true,
      silent = true,
      script = true,
      noremap = true,
    })

    -- Keymap untuk membersihkan saran dari Copilot dengan <C-K>
    vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Clear()', {
      expr = true,
      silent = true,
      script = true,
      noremap = true,
    })

    -- Aktifkan auto-trigger, Copilot akan otomatis memberikan saran saat mengetik
    vim.g.copilot_auto_trigger = true

    -- **Menonaktifkan Copilot pada beberapa filetype yang tidak relevan**
    vim.g.copilot_filetypes = {
      javascript = true,
      python = true,
      lua = true,
      go = true,
      html = true,
      css = true,
      typescript = true,
      ruby = true,
      php = true,
      java = true,
      rust = true,
      swift = true,
      json = true,
      markdown = true,
      text = true,
      yaml = true,
    }


-- Aktifkan saran lebih banyak dengan Copilot
vim.g.copilot_auto_trigger = true  -- Aktifkan auto trigger untuk saran lebih cepat
vim.g.copilot_suggestion_limit = 1000  -- Tentukan batas saran yang bisa ditampilkan

-- Gunakan tombol untuk melompat antar saran
vim.api.nvim_set_keymap("i", "<C-Down>", 'copilot#Next()', {expr = true, silent = true, noremap = true})
vim.api.nvim_set_keymap("i", "<C-Up>", 'copilot#Previous()', {expr = true, silent = true, noremap = true})

-- Gunakan Copilot secara penuh untuk menerima saran secara langsung
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept()', {expr = true, silent = true, noremap = true})

-- Menampilkan lebih banyak saran dengan tombol khusus
vim.api.nvim_set_keymap("i", "<C-Space>", 'copilot#Suggest()', {expr = true, silent = true, noremap = true})

    -- **Cek Kesalahan / Error handling**
    vim.g.copilot_log_level = "debug"  -- Sesuaikan level log (debug, info, warn, error)

    -- **Bahasa yang Didukung oleh Copilot (Saran Kata Umum dalam Banyak Bahasa)**
    vim.api.nvim_create_autocmd("InsertEnter", {
      callback = function()
        -- Aktifkan untuk semua bahasa: Indonesia, Inggris, Jerman, Jepang, Korea, China
        -- Semua filetype diaktifkan dengan saran dalam berbagai bahasa alami
        vim.cmd([[
          augroup CopilotAllLanguages
            autocmd!
            autocmd FileType * lua vim.g.copilot_filetypes[vim.bo.filetype] = true
          augroup END
        ]])
      end
    })

    -- **Menambahkan Keymap untuk Menampilkan Lebih Banyak Saran**
    vim.api.nvim_set_keymap("i", "<C-Down>", 'copilot#Suggest("<C-Space>")', {
      expr = true,
      silent = true,
      noremap = true,
    })
  end,
},
-------------------------------

 ----------------

{
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      enable_dependency_autocomplete = true,
      enable_task_runner = true,
    })
  end,
},



--------------------------------

  { "nvchad/menu",     lazy = true },

  { "nvchad/showkeys", cmd = "ShowkeysToggle", opts = { position = "top-center" } },

  { "nvchad/timerly",  cmd = "TimerlyToggle" },
------------------------------
{
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = false },
    { 'mfussenegger/nvim-jdtls', lazy = false },         -- Java language server wrapper
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = false },
    { 'hrsh7th/nvim-cmp', lazy = false },  -- Autocompletion for nvim-cmp
    { 'hrsh7th/cmp-buffer', lazy = false }, -- Buffer completion for autocomplete
    { 'saadparwaiz1/cmp_luasnip', lazy = false },
    { 'L3MON4D3/LuaSnip', lazy = false },   -- LuaSnip for snippets
    { 'hrsh7th/cmp-nvim-lsp-signature-help', lazy = false }, -- LSP signature help
    { 'hrsh7th/cmp-path', lazy = false },
    { 'hrsh7th/cmp-nvim-lsp', lazy = false },
    { 'hrsh7th/cmp-cmdline', lazy = false },
    { 'hrsh7th/cmp-calc', lazy = false },
    { 'hrsh7th/cmp-vsnip', lazy = false },
    { 'hrsh7th/cmp-nvim-lua', lazy = false },
    { 'hrsh7th/cmp-emoji', lazy = false },
    { 'ibhagwan/fzf-lua', lazy = false }, -- File selector using fzf
    { 'nvim-telescope/telescope.nvim', lazy = false }, -- File selector using telescope
    { 'nvim-lua/plenary.nvim', lazy = false }, -- Utility functions
    { 'MunifTanjim/nui.nvim', lazy = false }, -- UI components
    { 'stevearc/dressing.nvim', lazy = false }, -- Improved UI for input
    { 'echasnovski/mini.pick', lazy = false }, -- File selector with mini.pick
    { 'nvim-tree/nvim-web-devicons', lazy = false }, -- Icons for filetypes
  },

  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
    "DBUIRenameBuffer",
    "DBUILastQueryInfo",
    "DBUIHideNotifications",
    "DBUISaveQuery",
  },

  init = function()
    -- Konfigurasi DBUI
    vim.g.db_ui_use_nerd_fonts = 1
  end,

  config = function()
    local cmp = require("cmp")

    -- Setup autocomplete untuk filetype SQL
    cmp.setup.filetype("sql", {
      sources = {
        { name = "vim-dadbod-completion" },
        { name = "buffer" },
      },
    })

    -- Setup autocomplete saat membuka file SQL, MySQL, atau PL/SQL
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sql", "mysql", "plsql" },
      callback = function()
        cmp.setup.buffer({
          sources = {
            { name = "vim-dadbod-completion" },
            { name = "buffer" },
          },
        })
      end,
    })
  end,
},

-----------------------------------

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require("configs.lspconfig")
    end,
  },
  {
    "folke/which-key.nvim",
    lazy = false,
    config = function()
      require("which-key").setup()
    end,
  },


  -- {
  --   "nvim-neotest/neotest",
  --   config = function()
  --     require("configs.neotest")
  --   end,
  --   dependencies = {
  --     "nvim-neotest/nvim-nio",
  --     "nvim-lua/plenary.nvim",
  --     "antoinemadec/FixCursorHold.nvim",
  --     "nvim-treesitter/nvim-treesitter"
  --   },
  -- },
  -- { "nvim-neotest/neotest-plenary" },
  -- { "nvim-neotest/neotest-python" },
  -- { "nvim-neotest/neotest-vim-test" },
  --


  -- {
  -- "NeogitOrg/neogit",
  --   config = function()
  --     require "configs.neogit"
  --   end,
  -- },
  -- {
  --   "whleucka/melody.nvim",
  --   dependencies = {
  --     "nvim-telescope/telescope.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "akinsho/toggleterm.nvim"
  --   },
  --   event = "VeryLazy",
  --   keys = {
  --     { "<leader>mm", "<cmd>lua require('melody').music_search()<cr>", desc = "Melody search" },
  --   },
  --   config = function()
  --     print("melody.nvim setup running...")  -- Tambahan debug
  --     require("melody").setup({
  --       music_dir = "/home/god/Musik"  -- HARUS absolute path, jangan pakai ~
  --     })
  --   end
  -- }

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
    end,
  },



  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",  -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua",              -- optional
      "echasnovski/mini.pick",         -- optional
    },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto", -- Sesuaikan tema lualine
        },
        sections = {
          lualine_c = {
            { "filename", path = 1 }, -- Tampilkan full path file
          },
        },
      })
    end
  },


  {
    "andweeb/presence.nvim",
    lazy = false, -- Plugin akan dimuat langsung
    config = function()
      local status_ok, presence_config = pcall(require, "configs.presence")
      if status_ok then
        presence_config.setup()
      else
        vim.notify("Failed to load presence.nvim configuration", vim.log.levels.ERROR)
      end
    end,
  },



  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettier",
        "json-lsp",
        "yaml-language-server",
        "tsserver",
        "eslint",
        "bash-language-server",
        "dockerfile-language-server",
        "graphql-lsp",
        "pyright",
        "jdtls",
      },
    },
  },


  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.chunk"
      --
    end,
  },

  {
    "wakatime/vim-wakatime",
    lazy = false,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "│", -- karakter indentasi
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
        highlight = { "Function", "Label" },
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "lazy",
          "neogitstatus",
          "NvimTree",
          "Trouble",
          "markdown",
        },
      },
    },
  },


  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    config = function()
      require "configs.inline-diagnostics"
    end,
  },

  { "nvchad/volt",     lazy = true },
  {
    "nvchad/minty",
    lazy = true,
    config = function()
      require "configs.minty"
    end,
  },



-------------------------------------------------

{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "lua", "vim", "vimdoc", "bash", "html", "css", "javascript", "typescript", "json", "yaml", "sql", "python", "java",
      "ruby", "go", "rust", "cpp", "c", "php", "dockerfile", "markdown", "graphql", "yaml", "toml",
      "terraform", "hcl", "elixir", "clojure", "scala", "json5", "proto", "phpdoc", "swift", "perl", "fennel", "scheme",
      "latex", "make", "nix", "r", "matlab", "vhdl", "haskell", "ocaml", "vala",
    },

    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },

    indent = {
      enable = true,
    },

    -- Menambahkan konfigurasi context_commentstring untuk semua bahasa
    context_commentstring = {
      enable = true,
      config = {
        javascript = "// %s",     -- Komentar untuk JavaScript
        typescript = "// %s",     -- Komentar untuk TypeScript
        python = "# %s",         -- Komentar untuk Python
        lua = "-- %s",           -- Komentar untuk Lua
        vim = "\" %s",           -- Komentar untuk Vim
        vimdoc = "\" %s",        -- Komentar untuk Vimdoc
        bash = "# %s",           -- Komentar untuk Bash
        html = "<!-- %s -->",    -- Komentar untuk HTML
        css = "/* %s */",        -- Komentar untuk CSS
        json = "// %s",          -- Komentar untuk JSON
        yaml = "# %s",           -- Komentar untuk YAML
        sql = "-- %s",           -- Komentar untuk SQL
        java = "// %s",          -- Komentar untuk Java
        ruby = "# %s",           -- Komentar untuk Ruby
        go = "// %s",            -- Komentar untuk Go
        rust = "// %s",          -- Komentar untuk Rust
        cpp = "// %s",           -- Komentar untuk C++
        c = "// %s",             -- Komentar untuk C
        php = "// %s",           -- Komentar untuk PHP
        dockerfile = "# %s",     -- Komentar untuk Dockerfile
        markdown = "<!-- %s -->",-- Komentar untuk Markdown
        graphql = "# %s",        -- Komentar untuk GraphQL
        terraform = "# %s",      -- Komentar untuk Terraform
        hcl = "# %s",            -- Komentar untuk HCL
        elixir = "# %s",         -- Komentar untuk Elixir
        clojure = "; %s",        -- Komentar untuk Clojure
        scala = "// %s",         -- Komentar untuk Scala
        json5 = "// %s",         -- Komentar untuk JSON5
        proto = "// %s",         -- Komentar untuk Protobuf
        phpdoc = "// %s",        -- Komentar untuk PHPDoc
        swift = "// %s",         -- Komentar untuk Swift
        perl = "# %s",           -- Komentar untuk Perl
        fennel = "; %s",         -- Komentar untuk Fennel
        scheme = "; %s",         -- Komentar untuk Scheme
        latex = "% %s",          -- Komentar untuk LaTeX
        make = "# %s",           -- Komentar untuk Makefile
        nix = "# %s",            -- Komentar untuk Nix
        r = "# %s",              -- Komentar untuk R
        matlab = "% %s",         -- Komentar untuk MATLAB
        tex = "% %s",            -- Komentar untuk TeX
        vhdl = "-- %s",          -- Komentar untuk VHDL
        haskell = "-- %s",       -- Komentar untuk Haskell
        ocaml = "(* %s *)",      -- Komentar untuk OCaml
        vala = "// %s",          -- Komentar untuk Vala
      },
    },

    -- Fitur lainnya yang sudah ada
    folding = {
      enable = true,
    },
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 1000,
    },
    autopairs = {
      enable = true,
    },
    autotag = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        node_decremental = "<BS>",
        scope_incremental = "<TAB>",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
    },
    playground = {
      enable = true,
      disable = {},
      updatetime = 25,
      persist_queries = false,
    },
  },

  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
  },
}



