"==================================================
" File:         code_complete.vim
" Brief:        function parameter complete, code snippets, and much more.
" Author:       Mingbai <mbbill AT gmail DOT com>
" Last Change:  2007-07-20 17:39:10
" Version:      2.7
"
" Install:      1. Put code_complete.vim to plugin
"                  directory.
"               2. Use the command below to create tags
"                  file including signature field.
"                  ctags -R --c-kinds=+p --fields=+S .
"
" Usage:
"           hotkey:
"               "<tab>" (default value of g:completekey)
"               Do all the jobs with this key, see
"           example:
"               press <tab> after function name and (
"                 foo ( <tab>
"               becomes:
"                 foo ( `<first param>`,`<second param>` )
"               press <tab> after code template
"                 if <tab>
"               becomes:
"                 if( `<...>` )
"                 {
"                     `<...>`
"                 }
"
"
"           variables:
"
"               g:completekey
"                   the key used to complete function
"                   parameters and key words.
"
"               g:rs, g:re
"                   region start and stop
"               you can change them as you like.
"
"               g:user_defined_snippets
"                   file name of user defined snippets.
"
"           key words:
"               see "templates" section.
"==================================================

if v:version < 700
    finish
endif

" Variable Definations: {{{1
" options, define them as you like in vimrc:
if !exists("g:completekey")
    let g:completekey = "<tab>"   "hotkey
endif

if !exists("g:rs")
    let g:rs = '`<'    "region start
endif

if !exists("g:re")
    let g:re = '>`'    "region stop
endif

if !exists("g:user_defined_snippets")
    let g:user_defined_snippets = "$VIMRUNTIME/plugin/my_snippets.vim"
endif

" ----------------------------
let s:expanded = 0  "in case of inserting char after expand
let s:signature_list = []
let s:jumppos = -1
let s:doappend = 1

" Autocommands: {{{1
autocmd BufReadPost,BufNewFile * call CodeCompleteStart()

" Menus:
menu <silent>       &Tools.Code\ Complete\ Start          :call CodeCompleteStart()<CR>
menu <silent>       &Tools.Code\ Complete\ Stop           :call CodeCompleteStop()<CR>

" Function Definations: {{{1

function! CodeCompleteStart()
    exec "silent! iunmap  <buffer> ".g:completekey
    exec "inoremap <buffer> ".g:completekey." <c-r>=CodeComplete()<cr><c-r>=SwitchRegion()<cr>"
endfunction

function! CodeCompleteStop()
    exec "silent! iunmap <buffer> ".g:completekey
endfunction

function! FunctionComplete(fun)
    let s:signature_list=[]
    let signature_word=[]
    let ftags=taglist("^".a:fun."$")
    if type(ftags)==type(0) || ((type(ftags)==type([])) && ftags==[])
        return ''
    endif
    for i in ftags
        if has_key(i,'kind') && has_key(i,'name') && has_key(i,'signature')
            if (i.kind=='p' || i.kind=='f') && i.name==a:fun  " p is declare, f is defination
                if match(i.signature,'(\s*void\s*)')<0 && match(i.signature,'(\s*)')<0
                    let tmp=substitute(i.signature,', ',g:re.', '.g:rs,'g')
                    let tmp=substitute(tmp,'(\(.*\))',g:rs.'\1'.g:re.')','g')
                else
                    let tmp=''
                endif
                if (tmp != '') && (index(signature_word,tmp) == -1)
                    let signature_word+=[tmp]
                    let item={}
                    let item['word']=tmp
                    let item['menu']=i.filename
                    let s:signature_list+=[item]
                endif
            endif
        endif
    endfor
    if s:signature_list==[]
        return ')'
    endif
    if len(s:signature_list)==1
        return s:signature_list[0]['word']
    else
        call  complete(col('.'),s:signature_list)
        return ''
    endif
endfunction

function! ExpandTemplate(cword)
    "let cword = substitute(getline('.')[:(col('.')-2)],'\zs.*\W\ze\w*$','','g')
    if has_key(g:template,&ft)
        if has_key(g:template[&ft],a:cword)
            let s:jumppos = line('.')
            return "\<c-w>" . g:template[&ft][a:cword]
        endif
    endif
    if has_key(g:template['_'],a:cword)
        let s:jumppos = line('.')
        return "\<c-w>" . g:template['_'][a:cword]
    endif
    return ''
