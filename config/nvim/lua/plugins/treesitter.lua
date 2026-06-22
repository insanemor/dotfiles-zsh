-- =====================================================================
--  treesitter.lua  —  Realce de sintaxe inteligente
--
--  Usa o branch "main" do nvim-treesitter (a nova arquitetura),
--  OBRIGATORIO no Neovim 0.12: o branch "master" antigo usa uma API
--  de treesitter que foi removida no 0.12 e causava erros de parse
--  (inclusive quebrando o preview de markdown).
--
--  Na nova API o realce nao e ligado pela config: instalamos os parsers
--  e ligamos o realce por arquivo com vim.treesitter.start().
-- =====================================================================
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false, -- carrega no inicio (para registrar os parsers/queries)
  config = function()
    require("nvim-treesitter").setup()

    -- Linguagens cujos parsers queremos instalados
    local langs = {
      "lua", "luadoc", "vim", "vimdoc", "bash", "regex",
      "json", "yaml", "toml", "ini",
      "javascript", "typescript", "tsx", "html", "css", "scss",
      "python", "go", "gomod", "rust",
      "markdown", "markdown_inline", "dockerfile", "gitignore", "sql",
    }

    -- Instala apenas os parsers que ainda faltam (assincrono, so na 1a vez)
    local ok, cfg = pcall(require, "nvim-treesitter.config")
    local installed = ok and cfg.get_installed() or {}
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, langs)
    if #missing > 0 then
      pcall(function() require("nvim-treesitter").install(missing) end)
    end

    -- Liga o realce de sintaxe automaticamente ao abrir cada arquivo
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("config-ts-highlight", { clear = true }),
      callback = function(args)
        -- pcall: se o parser ainda nao estiver instalado, ignora sem erro
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
