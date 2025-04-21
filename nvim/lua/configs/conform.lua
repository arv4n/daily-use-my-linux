local options = {
  formatters_by_ft = {
    lua = { "stylua", "luarocks" },
    python = { "ruff", "black", "isort" }, -- isort untuk pengurutan import
    go = { "gofumpt", "goimports" },
    golang = { "gofumpt", "goimports" },
    css = { "prettier", "stylelint" },
    scss = { "prettier", "stylelint" }, -- SCSS support
    html = { "prettier", "htmlhint" },
    javascript = { "prettier", "eslint" },
    javascriptreact = { "prettier", "eslint" },
    typescript = { "prettier", "eslint" },
    typescriptreact = { "prettier", "eslint" },
    vue = { "prettier", "vetur" },
    svelte = { "prettier", "svelte-check" },
    json = { "prettier", "jsonlint" },
    yaml = { "prettier", "yaml-lint" },
    toml = { "prettier", "toml-linter" },
    markdown = { "prettier", "markdownlint" },
    rust = { "rustfmt", "clippy" },
    java = { "google-java-format", "checkstyle" }, -- kadang filetype-nya `java`, bukan `jdtls`
    kotlin = { "ktlint" }, -- Kotlin formatter
    sh = { "shfmt", "shellcheck" }, -- Shell script
    bash = { "shfmt", "shellcheck" },
    zsh = { "shfmt", "shellcheck" },
    dockerfile = { "hadolint" }, -- Dockerfile linter
    sql = { "sql-formatter" }, -- SQL formatting
    xml = { "xmlformatter" }, -- XML formatting
    latex = { "latexindent" }, -- LaTeX formatter
    cpp = { "clang-format" }, -- C++
    c = { "clang-format" }, -- C
    make = { "checkmake" }, -- Makefile linter
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options

