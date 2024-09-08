# zsh-history-substring-search bind keyboard shortcuts 
# https://github.com/zsh-users/zsh-history-substring-search#zsh-history-substring-search
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# user configuration
bindkey \^U backward-kill-line # Ctrl-w kill a word
unix-word-rubout() {
  local WORDCHARS=$'!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
  zle backward-kill-word
}
zle -N unix-word-rubout
bindkey '^H' unix-word-rubout # Ctrl-delete kill from cursor to space, can use `showkey -a` find key
# macos need rebind
if [[ "$OSTYPE" == "darwin"* ]]; then
  bindkey '<CTL-H=BS>' unix-word-rubout
fi

# cd command combine with zsh-z
cd() {
    # Go to home without arguments
    [ -z "$*" ] && builtin cd && return
    # If directory exists, change to it
    [ -d "$*" ] && builtin cd "$*" && return
    [ "$*" = "-" ] && builtin cd "$*" && return
    # Catch cd . and cd ..
    case "$*" in
        ..) builtin cd ..; return;;
        .) builtin cd .; return;;
    esac
    # Finally, call z.
    zshz "$*" || builtin cd "$*"
}

# Go to a file's directory interactively
cdf() {
  NAME="$(dirname "$(fd -0 -t f | fzf --read0 -i -q "$* " -1)")"
  if [[ $NAME ]]; then
      builtin cd "$NAME"
  fi
}

# Searches file content recursively using ripgrep and edit with neovim
rgf() {
    local filename="$(rg "$*" | fzf -i -1 | cut -d ':' -f 1 -)"
    if [[ $filename ]]; then
        nvim "$filename"
    fi
}

# Proxy environment set
with_proxy() {
   HTTPS_PROXY=http://127.0.0.1:7890 HTTP_PROXY=https://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7891 "$@"
}