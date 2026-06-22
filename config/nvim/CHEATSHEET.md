# 🚀 Guia do Neovim — do zero ao dia a dia

> Abra este arquivo a qualquer momento com: `nvim ~/.config/nvim/CHEATSHEET.md`
> A tecla **`<leader>` é o ESPAÇO**. Sempre que apertar ESPAÇO e esperar, o
> **which-key** mostra na tela todas as opções disponíveis. Você não precisa decorar nada!

---

## 1. O conceito mais importante: MODOS

O Neovim tem "modos". Isso assusta no começo, mas é o que o torna poderoso.

| Modo | Para que serve | Como entrar | Como sair |
|------|----------------|-------------|-----------|
| **Normal** | Navegar e dar comandos (é onde você fica a maior parte do tempo) | `Esc` | — |
| **Insert** | Digitar texto (como um editor normal) | `i` | `Esc` |
| **Visual** | Selecionar texto | `v` | `Esc` |
| **Comando** | Comandos `:w`, `:q`... | `:` | `Esc` ou Enter |

👉 **Regra de ouro:** quando estiver perdido, aperte `Esc` para voltar ao modo Normal.

---

## 2. Sobreviver: abrir, salvar e sair

| Ação | Como fazer |
|------|------------|
| Abrir um arquivo no terminal | `nvim arquivo.txt` |
| Abrir o Neovim numa pasta | `nvim .` |
| Entrar no modo de digitar | `i` |
| Voltar ao modo Normal | `Esc` |
| **Salvar** | `<leader>w` ou `Ctrl+s` ou `:w` |
| **Sair** | `<leader>q` ou `:q` |
| Salvar e sair | `:wq` ou `ZZ` |
| Sair SEM salvar | `:q!` |
| Sair de tudo | `<leader>Q` ou `:qa` |

---

## 3. Navegar entre arquivos (o que você pediu!)

### 📁 Explorador lateral (árvore, estilo VSCode) — plugin neo-tree
| Atalho | Ação |
|--------|------|
| `<leader>e` | Abrir/fechar a árvore de arquivos |
| `<leader>o` | Focar na árvore |

Dentro da árvore: `Enter` abre · `a` cria (termine com `/` p/ pasta) · `d` deleta · `r` renomeia · `c`/`x`/`p` copia/recorta/cola · `H` mostra ocultos · `s`/`S` abre em split · `?` ajuda

### 🔭 Busca fuzzy (o mais poderoso!) — plugin Telescope
| Atalho | Ação |
|--------|------|
| `<leader><space>` | **Buscar arquivo pelo nome** (= Ctrl+P do VSCode) |
| `<leader>fg` | **Buscar texto dentro dos arquivos** (= Ctrl+Shift+F) |
| `<leader>fb` | Alternar entre arquivos abertos |
| `<leader>fr` | Arquivos abertos recentemente |
| `<leader>/` | Buscar dentro do arquivo atual |
| `<leader>fk` | Ver TODOS os atalhos configurados |

Dentro da busca: digite para filtrar · `Ctrl+j`/`Ctrl+k` desce/sobe · `Enter` abre · `Esc` fecha

### 🗂️ Abas no topo (um arquivo por aba) — plugin bufferline
| Atalho | Ação |
|--------|------|
| `Shift+l` | Próxima aba |
| `Shift+h` | Aba anterior |
| `<leader>bd` | Fechar a aba atual |

---

## 4. Movimentação no modo Normal (sem mouse!)

| Tecla | Move |
|-------|------|
| `h` `j` `k` `l` | esquerda, baixo, cima, direita |
| `w` / `b` | próxima / palavra anterior |
| `0` / `$` | início / fim da linha |
| `gg` / `G` | início / fim do arquivo |
| `5j` / `10k` | 5 linhas pra baixo / 10 pra cima |
| `Ctrl+d` / `Ctrl+u` | meia página baixo / cima |
| `{` / `}` | parágrafo anterior / próximo |
| `%` | pula para o par `( )`, `{ }`... |
| `/texto` Enter | buscar "texto" (`n` = próximo, `N` = anterior) |

---

## 5. Editar texto

