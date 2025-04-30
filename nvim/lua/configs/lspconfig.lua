
-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

local servers = {
  "asm_lsp", "bashls", "clojure_lsp", "clangd", "cssls", "eslint", "fortls",
  "groovyls", "intelephense", "jdtls", "jsonls", "lua_ls", "phpactor",
  "solargraph", "sourcery", "sqlls", "superhtml", "svelte", "tailwindcss",
  "taplo", "ts_ls", "ts_query_ls", "tvm_ffi_navigator", "unocss", "vimls",
  "visualforce_ls", "vuels", "yamlls", "rust_analyzer"
}

------------------------------------
-- 1. Import libraries
local cmp = require('cmp')
local luasnip = require('luasnip')

-- 2. Setup luasnip untuk snippet expansion
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- Expand snippet with luasnip
    end,
  },

  -- 3. Setup keymap saat di completion menu
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),              -- Open completion menu
    ['<CR>'] = cmp.mapping.confirm({ select = true }),    -- Confirm selection
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item() -- Move to next item
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump() -- Expand snippet if possible
      else
        fallback() -- Fallback if no match
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item() -- Move to previous item
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1) -- Jump back in snippet
      else
        fallback() -- Fallback if no match
      end
    end,
  }),

  -- 4. Define sources untuk completion
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },   -- LSP suggestions
    { name = 'luasnip' },    -- luasnip suggestions
    { name = 'buffer' },     -- Text from buffer
    { name = 'path' },       -- Path/filesystem
    { name = 'nvim_lua' },   -- Lua API support
    { name = 'calc' },       -- Math calculations
    { name = 'treesitter' }, -- Advanced AST parsing
    { name = 'spell' },      -- Spell checker
  }),

  -- ** Removed the formatting section for symbols **
})

-- 5. Setup capabilities untuk LSP supaya support completion + snippet
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- 6. Diagnostic setting (global)
vim.diagnostic.config({
  underline = true,
  virtual_text = {
    spacing = 4,
    prefix = "●",
  },
  signs = true,
  update_in_insert = true,
  severity_sort = true,
})

-- 7. Default LSP config
local default_lsp_config = {
  on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true }
    local keymap = vim.api.nvim_buf_set_keymap

    keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
    keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.lsp.buf.format { async = true }<CR>", opts)

    -- Highlight current symbol
    if client.server_capabilities.documentHighlightProvider then
      vim.cmd([[
        augroup lsp_document_highlight
          autocmd! * <buffer>
          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
      ]])
    end

    -- Auto-format on save
    if client.server_capabilities.documentFormattingProvider then
      vim.cmd([[
        augroup lsp_auto_format
          autocmd! * <buffer>
          autocmd BufWritePre <buffer> lua vim.lsp.buf.format { async = true }
        augroup END
      ]])
    end
  end,

  on_init = function(client)
    print("🌐 LSP Initialized: " .. client.name)
  end,

  capabilities = capabilities,

  flags = {
    debounce_text_changes = 1000,
  },
}

-- Setup all LSPs
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup(vim.tbl_deep_extend("force", {}, default_lsp_config))
end

----------------assembly---------------------

lspconfig.asm_lsp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  on_init = on_init,
  cmd = { "asm-lsp" },
  filetypes = { "asm", "s", "S" },
  root_dir = lspconfig.util.root_pattern("Makefile", ".git", "boot", "kernel", "linker.ld"),
  settings = {
    asm = {
      architecture = "x86_64",
      mode = "linux",
      diagnostics = {
        enabled = true,
        warnOnUnusedLabels = true,
        warnOnUndefinedSymbols = true,
        warnOnDeprecatedInstructions = true,
        warnOnUnalignedAccess = true,
        warnOnInvalidOpcode = true,
        showErrorCodes = true,
        showHints = true,
      },
      formatting = {
        enable = true,
        indentStyle = "space",
        indentSize = 2,
        trimTrailingWhitespace = true,
        formatOnSave = true,
        tabWidth = 2,
        alignLabels = true,
        alignComments = true,
      },
      linting = {
        enable = true,
        checkSyntaxOnly = false,
        styleRules = {
          enforceUppercaseOpcodes = true,
          requireCommentForSections = true,
        },
      },
      analysis = {
        enable = true,
        constantFolding = true,
        deadCodeDetection = true,
        unreachableCode = true,
        macroExpansion = true,
      },
      navigation = {
        goToDefinition = true,
        goToInclude = true,
        symbolOutline = true,
        showParameterHints = true,
      },
      hover = {
        showInstructionDocs = true,
        showRegisterInfo = true,
        showDirectivesHelp = true,
        showSyscallInfo = true, -- ⬅️ Tambahan untuk OS dev
      },
      completion = {
        enable = true,
        suggestLabels = true,
        suggestRegisters = true,
        suggestMnemonics = true,
        suggestMacros = true,
        suggestSyscalls = true, -- ⬅️ Tambahan: syscall autocomplete
        suggestInterrupts = true, -- ⬅️ Tambahan: INT/BIOS/UEFI
        libraryPaths = {
          "/usr/include", -- libc headers
          "/usr/include/sys", -- syscall headers
          "/usr/local/include",
          "/path/to/your/os/lib/include", -- ⬅️ Tambahkan custom OS lib
        },
      },
      advanced = {
        highlightDirectives = true,
        highlightMacros = true,
        showInstructionHints = true,
        symbolIndexing = true,
        symbolRenaming = true,
      },
      experimental = {
        disassemblerIntegration = false,
        emulateInstructions = false
      }
    }
  }
}


----------------------------------------------------------
-------------------------jdtls----------------------------------

-- jdtls configuration (Java LSP)
require'lspconfig'.jdtls.setup{
  -- On attach function to define key mappings and settings for the buffer
  on_attach = function(client, bufnr)
    -- Enable hover functionality
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
    -- Keymap for completion
    vim.api.nvim_buf_set_keymap(bufnr, 'i', '<C-Space>', '<Cmd>lua vim.lsp.buf.completion()<CR>', { noremap = true, silent = true })
  end,

  -- Capabilities to enable auto-completion and hover
  capabilities = vim.lsp.protocol.make_client_capabilities(),

  settings = {
    java = {
      -- Enable auto-completion
      completion = {
        enabled = true,
        suggestions = {
          enabled = true,
          showDetailed = true, -- Show detailed suggestions
        },
      },

      -- Enable signature help
      signatureHelp = {
        enabled = true,
        showSignatures = true, -- Show function signatures
      },

      -- Formatting settings
      format = {
        settings = {
          profile = "Eclipse",  -- Can use "Eclipse" or "Sun" profile
          options = {
            tabSize = 2,
            insertSpaces = true,
            endOfLine = "lf",
            insertFinalNewline = true,
            trimTrailingWhitespace = true,
            trimFinalNewlines = true,
          },
        },
      },

      -- Enable diagnostics and code actions
      diagnostics = {
        enable = true,
        runOnSave = true,
        showCodeActions = true,
      },

      -- Build settings
      build = {
        autoBuild = true,
        buildOnSave = true,
      },

      -- Code actions for organizing imports and other fixes
      codeAction = {
        organizeImports = true,
        enable = true,
        showImplicit = true,
      },

      -- JDK setup
      jdk = {
        home = "/usr/lib/jvm/java-24-openjdk/",
      },

      -- Maven settings for downloading sources and Javadoc
      maven = {
        downloadSources = true,
        downloadJavadoc = true,
        offline = true,
      },

      -- Google Java format integration
      googleJavaFormat = {
        enabled = true,
      },

      -- Enable Java test features
      javaTest = {
        enabled = true,
      },

      -- Debug adapter settings
      javaDebugAdapter = {
        enabled = true,
        port = 1998,
      },

      -- Interactive code assistance
      interactiveCodeAssist = {
        enabled = true,
        showInlineHints = true,
      },

      -- Enable web development (Spring Boot, front-end support)
      webDevelopment = {
        enabled = true,
        frameworks = {
          springBoot = true,
        },
        frontEnd = {
          html = { enabled = true },
          css = { enabled = true, supportSCSS = true },
          javascript = { enabled = true },
        },
      },

      -- Snippets configuration for Java classes, methods, etc.
      snippets = {
        class = "public class ${1:ClassName} {\n    public static void main(String[] args) {\n        ${2:// body}\n    }\n}",
        method = "public ${1:void} ${2:methodName}(${3}) {\n    ${4:// body}\n}",
        constructor = "public ${1:ClassName}(${2}) {\n    ${3:// body}\n}",
        interface = "public interface ${1:InterfaceName} {\n    ${2:// body}\n}",
      },

      -- Enable or disable various Java features
      enableJavaFeatures = true,
    },
  },
}






-----------------------------------------------------------
------------------gradle_ls.setup------------------

