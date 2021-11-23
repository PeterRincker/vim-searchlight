if exists('g:loaded_searchlight') || &cp || !exists('##CursorMoved') || !has_key(v:, 'hlsearch')
  finish
endif
let g:loaded_searchlight = 1

let s:enable = !get(g:, 'searchlight_disable_on_startup', 0)

highlight default link Searchlight ErrorMsg

command! -bar -bang -range=-1 Searchlight
      \ if <count> == -1 |
      \   let s:enable = <bang>1 |
      \   call s:activate() |
      \ else |
      \   call s:trigger() |
      \ endif

map <expr> <SID>(searchlight) <SID>mapping()
nnoremap <script> <Plug>(searchlight) <SID>(searchlight)

augroup SearchlightActivate
  autocmd!
  autocmd OptionSet hlsearch if v:option_new != v:option_old | call <SID>activate(v:option_new) | endif
augroup END

function s:activate(...)
  let hlsearch = a:0 ? a:1 : &hlsearch
  if s:enable && hlsearch
    call s:start()
  else
    call s:stop()
  endif
endfunction

function s:start()
  augroup Searchlight
    autocmd!
    if exists('*timer_start')
      autocmd CursorMoved,WinEnter,CmdlineLeave * if !get(s:, 'timer', 0) | let s:timer = timer_start(1, {-> <SID>update()}) | endif
    else 
      autocmd CursorMoved,WinEnter,CmdlineLeave * call <SID>update()
    endif
    autocmd InsertLeave * call <SID>update()
    autocmd InsertEnter,WinLeave,CmdlineEnter * call <SID>clear()
  augroup END
  call s:trigger()
endfunction

function s:stop()
  call s:clear()
  augroup Searchlight
    autocmd!
  augroup END
endfunction

function s:clear(...)
  silent! call matchdelete(get(w:, 'searchlight_id', -1))
endfunction

function s:mapping()
  call s:trigger()
  return ''
endfunction

function s:trigger()
  if exists('*timer_start')
    if !get(s:, 'timer', 0)
      let s:timer = timer_start(1, {-> s:update() })
    endif
  else
    call s:update()
  endif
endfunction

function! s:update()
  let s:timer = 0
  let id = get(w:, 'searchlight_id', -1)
  if id != -1
    silent! call matchdelete(id)
  endif

  if !v:hlsearch || @/ == '' || !s:enable || mode() == 'r'
    return
  endif

  let view = winsaveview()

  try
    let timeout = get(g:, 'searchlight_timeout', 30)
    let pos = [line('.'), col('.')]
    let context = get(g:, 'searchlight_context', 25)
    let top = max([1, pos[0] - context])
    let bottom = pos[0] + context

    try
      let start = searchpos(@/, 'bc', top, timeout)
    catch /^Vim\%((\a\+)\)\=:E/
      return
    endtry

    if start == [0, 0]
      return
    endif

    let z_less_pat = substitute(@/, '\v%(%(\\\\)*\\)@<!%(\\z[se])', '', 'g')
    if z_less_pat != @/
      call search(z_less_pat, 'bc', top, timeout)
    endif

    " Search for zero-width match by forcing the start of the match (\zs) at the end of the pattern
    let zero_width_search = searchpos(@/ . '\m\zs', 'cn', bottom, timeout)

    if zero_width_search == start
      " Found a zero-width match. The end is the same as start
      let end = start
    else
      let end = searchpos(@/, 'cen', bottom, timeout)
      if end == [0, 0]
        return
      endif
    endif

    let is_inside = s:cmp(pos, start) >= 0 && s:cmp(pos, end) <= 0

    if is_inside
      let pat = '\m\%' . start[0] . 'l\%' . start[1] . 'c'
      if start != end
        let pat .= '\_.*\%' . end[0] . 'l\%' . end[1] . 'c.'
      endif
      let w:searchlight_id = matchadd('Searchlight', pat, get(g:, 'searchlight_priority', 10), get(w:, 'searchlight_id', -1))
    endif
  finally
    call winrestview(view)
  endtry
endfunction

function! s:cmp(a, b)
  for i in range(len(a:a))
    if a:a[i] < a:b[i]
      return -1
    elseif a:a[i] > a:b[i]
      return 1
    endif
  endfor
  return 0
endfunction

if s:enable && &hlsearch
  call s:start()
endif
