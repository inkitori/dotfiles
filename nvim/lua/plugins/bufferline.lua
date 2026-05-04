return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
    { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
    {
      "<leader>bd",
      function()
        local bufnr = vim.api.nvim_get_current_buf()
        local others = vim.tbl_filter(function(b)
          return b ~= bufnr and vim.fn.buflisted(b) == 1
        end, vim.api.nvim_list_bufs())
        if #others > 0 then
          vim.cmd("BufferLineCyclePrev")
        else
          vim.cmd("enew")
        end
        vim.cmd("bdelete " .. bufnr)
      end,
      desc = "Delete buffer (keep window)",
    },
  },
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      offsets = {
        { filetype = "neo-tree", text = "Explorer", text_align = "left", separator = true },
      },
    },
  },
}