-- lspconfig.gradle_ls.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
--   on_init = on_init,
--   settings = {
--     gradle = {
--       jvmArguments = {
--         "-Xmx1g",
--         "-Xms256m",
--         "-XX:+UseParallelGC",
--         "-XX:GCTimeRatio=4",
--         "-XX:AdaptiveSizePolicyWeight=90",
--         "-Dsun.zip.disableMemoryMapping=true",
--         "-Djava.ext.dirs=workspaceFolder/lib",
--         "-Dfile.encoding=UTF-8",
--         "-Duser.language=en",
--         "-Duser.country=US",
--         "-Djava.awt.headless=true",
--       },
--       arguments = {
--         "--no-build-cache",
--         "--no-configuration-cache",
--         "--no-daemon",
--         "--parallel",  -- Mengaktifkan build paralel untuk proyek besar
--       },
--       isAndroidSupported = true,
--       isWorkspaceCacheEnabled = true,
--       isBuildCacheEnabled = true,
--       isIncrementalAnalysisSupported = true,
--       isJavaSupported = true,
--       isKotlinSupported = true,
--       isGroovySupported = true,
--       isScalaSupported = true,
--       isGolangSupported = true,
--       isNimSupported = true,
--       isRubySupported = true,
--       isSwiftSupported = true,
--       isPhpSupported = true,
--       isObjectiveCSupported = true,
--       projects = {
--         paths = {
--           "build.gradle",
--           "settings.gradle",
--         },
--       },
--       repositories = {
--         mavenCentral = true,
--         jcenter = true,
--         customRepos = {
--           "https://repo.maven.apache.org/maven2",
--           "https://jcenter.bintray.com",
--           "https://jitpack.io",
--           "https://repo1.maven.org/maven2",
--           "https://oss.sonatype.org/content/repositories/snapshots",
--           "https://oss.sonatype.org/content/repositories/releases",
--           "https://maven.pkg.github.com/navikt/fp-felles",
--           "https://maven.pkg.github.com/navikt/fp-felles-test",
--           "https://maven.pkg.github.com/navikt/fp-felles-schema",
--           "https://maven.pkg.github.com/navikt/fp-biblioteker",
--           "https://maven.pkg.github.com/navikt/fp-kontrakter",
--         },
--       },
--       dependencies = {
--         additionalDependencies = {
--           "org.springframework.boot:spring-boot-starter-web:2.4.0",
--           "com.fasterxml.jackson.core:jackson-databind:2.12.0",
--           "org.apache.commons:commons-lang3:3.12.0",  -- Dependensi tambahan untuk utilitas umum
--           "org.junit.jupiter:junit-jupiter-api:5.7.0",  -- Dependensi untuk unit testing (https://junit.org/junit5/)
--           "org.mockito:mockito-core:3.7.0",  -- Dependensi untuk unit testing (https://site.mockito.org/)
--           "org.mockito:mockito-junit-jupiter:3.7.0",  -- Dependensi untuk unit testing (https://site.mockito.org/)
--           "org.junit.jupiter:junit-jupiter-api:5.7.0",  -- Dependensi untuk unit testing
--           "org.mockito:mockito-core:3.7.0",  -- Dependensi untuk unit testing
--           "org.mockito:mockito-junit-jupiter:3.7.0",  -- Dependensi untuk unit testing
--           "org.mockito:mockito-inline:3.7.0",  -- Dependensi untuk unit testing
--           "org.assertj:assertj-core:3.19.0",  -- Dependensi untuk unit testing
--           "org.hamcrest:hamcrest:2.2",  -- Dependensi untuk unit testing
--           "org.junit.jupiter:junit-jupiter-engine:5.7.0",  -- Dependensi untuk unit testing
--           "org.junit.platform:junit-platform-launcher:1.7.0",  -- Dependensi untuk unit testing
--           "org.junit.platform:junit-platform-commons:1.7.0",  -- Dependensi untuk unit testing
--         },
--       },
--       gradleWrapper = {
--         path = "./gradlew",  -- Menentukan path ke gradle wrapper
--       },
--       multiModule = {
--         enabled = true,
--         rootProjectName = "emelyn",  -- Nama proyek root
--         moduleDirectories = {
--           "modules",  -- Menentukan direktori modul untuk proyek multi-modul
--           "src/main/java/com/emelyn/app",  -- Menentukan direktori modul untuk proyek multi-modul
--           "src/main/java/com/emelyn/app/controller",  -- Menentukan direktori modul untuk proyek multi-modul
--           "src/main/java/com/emelyn/app/service",  -- Menentukan direktori modul untuk proyek multi-modul
--           "src/main/java/com/emelyn/app/repository",  -- Menentukan direktori modul untuk proyek multi-modul
--           "src/main/java/com/emelyn/app/dto",  -- Menentukan direktori modul untuk proyek multi-modul
--           "src/main/java/com/emelyn/app/exception",  -- Menentukan direktori modul untuk proyek multi-modul
--         },
--       },
--       buildTasks = {
--         compileJava = "build/classes",  -- Output dari kompilasi Java
--         runTests = "test",  -- Task untuk menjalankan unit test
--       },
--       taskConfiguration = {
--         customTask = {
--           name = "deploy",
--           arguments = {"--deployTo=prod", "--no-cache"},  -- Menentukan argument untuk task kustom
--         },
--       },
--       logging = {
--         level = "info",  -- Pilihan: "debug", "info", "warn", "error"
--         file = "./build/logs/gradle.log",  -- Lokasi file log untuk debugging build
--       },
--       output = {
--         redirectToFile = true,  -- Redirect output build ke file log
--         outputPath = "./build/output",  -- Menentukan path untuk output build
--       },
--       advancedSettings = {
--         gradleDaemon = true,  -- Mengaktifkan daemon untuk meningkatkan performa
--         parallelExecution = true,  -- Menjalankan eksekusi build secara paralel
--         continueOnFailure = false,  -- Menentukan apakah build harus dilanjutkan meskipun ada kegagalan
--         showStacktraces = true,  -- Menampilkan stacktraces ketika ada kegagalan
--         showFailedTasks = true,  -- Menampilkan task yang gagal
--         showStandardStreams = true,  -- Menampilkan output standar
--         showPassed = true,  -- Menampilkan output build yang berhasil
--       },
--     },
--   },
-- })
--
--
-- lspconfig.dockerls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   on_init = on_init,
--   settings = {
--     docker = {
--       diagnostics = {
--         -- Menampilkan peringatan, error, dan petunjuk untuk file Docker
--         showWarnings = true,
--         showError = true,
--         showHints = true,
--         showErrorCodes = true,
--         -- Mengabaikan file-file tertentu saat memeriksa Dockerfile
--         ignoreFiles = {
--           "Dockerfile",
--           "docker-compose.yml",
--           "docker-compose.yaml",
--           "Dockerfile.dev",
--         },
--       },
--       -- Menambahkan pengaturan format otomatis
--       formatting = {
--         enable = true,  -- Mengaktifkan auto-formatting
--         -- Menentukan default formatter untuk Dockerfile
--         defaultFormatter = "dockerfile-language-server",
--         -- Menambahkan aturan format khusus
--         formatOnSave = true, -- Mengaktifkan format otomatis saat file disimpan
--         trimTrailingWhitespace = true, -- Menghapus spasi kosong di akhir baris
--       },
--       -- Menambahkan linting untuk Dockerfile
--       linting = {
--         enable = true,  -- Mengaktifkan linting
--         rules = {
--           deprecated = true,  -- Peringatan jika menggunakan fitur deprecated
--           unoptimized = true, -- Peringatan jika Dockerfile tidak dioptimalkan
--           missingArgs = true, -- Peringatan jika ada argumen yang hilang
--           unnecessarySteps = true, -- Menunjukkan langkah yang tidak diperlukan dalam Dockerfile
--         },
--       },
--       -- Menambahkan pengaturan untuk Docker Compose
--       compose = {
--         enable = true, -- Mengaktifkan pengenalan file docker-compose
--         validation = {
--           enable = true, -- Mengaktifkan validasi sintaks docker-compose.yml
--           showWarnings = true, -- Menampilkan peringatan saat validasi
--         },
--         linting = {
--           enable = true, -- Mengaktifkan linting untuk file docker-compose
--           rules = {
--             unusedServices = true, -- Peringatan jika ada layanan yang tidak digunakan
--             versionMismatch = true, -- Peringatan jika versi docker-compose tidak cocok
--           },
--         },
--       },
--       -- Menambahkan pengaturan untuk mempermudah navigasi Dockerfile
--       navigation = {
--         enable = true,  -- Mengaktifkan navigasi antar bagian Dockerfile
--         goToDefinition = true,  -- Navigasi ke definisi instruksi
--         showParameterHints = true, -- Menampilkan petunjuk parameter untuk instruksi Dockerfile
--       },
--       -- Pengaturan untuk penanganan image dan container
--       containerManagement = {
--         enable = true, -- Mengaktifkan pengelolaan container
--         autoStart = true, -- Mengaktifkan pemulihan dan start otomatis container saat dibutuhkan
--         autoStop = true,  -- Menghentikan container secara otomatis saat tidak digunakan
--       },
--     },
--   },
-- }

--------------------------sqlls lspconfig------------------------------------------
require'lspconfig'.sqls.setup{
  cmd = { "sqls" },
  filetypes = { "sql" },
  root_dir = require'lspconfig'.util.root_pattern(".git", "sqls.yml", "*.sql"),
  settings = {
    sqls = {
      connections = {
        {
          driver = "mysql",
          datasource = "viona:god@tcp(localhost:3306)/daily_routine",  -- Make sure to replace with actual credentials
        },
      },  -- <-- Closing brace for connections
      max_line_length = 120,
      use_single_quote = true,
      enable_diagnostics = true,
      enable_formatting = true,
      auto_format = true,
      show_table_info = true,

      completion = {
        usePlaceholders = true,
        keywordSnippet = "Both",
        caseSensitive = false,
      },

      hover = {
        documentation = true,
        show_column_type = true,
        show_table_comment = true,
        show_column_comment = true,
      },

      linting = {
        enable = true,
        strict_mode = true,
        rules = {
          syntax_error = true,
          unused_column = true,
          unquoted_identifier = true,
          column_length = 100,
          table_case = "upper",
        },
      },

      diagnostics = {
        level = "warning",
        enable = true,
        globals = { "vim" },
        severity = {
          unused_local = "warn",
          undefined_global = "error",
          undefined_method = "info",
          undefined_field = "info",
        },
      },

      formatting = {
        align_keywords = true,
        indent_keywords = true,
        keyword_case = "upper",
        max_column_width = 120,
        enable = true,
        trim_trailing_whitespace = true,
        insert_space_after_comma = true,
        insert_space_after_functioncall = true,
        insert_space_after_semicolon = true,
        insert_space_before_functionparenthesis = true,
        insert_space_before_comma = true,
        insert_space_before_semicolon = true,
        capitalize_keywords = true,
        break_on_multiline = true,
      },

      enable_advanced_sql_features = true,
      auto_correction = true,

      schema_introspection = {
        enable = true,
        show_table_info = true,
        show_column_info = true,
        show_index_info = true,
        cache_schema = true,
        load_on_startup = true,
      },

      experimentalFeatures = {
        enable = true,
        mysql = {
          enable = true,
          experimental = true,
          dialect = "mysql",
          connection = "MySQL-Connection",
          schema = "information_schema",
          table = "tables",
          column = "columns",
          index = "indexes",
          foreign_key = "foreign_keys",
          primary_key = "primary_key",
          unique_key = "unique_keys",
          show_schemas = true,
          show_tables = true,
          show_columns = true,
          show_indexes = true,
          show_foreign_keys = true,
          show_primary_keys = true,
          show_unique_keys = true,
        },
      },

      snippets = {
        enable = true,
        snippets = {
          create_database = "CREATE DATABASE ${1:database_name};",
          create_table = [[
CREATE TABLE ${1:table_name} (
  ${2:column_name} ${3:data_type},
  PRIMARY KEY (${4:primary_key})
);]],
          insert_into = "INSERT INTO ${1:table_name} (${2:column_names}) VALUES (${3:values});",
          alter_table = "ALTER TABLE ${1:table_name} ADD COLUMN ${2:column_name} ${3:data_type};",
          drop_database = "DROP DATABASE ${1:database_name};",
          drop_table = "DROP TABLE ${1:table_name};",
          drop_column = "ALTER TABLE ${1:table_name} DROP COLUMN ${2:column_name};",

          select_query = "SELECT ${1:*} FROM ${2:table} WHERE ${3:condition};",
          update_query = "UPDATE ${1:table} SET ${2:column} = ${3:value} WHERE ${4:condition};",
          delete_query = "DELETE FROM ${1:table} WHERE ${2:condition};",

          join_query = [[
SELECT ${1:*} FROM ${2:table1}
JOIN ${3:table2} ON ${4:table1}.${5:column} = ${6:table2}.${7:column};]],

          subquery = [[
SELECT ${1:*} FROM (
  SELECT ${2:*} FROM ${3:table} WHERE ${4:condition}
) AS ${5:sub};]],
        },
      },
    },
  },
}



