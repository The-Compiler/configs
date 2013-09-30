"" TO INSTALL:
"" - Install exuberant ctags (e.g. the ctags package in your distribution)
"" - Install git
"" - Copy or symlink this config to ~/.vimrc
"" - Start vim, wait until everything is installed

set nocompatible " Turn off vim compability mode

"""""" Set vimfiles path
if has("unix")
	let vimfiles = expand("$HOME/.vim")
else
	let vimfiles = expand("$VIMRUNTIME/../vimfiles")
endif

"""""" Create directories
if !isdirectory(vimfiles) | call mkdir(vimfiles) | endif
if !isdirectory(vimfiles . '/bundle') | call mkdir(vimfiles . '/bundle') | endif
if !isdirectory(vimfiles . '/tags') | call mkdir(vimfiles . '/tags') | endif
if !isdirectory(vimfiles . '/undo') | call mkdir(vimfiles . '/undo') | endif
if !isdirectory(vimfiles . '/bak') | call mkdir(vimfiles . '/bak') | endif
if !isdirectory(vimfiles . '/tmp') | call mkdir(vimfiles . '/tmp') | endif

"""""" NeoBundle
" Bootstrap
let s:neobootstrapdone = 1
if !executable('git')
    echoerr 'Git is not installed, beware of breakage!'
elseif !isdirectory(vimfiles . '/bundle/neobundle.vim')
    let s:neobootstrapdone = 0
    echo 'Installing NeoBundle...'
    echo ''
    echo 'WARNING: If you are on Windows, this will take some time in which '
    echo 'you will only see random command windows popping up.'
    echo ''
    echo 'Please be patient and do not start another vim instance until'
    echo 'the install is finished!'
    call confirm("")
    call mkdir(vimfiles . '/bundle/neobundle.vim')
    execute ':silent !git clone git://github.com/Shougo/neobundle.vim ' . shellescape(vimfiles . '/bundle/neobundle.vim')
endif
" Activate
if has('vim_starting')
    let &runtimepath .= ','. vimfiles .'/bundle/neobundle.vim/'
endif
call neobundle#rc(vimfiles . "/bundle/")
" Update
NeoBundleFetch 'Shougo/neobundle.vim'

"""""" Options
set esckeys                     " Arrow keys, etc. in insert mode
set hidden                      " Support hidden unsaved buffers
set ruler                       " Display line/column in bottom right
set visualbell                  " Blink screen instead of beeping
set noerrorbells                " Don't ring bell for errors
set number                      " Line numbering
set incsearch                   " Search while typing
set hlsearch                    " Highlight search results
set autoindent                  " Auto-indent new lines
set ignorecase                  " Only be case-sensitive with uppercase chars
set smartcase                   " ...
set nostartofline               " Don't move cursor to line start
set showmode                    " Show the mode we're in
set smarttab                    " Insert tabs according to shiftwidth
set expandtab                   " Use 4 spaces as tab
set cursorline                  " Highlight cursor line
set title                       " Set terminal title
set showcmd                     " Show command at lower right
set ttyfast                     " Always on a fast tty
set backspace=indent,eol,start  " Allow backspace to delete any char
set formatoptions=cqrt          " Formatting options, see :h fo-table
set laststatus=2                " Always display a status line
set shortmess=at                " Short messages in statusline
set whichwrap=<,>,h,l           " Allow cursor keys and h/l to wrap lines
set background=dark             " For dark terminals
set termencoding=utf-8          " UTF8 as default encoding
set encoding=utf-8              " ...
set tabstop=4                   " Tab options
set shiftwidth=4                " ...
set softtabstop=4               " ...
set completeopt=menuone,preview " Also show completion menu with one item
set pumheight=20                " Show max 20 entries in completion
set scrolloff=4                 " Always show 4 lines before/after cursor
set virtualedit=block           " Allow extending after EOL in block selection
set nrformats=hex               " Don't allow octal numbers for CTRL-A/CTRL+X
set switchbuf=useopen           " Switch to already open buffers from quickfix
set undolevels=1000             " Save many undo steps
set undofile                    " ...
let &undodir=vimfiles . "/undo" " Keep persistent undo file
set numberwidth=5               " Width of number column
set updatetime=100              " Run autocmds all 100ms
set autoindent                  " Non-intrusive auto-indenting
let &backupdir=vimfiles . "/bak" " Write backup files to vim folder
let &dir=vimfiles . "/tmp"      " Write Swapfiles to vim folder
set autochdir                   " Automatically switch to file path
let no_buffers_menu = 1         " Show no buffers menu in GUI
set history=100                 " Bigger history
set confirm                     " Ask user when :q with modified files
if has("gui_running")           " Set font for gui
    set guifont=ProggyTinyTT_12,ProggyTinyTT:h12:cANSI
    set guioptions+=a           " Autoselect text
    set guioptions+=c           " Use console dialogs
    set guioptions-=t           " No tear-off menus
    set guioptions-=T           " No toolbar
    set guioptions-=r           " No scrollbars
    set guioptions-=L           " No scrollbars
