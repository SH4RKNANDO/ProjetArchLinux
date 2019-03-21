# If you come from bash you might have to change your $PATH.
export PATH=$HOME:/bin:/usr/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/$USER/.oh-my-zsh"

source /usr/share/zsh-theme-powerlevel9k/powerlevel9k.zsh-theme
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to change how often to auto-update (in days).
  export UPDATE_ZSH_DAYS=13

# Uncomment the following line to enable command auto-correction.
  ENABLE_CORRECTION="true"

# Liste de plugins zsh
plugins=(
  git
  bundler
  dotenv
  osx
  rake
  rbenv
  ruby
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG='fr_BE.UTF-8'

# Preferred editor for local and remote sessions (nano)
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
   export EDITOR='nano'
fi

# ssh key
export SSH_KEY_PATH="~/.ssh/rsa_id"

# FONT & CONFIG
POWERLEVEL9K_MODE='awesome-fontconfig'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ssh dir dir_writable vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs history todo time)

##################
# ALIAS SECTION  #
##################
alias ls="ls --color=auto"
alias htop="htop -t"

#####################
#    First LINES    #
#####################

