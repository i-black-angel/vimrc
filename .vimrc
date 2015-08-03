"""""""""""""""""""""""""""""""""""""""""""""""
"General
"
"This .vimrc suit to "vim for unix/linux" edition
""""""""""""""""""""""""""""""""""""""""""""""""

"For ctags, then it can find the 'tags' file even not in current directory
set tags=tags;/
set tags+=/usr/include/tags

filetype plugin indent on
set nocp
filetype plugin on
"Get out of VI's compatible mode..
"set nocompatible
"
""Sets how many lines of history VIM har to remember
set history=400

"""""""""""""""""""""""""""""""""""""""
" Gvim Settings
""""""""""""""""""""""""""""""""""""""
" No menu
set guioptions=menu
"set go-=mT
" Make gvim maximum when startup  
autocmd GUIEnter * winsize 1280 1024

" Set file encodings and let terminal encoding = encoding
" To read Chinese characters
let &termencoding=&encoding
set fileencodings=utf-8,gbk,cp936,gb2312

"Set to auto read when a file is changed from the outside
set autoread
"
""Have the mouse enabled all the time:
"when you need to copy from vim, maybe you have to ':set mouse=' first
"set mouse=a
"
""""""""""""""""""""""""""""""""""""""
" Colors and Fonts
" """""""""""""""""""""""""""""""""""""
" "Enable syntax highlight
 syntax enable
"
" "set colorscheme
 colorscheme oceandeep
" """""""""""""""""""""""""""""""""""""
" " VIM userinterface
" """""""""""""""""""""""""""""""""""""
" "Set 7 lines to the curors away from the border- when moving vertical..
 set so=7
"
" "Turn on WiLd menu
 set wildmenu
"
" "Always show current position
 set ruler
"
" "The commandbar is 2 high
 set cmdheight=2
"
" "Show line number
 set nu
"
" "Set backspace
 set backspace=eol,start,indent
"
" "Bbackspace and cursor keys wrap to
 set whichwrap+=<,>,h,l
"
" "show matching bracets
 set showmatch
"
" "How many tenths of a second to blink
 set mat=2
"
"Highlight search things
set hlsearch
"imediately show the search result
set is
set ignorecase
set smartcase
set nowrapscan

"set autoindent
set ai

"No error bells
set noerrorbells

"something like the firefox's search
set incsearch

" show state bar all the times
set laststatus=2

" """""""""""""""""""""""""""""""""""""
" " Folding
" """""""""""""""""""""""""""""""""""""
" "Enable folding, I find it very useful
 set fen
 set fdl=0
"
"
" """""""""""""""""""""""""""""""""""""
" " Text options
 """""""""""""""""""""""""""""""""""""
 set expandtab
 set shiftwidth=2
 set ambiwidth=double
 set smarttab
 "Set Tab=4 spaces
 set ts=4
 set lbr
 set tw=78
 set selection=inclusive
"    """"""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""
" Text format 
" """"""""""""""""""""""""""""""""""""""
" set auto indent for c program
set smartindent
" use c style indent
set cindent

" C compile & run
 map <F5> :call CompileRunGcc()<CR>
 func! CompileRunGcc()
 exec "w"
 exec "!gcc % -o %<"
 exec "! ./%<"
 endfunc 

" These are very useful when programming.
" Follow are for C.
ab inc #include <stdio.h><CR>#include <stdlib.h><CR>#include <math.h><CR>#include <string.h><CR>#include <time.h><CR>#include <ctype.h><CR>
ab rz return 0
norea re return
iab im int main(int argc, char **agrv)<CR>{<CR>}<Up>
iab ff for (i = 0; i <; ++i)<CR>{<CR>}<ESC>bbbbbei
norea ffj for (j = 0; j <; ++j)<CR>{<CR>}<ESC>bbbbbei
iab ife if ()<CR>{<CR>}<CR>else<CR>{<CR>}<ESC>bbbbbei
iab ui unsigned int
norea de #define
norea ty typedef
norea sa clock_t start = clock();
norea ed clock_t end = clock();<CR>printf ("time use:\n\t%lf seconds.\n", (double)(end-start)/CLOCKS_PER_SEC);
norea sc sc<C-p>
iab pn printf("\n")
iab db double
iab fl float
norea sof sizeof
norea ull unsigned long long

" And from here are for C++
iab inx #include <iostream><CR>#include <vector><CR>#include <list><CR>#include <string><CR>#include <stack><CR>#include <queue><CR>#include <map><CR>#include <set><CR>#include <algorithm><CR>#include <deque><CR>#include <cstdlib><CR>#include <bitset><CR>#include <functional><CR>#include <numeric><CR>#include <utility><CR>#include <sstream><CR>#include <iomanip><CR>#include <cstdio><CR>#include <cmath><CR>#include <cstdlib><CR>#include <ctime><CR>#include <cctype><CR><CR>using namespace std;<CR>
norea tvi typedef vector<int> vi;
norea tvs typedef vector<string> vs;
norea tvvi typedef vector<vi> vvi;
norea fp for (unsigned int i = 0; i <; ++i)<CR>{<CR>}<ESC>bbbbbei
norea fpj for (unsigned int j = 0; j <; ++j)<CR>{<CR>}<ESC>bbbbbei

" From here are for Java
iab spn System.out.println
norea pc public class<CR>{<CR>}<ESC>bbea
iab pm public static void main(String[] argv)<CR>{<CR>}<UP>

" omnicppcomplete tags
"map <C-F12> :!ctags -R --c++-kinds=+ps --fields=+iaS --extra=+q .<CR>
map <C-F12> :call CtagsTags()<CR>
func! CtagsTags()
  exec "wa"
  exec "!ctags -R --c++-kinds=+ps --fields=+iaS --extra=+q ."
endfunc

" Use <C-L> in insert-mode to add ";" in the end of a line
imap <C-L> <ESC>A;<CR>

" Close preview window(s)
map <F8> <C-W><C-Z><CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" vimplate
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let Vimplate="/usr/bin/vimplate"

