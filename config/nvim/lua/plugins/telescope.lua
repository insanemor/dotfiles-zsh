-- =====================================================================
--  telescope.lua  —  Busca fuzzy ("navegar entre arquivos")
--
--  E o equivalente ao Ctrl+P / Ctrl+Shift+F do VSCode, so que mais
--  poderoso. Voce digita parte do nome e ele filtra na hora.
--
--  Atalhos principais (todos comecam com <leader> = ESPACO):
--    <leader><space>  -> buscar ARQUIVOS pelo nome  (o mais usado!)
--    <leader>ff       -> buscar arquivos
--    <leader>fg       -> buscar TEXTO dentro dos arquivos (grep)
--    <leader>fb       -> alternar entre arquivos abertos (buffers)
--    <leader>fr       -> arquivos abertos recentemente
--    <leader>fk       -> listar TODOS os atalhos configurados
--    <leader>fh       -> buscar na ajuda do Neovim
--
--  Dentro da busca:
--    Ctrl+j / Ctrl+k  -> descer / subir na lista
--    Enter            -> abrir
--    Ctrl+v / Ctrl+x  -> abrir em split vertical / horizontal
--    Esc              -> fechar
-- =====================================================================
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Acelera a busca fuzzy (compilado em C). Precisa de 'make'.
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Telescope",
  keys = {
    { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Buscar arquivos" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Buscar arquivos" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Buscar texto (grep)" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers (arquivos abertos)" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Arquivos recentes" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Ajuda do Neovim" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Listar atalhos" },
    { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Listar comandos" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Erros/avisos (diagnosticos)" },
    { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buscar no arquivo atual" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    telescope.setup({
      defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        mappings = {
          i = { -- modo de insercao (digitando)
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<Esc>"] = actions.close, -- ESC fecha direto (sem ir p/ modo normal)
          },
        },
      },
    })
    pcall(telescope.load_extension, "fzf") -- ativa o acelerador (se compilou)
  end,
}
