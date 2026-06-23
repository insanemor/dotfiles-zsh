-- =====================================================================
--  init.lua  —  Ponto de entrada da configuracao do Neovim
--  Estrutura:
--    lua/config/  -> opcoes, atalhos e bootstrap do gerenciador de plugins
--    lua/plugins/ -> um arquivo por plugin (carregados automaticamente)
-- =====================================================================

-- A tecla <leader> e a tecla "lider" usada como prefixo dos atalhos.
-- Definimos como ESPACO. IMPORTANTE: precisa vir ANTES de carregar plugins.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Carrega opcoes gerais e atalhos
require("config.options")
require("config.keymaps")

-- Quebra de linha automatica em arquivos de texto puro (markdown, txt, etc.).
-- Em codigo a formatacao automatica atrapalha; em texto livre faz com que a
-- linha quebre sozinha quando voce passa de `textwidth` colunas. O wrap visual
-- (options.lua) ja esta ligado globalmente, isto adiciona o line-break real
-- (que grava no arquivo) para prose.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "txt", "gitcommit", "gitrebase" },
  callback = function()
    vim.opt_local.textwidth = 100
    vim.opt_local.formatoptions = "tjqnl" -- t=auto-wrap em texto, j=cursor no inicio, q=fmt com comentario
  end,
})

-- Inicializa o gerenciador de plugins (lazy.nvim) e carrega tudo de lua/plugins/
require("config.lazy")
