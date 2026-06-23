-- =====================================================================
--  options.lua  —  Opcoes gerais do editor
--  (equivalem aos "settings" do VSCode)
-- =====================================================================
local opt = vim.opt

-- --- Numeros de linha ---
opt.number = true             -- mostra o numero da linha atual
opt.relativenumber = true     -- numeros relativos (facilita pular: 5j, 3k...)

-- --- Indentacao ---
opt.tabstop = 2               -- largura visual de um TAB
opt.shiftwidth = 2            -- largura da indentacao automatica
opt.expandtab = true          -- usa espacos no lugar de TAB
opt.smartindent = true        -- indentacao inteligente em novos blocos
opt.autoindent = true         -- mantem a indentacao da linha anterior
opt.breakindent = true        -- linhas quebradas mantem indentacao

-- --- Visual ---
-- Quebra visual automatica: linhas longas quebram na tela enquanto voce digita,
-- sem inserir line-breaks reais no arquivo. Pareado com `formatoptions` em
-- keymaps.lua (textwidth) para que texto digitado em paragrafo continuo continue
-- quebrando ate o limite, mas evitando wrap em codigo (commentstring/formatprg
-- continuam nas suas defaults).
opt.wrap = true               -- linhas longas quebram visualmente na tela
opt.linebreak = true          -- quebra em caracteres "seguros" (,.;!? etc), nao no meio da palavra
opt.showbreak = "↪  "         -- marcador discreto na linha de baixo
opt.breakindentopt = "shift:0,sbr"  -- continuacao alinha com a linha de origem, marca o prefixo "↪  "
opt.cursorline = true         -- destaca a linha onde esta o cursor
opt.termguicolors = true      -- cores 24-bit (truecolor) — essencial p/ o tema
opt.signcolumn = "yes"        -- coluna lateral sempre visivel (git/erros nao "pulam")
opt.scrolloff = 8             -- mantem 8 linhas de folga acima/abaixo ao rolar
opt.sidescrolloff = 8
opt.colorcolumn = "100"       -- linha guia vertical na coluna 100 (wrap desliga o scroll horizontal)
opt.colorcolumn = ""          -- wrap = sem scroll horizontal; colorcolumn atrapalha a leitura
opt.pumheight = 12            -- altura maxima do menu de autocomplete

-- --- Busca ---
opt.ignorecase = true         -- busca ignora maiusculas/minusculas...
opt.smartcase = true          -- ...exceto quando voce digita uma maiuscula
opt.hlsearch = true           -- destaca todos os resultados da busca
opt.incsearch = true          -- mostra os resultados enquanto digita

-- --- Comportamento ---
opt.mouse = "a"               -- mouse habilitado em todos os modos
opt.clipboard = "unnamedplus" -- compartilha o clipboard com o sistema
opt.splitright = true         -- splits verticais abrem a direita
opt.splitbelow = true         -- splits horizontais abrem embaixo
opt.undofile = true           -- historico de undo persiste entre sessoes
opt.swapfile = false          -- sem arquivos de swap
opt.updatetime = 250          -- resposta mais rapida (diagnosticos, git, hover)
opt.timeoutlen = 400          -- janela de tempo p/ sequencias de teclas (which-key)
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true            -- pergunta ao sair com alteracoes nao salvas

-- --- Caracteres invisiveis (espacos no fim, tabs, etc) ---
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- --- Caracteres de preenchimento (visual mais limpo) ---
opt.fillchars = { eob = " " } -- esconde os "~" no fim do buffer