endif
if has("mouse") | set mouse=a | endif " Mouse support
if has("wildmenu") | set wildmenu | endif " Visual tab completion
" Ignore some files for tab menu
if has("wildignore")
    set wildignore=*.swp,*.bak,*.pyc,*/.git/*,*/.hg/*,*/.svn/*
endif
" viminfo
" ': Save N previous files
" <: Save N lines per register
" !: Save all-uppercase global variables
" n: Name
" r: Don't store these paths
" s: Size limits for registers in KB
let &viminfo="'50,s100,!,r/tmp,r/mnt,r/media,n" . vimfiles . "/viminfo"
" Locations for tag file
set tags=./tags,./TAGS,tags,TAGS,../tags,../../tags,../../../tags,../../../../tags
filetype plugin on              " Automatically load filetype-specific plugins
filetype indent on              " Automatically load filetype-specific indents
let mapleader=","               " Use , as leader instead of \

"""""" Plugins
""" Vimproc - needed for NeoBundle
NeoBundle 'Shougo/vimproc', {
   \ 'build' : {
   \     'windows' : 'make -f make_mingw32.mak',
   \     'cygwin'  : 'make -f make_cygwin.mak',
   \     'mac'     : 'make -f make_mac.mak',
   \     'unix'    : 'make -f make_unix.mak',
   \    },
   \ }

""" xoria256 - colorscheme
NeoBundle 'xoria256.vim' " Color scheme
set t_Co=256             " Number of terminal colors
if has("syntax") | syn on | endif
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$' " highlight conflict markers
if s:neobootstrapdone == 1
    colorscheme xoria256
endif

""" Repeat - repeation for plugins
NeoBundle 'tpope/vim-repeat'

""" Tabular - easy aligning of lines
NeoBundle 'godlygeek/tabular'
nnoremap <leader><tab> :Tab /
vnoremap <leader><tab> :Tab /

""" Ctrl-P - fuzzy finder for files and more
NeoBundle 'kien/ctrlp.vim'
let g:ctrpl_extensions =  ['buffertag', 'line']      " Plugins to use
let g:ctrlp_map = ''                                 " No default mapping
let g:ctrlp_match_window = 'bottom,order:ttb,max:30' " 30 entries in window
let g:ctrlp_root_markers = ['NEWS', 'AUTHORS', 
                          \ 'BUGS', 'README.md']     " Project root markers
let g:ctrlp_clear_cache_on_exit = 0                  " Persistent cache
let g:ctrlp_cache_dir = vimfiles . '/.ctrlp_cache'   " ...
let g:ctrlp_show_hidden = 1                          " Show hidden files
let g:ctrlp_follow_symlinks = 1                      " Follow symlinks
" <leader>f[ftbl] for files/tags/buffers/lines
nnoremap <leader>ff :CtrlP<cr>
nnoremap <leader>ft :CtrlPBufTagAll<cr>
nnoremap <leader>fb :CtrlPBuffer<cr>
nnoremap <leader>fl :CtrlPLine<cr>

""" showmarks - shows marks in SignColumn
NeoBundle 'ShowMarks'
" Hide special marks
let showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
let showmarks_textupper = "\t" " Don't display mark markers
let showmarks_textlower = "\t" " ...
let showmarks_textother = "\t" " ...
" <leader>[mM] to clear one/all marks
nnoremap <leader>m :ShowMarksClearMark<cr>
nnoremap <leader>M :ShowMarksClearAll<cr>
highlight ShowMarksHLl ctermfg=150 guifg=#afdf87 ctermbg=239 guibg=#4e4e4e
highlight ShowMarksHLu ctermfg=150 guifg=#afdf87 ctermbg=239 guibg=#4e4e4e
highlight ShowMarksHLo ctermfg=150 guifg=#afdf87 ctermbg=239 guibg=#4e4e4e
highlight ShowMarksHLm ctermfg=174 guifg=#df8787 ctermbg=239 guibg=#4e4e4e

""" Gundo - graphical undo tree
if has("python")
    NeoBundle 'http://bitbucket.org/sjl/gundo.vim'
    let g:gundo_preview_bottom = 1                   " Bigger preview window
    let g:gundo_close_on_revert = 1                  " Autoclose
    let g:gundo_tree_statusline = "Gundo tree"       " Nicer statuslines
    let g:gundo_preview_statusline = "Gundo preview" " ...
    " <leader>u to toggle undo tree
    noremap <leader>u :GundoToggle<cr><cr>
endif

""" YankRing - clipboard management
NeoBundle 'YankRing.vim'
" <leader>p to toggle paste list
nnoremap <leader>p :YRShow<cr>
" history file location
let g:yankring_history_dir = vimfiles . "/bundle/YankRing.vim"

""" Surround - easily surround text by braces
NeoBundle 'tpope/vim-surround'

""" Scratch - scratchpad
NeoBundle 'scratch.vim'
let g:scratchpad_shown = 0
function! ScratchpadToggle()
    if (g:scratchpad_shown == 0)
        let g:scratchpad_shown = 1
        Sscratch
    else
        let g:scratchpad_shown = 0
        bdelete "__Scratch__"
    endif
endfunction
" <leader>s to toggle scratchpad
nnoremap <leader>s :call ScratchpadToggle()<cr>

""" NERDtree - file manager
NeoBundle 'scrooloose/nerdtree'
let NERDTreeShowHidden=1          " Show hidden files
let NERDTreeHighlightCursorline=1 " Highlight the selected entry in the tree
let NERDTreeMouseMode=3           " Use single-click
let NERDTreeIgnore=[ '\.pyc$', '\.pyo$', '\.py\$class$', '\.obj$',
            \ '\.o$', '\.so$', '\.egg$', '^\.git$' ]
" <leader>n to toggle NERDtree
nnoremap <leader>n :NERDTreeToggle<cr>

""" NERDcommenter - easy commenting
" does own keybindings :(
NeoBundle 'scrooloose/nerdcommenter'
let NERDSpaceDelims=1 " Use spaces around comment chars

""" fugitive - git integration
NeoBundle 'tpope/vim-fugitive'
" gd: git diff (as text)
nnoremap <leader>gd :Gvsplit! diff<cr>
" gv: visual diff
nnoremap <leader>gv :Gdiff<cr>
" gV: (attempt to) close visual diff
nnoremap <leader>gV <C-w>h:q<cr><C-^>
" ge: Prompt to edit file
nnoremap <leader>ge :Gedit<Space>
" gb: Blame
nnoremap <leader>gb :Gblame<cr>
" gm: Prompt to move
nnoremap <leader>gm :Gmove<Space>
" gm: Prompt to remove
nnoremap <leader>gr :Gremove<Space>
" gm: Prompt to grep
nnoremap <leader>gg :Ggrep<Space>
" gl: Show git log
nnoremap <leader>gl :Glog<cr><cr>:cw<cr>
" gr: (read) checkout --
nnoremap <leader>gr :Gread<cr>
" gx: prompt to eXecute git command
nnoremap <leader>gx :Git<Space>
" gc: git commit
nnoremap <leader>gc :Gcommit<cr>
" gC: git commit --amend
nnoremap <leader>gC :Gcommit --amend<cr>
" gp: git commit --patch
nnoremap <leader>gp :Gcommit --patch<cr>
" gs: git status
nnoremap <leader>gs :Gstatus<cr>

""" EasyTags (automatical tag generation) / tag bar (tag sidebar)
NeoBundle 'xolox/vim-misc'                  " Needed by easytags
NeoBundle 'xolox/vim-easytags'
let g:easytags_include_members = 1          " Include struct members
let g:easytags_dynamic_files = 1            " Reuse project-specific files
let g:easytags_by_filetype = vimfiles . "/tags" " Use tags per filetype
let g:easytags_updatetime_warn = 0          " Don't warn about fast updatetime
let g:easytags_resolve_links = 1            " Resolve symbolic links
let g:easytags_auto_highlight = 0           " Don't highlight tags
let g:easytags_events = ['BufWritePost', 'BufRead'] " Update on reading/saving
NeoBundle 'majutsushi/tagbar'
" <leader>t: toggle tagbar
nnoremap <leader>t :TagbarToggle<cr>

""" Show trailing whitespace
NeoBundle 'ShowTrailingWhitespace'

""" Automatically save/restore sessions
"NeoBundle 'https://code.google.com/p/vim-plugin-autosess/'

""" Vim-Wiki
NeoBundle 'vimwiki'

""" Startify
NeoBundle 'mhinz/vim-startify'

""" My own vimfiles
NeoBundle 'git://cmpl.cc/vimfiles/'

"""""" Statusline
if has("statusline")
    function! Gitstatus()
      if !exists('b:git_dir')
        return ''
      endif
      return ' ' . fugitive#head(7) . ' '
    endfunction
    " Git branch (red)
    highlight User1 ctermbg=174 ctermfg=235 guibg=#df8787 guifg=#262626
    " file name / cwd (green)
    highlight User2 ctermbg=150 ctermfg=235 guibg=#afdf87 guifg=#262626
    " encoding / percentage
    highlight User3 ctermbg=247 ctermfg=235 guibg=#9e9e9e guifg=#262626
    " CRLF / lines
    highlight User4 ctermbg=245 ctermfg=235 guibg=#8a8a8a guifg=#262626
    " filetype / columns
    highlight User5 ctermbg=243 ctermfg=235 guibg=#767676 guifg=#262626
    " flags / tab
    highlight User6 ctermbg=241 ctermfg=235 guibg=#626262 guifg=#262626
    set statusline=
    set statusline+=%1*
    set statusline+=%{Gitstatus()}                      " git branch
    set statusline+=%2*
    set statusline+=\ %t                                " filename
    set statusline+=\ %3*
    set statusline+=\ %{strlen(&fenc)?&fenc:'none'}     " file encoding
    set statusline+=\ %4*
    set statusline+=\ %{&ff}                            " file format
    set statusline+=\ %5*
    set statusline+=\ %{strlen(&ft)?&ft:'plain'}        " filetype
    set statusline+=\ %6*
    set statusline+=\ %{&mod?'M':'m'}                   " modified flag
    set statusline+=%{&ro?'R':'r'}                      " read only flag
    set statusline+=%{&paste?'P':'p'}                   " paste flag
    set statusline+=\ %*
    set statusline+=\ %a                                " argument list
    set statusline+=%=                                  " left/right separator
    set statusline+=%6*
    set statusline+=\ %{strlen(&et)?&sts.'\ spc':'tab'} " space/tab indicator
    set statusline+=\ %5*
    set statusline+=\ C:%2c/%2{len(getline('.'))}       " cursor column
    set statusline+=\ %4*
    set statusline+=\ L:%3l/%3L                         " cursor line/total lines
    set statusline+=\ %3*
    set statusline+=\ %P                                " percent through file
    set statusline+=\ %2*
    set statusline+=%<                                  " truncate here if too long
    set statusline+=\ %0.20{getcwd()}                   " current working dir
    set statusline+=\ "                                 " trailing space
endif

"""""" Autocommands
if has("autocmd")
    autocmd FileType mail set tw=70 " Text width for mail
    " When editing a file, always jump to the last cursor position
    autocmd BufReadPost *
        \ if line("'\"") && line("'\"") <= line("$") |
        \   exe "normal `\"" |
        \ endif
    " Load skeletons
    autocmd BufNewFile *.py 0r expand(vimfiles . "/skeletons/py.py")
    autocmd BufNewFile *.cs 0r expand(vimfiles . "/skeletons/cs.cs")
    " Use K for vim-help in vim-files
    autocmd filetype vim noremap K <Esc>:help <C-r><C-w><cr>
    " Automatically open quickfix after grep
    autocmd QuickFixCmdPost *grep* cwindow
    " Force -o for C files
    autocmd FileType c set fo-=o
    " Close vim if NERDTree is only window
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
    " Auto-reload vimrc on write
    autocmd BufWritePost .vimrc source %
endif

"""""" Custom mappings
" f12: Compile and show error list
noremap <F12> :make<Enter>:cw<Enter>
" Avoid accidental hits of <F1> while aiming for <Esc>
noremap! <F1> <Esc>
" Swap implementations of ` and ' jump to markers
" By default, ' jumps to the marked line, ` jumps to the marked line and
" column, so swap them
nnoremap ' `
nnoremap ` '
" <leader><space>: Clear search highlighting
nnoremap <silent> <leader><space> :nohlsearch<cr>
" <leader>= / <leader>-: underlining
nnoremap <leader>= yypVr=k
nnoremap <leader>- yypVr-k
" Use tab to switch between braces
nnoremap <tab> %
vnoremap <tab> %
" Use <leader>@ to repeat a macro line-wise
nnoremap <leader>@ :normal! @
" Use C-hjkl to navigate windows
noremap <C-J> <C-W>j
noremap <C-K> <C-W>k
noremap <C-H> <C-W>h
noremap <C-L> <C-W>l
" <leader>w: Write
noremap <leader>w :w<cr>
" <leader>P: Paste mode
noremap <leader>P :setlocal paste!<cr>

"""""" Misc
" Use make as default compiler
if s:neobootstrapdone == 1
    compiler make
endif
" Write with sudo with :W
com! W w<bang> !sudo tee % >/dev/null
" Highlight tw+1
hi ColorColumn ctermbg=235 guibg=#262626
set cc=+1

"""""" Finish NeoBundle Bootstrap
if s:neobootstrapdone == 0
    execute ':NeoBundleInstall'
    execute ':NeoBundleCheck'
    if !isdirectory(vimfiles . '/bundle/ShowMarks/doc') | call mkdir(vimfiles . '/bundle/ShowMarks/doc') | endif
    source $MYVIMRC
endif