-----------------------------latext----------------------------------
lspconfig.texlab.setup {
  on_attach = on_attach,  -- Fungsi on_attach Anda
  capabilities = capabilities,  -- Kemampuan LSP Anda
  on_init = on_init,  -- Fungsi on_init Anda
  settings = {
    texlab = {
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "%f" },
        onSave = true,  -- Auto build saat menyimpan
      },
      forwardSearch = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:1:%f", "%p" },
      },
      lint = {
        onSave = true,  -- Lakukan lint saat menyimpan
      },
      bibtex = {
        executable = "bibtex",
        args = { "%f" },
      },
      viewer = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:1:%f", "%p" },
      },
      diagnosticsDelay = 300,
      chktex = {
        onOpenAndSave = true,
        onEdit = true,
      },
      latexFormatter = "latexindent",
      latexindent = {
        modifyLineBreaks = true
      },
      auxDirectory = ".aux",
      outputDirectory = ".out",
      rootDirectory = ".",
      logLevel = "info",
      experimental = {
        formatterLineLength = 100,
        mathEnvironments = { "equation*", "align*", "multline*" },
      },
    },
  },
  flags = {
    debounce_text_changes = 150,
    format_on_save = {
      enabled = true,
      filter = function(client)
        return client.name == "texlab"
      end,
    },
  }
,
  commands = {
    TexlabBuild = {
      function()
      end,
      description = "Build the current LaTeX file using texlab"
    },
    TexlabForward = {
      function()
      end,
      description = "Forward search using texlab"
    },
  },
}
---










lspconfig.sourcery.setup {
  on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap=true, silent=true }

    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '[d', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)

    if client.server_capabilities.documentFormattingProvider then
      vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ async = true })]]
    end
  end,

  on_init = function(client)
    print("✅ Sourcery Ready!")
  end,

  capabilities = vim.lsp.protocol.make_client_capabilities(),

  settings = {
    sourcery = {
      lsp = {
        enabled = true,
        builtin = true,
        telemetry = {
          enabled = true,
          usageStats = true,
          performanceMetrics = true,
          errorReports = true,
          featureUsage = true,
        },
        interactive = true,
        explainCode = true,
        suggestCode = true,
        suggestLibraries = true,
        explainLibraries = true,
        codeInsights = true,
        documentationOnHover = true,
        autoFixIssues = true,
        semanticTokens = true,
        symbolSupport = true,
        hover = true,
        completion = true,
        codeActions = true,
        signatureHelp = true,
        documentSymbols = true,
        foldingRange = true,
        documentHighlight = true,
        references = true,
        rename = true,
        inlayHints = true,
      },
      python = {
        analysis = {
          typeCheckingMode = "strict",
          autoImportCompletions = true,
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
          extraPaths = { "./", "./src", "./venv/lib/python3.*/site-packages" },
        },
      },

      documentation = {
        showLibraryDocs = true,
        fetchExamples = true,
        explainFunctions = true,
        showSourceLink = true,
        showCode = true,
        showRelatedSnippets = true, -- Tambahan: contoh-contoh kode lain
      },

      linting = {
        enabled = true,
        pylintEnabled = true,
        flake8Enabled = true,
        mypyEnabled = true,
        banditEnabled = true,
        maxLineLength = 120,
      },

      formatting = {
        provider = "black",
        blackPath = "black",
        autoFormatOnSave = true,
      },

      refactor = {
        extractMethod = true,
        extractVariable = true,
        organizeImports = true,
        inlineVariable = true,
        renameSymbol = true,
        smartRefactorAI = true, -- Tambahan AI Refactoring
      },

      docStringGeneration = true,
      explain = true,

      importResolver = {
        autoFixMissing = true,
        autoOrganize = true,
      },

      codeQuality = {
        suggestImprovements = true,
        analyzeComplexity = true,
        detectDeadCode = true,
        detectInefficientPatterns = true,
        inlineCommentsAI = true,
        maxLineLength = 120,
        maxMethodLength = 120,
        maxParameterListLength = 120,
        maxParameters = 120,
      },

      productivity = {
        taskTracking = true,
        focusMode = true,
        todoHighlight = true,
        deadlineReminder = true,
      },

      personalization = {
        preferredLanguage = "id", -- jika ingin pakai bahasa Indonesia
        tone = "friendly", -- gaya output AI
      },

      learningAssistant = {
        enableMentorMode = true,
        highlightConcepts = true,
        autoSuggestDocs = true,
        challengeSuggestions = true,
        interactiveQuizzes = true,
        explainErrors = true,
        stepByStepGuides = true,
        adaptiveLearningPath = true,

      },
    },
  },



      productivity = {
        taskTracking = true,
        focusMode = true,
        todoHighlight = true,
        deadlineReminder = true,
        smartNotifications = true,
        flowMode = true,
      },

      personalization = {
        preferredLanguage = "id",
        tone = "friendly",
        interfaceTheme = "dark",
        voiceAssistant = true,
        accessibilitySupport = true,
      },

      writingAssistant = {
        grammarSuggestions = true,
        toneAnalysis = true,
        rewriteSuggestions = true,
        plagiarismCheck = true,
        generateHeadings = true,
        summarizeText = true,
        expandSentences = true,
      },

  hooks = {
    before_command = function(command)
      print("🚀 Executing Maven command:", command)
    end,
    after_command = function(command, result)
      print("✅ Maven command completed:", command, "Result:", result)
    end,
  },

  init_options = {
    token = "user_ecGzCpURooNJ3xepwNw87emgaBjDCHkufVUU6DebSqKva8p7Xk9Mnpzc2m4",
  },
}



lspconfig.superhtml.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  on_init = on_init,
  settings = {
    html = {
      validate = {
        enable = true,
        scripts = true,
        styles = true,
        autoFix = true,
        validateElementClose = true,
        validateElementName = true,
        validateIndentation = true,
        validateSelfClosing = true,
        validateTagName = true,
        warnAboutInvalidHTML = true,
      },
      format = {
        enable = true,
        wrapLineLength = 120,
        unformatted = { "pre", "code" },
        defaultFormatter = "markuplint", -- Diganti ke Markuplint
        style = { ["markuplint/markuplint"] = true },
        script = { ["markuplint/markuplint"] = true },
        css = { ["markuplint/markuplint"] = true },
        inlineStyle = { ["markuplint/markuplint"] = true },
        inlineScript = { ["markuplint/markuplint"] = true },
      },
      suggest = {
        html5 = true,
        style = true,
        tag = true,
        css = true,
        script = true,
        json = true,
        yaml = true,
        markdown = true,
        sql = true,
        typescript = true,
        vue = true,
        attribute = true,
        event = true,
        semantic = true,
        jsonSchema = true,
        xml = true,
      },
      lint = {
        validate = true,
        maxLineLength = 80,
        htmlhint = { -- Integrasi HTMLHint untuk linting
          enable = true,
          config = {
            ["attr-value-double-quotes"] = true,
            ["tag-pair"] = true,
            ["id-unique"] = true,
            ["attr-lowercase"] = true,
            ["doctype-first"] = true,
          },
        },
      },
      completion = {
        enable = true,
        autoInsert = true,
        suggest = true,
        snippetSupport = true,
        matchOnInsert = true,
        autoTrigger = true,
        detailed = true,
        triggerCharacters = { "<", "/", ":", "." },
        autoCloseTags = { -- Fitur Auto-close Tags
          enable = true,
        },
      },
      css = {
        validate = true,
        lint = true,
        format = {
          enable = true,
          defaultFormatter = "prettier",
        },
      },
      javascript = {
        validate = true,
        format = {
          enable = true,
          defaultFormatter = "prettier",
        },
      },
      vue = {
        validate = true,
        format = {
          enable = true,
          defaultFormatter = "prettier",
        },
      },
      snippets = { -- Menambahkan Snippets HTML Bawaan
        enable = true,
        builtInSnippets = true,
        customSnippets = {
          ["html5-template"] = "<!DOCTYPE html>\n<html>\n<head>\n<title>${1:Document}</title>\n</head>\n<body>\n${2}\n</body>\n</html>",
        },
      },
      tailwindCSS = { -- Integrasi TailwindCSS IntelliSense
        validate = true,
        format = true,
        completion = true,
        lint = true,
      },
      semanticHighlighting = { -- Semantic Highlighting
        enable = true,
      },
      debug = {
        enable = true,
        logLevel = "debug",
        traceResponse = true,
        runInFile = true,
        runInTerminal = true,
        console = "integratedTerminal",
        source = "always",
        adapter = "test-adapter",
        internalConsoleOptions = "neverOpen",
        debuggerType = "integrated",
        traceServer = "verbose",
        workspaceFolder = true,
        traceFiles = {
          enable = true,
          level = "verbose",
        },
        integratedTerminal = {
          enable = true,
          startInBackground = true,
        },
      },
      api = {
        documentation = {
          enable = true,
          triggerOnHover = true,
        },
        mapping = {
          enable = true,
          trigger = "ctrl-space",
        },
      },
    },
  },
}



-- lspconfig.ruff.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   on_init = on_init,
--   settings = {
--     python = {
--       analysis = {
--         diagnosticMode = "workspace",
--         autoSearchPaths = true,
--         useLibraryCodeForTypes = true,
--         typeCheckingMode = "strict",
--         importStrategy = "fromEnvironment",
--         importFormat = "relative",
--         reportMissingImports = true,
--         reportUnusedImport = true,
--         reportUnusedClass = true,
--         reportUnusedFunction = true,
--         reportUnusedVariable = true,
--         runtimeTypeChecking = true,
--         stubPath = "./stubs",
--         reportGeneralTypeIssues = true,
--         reportUnusedSelf = true,
--         reportUnusedFunctionArgs = true,
--         reportUnusedLoopVars = true,
--         reportUnusedLocals = true,
--         reportUnusedAssignments = true,
--         reportUnusedFunctionResults = true,
--       },
--       linting = {
--         enabled = true,
--         rules = {
--           ["no-assert"] = "off",
--           ["unused-imports"] = "off",
--           ["too-many-locals"] = "off",
--           ["complexity"] = "off",
--           ["inconsistent-return-statements"] = "on",
--           ["no-self-argument"] = "on",
--           ["no-dupe-args"] = "on",
--         },
--         select = {
--           "ALL", -- Aktifkan semua ruleset dari Ruff
--         },
--         ignore = {
--           "C901", -- Ignore complexity warning
--         },
--         extendSelect = {
--           "I",   -- isort rules (import sorting)
--           "F",   -- pyflakes rules
--           "E",   -- pycodestyle errors
--           "W",   -- pycodestyle warnings
--           "D",   -- pydocstyle (docstring rules)
--           "B",   -- flake8-bugbear
--           "PL",  -- pylint-style checks
--           "PT",  -- flake8-pytest-style
--           "NPY", -- numpy specific
--           "PD",  -- pandas specific
--         },
--         fixAll = true, -- Aktifkan auto-fix jika memungkinkan
--       },
--       formatting = {
--         enabled = true,
--         provider = "black",
--         lineLength = 120,
--         allowMultipleLines = true,
--         singleQuote = true,
--       },
--       workspace = {
--         maxPreload = 2000,
--         preloadModules = true,
--         extraPaths = {
--           "./src",
--           "./lib",
--           "./tests",
--         },
--       },
--
--       pythonPath = "/usr/bin/python3.13",
--       targetVersion = "py313",
--
--     },
--     lua = {
--       runtime = {
--         version = "LuaJIT",
--         path = vim.split(package.path, ";"),
--       },
--       diagnostics = {
--         globals = { "vim" },
--       },
--       workspace = {
--         library = vim.api.nvim_get_runtime_file("", true),
--       },
--     },
--   },
--   flags = {
--     debounce_text_changes = 150,
--   },
--   filetypes = { "python", "jupyter", "ipynb" },
-- }
--


