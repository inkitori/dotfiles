return {
  "let-def/texpresso.vim",
  ft = { "tex", "latex", "plaintex" },
  cmd = { "TeXpresso", "Tex" },
  keys = {
    { "<leader>lp", "<cmd>Tex %<cr>", desc = "TeXpresso preview", ft = { "tex", "latex", "plaintex" } },
  },
  config = function()
    require("texpresso")
    vim.api.nvim_create_user_command("Tex", function(opts)
      vim.cmd("TeXpresso " .. (opts.args ~= "" and opts.args or "%"))
    end, { nargs = "*", complete = "file" })
    vim.cmd([[cnoreabbrev <expr> tex (getcmdtype() == ':' && getcmdline() ==# 'tex') ? 'Tex' : 'tex']])
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("user_texpresso_theme", { clear = true }),
      callback = function() pcall(vim.cmd, "TeXpressoTheme") end,
    })
  end,
}
