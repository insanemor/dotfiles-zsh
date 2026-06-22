-- =====================================================================
--  completion.lua  —  Menu de autocomplete (nvim-cmp)
--
--  Mostra sugestoes enquanto voce digita (igual VSCode/Cursor).
--
--  Dentro do menu de sugestoes:
--    Tab / Shift+Tab  -> proxima / anterior sugestao
--    Enter            -> aceitar a sugestao selecionada
--    Ctrl+Espaco      -> abrir o menu manualmente
--    Ctrl+f / Ctrl+b  -> rolar a janela de documentacao
--    Ctrl+e           -> fechar o menu
-- =====================================================================
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- sugestoes do LSP
    "hrsh7th/cmp-buffer",   -- palavras do arquivo atual
    "hrsh7th/cmp-path",     -- caminhos de arquivos
    {
      "L3MON4D3/LuaSnip", -- motor de snippets
      build = "make install_jsregexp",
      dependencies = { "rafamadriz/friendly-snippets" }, -- biblioteca de snippets pronta
    },
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Carrega os snippets prontos (estilo VSCode)
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter aceita
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
      }, {
        { name = "buffer" },
      }),
    })
  end,
}