endfunction

function! SwitchRegion()
    if len(s:signature_list)>1
        let s:signature_list=[]
        return ''
    endif
    if s:jumppos != -1
        call cursor(s:jumppos,0)
        let s:jumppos = -1
    endif
    if match(getline('.'),g:rs.'.*'.g:re)!=-1 || search(g:rs.'.\{-}'.g:re)!=0
        normal 0
        call search(g:rs,'c',line('.'))
        normal v
        call search(g:re,'e',line('.'))
        if &selection == "exclusive"
            exec "norm " . "\<right>"
        endif
        return "\<c-\>\<c-n>gvo\<c-g>"
    else
        if s:doappend == 1
            if g:completekey == "<tab>"
                return "\<tab>"
            endif
        endif
        return ''
    endif
endfunction

function! CodeComplete()
    let s:doappend = 1
    let function_name = matchstr(getline('.')[:(col('.')-2)],'\zs\w*\ze\s*(\s*$')
    if function_name != ''
        let funcres = FunctionComplete(function_name)
        if funcres != ''
            let s:doappend = 0
        endif
        return funcres
    else
        let template_name = substitute(getline('.')[:(col('.')-2)],'\zs.*\W\ze\w*$','','g')
        let tempres = ExpandTemplate(template_name)
        if tempres != ''
            let s:doappend = 0
        endif
        return tempres
    endif
endfunction


" [Get converted file name like __THIS_FILE__ ]
function! GetFileName()
    let filename=expand("%:t")
    let filename=toupper(filename)
    let _name=substitute(filename,'\.','_',"g")
    let _name="__"._name."__"
    return _name
endfunction

" [Just get file name what they like]
function! GetNormalFileName()
  let filename=expand("%:t")
  return filename
endfunction

" Templates: {{{1
" to add templates for new file type, see below
"
" "some new file type
" let g:template['newft'] = {}
" let g:template['newft']['keyword'] = "some abbrevation"
" let g:template['newft']['anotherkeyword'] = "another abbrevation"
" ...
"
" ---------------------------------------------
" C templates
let g:template = {}
let g:template['c'] = {}
let g:template['c']['co'] = "/*  */\<left>\<left>\<left>"
let g:template['c']['cc'] = "/**<  */\<left>\<left>\<left>"
let g:template['c']['df'] = "#define  "
let g:template['c']['ic'] = "#include \"\"\<left>"
let g:template['c']['ii'] = "#include <>\<left>"
let g:template['c']['ff'] = "#ifndef  \<c-r>=GetFileName()\<cr>\<CR>#define  \<c-r>=GetFileName()\<cr>".
            \repeat("\<cr>",5)."#endif  /*\<c-r>=GetFileName()\<cr>*/".repeat("\<up>",3).
            \g:rs."code here".g:re
let g:template['c']['for'] = "for( ".g:rs."...".g:re." ; ".g:rs."...".g:re." ; ".g:rs."...".g:re." )\<cr>{\<cr>".
            \g:rs."...".g:re."\<cr>}\<cr>"
let g:template['c']['main'] = "int main(int argc, char \*argv\[\])\<cr>{\<cr>".g:rs."...".g:re."\<cr>}"
let g:template['c']['switch'] = "switch ( ".g:rs."...".g:re." )\<cr>{\<cr>case ".g:rs."...".g:re." :\<cr>break;\<cr>case ".
            \g:rs."...".g:re." :\<cr>break;\<cr>default :\<cr>break;\<cr>}"
let g:template['c']['if'] = "if( ".g:rs."...".g:re." )\<cr>{\<cr>".g:rs."...".g:re."\<cr>}"
let g:template['c']['while'] = "while( ".g:rs."...".g:re." )\<cr>{\<cr>".g:rs."...".g:re."\<cr>}"
let g:template['c']['ife'] = "if( ".g:rs."...".g:re." )\<cr>{\<cr>".g:rs."...".g:re."\<cr>} else\<cr>{\<cr>".g:rs."...".
            \g:re."\<cr>}"
