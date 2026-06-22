-- =====================================================================
--  keymaps.lua  —  Atalhos gerais (os de plugins ficam em cada plugin)
--  A tecla <leader> e o ESPACO.
--
--  OBS sobre o tmux: como o tmux ja usa Ctrl+setas, Shift+setas e
--  Alt+setas (sem prefixo), aqui evitamos as SETAS com esses modificadores
--  para nao haver conflito. Usamos letras (hjkl) no lugar.
-- =====================================================================
local map = vim.keymap.set

-- --- Salvar e sair ---
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Salvar arquivo" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Fechar janela" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Sair do Neovim" })
map({ "n", "i" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Salvar (Ctrl+S)" })

-- --- Limpar o destaque da busca apertando ESC ---
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Limpar destaque da busca" })

-- --- Navegar entre janelas/splits com Ctrl + h/j/k/l ---
map("n", "<C-h>", "<C-w>h", { desc = "Janela a esquerda" })
map("n", "<C-j>", "<C-w>j", { desc = "Janela abaixo" })
map("n", "<C-k>", "<C-w>k", { desc = "Janela acima" })
map("n", "<C-l>", "<C-w>l", { desc = "Janela a direita" })

-- --- Dividir a tela (splits) ---
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Dividir vertical" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Dividir horizontal" })

-- --- Mover linhas para cima/baixo (estilo VSCode: Alt+j / Alt+k) ---
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Mover linha p/ baixo" })
map("n", "<A-k>", "<cmd>m .-1<cr>==", { desc = "Mover linha p/ cima" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Mover selecao p/ baixo" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Mover selecao p/ cima" })

-- --- Indentar mantendo a selecao no modo visual ---
map("v", "<", "<gv", { desc = "Desindentar" })
map("v", ">", ">gv", { desc = "Indentar" })

-- --- Manter o cursor centralizado ao rolar e ao buscar ---
map("n", "<C-d>", "<C-d>zz", { desc = "Meia pagina p/ baixo (centralizado)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Meia pagina p/ cima (centralizado)" })
map("n", "n", "nzzzv", { desc = "Proximo resultado (centralizado)" })
map("n", "N", "Nzzzv", { desc = "Resultado anterior (centralizado)" })

-- --- Colar por cima de uma selecao SEM perder o que estava copiado ---
map("v", "p", '"_dP', { desc = "Colar sem sobrescrever o registro" })