----------------------------------------------------------------------------



--phpactor

lspconfig.phpactor.setup {
  on_attach = function(client, bufnr)
    -- Fungsi untuk mengatur keymap untuk buffer
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap = true, silent = true }

    -- Keymaps dasar untuk navigasi dan aksi umum
    buf_set_keymap('n', '<leader>rn', '<cmd>lua require("lspsaga.rename").rename()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua require("lspsaga.codeaction").code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua require("lspsaga.rename").rename()<CR>', opts)
    buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua require("lspsaga.codeaction").code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua require("lspsaga.rename").rename()<CR>', opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

    -- Keymaps untuk database
    buf_set_keymap('n', '<leader>db', '<cmd>lua require("phpactor").query_database()<CR>', opts) -- Query database langsung
    buf_set_keymap('n', '<leader>ds', '<cmd>lua require("phpactor").show_schema()<CR>', opts) -- Tampilkan skema DB
    buf_set_keymap('n', '<leader>di', '<cmd>lua require("phpactor").inspect_schema()<CR>', opts) -- Inspeksi skema DB

    -- Keymaps untuk pengujian (Testing Framework)
    buf_set_keymap('n', '<leader>tt', '<cmd>lua require("phpactor").run_tests()<CR>', opts)  -- Jalankan unit test
    buf_set_keymap('n', '<leader>tf', '<cmd>lua require("phpactor").run_feature_tests()<CR>', opts) -- Jalankan feature test

    -- Keymaps untuk refactoring lanjutan
    buf_set_keymap('n', '<leader>refactor', '<cmd>lua require("phpactor").refactor()<CR>', opts)  -- Refactor kode PHP
    buf_set_keymap('n', '<leader>ext', '<cmd>lua require("phpactor").extract_method()<CR>', opts)  -- Ekstrak metode dari fungsi

    -- Keymaps untuk navigasi kode
    buf_set_keymap('n', '<leader>go', '<cmd>lua vim.lsp.buf.references()<CR>', opts)  -- Go to references
    buf_set_keymap('n', '<leader>ld', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)  -- List Document Symbols
    buf_set_keymap('n', '<leader>ws', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)  -- List Workspace Symbols

    -- Keymaps untuk aksi umum
    buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)  -- Format file
    buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)  -- Deklarasi
    buf_set_keymap('n', '<leader>ca', '<cmd>lua require("lspsaga.codeaction").code_action()<CR>', opts)  -- Code Action
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)  -- Buka diagnosa
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)  -- Pindah ke diagnosa sebelumnya
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)  -- Pindah ke diagnosa berikutnya
    buf_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)  -- Lihat diagnosa dalam list

    -- Keymaps untuk workspace
    buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)  -- Tambah folder workspace
    buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)  -- Hapus folder workspace
    buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)  -- List folder workspace
  end,

  -- Pengaturan khusus untuk phpactor
  settings = {
    phpactor = {
      -- Aktifkan fitur completions
      completion = {
        enable = true,
        triggerCharacters = { '->', '::' },


      },
      -- Aktifkan diagnosa
      diagnostics = {
        enable = true,

      },
      -- Aktifkan refactoring
      refactor = {
        enable = true,
      },
      -- Aktifkan auto-formatting
      format = {
        enable = true,

      },
      -- Database integrasi
      database = {
        enable = true, -- Aktifkan query database
        connection = "mysql", -- Tentukan jenis database
      },
      -- Testing framework
      testing = {
        enable = true,
        frameworks = {"PHPUnit", "Behat", "Codeception"},  -- Framework pengujian yang didukung
      },
    },
  },

  -- Tentukan root proyek PHP berdasarkan folder atau file
  root_dir = require('lspconfig.util').root_pattern(
    'composer.json', -- Phpactor mendeteksi root proyek dengan adanya composer.json
    '.git'
  ),

  -- Tentukan kemampuan untuk meningkatkan pengalaman auto-completion
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
}


-- LSP for PHP, Web, and MySQL
lspconfig.intelephense.setup {
  on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap = true, silent = true }

    -- Keymaps dasar
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<leader>f', '<Cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)

    -- Auto-format on save
    if client.server_capabilities.documentFormattingProvider then
      vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ async = false })]]
    end

    -- Tampilkan diagnostics di hover
    vim.cmd [[
      autocmd CursorHold <buffer> lua vim.diagnostic.open_float(nil, { focusable = false })
    ]]

    -- Aktifkan perbaikan otomatis setelah save jika ESLint mendukungnya
    if client.server_capabilities.codeActionProvider then
      vim.cmd [[autocmd BufWritePre <buffer> EslintFixAll]]
    end
  end,

  on_init = function(client)
    print("Intelephense LSP initialized!")
  end,

  capabilities = require('cmp_nvim_lsp').default_capabilities(), -- Kompatibilitas dengan nvim-cmp

  settings = {
    intelephense = {
      filetypes = { "php", "html", "css", "javascript", "typescript", "json" },
      php = {
        validate = true,
        suggest = {
          basic = true,
          experimental = true,
          classes = true,
          functions = true,
          interfaces = true,
          traits = true,
          types = true,
        },
      },
      diagnostics = {
        enable = true,
        pecl = true,
        phpVersion = "8.3.15", -- Atur ke versi PHP yang sesuai
        globals = { 'all' },
        run = 'onType',
        diagnosticTypes = {
          Enable = {
            "Undefined variable",
            "Undefined index",
            "Undefined offset",
            "Undefined property",
            "Undefined class constant",
            "Undefined function",
            "Missing argument",
            "Missing property",
            "Missing class",
            "Missing file",
            "Invalid argument supplied",
            "Invalid array key",
            "Invalid character",
            "Invalid default argument",
            "Invalid function",
            "Invalid number format",
            "Invalid property assignment",
            "Invalid return type",
            "Invalid static method",
            "Invalid string offset",
            "Invalid type",
            "Is deprecated",
            "Method may expect argument",
            "No value",
            "Recursion",
            "Too few arguments",
            "Too many arguments",
            "Type error",
          },
      },
      completion = {
        enable = true,
        triggerCharacters = { "->", "::" },
      },
      format = {
        enable = true, -- Aktifkan auto-format untuk PHP
      },
      refactor = {
        enable = true, -- Aktifkan fitur refactoring
      },
      phpdoc = {
        enable = true, -- Aktifkan dokumentasi otomatis PHPDoc
      },
    },

    -- Pengaturan untuk Web Development
    html = {
      format = {
        enable = true,
        end_with_newline = true,
        indent_inner_html = true,
        indent_size = 2,
        indent_width = 2,
        preserve_newlines = true,
        wrap_attributes = "auto",
        wrap_attributes_indent_size = 2,
        wrap_attributes_indent_with_tabs = false,
      },
      suggestions = {
        enable = true,
        attribute_default = true,
        attribute_indent = true,
        attribute_quotes = true,
        case_sensitive = true,
        class_value = true,
        color_value = true,
        comment = true,
      },
    },
    css = {
      validate = true,
      lint = {
        "box-model",
        "color-hex-case",
        "indentation",
      },
    },

    javascript = {
      format = {
        enable = true,
      },
      lint = {
        "no-unused-vars",
        "eqeqeq",
        "semi",
      },
    },

    -- Webpack & Browser Debugging Integration
    webpack = {
      enable = true,  -- Aktifkan integrasi webpack
      webpackConfig = "./webpack.config.js",  -- Lokasi file konfigurasi webpack
    },
  },

  root_dir = require('lspconfig.util').root_pattern(
    '.eslintrc',
    '.eslintrc.json',
    '.eslintrc.js',
    '.eslintrc.yaml',
    '.eslintrc.yml',
    'package.json',
    'tsconfig.json',
    'jsconfig.json',
    'babel.config.js',
    '.babelrc',
    '.babelrc.json',
    '.babelrc.js',
    'composer.json', -- Tambahkan file konfigurasi PHP seperti composer.json
    '.git' -- Tentukan root direktori berbasis Git
  ),
}
}




