source $HOME/.config/nvim/vim-plug/plugins.vim

" Catppuccin colour scheme overrides
" surface1: Line numbrs
" base: Empty line character (~)
" overlay0: Comments
"
" Lua process call does not work if the setup line is split onto multiple
" lines for some reason
lua require("catppuccin").setup({flavour = "mocha", transparent_background = true, coc_nvim = true, color_overrides = {mocha = { surface1 = "#F5C2E7", base = "#F2CDCD", overlay0 = "#EBA0AC", },},})
colorscheme catppuccin

inoremap <silent><expr> <tab> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<TAB>"
inoremap <silent><expr> <cr> "\<c-g>u\<CR>"

set number
