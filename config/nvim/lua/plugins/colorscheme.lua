-- =====================================================================
--  colorscheme.lua  —  Tema combinando com o seu kitty
--
--  Usamos o mini.base16 para gerar um tema completo (syntax, LSP,
--  telescope, etc) a partir de uma paleta de 16 cores. A paleta abaixo
--  foi derivada do seu ~/.config/kitty/current-theme.conf, entao kitty,
--  tmux e neovim ficam visualmente consistentes.
--
--  Os tons de FUNDO (base00-02) seguem o roxo escuro do kitty (#1e1c44)
--  e os tons de DESTAQUE (base08-0F) sao as cores de syntax do terminal.
--  Alguns foram clareados levemente para ter contraste legivel no editor.
-- =====================================================================
return {
  "echasnovski/mini.base16",
  version = false,
  lazy = false,    -- carrega imediatamente (nao sob demanda)
  priority = 1000, -- prioridade maxima: o tema deve carregar antes de tudo
  config = function()
    require("mini.base16").setup({
      palette = {
        base00 = "#1e1c44", -- fundo principal          (kitty background)
        base01 = "#262350", -- fundo +1 (linha atual, popups)
        base02 = "#3d3868", -- fundo +2 (selecao visual)
        base03 = "#6f6a8e", -- comentarios / texto esmaecido
        base04 = "#b9b3d6", -- texto escuro (barra de status)
        base05 = "#f8dbc0", -- TEXTO PADRAO              (kitty foreground)
        base06 = "#fdf0e3", -- texto +1
        base07 = "#f5f4fb", -- texto claro              (kitty color15)
        base08 = "#fc5e59", -- vermelho: variaveis      (kitty color9)
        base09 = "#e6741d", -- laranja: numeros/const.  (kitty color3)
        base0A = "#efc11a", -- amarelo/dourado: tipos   (kitty color11)
        base0B = "#9dff6e", -- verde: strings           (kitty color10)
        base0C = "#6fa497", -- ciano: regex/escape      (kitty color6)
        base0D = "#1896c6", -- azul: funcoes            (kitty color12)
        base0E = "#a98fd6", -- roxo: palavras-chave     (derivado do color5)
        base0F = "#9a5952", -- marrom/rosa: especiais   (kitty color13)
      },
      use_cterm = true, -- tambem define cores p/ terminais de 256 cores
    })
  end,
}
