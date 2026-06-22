-- =====================================================================
--  lazy.lua  —  Instala e inicializa o gerenciador de plugins lazy.nvim
--  Na primeira vez que voce abrir o Neovim, ele baixa o lazy.nvim e
--  todos os plugins automaticamente.
-- =====================================================================

-- Caminho onde o lazy.nvim sera instalado
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Se ainda nao existe, clona o repositorio (versao estavel)
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Falha ao clonar o lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- Adiciona o lazy.nvim ao runtimepath
vim.opt.rtp:prepend(lazypath)

-- Carrega TODOS os arquivos de lua/plugins/ automaticamente
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  -- Tema usado na tela de instalacao de plugins
  install = { colorscheme = { "habamax" } },
  -- Checa atualizacoes de plugins em segundo plano (sem incomodar)
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
})
