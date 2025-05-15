# Command prompter caching
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# initiate zinit by either downloading or pointing towards where it's located
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"
# Zinit plugins
# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k
# History search plugin
# zsh-fzf-history-search
zinit ice lucid wait'0'
zinit light joshskidmore/zsh-fzf-history-search
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
autoload -U compinit && compinit
zinit cdreplay -q
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/go:$HOME/go/bin:$PATH:/opt/google-cloud-cli/bin:~/.cargo/bin/
# Set vim as EDITOR
export EDITOR=vim
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# Setting GO environment vars
export GONOPROXY='github.com/Mattilsynet/*'
export GONOSUMDB='github.com/Mattilsynet/*'
export GOPRIVATE='github.com/Mattilsynet/*'
export FZF_BASE=/usr/bin
source $ZSH/oh-my-zsh.sh
# User configuration
alias gal='gcloud auth login'
alias gaal='gcloud auth application-default login'
alias gmtv='go mod tidy && go mod vendor'
alias ls="eza --icons=auto --long --all"
alias l="ls"
alias ll="ls"
alias vim="nvim"
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
# Manage history file
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
HISTDUP=erase
setopt appendhistory # Immediately append history instead of overwriting
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/laetho/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/laetho/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/home/snutz/google-cloud-sk/path.zsh.inc' ]; then . '/home/snutz/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/Users/laetho/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/laetho/google-cloud-sdk/completion.zsh.inc'; fi
if [ -f '/home/snutz/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/snutz/google-cloud-sdk/completion.zsh.inc'; fi
# Added direnv
eval "$(direnv hook zsh)"
# Added The Fuck
eval $(thefuck --alias)
# Added zoxide replacement for cd
if [ -f /usr/bin/zoxide ]; then eval "$(/usr/bin/zoxide init zsh)"; fi
if [ -f /opt/homebrew/bin/zoxide ]; then eval "$(/opt/homebrew/bin/zoxide init zsh)"; fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# Completion styling
zstyle ':autocomplete:*' default-context history-incremental-search-backward
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/laetho/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -zsh)"

export OPENAI_API_KEY=$(cat ~/chatgptkey.txt)
