# vim-searchlight

Vim-searchlight highlights Vim's current search match.

## Requirements

Searchlight requires Vim 8+ with timer support. It is tested on Vim 8.1.

## Experimental

Searchlight is an experiment. Your mileage my vary. Might not work with other plugins or your `vimrc`.

## Installation

Follow your favorite plugin/runtimepath manager's instructions.

If you choose manual installation, use Vim's packages. Clone into one of the following directories:

    $HOME/.vim/pack/bundle/start/        on Unix-like systems
    $HOME\vimfiles\pack\bundle\start\    on Windows

## Commands

Use `:Searchlight` to enable and `:Searchlight!` to disable.

## Customization

Searchlight uses the `Searchlight` highlight group. It defaults to `ErrorMsg`. Change by doing:

    highlight link Searchlight Incsearch

Searchlight's highlighting can be triggered manually via `:1Searchlight`. This might be required for some mappings or plugin compatibility.

Searchlight is activated by default on startup. To prevent this set `g:searchlight_disable_on_startup`. e.g.

    let g:searchlight_disable_on_startup = 1

## Background

This is an experiment to implement current search highlighting without any mappings. Thank-you to both [vim-searchhi](https://github.com/qxxxb/vim-searchhi) & [vim-searchant](https://github.com/timakro/vim-searchant) which inspired this plugin.

## Known Issues

When using any search command like: `*`, `#`, etc at the beginning of a match and it is the only match and therefore will not cause the cursor to move, will not trigger searchlight.

One solution would be to trigger an update with mappings like so:

    nnoremap <silent> * *:1Searchlight<cr>
    nnoremap <silent> # #:1Searchlight<cr>

However, this goes against the goal of having no mappings. Sad panda