lspconfig.cssls.setup {
  on_attach = function(client, bufnr)
    -- Fungsi untuk mengatur keymap untuk buffer
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap = true, silent = true }

    -- Keymaps dasar untuk navigasi dan aksi umum
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<leader>f', '<Cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)

    -- Auto-format on save jika server mendukung document formatting
    if client.server_capabilities.documentFormattingProvider then
      vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ async = false })]]
    end

    -- Menampilkan diagnostics di hover
    vim.cmd [[
      autocmd CursorHold <buffer> lua vim.diagnostic.open_float(nil, { focusable = false })
    ]]

    -- Tailwind CSS Autocompletion
    vim.cmd [[
      autocmd BufRead,BufNewFile *.html,*.css,*.scss,*.js lua require('cmp').setup.buffer { sources = { { name = 'nvim_lsp' }, { name = 'path' }, { name = 'buffer' }, { name = 'emoji' } } }
    ]]
  end,

  on_init = function(client)
    print("CSS LSP with Tailwind CSS and Sass initialized!")
  end,

  capabilities = require('cmp_nvim_lsp').default_capabilities(),  -- Integrasi dengan nvim-cmp untuk auto-completion

  settings = {
    css = {
      validate = true,  -- Aktifkan validasi untuk CSS
      lint = {
        'css', 'scss', 'less', 'sass'  -- Mendukung linting untuk berbagai format CSS
      },
      properties = true,  -- Dukungan untuk CSS Custom Properties
      color = true,  -- Untuk mendukung rekomendasi warna
      -- Menambahkan dukungan untuk CSS Grid, Flexbox dan lainnya
      grid = true,  -- Validasi dan saran terkait Grid CSS
      flexbox = true,  -- Validasi dan saran terkait Flexbox
    },

    scss = {
      validate = true,
      lint = true,
      -- Pengaturan tambahan untuk SCSS linting dan fungsionalitas
      includeLanguages = {
        scss = "scss",
        sass = "sass",
        less = "less",
        stylus = "stylus",
        postcss = "postcss",
        css = "css",
        html = "html",
        vue = "vue",
        javascript = "javascript",
        typescript = "typescript",
        svelte = "svelte",
        json = "json",
      },
      linting = {
        unknownAtRules = "ignore",  -- Mengabaikan aturan yang tidak dikenali
        unknownProperties = "ignore",  -- Mengabaikan properti yang tidak dikenali
        unknownMixins = "warning",  -- Memberikan peringatan jika mixin tidak dikenal
        unknownVariables = "warning",  -- Memberikan peringatan jika variabel tidak dikenal
      },
      -- Pengaturan untuk memeriksa kesalahan dalam deklarasi SCSS
      syntaxValidation = {
        invalidVariables = "error",  -- Menampilkan kesalahan untuk variabel yang tidak valid
        invalidMixins = "error",     -- Menampilkan kesalahan untuk mixins yang tidak valid
      },
    },  -- Validasi untuk SCSS
    sass = {
      validate = true,
      lint = true,
      linting = {
        unknownAtRules = "ignore",  -- Mengabaikan aturan yang tidak dikenali
        unknownProperties = "ignore",  -- Mengabaikan properti yang tidak dikenali
        unknownMixins = "warning",  -- Peringatan jika mixin tidak dikenal
        unknownVariables = "warning",  -- Peringatan jika variabel tidak dikenal
      },
      syntaxValidation = {
        invalidVariables = "error",  -- Menampilkan kesalahan untuk variabel yang tidak valid
        invalidMixins = "error",     -- Menampilkan kesalahan untuk mixins yang tidak valid
        invalidProperties = "error",  -- Menampilkan kesalahan untuk properti yang tidak valid
        invalidAtRules = "error",  -- Menampilkan kesalahan untuk at-rule yang tidak valid
        invalidValues = "error",  -- Menampilkan kesalahan untuk nilai yang tidak valid
        invalidImportStatement = "error",  -- Menampilkan kesalahan untuk statement import yang tidak valid

      },
    },  -- Validasi untuk SASS
    html = {
      validate = true,  -- Validasi untuk HTML yang menggunakan CSS
      tagCompletion = true,  -- Menambahkan saran tag otomatis di HTML
      lint = {
        unknownTags = "warning",  -- Memberikan peringatan jika ada tag yang tidak dikenal
        unknownAttributes = "warning",  -- Memberikan peringatan jika ada atribut yang tidak dikenal
        invalidAttributes = "warning",  -- Memberikan peringatan jika ada atribut yang tidak valid
      },
    },

    tailwindCSS = {
      validate = true,
      experimental = {
        classRegex = {
          'tw`([^`]*)`',      -- Menangani tailwind yang ditulis dalam backticks
          'tw="([^"]*)"',     -- Menangani tailwind yang ditulis dalam atribut
          'tw=([a-zA-Z0-9-]*)', -- Mendeteksi Tailwind class dalam atribut HTML
        },
      },
      linting = {
        unknownClasses = "warning",  -- Memberikan peringatan jika ada class Tailwind yang tidak dikenal
        unknownProperties = "warning",  -- Memberikan peringatan jika ada property CSS yang tidak dikenal
        invalidProperties = "warning",  -- Memberikan peringatan jika ada property CSS yang tidak valid
        unknownAtRules = "warning",  -- Memberikan peringatan jika ada at-rule yang tidak dikenal
        invalidAtRules = "warning",  -- Memberikan peringatan jika ada at-rule yang tidak valid
        unknownFontFamilies = "warning",  -- Memberikan peringatan jika ada font-family yang tidak dikenal
        duplicateFontFamilies = "warning",  -- Memberikan peringatan jika ada duplikat font-family
        duplicateProperties = "warning",  -- Memberikan peringatan jika ada duplikat property CSS
        emptyRules = "warning",  -- Memberikan peringatan jika ada rule kosong
        emptyAtRules = "warning",  -- Memberikan peringatan jika ada at-rule kosong
        importStatement = "warning",  -- Memberikan peringatan jika ada statement import yang tidak valid
        boxModel = "warning",  -- Memberikan peringatan jika ada box-model yang tidak valid
        universalSelector = "warning",  -- Memberikan peringatan jika ada selector universal yang tidak valid
      },
    },

    -- Mengaktifkan dukungan untuk CSS yang lebih modern
    modernCssFeatures = {
      grid = true,  -- Mendukung fitur grid CSS
      flexbox = true,  -- Mendukung fitur flexbox CSS
      customProperties = true,  -- Mendukung CSS custom properties (variabel)
      animations = true,  -- Menambahkan dukungan animasi CSS
      variables = true,  -- Mendukung CSS variables
      calc = true,  -- Mendukung CSS calc
      units = true,  -- Mendukung CSS units
      mediaQueries = true,  -- Mendukung CSS media queries
      colorFunctions = true,  -- Mendukung CSS color functions
      nesting = true,  -- Mendukung CSS nesting
      pseudoElements = true,  -- Mendukung CSS pseudo elements
      combinators = true,  -- Mendukung CSS combinators
      atRules = true,  -- Mendukung CSS at rules
      atDirectives = true,  -- Mendukung CSS at directives
      selectors = true,  -- Mendukung CSS selectors
      properties = true,  -- Mendukung CSS properties
      values = true,  -- Mendukung CSS values
      syntax = true,  -- Mendukung CSS syntax
      vendorPrefixes = true,  -- Mendukung CSS vendor prefixes
    },

    -- Optimasi untuk mendeteksi dan memperbaiki masalah umum CSS
    linting = {
      unknownAtRules = "ignore",  -- Mengabaikan aturan yang tidak dikenal
      unknownProperties = "ignore",  -- Mengabaikan properti yang tidak dikenali
      unknownFontFamilies = "ignore",  -- Mengabaikan font-family yang tidak dikenali
      duplicateFontFamilies = "ignore",  -- Mengabaikan duplikat font-family
      duplicateProperties = "ignore",  -- Mengabaikan duplikat properti CSS
      emptyRules = "ignore",  -- Mengabaikan rule kosong
      emptyAtRules = "ignore",  -- Mengabaikan at-rule kosong
      importStatement = "ignore",  -- Mengabaikan statement import yang tidak valid
      boxModel = "ignore",  -- Mengabaikan box-model yang tidak valid
      universalSelector = "ignore",  -- Mengabaikan selector universal yang tidak valid
    },
  },
}



-- lspconfig.ltex.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   on_init = on_init,
--   settings = {
--     ltex = {
--       language = "en",  -- Bahasa yang digunakan untuk pemeriksaan tata bahasa, bisa diganti dengan bahasa lain (misalnya: "de" untuk Jerman, "fr" untuk Perancis)
--       diagnosticSeverity = {
--         -- Menentukan tingkat keparahan diagnostic error
--         ["grammar"] = "warning",  -- "error", "warning", atau "information"
--         ["spelling"] = "warning",
--         ["punctuation"] = "warning",
--       },
--       dictionary = {
--         -- Kata-kata khusus yang Anda ingin ltex mengenali
--         ["en"] = { "companyName", "specificTerm" }, -- Menambahkan kata atau frasa tertentu ke dalam kamus
--       },
--       userDefinedRules = {
--         -- Menentukan aturan tata bahasa kustom
--         {
--           pattern = "eg.",  -- Pattern atau kata yang diinginkan untuk aturan kustom
--           message = "Consider replacing 'eg.' with 'for example'.",  -- Pesan jika ditemukan
--           action = "replace",  -- Tindakan: "replace", "suggest", atau "ignore"
--         }
--       },
--       completion = {
--         enabled = true,  -- Mengaktifkan fitur saran kata
--         timeout = 300,   -- Waktu tunggu dalam milidetik untuk saran
--       },
--       ltex_lsp = {
--         enableAutoSave = true,   -- Mengaktifkan penyimpanan otomatis
--         enableLinting = true,    -- Menyalakan pemeriksaan tata bahasa
--       }
--     },
--   },
-- }
--

-------------------------fotrans-lsp-settings---------------------------------------------

-- FortLS setup for advanced AI-based nuclear reactor simulation and rocket control in Fortran
local lspconfig = require('lspconfig')

lspconfig.fortls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  on_init = on_init,
  settings = {
    fortls = {
      nthreads = 4, -- Optimized threading for analysis
      suggest_use = true, -- Show usage suggestions
      hover_signature = true, -- Show function signatures
      auto_set_mod = true, -- Auto-modules support
      incremental_sync = true, -- Fast sync
      source_dirs = {"src", "include", "modules"},
      lower_case_intrinsics = true,
      use_signature_help = true,
      max_line_length = 120,
      debug_logging = false,
      enable_code_actions = true,
      provide_symbols = true,
      variable_hover = true,
      lint_on_change = true,
      exclude_dirs = {"build", ".git", ".vscode"},
    },
  },
  flags = {
    debounce_text_changes = 200,
  },
  -- Custom nuclear + rocket AI dev environment
  cmd = {"fortls",
    "--notify_init",
    "--sort_keywords",
    "--use_signature_help",
    "--hover_signature",
    "--enable_code_actions",
    "--symbol_section",
    "--include-symbols"
  },
}

-- Optional: Diagnostics & UI enhancements
vim.diagnostic.config({
  virtual_text = {
    prefix = '🔬',
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Autocommand: Run Fortran AI Simulation when saving
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.f90", "*.f95", "*.f03", "*.f08"},
  callback = function()
    vim.cmd("!gfortran % -o ai_sim && ./ai_sim")
  end,
})

-- Optional: Integration with plotting tools (Python bridge)
-- You can later trigger Python via Lua or command to render AI data
-- For example: vim.cmd("!python3 plot_data.py")

-- Status
print("✅ FortLS Ready!")

-----

------------------------------pyright lspconfig------------------------------------------
-- pyright
lspconfig.pylsp.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict", -- Mode pengecekan tipe yang ketat
        autoSearchPaths = true, -- Mendeteksi otomatis jalur file proyek
        diagnosticMode = "workspace", -- Analisis seluruh workspace untuk linting
        useLibraryCodeForTypes = true, -- Dukungan tipe untuk pustaka pihak ketiga
        logLevel = "Information", -- Level logging untuk debug
        autoImportCompletions = true, -- Saran impor otomatis
        stubPath = "typings", -- Folder untuk stub file .pyi
        reportMissingImports = true, -- Laporkan impor yang hilang
        reportUnusedImport = true, -- Laporkan impor yang tidak digunakan
        reportUnusedClass = true, -- Laporkan kelas yang tidak digunakan
        reportUnusedFunction = true, -- Laporkan fungsi yang tidak digunakan
        reportUnusedVariable = true, -- Laporkan variabel yang tidak digunakan
        runtimeTypeChecking = true, -- Menguji tipe runtime
        reportGeneralTypeIssues = true, -- Laporkan masalah tipe umum
        reportUnusedSelf = true, -- Laporkan self yang tidak digunakan
        reportUnusedFunctionArgs = true, -- Laporkan argumen fungsi yang tidak digunakan
        reportUnusedLoopVars = true, -- Laporkan variabel loop yang tidak digunakan
        reportUnusedLocals = true, -- Laporkan lokal yang tidak digunakan
        reportUnusedImports = true, -- Laporkan impor yan
      },
      venvPath = "~/.virtualenvs", -- Virtual environment path
      pythonPath = "/usr/bin/python3", -- Path interpreter Python utama
    },
    plugins = {
      -- Pyright untuk analisis tipe statis dan linting dasar
      pyright = {
        enable = true, -- Mengaktifkan plugin Pyright
      },
      -- Pylint untuk linting kode secara detail
      pylint = {
        enabled = true,
        args = { "--max-line-length=180", "--disable=C0111", "--enable=W,E" },
      },
      -- MyPy untuk tipe statis yang lebih kuat
      mypy = {
        enabled = true,
        live_mode = true,
        strict = true, -- Mode pemeriksaan tipe ketat
        additional_args = { "--ignore-missing-imports" },
      },
      -- Black untuk format otomatis
      black = {
        enabled = true,
        line_length = 88,
      },
      -- isort untuk pengurutan impor
      isort = {
        enabled = true,
        profile = "black",
        multi_line_output = 3, -- Multi-line output yang disesuaikan
        force_sort_within_sections = true,
      },
      -- Jedi untuk fitur lanjutan
      jedi = {
        enabled = true,
        completion = true, -- Penyelesaian otomatis
        hover = true, -- Informasi tooltip
        goto_definitions = true, -- "Go to definition"
        signatures = true, -- Penandatangan fungsi
        find_references = true, -- Temukan referensi
        rename = true, -- Fitur rename simbol
      },
      -- Flake8 untuk linting tambahan
      flake8 = {
        enabled = true,
        max_line_length = 88,
        ignore = { "E203", "W503" },
      },
      -- Integrasi Debugging
      debugpy = {
        enabled = true,
        host = "localhost",
        port = 5678, -- Port debugger
      },
      -- AI Model Integration (Custom Plugin)
      ai_assist = {
        enabled = true,
        model = "openai-chatgpt", -- Gunakan API OpenAI (jika tersedia)
        prompt_length = 4096,
        max_tokens = 1024,
        temperature = 0.8,
      },
    },
  },
  commands = {
    PyrightOrganizeImports = {
      function()
        vim.lsp.buf.execute_command({
          command = "_typescript.organizeImports",
          arguments = { vim.api.nvim_buf_get_name(0) },
        })
      end,
      description = "Organize Imports with Pyright",
    },
    PyrightRenameSymbol = {
      function()
        vim.lsp.buf.rename()
      end,
      description = "Rename symbol with Pyright",
    },
  },
})


