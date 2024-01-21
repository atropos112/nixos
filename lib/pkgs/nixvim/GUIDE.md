# NixVim

## Introduction
Befor dveling into why using NixVim lets answer first two other questions

### Why use NeoVim
It is fast, its versatile, if given a lot of time one can become much faster with it than something like VsCode or Rider or whatever other IDE. Its not free however, you do pay a lot of hours setting it up, and then crazy number of hours getting used to it but if being developer is your career goal, in my opinion its a worthy investment.

### Why not use a native neovim frameowork LunarVim or LazyVim

A neovim framework seems to reduce the "upfront cost" by not requiring you to do much setup, its all here to begin with, and its extensible is the sales pitch. Its all lazy loaded so no bloat at runtime even though they do pack milion packages into it.

There are two neovim frameworks I have tried myself for many months [LunarVim](https://www.lunarvim.org) and [LazyVim](https://www.lazyvim.org), mind you I used them because I wanted to reduce my upfront cost, that was the aim of it instead of buinding my own configuration from scratch. Over time I have realised this was a bad idea, here are 3 reasons why

1. Some of them pester you to update the underlying packages, and they do so a lot. If you don't update, the moment you update neovim past a certain version you will see breakages. I guess at this point you think "duh update both", in practice however I always have the thing break after a month or two, and it's unclear why since I changed not a single lua file. Deleting all of the stuff (using their uninstaller) and re-installing often solves the issue, temporarily.
2. They do give it a good attempt (through good documentation and sometimes YouTube videos) to help you work with the lua code they built, but to me this was extremely confusing as I was constantly having to adjust my way of thinking to theirs, after some fidling I would get what I wanted but I didn't feel like I understood how my changes propagated throughout the framework.
3. Lazy loading means only packages needed are loaded so having milion packages doesn't bloat it as much, but if you try to figure out all the functionalities and how to do X and Y, you better be ready to watch their 1000 hours of YouTube videos because otherwise you are out of luck, and to figure this out from the framework itself is very difficult because of how much stuff this framework covers (most of that stuff you probably will never need or even know it exists).

### What is NixVim

Is a Nix module that allows one to setup and configure neovim configuration, as opposed to using lua/vim languages. In a way it is framework-like becaause a lot of the setup work has been done by them, want a theme just put
```nix
{
  ...
  programs.nixvim.colorschemes.onedark.enable = true;
}
```
how is this eventually translated into lua/vim code that makes the theme work? No idea, the NixVim framework does it. This is where you say, so it is a framework like the above. And yes, yes it is but unlike the above you start with nothing and in modular fashion add stuff, you still have to add that theme, you don't get one by default, you want a formatter, you want to debug? You have to set them up in a way, the difference from writing the lua/vim code yourself is you avoid a lot of obvious boilerplate code that basically everyone has to set.

# Implementation

Lets start with a wish list:
- Syntax highlighting
- Copilot support
- Auto completions

- Go-to definition on each programming language.
- Formatting on save, of affected lines.
- Static code analysis for simple typos and errors during the writting.
- Debugging in all programming languages
- Windowing of multiple files at the same time and a fuzzy finder for files and live grep.
- Support for testing in the programming languages of choice. You can just run the tests from terminal but if you have a lot of tests, that is hard to manuver around.
- A easily togglable terminal for quick terminal commands.
- Clipboard and other small parts to work with the rest of the OS, this feels like it shouldn't be on the wishlist, but apparently thats not "common sense" enough for vim default settings.

It is a lot to ask for from a text editor but big IDEs like Rider have all of those (maybe with some plugin support) so I can't see a reason why vim shouldn't be able to.

## Syntax highlighting
Use tree-sitter. It will automagically get you the correct parsers for each languge in NixVim so all you need to do is
```nix
{
  ...
  programs.nixvim.plugins.treesitter.enable = true;
}
```
In native neovim one has to install treesitter plugin and then do `:TSInstall <language_to_install>` but in NixVim that is done for you.

## Copilot support
Another plugin
```nix
{
  ...
  programs.nixvim.plugins.copilot-lua = {
    enable = true;
    suggestion = {
      autoTrigger = true;
      keymap.accept = "<C-CR>";
    };
  };
}
```
Here `autoTrigger` option has Copilot constantly try to find suggestions for you (same as in other IDEs like VsCode or JetBrains family). To accept the suggestion this is where `keymap.accept` comes in, in the example above `<C-CR>` means Ctrl + Enter.

## Auto completion
The nvim-cmp plugin is a "completion engine" which does all the auto-suggestions. I added `luasnip` as the snippet.expand to it
```nix
{
  ...
  programs.nixvim.plugins = {
    cmp_luasnip.enable = true;

    nvim-cmp = {
      enable = true;
      autoEnableSources = true;
      snippet.expand = "luasnip";
      sources = [
        {name = "nvim_lsp";}
        {name = "buffer";}
        {name = "path";}
      ];
      mapping = {
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<Tab>" = {
          action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end
          '';
          modes = ["i" "s"];
        };
      };
    };
  };
}
```
I needed a snippet engine, heard luasnip is a good one, haven't looked into it.
