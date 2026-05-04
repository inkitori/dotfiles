-- Ensure Homebrew's bin dir is on PATH for headless / non-interactive nvim
-- launches. Interactive shells already have it via /etc/zprofile, but a bare
-- `nvim --headless` from cron/launchd/another process may not — and
-- nvim-treesitter needs to spawn the `tree-sitter` CLI.
if vim.fn.has("mac") == 1 then
  for _, dir in ipairs({ "/opt/homebrew/bin", "/usr/local/bin" }) do
    if vim.fn.isdirectory(dir) == 1 and not vim.env.PATH:find(dir, 1, true) then
      vim.env.PATH = dir .. ":" .. vim.env.PATH
    end
  end
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "rose-pine" } },
  change_detection = { notify = false },
  ui = {
    border = "rounded",
    backdrop = 100, -- transparent backdrop, no dim overlay
  },
})
