-- =====================================================================
--  ui.lua  —  Interface: barra de status, abas e dica de atalhos
-- =====================================================================
return {
  -- -------------------------------------------------------------------
  -- which-key: mostra na tela quais atalhos estao disponiveis.
  -- Aperte <leader> (ESPACO) e ESPERE — aparece um menu com as opcoes.
  -- ESSENCIAL para quem esta aprendendo: voce nao precisa decorar nada.
  -- -------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300, -- ms ate aparecer o menu
      spec = {
        -- Nomes dos grupos de atalhos (organiza o menu)
        { "<leader>f", group = "󰍉 Buscar (find)" },
        { "<leader>s", group = " Splits/Janelas" },
        { "<leader>c", group = " Codigo (LSP)" },
        { "<leader>r", group = " Renomear" },
        { "<leader>g", group = " Git" },
        { "<leader>b", group = " Buffers/Abas" },
        { "<leader>m", group = " Markdown" },
      },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = true }) end,
        desc = "Mostrar todos os atalhos",
      },
    },
  },

  -- -------------------------------------------------------------------
  -- lualine: barra de status na parte de baixo (modo, git, arquivo...)
  -- -------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",      -- usa as cores do tema base16
        globalstatus = true, -- uma unica barra (nao uma por janela)
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
      sections = {
        lualine_c = { { "filename", path = 1 } }, -- mostra o caminho relativo
        lualine_x = { "diagnostics", "encoding", "filetype" },
      },
    },
  },

  -- -------------------------------------------------------------------
  -- bufferline: abas no topo, uma por arquivo aberto (estilo VSCode)
  --   Shift+l / Shift+h  -> proxima / aba anterior
  --   <leader>bd         -> fechar a aba atual
  -- -------------------------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Proxima aba" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Aba anterior" },
      { "<leader>bd", "<cmd>bdelete<cr>", desc = "Fechar aba" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Fechar outras abas" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "slant", -- bordas inclinadas (combina com seu tmux)
        offsets = {
          { filetype = "neo-tree", text = "EXPLORADOR", highlight = "Directory", separator = true },
        },
      },
    },
  },
}
