#!/bin/bash -i

cd /root/

# UV stuff
pip install uv

# Other stuff
apt update 
apt install -y vim gh npm zoxide ripgrep fzf tmux htop redis-server lsof net-tools iperf3 jq exa strace

# Fix; necessary for markdown neovim plugin
apt-get update && apt-get install -y locales
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# install recomendations of brendan gregg; https://www.brendangregg.com/blog/2024-03-24/linux-crisis-tools.html
apt install -y procps util-linux sysstat iproute2 numactl tcpdump linux-tools-common bpfcc-tools bpftrace trace-cmd nicstat ethtool tiptop cpuid msr-tools

cd /workspace/

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22

# neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc


# login
npm install -g @anthropic-ai/claude-code
npm install -g ccusage
npm install -g tldr

# Github; i feel like gh auth should be able to be automated if i pass the auth key as a token to input
git config --global user.email "harmonprograms@protonmail.com"
git config --global user.name "harm0n"


git clone https://github.com/harmonbhasin/dotfiles


echo '# Minimal tmux config for server

# Change prefix to C-a
set -g prefix C-a
unbind C-b

# Neovim compatibility
set -sg escape-time 10
set -g default-terminal "screen-256color"
set-option -a terminal-features "xterm:RGB"
set-option -g focus-events on

# Start windows at 1
set -g base-index 1

# Basic pane splitting
bind | split-window -h
bind - split-window -v

# Use vi keybindings in copy mode
set-window-option -g mode-keys vi

# Allow yanking
bind-key -T copy-mode-vi "v" send -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xsel -i -p && xsel -o -p | xsel -i -b"
bind-key p run "xsel -o | tmux load-buffer - ; tmux paste-buffer"

# Enable mouse
set -g mouse on

# Reload config
bind r source-file ~/.tmux.conf \; display-message "Config reloaded."

# Vim-tmux navigation
is_vim="ps -o state= -o comm= -t '\'#{pane_tty}\'' | grep -iqE '\''^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'\''"
bind-key -n '\''C-h'\'' if-shell "$is_vim" '\''send-keys C-h'\'' '\''select-pane -L'\''
bind-key -n '\''C-j'\'' if-shell "$is_vim" '\''send-keys C-j'\'' '\''select-pane -D'\''
bind-key -n '\''C-k'\'' if-shell "$is_vim" '\''send-keys C-k'\'' '\''select-pane -U'\''
bind-key -n '\''C-l'\'' if-shell "$is_vim" '\''send-keys C-l'\'' '\''select-pane -R'\''' > ~/.tmux.conf

mkdir ~/.config
mkdir ~/.claude
ln -s /workspace/dotfiles/nvim /root/.config/
ln -s /workspace/dotfiles/claude/CLAUDE.md /root/.claude/
ln -s /workspace/dotfiles/claude/commands /root/.claude/

# config for uv
echo 'export UV_CACHE_DIR=/workspace/.cache/uv' >> ~/.bashrc
mkdir -p /workspace/.cache/uv

# nsys
wget https://developer.nvidia.com/downloads/assets/tools/secure/nsight-systems/2025_3/NsightSystems-linux-cli-public-2025.3.1.90-3582212.deb
dpkg -i NsightSystems-linux-cli-public-2025.3.1.90-3582212.deb

echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc
echo "alias vi=nvim" >> ~/.bashrc
echo "alias v=nvim" >> ~/.bashrc
echo "alias vim=nvim" >> ~/.bashrc
echo "alias ls=exa" >> ~/.bashrc
echo "set -o vi" >> ~/.bashrc
echo "export LANG=en_US.UTF-8" >> ~/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
echo "export LC_CTYPE=en_US.UTF-8" >> ~/.bashrc
echo "export TERM=xterm-256color" >> ~/.bashrc
echo 'alias gs="git status"' >> ~/.bashrc
echo 'alias gpom="git push origin main"' >> ~/.bashrc
source ~/.bashrc

