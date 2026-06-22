-- =====================================================================
--  lsp.lua  —  Language Server Protocol (a "inteligencia" do editor)
--
--  O LSP traz: autocomplete preciso, "ir para definicao", documentacao
--  ao passar o mouse, renomear simbolo no projeto todo, erros em tempo
--  real, etc — igual ao VSCode.
--
--  O Mason instala os servidores de linguagem automaticamente.
--  Comando util:  :Mason   (abre a interface p/ instalar mais servidores)
--
--  Atalhos (ativos quando ha um servidor rodando no arquivo):
--    gd          -> ir para a definicao
--    gr          -> listar referencias (onde e usado)
--    gI          -> ir para a implementacao
--    K           -> documentacao (hover)
--    <leader>rn  -> renomear simbolo (em todo o projeto)
--    <leader>ca  -> acoes de codigo (quick fix)
--    <leader>cf  -> formatar o arquivo
--    [d  /  ]d   -> erro/aviso anterior / proximo
-- =====================================================================
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "mason-org/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp", -- conecta o autocomplete (nvim-cmp) ao LSP
  },
  config = function()
    -- Capacidades extras vindas do autocomplete (nvim-cmp)
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Aplica essas capacidades a TODOS os servidores
    vim.lsp.config("*", { capabilities = capabilities })

    -- Configuracao especifica do servidor de Lua (reconhece a variavel "vim")
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })

    -- Servidores que serao instalados e habilitados automaticamente.
    -- Para adicionar suporte a mais linguagens, inclua o nome aqui
    -- (ex: "ts_ls" p/ TypeScript, "pyright" p/ Python, "gopls" p/ Go).
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",   -- Lua (a propria config do Neovim)
        "bashls",   -- Shell / Bash
        "jsonls",   -- JSON
        "yamlls",   -- YAML
        -- "ts_ls",    -- TypeScript / JavaScript
        -- "pyright",  -- Python
        -- "gopls",    -- Go
        -- "dockerls", -- Dockerfile
      },
      automatic_enable = true, -- habilita cada servidor instalado (vim.lsp.enable)
    })

    -- --- Atalhos que so existem quando um servidor "anexa" ao arquivo ---
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("config-lsp-attach", { clear = true }),
      callback = function(event)
        local function m(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
        end
        local builtin = require("telescope.builtin")
        m("gd", builtin.lsp_definitions, "Ir p/ definicao")
        m("gr", builtin.lsp_references, "Referencias")
        m("gI", builtin.lsp_implementations, "Implementacao")
        m("gy", builtin.lsp_type_definitions, "Definicao de tipo")
        m("K", vim.lsp.buf.hover, "Documentacao (hover)")
        m("<leader>rn", vim.lsp.buf.rename, "Renomear simbolo")
        m("<leader>ca", vim.lsp.buf.code_action, "Acao de codigo")
        m("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Formatar arquivo")
        m("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Diagnostico anterior")
        m("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Proximo diagnostico")
        m("<leader>cd", vim.diagnostic.open_float, "Detalhe do diagnostico")
      end,
    })

    -- --- Aparencia dos erros/avisos (diagnosticos) ---
    vim.diagnostic.config({
      virtual_text = { prefix = "●" }, -- mostra a mensagem ao lado da linha
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = true },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      },
    })
  end,
}
