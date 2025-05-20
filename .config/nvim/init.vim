call plug#begin('~/.config/nvim/plugged')
Plug 'vimwiki/vimwiki'
call plug#end()

let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
