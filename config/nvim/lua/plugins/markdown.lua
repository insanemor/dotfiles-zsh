-- =====================================================================
--  markdown.lua  —  Preview de Markdown DENTRO do Neovim
--
--  Renderiza o markdown no proprio buffer: titulos com icones, listas,
--  tabelas alinhadas, blocos de codigo com fundo, checkboxes [ ] / [x].
--
--  Como alternar preview <-> edicao:
--    <leader>mp   -> liga/desliga a renderizacao (preview total <-> texto cru)
--
--  Comportamento padrao (com a renderizacao LIGADA):
--    - a linha onde esta o CURSOR aparece "crua" (para voce editar)
--    - todas as outras linhas ficam renderizadas (preview)
--  Ou seja: voce edita e ve o resultado ao mesmo tempo.
-- =====================================================================
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" }, -- so carrega ao abrir arquivos .md
  keys = {
    { "<leader>mp", "<cmd>RenderMarkdown toggle<cr>", desc = "Markdown: preview <-> edicao" },
  },
  opts = {
    -- Em quais modos renderizar (normal, comando, terminal).
    -- Ao entrar em INSERT, mostra tudo cru automaticamente p/ digitar.
    render_modes = { "n", "c", "t" },
    -- A linha do cursor fica crua p/ edicao; o resto renderizado.
    anti_conceal = { enabled = true },
    -- Blocos de codigo com fundo e linguagem no topo
    code = {
      style = "full",
      width = "block",
      border = "thin",
    },
    -- Caixas de tarefa: [ ] pendente, [x] feito
    checkbox = {
      unchecked = { icon = "󰄱 " },
      checked = { icon = "󰱒 " },
    },
  },
}