--------------------------tailwindcss lsp config--------------------------


require('lspconfig').tailwindcss.setup({
  filetypes = {
    "css", "scss", "sass", "html", "javascript", "typescript",
    "javascriptreact", "typescriptreact", "vue", "svelte",
    "astro", "react", "blade", "php", "mdx", "markdown"
  },

  on_attach = function(client, bufnr)
    local bufmap = function(mode, lhs, rhs)
      vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { noremap = true, silent = true })
    end

    -- ✨ Keymaps LSP Premium
    bufmap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>')
    bufmap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>')
    bufmap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>')
    bufmap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>')
    bufmap('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>')
    bufmap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>')
    bufmap('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>')
    bufmap('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>')
    bufmap('n', '<leader>f', '<Cmd>lua vim.lsp.buf.format({ async = true })<CR>')
    bufmap('n', 'gh', '<Cmd>lua vim.lsp.buf.hover()<CR>')

    -- ✨ Format otomatis
    if client.server_capabilities.documentFormattingProvider then
      vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ async = false })]]
    end
  end,

  on_init = function(client)
    print("🎨 TailwindCSS LSP initialized — Design with power!")
  end,

  capabilities = require("cmp_nvim_lsp").default_capabilities(),

  flags = {
    debounce_text_changes = 100,
    allow_incremental_sync = true,
  },

  settings = {
    tailwindCSS = {
      validate = true,
      experimental = {
        classRegex = {
          -- Regex untuk berbagai framework
          { "tw`([^`]*)", 1 },
          { "tw=\"([^\"]*)", 1 },
          { "tw={\"([^\"]*)", 1 },
          { "tw\\.\\w+`([^`]*)", 1 },
          { "className=\"([^\"]*)", 1 },
          { "class=\"([^\"]*)", 1 },
          { "class:\\s*\"([^\"]*)", 1 },
        }
      },
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidScreen = "error",
        invalidVariant = "error",
        invalidConfigPath = "error",
        recommendedVariantOrder = "warning",
      },
      classAttributes = { "class", "className", "ngClass" },

      completion = {
        enable = true,
        suggestClassName = true,
        suggestClassKey = "class",
      },

      hover = {
        enable = true,
        showTailwindConfig = true,
        showExpandedClasses = true,
      },

      snippet = {
        enable = true,
        html = { enable = true },
        css = { enable = true },
        javascript = { enable = true },
        typescript = { enable = true },
        vue = { enable = true },
        react = { enable = true },
        svelte = { enable = true },
      },

      emmetCompletions = true,
      rootPattern = { ".git", "tailwind.config.js", "tailwind.config.ts", "postcss.config.js" },
    }
  },

  -- 🔍 Diagnostics setup

  handlers = {
    ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
      config = config or {}
      config.underline = true
      config.virtual_text = {
        spacing = 2,
        prefix = "●",
      }
      config.signs = true
      config.update_in_insert = true
      -- vim.diagnostic.handlers.default.publish_diagnostics(_, result, ctx, config)
    end,
  },

})



---






-------------------rust_analyzer lsp config-------------------
require('lspconfig').rust_analyzer.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,                -- Mengaktifkan semua fitur Cargo
        features = { "tch", "ndarray", "autodiff", "burn", "nalgebra", "tokio", "async-std", "rayon", "serde_json", "chrono" }, -- Menambah pustaka untuk AI dan OS
        loadOutDirsFromCheck = true,       -- Memuat output dari pemeriksaan Cargo
        buildScripts = { enable = true },  -- Mengaktifkan build scripts
      },
      procMacro = {
        enable = true,
        ignored = {
          ["async-trait"] = { "async_trait" },
          ["napi-derive"] = { "napi" },
          ["async-recursion"] = { "async_recursion" },
        },
      },
      checkOnSave = {
        command = "clippy",
        extraArgs = { "--all-targets", "--all-features" },
      },
      diagnostics = {
        enable = true,
        experimental = { enable = true },
      },
      completion = {
        autoimport = { enable = true },
        postfix = { enable = true },
        snippets = { enable = true },  -- Mengaktifkan snippet
        detailedCompletion = { enable = true }, -- Mengaktifkan rekomendasi kode lebih rinci
        completions = {
          enable = true,
          autocomplete = "always", -- Selalu menampilkan saran
          showDocumentation = true, -- Menampilkan dokumentasi saat mengarahkan kursor pada item
          triggerCharacters = { ".", ":", "(", "," }, -- Memicu rekomendasi berdasarkan karakter tertentu
        },
      },
      inlayHints = {
        bindingModeHints = { enable = true },
        chainingHints = { enable = true },
        closingBraceHints = { enable = true, minLines = 10 },
        closureReturnTypeHints = { enable = "with_block" },
        lifetimeElisionHints = { enable = "always", useParameterNames = true },
        maxLength = 40,
        parameterHints = { enable = true },
        reborrowHints = { enable = "always" },
        renderColons = true,
        typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
      },
      hover = {
        actions = {
          references = { enable = true },
          implementations = { enable = true },
          run = { enable = true },
        },
      },
      assist = {
        importMergeBehavior = "last",
        importPrefix = "by_self",
      },
      lens = {
        enable = true,
        methodReferences = true,
        references = true,
        enumVariantReferences = true,
      },
      telemetry = { enable = false },
      files = { watcher = "client" },
      semanticHighlighting = {
        operator = true,
        punctuation = true,
        variable = {
          global = true,
          static = true,
        },
      },
      experimental = {
        procAttrMacros = true,
        serverStatusNotification = true,
      },

      -- Fitur tambahan untuk pengembangan OS dan AI
      -- Sistem Operasi
      os = {
        enable = true,
        kernelModules = { "process", "memory", "filesystem" },  -- Menambahkan modul kernel untuk OS
        memoryManagement = { enable = true, optimizations = "low-level" },  -- Manajemen memori untuk sistem operasi
        threading = { enable = true, mode = "multi-threaded" }, -- Menambah dukungan multithreading untuk OS
        ipc = { enable = true, methods = { "shared_memory", "message_passing" } }, -- Komunikasi antar proses
        syscalls = { enable = true }, -- Menambahkan dukungan untuk sistem panggilan OS
      },

      -- Pengembangan AI
      ai = {
        enable = true,
        libraries = { "tch", "ndarray", "burn", "autodiff", "serde_json", "chrono" }, -- Menambah pustaka untuk AI
        parallelization = { enable = true, method = "rayon" }, -- Paralelisasi untuk perhitungan AI
        neuralNetworks = { enable = true, frameworks = { "burn", "tch" } }, -- Framework untuk jaringan saraf
        optimizers = { enable = true, methods = { "adam", "sgd" } }, -- Optimizer untuk model AI
        dataProcessing = { enable = true, methods = { "batching", "shuffling" } }, -- Pengolahan data untuk pelatihan model AI
      },

      -- Pengolahan Data Sensor dan AI
      sensor = {
        enable = true,
        libraries = { "serde", "bincode", "serde_json" }, -- Menambah pustaka untuk komunikasi sensor
        dataRate = 100, -- Mengatur frekuensi data sensor
        maxRange = 1024, -- Jangkauan maksimal data sensor
      },

      -- Optimasi untuk Sistem Embedded dan Robotika
      embedded = {
        enable = true,
        optimization = {
          memory = { enable = true, target = "embedded" }, -- Optimalisasi memori untuk sistem embedded
          cpu = { enable = true, target = "embedded" },    -- Optimalisasi CPU untuk perangkat embedded
        },
      },

      -- Penanganan error untuk robotika dan AI
      errorHandling = {
        enable = true,
        warnings = { "unreachable_code", "unused_variables" }, -- Mengaktifkan peringatan untuk kode yang tidak terjangkau dan variabel yang tidak digunakan
        criticalErrors = { "out_of_memory", "stack_overflow" }, -- Menangani error kritis
      },
    },
  },
})


---

---------------------------------clangd lsp config---------------------------------

require('lspconfig').clangd.setup({
  on_attach = function(client, bufnr)
    local bufmap = function(mode, lhs, rhs)
      vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { noremap = true, silent = true })
    end

    -- Navigasi
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>') -- Go to definition
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>') -- Go to declaration
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>') -- Show references
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>') -- Go to implementation
    bufmap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>') -- Rename symbol
    bufmap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>') -- Code actions
    bufmap('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>') -- Format code
    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>') -- Hover documentation

    -- Format otomatis saat save
    if client.server_capabilities.documentFormattingProvider then
      vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ async = false })]]
    end
  end,

  on_init = function(client)
    print("🚀 C++ Ready for development!")
  end,

  capabilities = require("cmp_nvim_lsp").default_capabilities(),

  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",                 -- Aktifkan clang-tidy untuk analisis kode
    "--enable-config",              -- Mengaktifkan file konfigurasi untuk clangd
    "--header-insertion=iwyu",      -- Penyisipan header menggunakan include-what-you-use
    "--completion-style=detailed",  -- Menampilkan saran lengkap dalam auto-complete
    "--pch-storage=memory",         -- Menggunakan penyimpanan header precompiled di memori
    "--function-arg-placeholders",  -- Placeholder argumen untuk fungsi
    "--log=verbose",                -- Log lebih mendetail
    "--malloc-trim",                -- Mengurangi penggunaan memori
    "--pretty",                     -- Format output yang lebih mudah dibaca
    "--all-scopes-completion",      -- Menyelesaikan kata dalam semua scope
    "--suggest-missing-includes",   -- Menyarankan header yang hilang
    "--cross-file-rename",          -- Mendukung penggantian nama lintas file
    "--offset-encoding=utf-16",     -- Menggunakan encoding UTF-16 untuk offset
    "--fallback-style=webkit",      -- Menyesuaikan gaya kode untuk Webkit
    "--header-insertion-decorators=true", -- Menambahkan dekorator header
    "--ranking-model=decision_forest", -- Gunakan model ranking berbasis decision forest
  },

  init_options = {
    clangdFileStatus = true,
    usePlaceholders = true,
    completeUnimported = true,
    semanticHighlighting = true,    -- Sorot sintaks lebih cerdas
    enableSnippetSupport = true,    -- Dukungan snippet untuk penyelesaian kode lebih cepat
  },

  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },

  root_dir = require('lspconfig.util').root_pattern(
    "compile_commands.json", "Makefile", ".git", "CMakeLists.txt"
  ),

  settings = {
    clangd = {
      fallbackFlags = {
        "-std=c++20",                 -- Standar C++ terbaru
        "-Wall",                       -- Peringatan umum
        "-Wextra",                     -- Peringatan tambahan
        "-Wpedantic",                  -- Peringatan ketat
        "-DDEBUG",                     -- Menambahkan makro untuk debugging
        "-D_GNU_SOURCE",               -- Menyertakan sumber daya GNU
        "-fPIC",                       -- Menghasilkan kode posisi independen
        "-pthread",                    -- Dukungan threading dengan pthread
        "-Wshadow",                    -- Peringatan tentang variabel yang tersembunyi
        "-Wconversion",                -- Peringatan konversi tipe yang tidak aman
        "-Wno-unused-parameter",       -- Nonaktifkan peringatan parameter yang tidak terpakai
        "-fdiagnostics-color=always",  -- Menyertakan warna untuk diagnosa
      },

      clangTidy = {
        checks = "*, -clang-analyzer-*",  -- Aktifkan semua pemeriksaan, kecuali analisis clang
        checkOptions = {
          { key = "clang-tidy.Checks", value = "*, -clang-analyzer-*"},  -- Pengaturan untuk clang-tidy
        },
      },
    },
  },

  flags = {
    debounce_text_changes = 80,    -- Waktu tunggu antara perubahan teks
    allow_incremental_sync = true, -- Izinkan sinkronisasi inkremental
  },
})



