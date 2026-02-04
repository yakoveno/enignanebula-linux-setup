# .bashrc for EnigmaNebula Linux System

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Colors for ls
export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:"

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Docker aliases
alias dps='docker ps'
alias dimages='docker images'
alias dlogs='docker logs'
alias dexec='docker exec -it'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Set prompt
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Set PATH
export PATH="$HOME/.local/bin:$PATH"

# Docker completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Set editor
export EDITOR=vim

# History settings
export HISTSIZE=5000
export HISTFILESIZE=5000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT='%F %T '

# Custom functions
docker_clean_images() {
    docker rmi $(docker images -q -f dangling=true)
}

docker_clean_containers() {
    docker rm $(docker ps -q -f status=exited)
}

docker_clean_all() {
    docker_clean_containers
    docker_clean_images
}

# System monitoring function
sysmon() {
    echo "CPU Usage:"
    htop
}

# EnigmaNebula status function
enigma_status() {
    echo "Checking EnigmaNebula services..."
    docker ps | grep enignanebula
    echo "OpenClaw gateway status:"
    pgrep -f openclaw || echo "OpenClaw is not running"
}