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

-- Inicializa o gerenciador de plugins (lazy.nvim) e carrega tudo de lua/plugins/
require("config.lazy")
