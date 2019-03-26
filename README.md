
# my zshrc extras

some functions especially for macOS.

clone bin/* to your $HOME/bin/, and enable them:

```bash
cat >>$HOME/.zshrc <<EOF

[ -f $HOME/bin/.zsh.path ]    && source $HOME/bin/.zsh.path
[ -f $HOME/bin/.zsh.aliases ] && source $HOME/bin/.zsh.aliases
[ -f $HOME/bin/.zsh.tool ]    && source $HOME/bin/.zsh.tool

EOF
```

feel free.

# LICENSE

MIT.
have fun.