---






---------------------------------lua_ls lsp config---------------------------------
lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      hint = {
        enable = true,
        arrayIndex = "Disable", -- Bisa "Disable", "Enable", atau "Auto"
        setType = true,
        paramType = true,
        paramName = "All", -- Tambahan: tampilkan semua nama parameter
        variableName = "All", -- Tambahan: tampilkan semua nama variabel
      },

      diagnostics = {
        enable = true,
        globals = { "vim", "use" },
        severity = {
          unusedLocal = "warn",
          undefinedGlobal = "error",
          undefinedMethod = "info",
          undefinedField = "info",
        },
        neededFileStatus = {
          ["codestyle-check"] = "Any",
          ["await-support"] = "Any",
        },
        groupSeverity = {
          strong = "Error",
          strict = "Warning",
        },
      },

      workspace = {
        checkThirdParty = false,
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
          vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
          vim.fn.stdpath("config") .. "/lua", -- Tambahan: konfigurasi lokal
        },
        maxPreload = 2000,
        preloadFileSize = 1000,
        ignoreDir = { ".git", "node_modules", "dist" },
      },

      completion = {
        enable = true,
        keywordSnippet = "Both",
        preselect = "Item",
        callSnippet = "Both",
        showWord = "Enable", -- Tambahan
        workspaceWord = true, -- Tambahan
      },

      formatting = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = 2,
          tab_size = 2,
        },
        formatOnSave = true,
      },

      telemetry = {
        enable = true,
        enableTelemetry = true,
        enablePrompt = true,
      },

      debug = {
        enable = true,
        showLogs = true,
        loggingLevel = "trace",
      },

      cache = {
        enable = true,
        directory = vim.fn.stdpath("cache") .. "/lua_ls_cache",
        maxFileSize = 10 * 1024 * 1024,
      },

      codeLens = {
        enable = true, -- Tambahan: untuk info penggunaan fungsi, dll
      },

      signatureHelp = {
        enable = true, -- Tambahan
      },

      hover = {
        enable = true, -- Tambahan
      },

      semantic = {
        enable = true, -- Tambahan: semantic tokens untuk warna token cerdas
      },

      refactor = {
        smartRename = true,
        extractFunction = true,
        extractVariable = true,
      },

      symbol = {
        enable = true,
        callHierarchy = true,
        documentSymbol = true,
        workspaceSymbol = true,
      },

      misc = {
        parameters = {
          enable = true, -- Inlay hint param AI-style
        },
      },

      commands = {
        CleanCache = {
          description = "Clean Lua LS cache",
          command = "lua require('lspconfig').lua_ls.clean_cache()",
        },
        RefreshSymbols = {
          description = "Refresh Lua LS symbols",
          command = "lua vim.lsp.buf.request(0, 'workspace/executeCommand', { command = 'workspace/symbol', arguments = {} })",
        },
        FormatAll = {
          description = "Format all files",
          command = "lua vim.lsp.buf.format({ async = true })",
        },
      },
    },
  },

  on_init = function(client)
    print("Lua Ready!")
  end,
}





lspconfig.ts_ls.setup {
  on_attach = on_attach,  -- Fungsi yang mengonfigurasi keybindings dan pengaturan lainnya
  capabilities = capabilities,  -- Kemampuan untuk mendukung autocompletion, dll.
  on_init = on_init,  -- Fungsi untuk menginisialisasi server
  settings = {
    javascript = {
      validate = true,
      format = {
        enable = true,
        defaultFormatter = "prettier",  -- Gunakan Prettier untuk format kode
        wrapLineLength = 120,  -- Panjang garis maksimal
      },
      suggest = {
        enable = true,
        autoImports = true,  -- Aktifkan auto-import
        includeCompletionsForModuleExports = true,  -- Saran untuk ekspor modul
        showDocumentation = true,  -- Tampilkan dokumentasi saat hover
        completeFunctionCalls = true,  -- Lengkapi panggilan fungsi secara otomatis
        includeCompletionsWithSnippetText = true,  -- Gunakan snippet saat memberikan saran
      },
      diagnostics = {
        enable = true,
        lint = {
          enable = true,  -- Aktifkan linting untuk JavaScript
          rule = "all",  -- Terapkan semua aturan linting
        },
      },
    },
    typescript = {
      validate = true,
      format = {
        enable = true,
        defaultFormatter = "prettier",  -- Gunakan Prettier untuk format kode
        wrapLineLength = 120,  -- Panjang garis maksimal
      },
      suggest = {
        enable = true,
        autoImports = true,  -- Aktifkan auto-import untuk TypeScript
        includeCompletionsForModuleExports = true,  -- Saran ekspor modul TypeScript
        completeFunctionCalls = true,  -- Lengkapi panggilan fungsi secara otomatis
        includeCompletionsWithSnippetText = true,  -- Gunakan snippet saat memberikan saran
      },
      diagnostics = {
        enable = true,
        lint = {
          enable = true,
          rule = "all",  -- Terapkan semua aturan linting di TypeScript
        },
      },
    },
    python = {
      enable = true,
      linting = {
        enable = true,
        pyflakes = true,  -- Gunakan Pyflakes untuk linting
        pylint = true,  -- Gunakan Pylint untuk linting
        flake8 = true,  -- Gunakan Flake8 untuk linting
      },
      formatting = {
        provider = "black",  -- Gunakan Black untuk format otomatis
      },
      diagnostics = {
        enable = true,
        lint = {
          enable = true,  -- Aktifkan linting di Python
        },
      },
      suggest = {
        enable = true,
        autoImports = true,  -- Aktifkan auto-import untuk Python
        completeFunctionCalls = true,  -- Lengkapi panggilan fungsi secara otomatis
      },
    },
    java = {
      enable = true,
      format = {
        enable = true,
        defaultFormatter = "google-java-format",  -- Gunakan Google Java Format untuk format otomatis
      },
      diagnostics = {
        enable = true,  -- Aktifkan diagnostik di Java
      },
      completion = {
        enable = true,
        autoInsert = true,  -- Auto-insert completions
        completeFunctionCalls = true,  -- Lengkapi panggilan fungsi secara otomatis
      },
      suggest = {
        enable = true,
        autoImports = true,  -- Aktifkan auto-import untuk Java
        includeCompletionsForModuleExports = true,  -- Saran ekspor modul Java
        completeFunctionCalls = true,  -- Lengkapi panggilan fungsi Java secara otomatis
      },
    },
  },

  -- Pengaturan untuk debugging di Neovim
  debug = {
    enable = true,
    logLevel = "debug",  -- Tingkat log debugging
    runInTerminal = true,  -- Jalankan debug di terminal
    console = "integratedTerminal",  -- Gunakan terminal terintegrasi
  },

  -- Penambahan fungsionalitas canggih seperti navigasi kode
  keymaps = {
    ["gd"] = vim.lsp.buf.definition,  -- Navigasi ke definisi
    ["gr"] = vim.lsp.buf.references,  -- Temukan referensi
    ["K"] = vim.lsp.buf.hover,  -- Tampilkan dokumentasi saat hover
    ["gi"] = vim.lsp.buf.implementation,  -- Navigasi ke implementasi
    ["<C-k>"] = vim.lsp.buf.signature_help,  -- Tampilkan bantuan tanda tangan
    -- ["<C-space>"] = vim.lsp.buf.completion,  -- Trigger completion secara manual
  },

  -- Pengaturan untuk auto-completion dan snippet
  completion = {
    enable = true,
    autocomplete = true,  -- Aktifkan autocomplete saat mengetik
    keyword_length = 1,  -- Saran muncul setelah 1 karakter
    snippetSupport = true,  -- Mendukung snippet
    triggerCharacters = { ".", ":", "(", "[" },  -- Karakter trigger untuk saran otomatis
    preselect = true,  -- Pilih item pertama dalam daftar saran secara otomatis
    maxItems = 20,  -- Batasi jumlah saran yang ditampilkan
    completeFunctionCalls = true,  -- Lengkapi panggilan fungsi secara otomatis
    showSignature = true,  -- Tampilkan signature fungsi saat menyelesaikan panggilan fungsi
    showDocumentation = true,  -- Tampilkan dokumentasi saat hover
  },

  -- Menambahkan integrasi dengan AI (misalnya menggunakan model AI untuk kode)
  ai_integration = {
    enable = true,
    python_ai = true,  -- Integrasi dengan AI menggunakan Python (misalnya untuk analisis kode)
    java_ai = true,  -- Integrasi dengan AI menggunakan Java (misalnya untuk optimasi atau prediksi kode)
    model = "gpt-3.5-turbo",  -- Pilih model AI yang digunakan
    endpoint = "http://localhost:5000",  -- URL endpoint untuk server AI (misalnya server lokal yang menjalankan model)
    code_suggestions = true,  -- Aktifkan saran kode berbasis AI
    code_refactoring = true,  -- Aktifkan refactoring kode berbasis AI
  },

  -- Pengaturan tambahan untuk meningkatkan produktivitas pengkodean
  linting = {
    enable = true,
    lint_on_save = true,  -- Lakukan linting otomatis saat file disimpan
    lint_on_type = true,  -- Lakukan linting otomatis saat mengetik
  },

  -- Refactoring otomatis dan fitur lainnya
  refactor = {
    enable = true,
    rename = true,  -- Aktifkan refactoring untuk merename variabel dan fungsi
    extract_method = true,  -- Aktifkan ekstraksi metode untuk refactoring
    extract_variable = true,  -- Aktifkan ekstraksi variabel untuk refactoring
  },
}


