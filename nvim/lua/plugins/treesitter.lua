-- nvim-treesitter `main` branch (the rewrite). The classic `master` branch
-- has been archived/frozen and lags behind Neovim 0.12, causing crashes in
-- the highlighter. The `main` branch is the actively-maintained path forward.
--
-- Important differences from master:
--   * No lazy-loading — `lazy = false` is required.
--   * No `nvim-treesitter.configs.setup{}` — we install parsers directly and
--     enable highlight/fold/indent via FileType autocmds.
--   * Parsers install to ~/.local/share/nvim/site/parser/ (asynchronously).

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- Parsers we want available. Installed asynchronously on first launch;
    -- a no-op on subsequent launches.
    local parsers = {
      "bash", "c", "cpp", "css", "diff", "dockerfile", "go", "html",
      "javascript", "json", "lua", "luadoc", "make", "markdown",
      "markdown_inline", "python", "regex", "rust", "toml", "tsx",
      "typescript", "vim", "vimdoc", "yaml",
    }
    require("nvim-treesitter").install(parsers)

    -- Enable highlight + folds + indent on FileType. pcall guards against
    -- filetypes whose parsers haven't finished installing yet.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(ev)
        local ft = vim.bo[ev.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if not lang or lang == "" then return end

        if pcall(vim.treesitter.start, ev.buf, lang) then
          -- Treesitter-based folds (set per-window)
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldenable = false   -- start with folds open
          -- Treesitter-based indent (experimental but generally good)
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