| Tecla | Ação |
|-------|------|
| `i` / `a` | inserir antes / depois do cursor |
| `o` / `O` | nova linha abaixo / acima |
| `x` | apagar caractere |
| `dd` | recortar (apagar) a linha |
| `yy` | copiar a linha |
| `p` / `P` | colar depois / antes |
| `dw` / `cw` | apagar / trocar uma palavra |
| `u` | **desfazer** |
| `Ctrl+r` | refazer |
| `.` | repetir a última ação |
| `Alt+j` / `Alt+k` | mover a linha pra baixo / cima |
| `>>` / `<<` | indentar / desindentar a linha |

💡 A "gramática" do vim: **verbo + objeto**. `d` (delete) + `w` (word) = `dw`.
`c` (change) + `i` + `"` = `ci"` troca o texto **dentro das aspas**. Funciona com `(`, `{`, `[`, `t` (tag HTML)...

---

## 6. Inteligência de código (LSP) — igual VSCode

Funciona quando há um servidor de linguagem para o arquivo (Lua, Bash, JSON, YAML já vêm prontos).

| Atalho | Ação |
|--------|------|
| `gd` | Ir para a definição |
| `gr` | Ver onde é usado (referências) |
| `K` | Documentação (passar por cima) |
| `<leader>rn` | Renomear em todo o projeto |
| `<leader>ca` | Ações de código (quick fix) |
| `<leader>cf` | Formatar o arquivo |
| `[d` / `]d` | Erro/aviso anterior / próximo |

**Autocomplete** (aparece sozinho ao digitar): `Tab`/`Shift+Tab` navega · `Enter` aceita · `Ctrl+Espaço` abre manualmente.

### Adicionar mais linguagens
Rode `:Mason` para abrir o gerenciador, ou edite `~/.config/nvim/lua/plugins/lsp.lua`
e descomente as linhas (ex: `"ts_ls"` p/ TypeScript, `"pyright"` p/ Python). Salve e reinicie.

---

## 7. Git

| Atalho | Ação |
|--------|------|
| `<leader>gg` | Abrir **LazyGit** (interface git completa) |
| `]c` / `[c` | Próxima / anterior alteração |
| `<leader>gp` | Espiar a alteração (preview) |
| `<leader>gb` | Ver quem alterou a linha (blame) |
| `<leader>gr` | Reverter a alteração |

---

## 8. Janelas e divisões (splits)

| Atalho | Ação |
|--------|------|
| `<leader>sv` | Dividir vertical (lado a lado) |
| `<leader>sh` | Dividir horizontal (cima/baixo) |
| `Ctrl+h/j/k/l` | Pular entre as divisões |

---

## 9. Comentar código

| Atalho | Ação |
|--------|------|
| `gcc` | Comenta/descomenta a linha |
| `gc` (em modo Visual) | Comenta a seleção |

---

## 10. Comandos úteis (digite `:` antes)

| Comando | Ação |
|---------|------|
| `:Lazy` | Gerenciar plugins (instalar/atualizar/remover) |
| `:Mason` | Gerenciar servidores de linguagem (LSP) |
| `:checkhealth` | Diagnóstico geral da instalação |
| `:Telescope` | Listar tudo que o Telescope pode buscar |
| `:help <tema>` | Ajuda oficial (ex: `:help motion`) |

---

## ⭐ Plano de aprendizado sugerido (1ª semana)

1. **Dia 1-2:** Só `i` para digitar, `Esc` para sair, `:w` salvar, `:q` sair, e mover com `h j k l`.
2. **Dia 3-4:** Adicione `<leader>e` (árvore) e `<leader><space>` (buscar arquivo). Já dá pra trabalhar!
3. **Dia 5-6:** Aprenda `dd`, `yy`, `p`, `u`, `/busca`, `gg`/`G`.
4. **Dia 7+:** Comece a usar `gd`, `K`, `<leader>ca` (LSP) e a "gramática" `ci"`, `dw`.

> 🆘 **Travou e não sabe sair?** Aperte `Esc` várias vezes, depois digite `:q!` e Enter.
> 🎯 **Esqueceu um atalho?** Aperte `ESPAÇO` e espere o menu aparecer.
> 📚 **Tutorial oficial interativo** (30 min, vale MUITO a pena): rode `vimtutor` no terminal.