-------------------------------bash lsp config-------------------------------

lspconfig.bashls.setup {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh", "zsh", "env" },
  root_dir = lspconfig.util.root_pattern('.git', '.bashrc', '.bash_profile', '.profile', '.zshrc', '.env'),

  settings = {
    bash = {
      glob = true,
      checkExitCode = true,
      additionalTextEdits = true,
      semanticHighlighting = true,
      sortCompletion = true,
      completeFunctionCalls = true,

      diagnostics = {
        enable = true,
        severity = "warning",
        shellcheckArguments = {
          "--severity=style", "--enable=all", "--external-sources",
        },
        useShellcheck = true, -- Gunakan shellcheck untuk linting
      },

      completion = {
        enable = true,
        showFunctionParameters = true,
        snippets = true,
        suggestShellBuiltins = true,
        pathSuggestions = true,
        variableSuggestions = true,
        keywords = { "if", "then", "else", "fi", "for", "while", "do", "done", "case", "esac" },
      },

      highlight = {
        enable = true,
        additionalLanguages = { "sh", "zsh", "bash" },
        variables = true,
        functions = true,
      },

      hover = {
        enable = true,
        showDocumentation = true,
        showReferences = true,
      },

      codeActions = {
        enable = true,
        source = true,
        organizeImports = true,
        fixAll = true,
        renameSymbol = true,
      },

      inlayHints = {
        enable = true,
        parameterNames = "all", -- atau "none" atau "literals"
        parameterTypes = true,
        variableTypes = true,
        showFunctionReturnType = true,
      },

      codeLens = {
        enable = true, -- Tampilkan referensi dan run marker
      },

      signatureHelp = {
        enable = true,
      },

      formatting = {
        enable = true,
        tool = "shfmt",
        formatOnSave = true,
        shfmtArgs = {
          "-i", "2", "-ci"
        },
      },

      rename = {
        enable = true,
        smart = true,
        fallback = true,
      },

      symbol = {
        enable = true,
        documentSymbol = true,
        workspaceSymbol = true,
        fuzzyMatching = true,
      },

      workspace = {
        shellPaths = {
          vim.fn.expand("~/.bashrc"),
          vim.fn.expand("~/.zshrc"),
          "/etc/bash.bashrc",
          "/etc/profile",
        },
        environmentDetection = true,
        library = {
          vim.fn.stdpath("config") .. "/shell",
          "/usr/share/bash-completion",
        },
      },

      telemetry = {
        enable = false, -- Optional
      },

      debug = {
        enable = false,
      },
    }
  }
}


---

-- LSP configuration for Groovy in Neovim with Gradle integration for the "Emelyn" project

require('lspconfig').groovyls.setup({
  on_attach = on_attach,  -- Attach the LSP client to the buffer
  capabilities = capabilities,  -- Specify the capabilities for the LSP client
  on_init = on_init,  -- Run any initialization logic when the LSP is initialized
  settings = {
    groovy = {
      -- Code formatting settings
      format = {
        enabled = true,  -- Enable automatic formatting when saving or triggering
        autoCorrect = true,  -- Enable automatic corrections to improve formatting
        style = "google",  -- Use Google's code style for formatting (could be "eclipse", "intellij", etc.)
        indentation = 2,  -- Set indentation to 2 spaces for consistency
      },

      -- Code completion settings (auto-imports and import order)
      completion = {
        autoImports = true,  -- Enable automatic imports (Groovy-specific)
        importOrder = {  -- Define the order of imports (e.g., Java imports first, then Groovy)
          "java",
          "javax",
          "scala",
          "groovy",
          "org",
          "com",
          "",
        },
      },

      -- Linting configuration (catching errors and warnings)
      linting = {
        enabled = true,  -- Enable linting to detect syntax and logical errors
        lintOnSave = true,  -- Perform linting when saving the file
        lintLevel = "error",  -- Set the lint level to 'error' for serious issues (can also use "warning" or "info")
        rules = {
          groovy = "warning",  -- Show warnings for Groovy-specific issues
          java = "error",  -- Show errors for Java-related issues
          unused = "error",  -- Flag unused variables or imports as errors
        },
      },

      -- Profiling configuration (helpful for performance analysis)
      profiling = {
        enabled = true,  -- Enable profiling for performance insights
        jvmArguments = {  -- JVM arguments to control profiling output
          "-Xprof",  -- Enable basic profiling to analyze method calls and performance
          "-XX:+PrintGCDetails",  -- Print detailed garbage collection logs
          "-XX:+PrintGCDateStamps",  -- Include timestamps in garbage collection logs
        },
      },

      -- Gradle configuration for building and managing dependencies in the "Emelyn" project
      gradle = {
        enabled = true,  -- Enable Gradle integration
        gradleWrapperPath = "./gradlew",  -- Path to the Gradle wrapper script (ensures consistency across environments)
        gradleVersion = "8.12",  -- Specify the version of Gradle to use (this helps with compatibility)
        jvmArguments = {  -- JVM arguments specific to Gradle
          "-Xmx2g",  -- Set the maximum heap size to 2 GB for Gradle
          "-Xms512m",  -- Set the initial heap size to 512 MB for Gradle
          "-XX:+UseParallelGC",  -- Enable parallel garbage collection for better performance
          "-Dsun.zip.disableMemoryMapping=true",  -- Disable memory-mapped IO for ZIP files (can speed up builds)
        },
        arguments = {  -- Additional Gradle arguments for controlling build behavior
          "--no-build-cache",  -- Disable Gradle's build cache (helps ensure clean builds)
          "--no-configuration-cache",  -- Disable Gradle's configuration cache (helps in debugging issues)
          "--no-daemon",  -- Run Gradle without the background daemon to ensure a fresh process each time
          "--parallel",  -- Enable parallel task execution for faster builds
        },
        dependencies = {  -- List of project dependencies needed for the build
          additionalDependencies = {
            "org.codehaus.groovy:groovy-all:3.0.9",  -- Groovy core dependency
            "org.springframework.boot:spring-boot-starter-web:2.4.0",  -- Spring Boot starter for web applications
            "com.fasterxml.jackson.core:jackson-databind:2.12.0",  -- Jackson library for JSON processing
            "org.apache.commons:commons-lang3:3.12.0",  -- Common utility functions
            "org.spockframework:spock-core:2.0-groovy-3.0",  -- Spock for unit testing (Groovy-specific testing framework)
            "org.junit.jupiter:junit-jupiter-api:5.7.0",  -- JUnit for unit testing (Java testing framework)
          },
        },
        repositories = {  -- Repositories from which to fetch dependencies
          mavenCentral = true,  -- Use Maven Central for public dependencies
          jcenter = true,  -- Include JCenter for additional dependencies
          customRepos = {
            "https://repo.maven.apache.org/maven2",  -- Custom Maven repository for additional dependencies
            "https://jcenter.bintray.com",  -- Another custom repository
          },
        },
        buildTasks = {  -- Tasks for Gradle to handle specific actions
          compileGroovy = "compileGroovy",  -- Gradle task for compiling Groovy code
          compileJava = "compileJava",  -- Gradle task for compiling Java code (if you have mixed projects)
          runTests = "test",  -- Task to run unit tests
          buildJar = "jar",  -- Task to build the final JAR file for your project
        },
        taskConfiguration = {  -- Configure custom Gradle tasks and publishing steps
          customTask = {
            name = "deploy",  -- Name of your custom task (e.g., for deployment)
            arguments = {"--deployTo=prod", "--no-cache"},  -- Arguments for deployment task
          },
          publishToMaven = {
            name = "publishToMavenLocal",  -- Publish the project to the local Maven repository
            arguments = {"--skipTests"},  -- Skip running tests during publishing (can speed up the process)
          },
        },
      },

      -- Multi-module project support configuration
      multiModule = {
        enabled = true,  -- Enable multi-module support in Gradle (for larger projects)
        rootProjectName = "emelyn",  -- Set the name of your root project
        moduleDirectories = {  -- Define directories for different project modules
          "modules",  -- Specify where the modules are located (relative to the root project)
        },
      },

      -- Logging configuration for better build insights
      logging = {
        level = "info",  -- Set logging level to 'info' (can be 'debug', 'warn', or 'error')
        file = "./build/logs/gradle.log",  -- Define log file path for easier debugging
      },

      -- Output redirection settings (to manage where output gets saved)
      output = {
        redirectToFile = true,  -- Redirect Gradle build output to a file
        outputPath = "./build/output",  -- Path for the output build artifacts
      },

      -- Advanced settings for performance and build optimizations
      advancedSettings = {
        gradleDaemon = true,  -- Enable Gradle daemon for faster builds (runs in the background)
        parallelExecution = true,  -- Run tasks in parallel to speed up the build process
        continueOnFailure = false,  -- Stop the build if a task fails (set to true to continue after failures)
        profileTaskExecution = true,  -- Enable task profiling to measure execution times of each task
      },
    },
  },
})

-- Add features for better Groovy development:
lspconfig.groovyls.setup({
  on_attach = function(client, bufnr)
    -- Example action on LSP attach: Show documentation on hover
    vim.cmd('au CursorHold <buffer> lua vim.lsp.buf.hover()')  -- Show hover information (e.g., function docs)
  end,
  capabilities = capabilities,
  on_init = function(client)
    -- Initialization logic when the LSP is started
    print("Groovy LSP initialized for Emelyn project")
  end,
  settings = {
    groovy = {
      -- Additional Groovy-specific features for better coding experience
      format = {
        enabled = true,
        autoCorrect = true,
        style = "google",
        indentation = 2,
        endOfLine = "lf",
        insertFinalNewline = true,
        trimTrailingWhitespace = true,
        trimFinalNewlines = true,
      },
      completion = {
        autoImports = true,
        importOrder = { "java", "javax", "scala", "groovy", "org", "com", "" },
        classRegex = "^([A-Z][a-zA-Z0-9]*)$",
        enumRegex = "^([A-Z][a-zA-Z0-9]*)$",
        fieldRegex = "^([a-z][a-zA-Z0-9]*)$",
        methodRegex = "^([a-z][a-zA-Z0-9]*)$",
        interfaceRegex = "^([A-Z][a-zA-Z0-9]*)$",
      },
      linting = {
        enabled = true,
        autoFix = true,
        autoFixOnSave = true,
        autoFixSeverity = "error",
        lintOnSave = true,
        lintLevel = "error",
        rules = {
          groovy = "warning",
          java = "error",
          unused = "error",
        },
      },
      profiling = {
        enabled = true,
        jvmArguments = {
          "-Xprof",
          "-XX:+PrintGCDetails",
          "-XX:+PrintGCDateStamps",
          "-XX:+UseParallelGC",
          "-Dsun.zip.disableMemoryMapping=true",
          "-Djava.ext.dirs=workspaceFolder/lib",
          "-Dfile.encoding=UTF-8",
          "-Duser.language=en",
          "-Duser.country=US",
          "-Djava.awt.headless=true",
        },
      },
    },
  },
})