" C && C++ Comment
let name="������"
let mail="bluebird.shao@gmail.com"
let company="�㶫�Ϸ�����Ƽ����޹�˾���������ҵ��"

let g:template['c']['head'] = "/*\<cr>Copyright (c) 2009, ".company."\<cr>".
      \"All rights reserved.\<cr>\<cr>".
      \"�ļ����ƣ�\<c-r>=GetNormalFileName()\<cr>\<cr>".
      \"ժ    Ҫ��".g:rs."��Ҫ�����ļ�����".g:re."\<cr>\<cr>��ǰ�汾��".g:rs."...".g:re."\<cr>".
      \"�� �� �ߣ�".name."\<cr>��    �䣺".mail."\<cr>".
      \"�������ڣ�\<c-r>=strftime(\"%Y-%m-%d %H:%M:%S\")\<cr>\<cr>\<left>/"
let g:template['c']['coc'] = "/*\<cr>�� ����".g:rs."...".g:re."\<cr>".
      \"�����ռ䣺".g:rs."...".g:re."\<cr>".
      \"�� ����".g:rs."...".g:re."\<cr>\<cr>".
      \"�����ߣ�".name."\<cr>".
      \"��  �䣺".mail."\<cr>".
      \"�������ڣ�\<c-r>=strftime(\"%Y-%m-%d %H:%M:%S\")\<cr>\<cr>\<left>/"
let g:template['c']['cof'] = "/*\<cr>��������".g:rs."function name".g:re."\<cr>".
      \"�������ܣ�".g:rs."...".g:re."\<cr>".
      \"��    �ã�".g:rs."�����������õĺ����嵥".g:re."\<cr>".
      \"�� �� �ã�".g:rs."���ñ������ĺ����嵥".g:re."\<cr>".
      \"���������".g:rs."...".g:re."\<cr>".
      \"���������".g:rs."...".g:re."\<cr>".
      \"��������ֵ��".g:rs."...".g:re."\<cr>\<cr>".
      \"�����ߣ�".name."\<cr>".
      \"���䣺".mail."\<cr>".
      \"�������ڣ�\<c-r>=strftime(\"%Y-%m-%d %H:%M:%S\")\<cr>\<cr>\<left>/"
      

" ---------------------------------------------
" C++ templates
let g:template['cpp'] = g:template['c']

" ---------------------------------------------
" php templates
let g:template['php'] = g:template['c']
let g:template['php']['ht'] = "<html>\<cr><head><title>".g:rs."...".g:re."</title></head>\<cr><body>\<cr>".
      \g:rs."...".g:re."\<cr></body>\<cr></html>"
let g:template['php']['form'] = "<form action=".g:rs."...".g:re." method=".g:rs."...".g:re.">\<cr>".
      \g:rs."...".g:re."\<cr></form>"
let g:template['php']['input'] = "<input type=".g:rs."...".g:re." size=".g:rs."...".g:re." name=".
      \g:rs."...".g:re.">"
let g:template['php']['ips'] = "<input type=".g:rs."...".g:re." value=".g:rs."...".g:re.">"
let g:template['php']['iph'] = "<input type=".g:rs."...".g:re." name=".g:rs."...".g:re." value=".
      \g:rs."...".g:re.">"
let g:template['php']['ref'] = "<a href=".g:rs."...".g:re.">".g:rs."...".g:re."</a>"
let g:template['php']['ph'] = "<?php\<cr>".g:rs."...".g:re."\<cr>?>"
let g:template['php']['div'] = "<div align=".g:rs."...".g:re.">\<cr>".
      \g:rs."...".g:re."\<cr></div>"
let g:template['php']['ta'] = "<textarea name=".g:rs."...".g:re." rows=".g:rs."...".g:re." cols=".
      \g:rs."...".g:re." wrap=soft></textarea>"


" ---------------------------------------------
" html templates
let g:template['html'] = g:template['php']

" ---------------------------------------------
" common templates
let g:template['_'] = {}
let g:template['_']['xt'] = "\<c-r>=strftime(\"%Y-%m-%d %H:%M:%S\")\<cr>"

" ---------------------------------------------
" load user defined snippets
exec "silent! runtime ".g:user_defined_snippets


" vim: set ft=vim ff=unix fdm=marker :