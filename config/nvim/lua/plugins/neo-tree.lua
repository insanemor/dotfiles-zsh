-- =====================================================================
--  neo-tree.lua  —  Explorador de arquivos na barra lateral
--  (a "arvore de arquivos" estilo VSCode)
--
--  Abrir/fechar:  <leader>e   (espaco + e)
--  Focar nele:    <leader>o   (espaco + o)
--
--  Dentro da arvore:
--    Enter / o  -> abrir arquivo
--    a          -> criar arquivo/pasta (termine com / para pasta)
--    d          -> deletar
--    r          -> renomear
--    c / x / p  -> copiar / recortar / colar
--    H          -> mostrar/ocultar arquivos ocultos
--    P          -> preview (espiar sem abrir)
--    s / S      -> abrir em split vertical / horizontal
--    ?          -> ajuda com todos os atalhos
-- =====================================================================
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- icones de arquivos (usa sua Nerd Font)
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorador (abrir/fechar)" },
    { "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focar no explorador" },
  },
  opts = {
    close_if_last_window = true, -- fecha o Neovim se so sobrar a arvore
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    filesystem = {
      follow_current_file = { enabled = true }, -- destaca o arquivo aberto
      use_libuv_file_watcher = true,            -- atualiza ao mudar arquivos fora
      filtered_items = {
        visible = true,         -- mostra arquivos ocultos (esmaecidos)
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
    window = {
      width = 32,
      mappings = {
        ["<space>"] = "none", -- libera o ESPACO (e a tecla leader)
        ["H"] = "toggle_hidden",
        ["P"] = { "toggle_preview", config = { use_float = true } },
        ["s"] = "open_vsplit",
        ["S"] = "open_split",
      },
    },
    default_component_configs = {
      indent = { with_expanders = true }, -- setinhas p/ expandir pastas
      git_status = {
        symbols = {
          added = "✚", modified = "", deleted = "✖", renamed = "󰁕",
          untracked = "", ignored = "", unstaged = "󰄱", staged = "", conflict = "",
        },
      },
    },
  },
}
