-- =====================================================================
--  editor.lua  —  Ferramentas de edicao do dia a dia
-- =====================================================================
return {
  -- -------------------------------------------------------------------
  -- gitsigns: marca no canto esquerdo as linhas adicionadas/alteradas
  --   ]c / [c       -> proxima / anterior alteracao
  --   <leader>gp    -> espiar a alteracao (preview)
  --   <leader>gb    -> ver quem alterou a linha (blame)
  -- -------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = require("gitsigns")
        local function m(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = buffer, desc = desc })
        end
        m("]c", function() gs.nav_hunk("next") end, "Proxima alteracao git")
        m("[c", function() gs.nav_hunk("prev") end, "Alteracao git anterior")
        m("<leader>gp", gs.preview_hunk, "Espiar alteracao (git)")
        m("<leader>gb", function() gs.blame_line({ full = true }) end, "Quem alterou (blame)")
        m("<leader>gr", gs.reset_hunk, "Reverter alteracao (git)")
      end,
    },
  },

  -- -------------------------------------------------------------------
  -- lazygit: interface git completa dentro do Neovim
  --   <leader>gg  -> abrir o LazyGit
  -- -------------------------------------------------------------------
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Abrir LazyGit" } },
  },

  -- -------------------------------------------------------------------
  -- Comment: comentar/descomentar codigo
  --   gcc  -> comenta a linha atual
  --   gc   -> comenta a selecao (modo visual)
  -- -------------------------------------------------------------------
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },

  -- -------------------------------------------------------------------
  -- autopairs: fecha automaticamente ( ) [ ] { } " " ' '
  -- -------------------------------------------------------------------
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- -------------------------------------------------------------------
  -- indent-blankline: linhas verticais guiando a indentacao
  -- -------------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },

  -- -------------------------------------------------------------------
  -- vim-sleuth: detecta automaticamente a indentacao de cada arquivo
  -- -------------------------------------------------------------------
  { "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },

  -- -------------------------------------------------------------------
  -- todo-comments: realca TODO / FIXME / HACK / NOTE no codigo
  -- -------------------------------------------------------------------
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
  },
}
