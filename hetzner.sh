export HOME=/root

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Other stuff
apt update
DEBIAN_FRONTEND=noninteractive apt install -y vim gh npm zoxide tmux htop redis-server lsof net-tools iperf3 jq strace kitty-terminfo libclang-dev python3.12-venv python3-pip btop atop

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-update-rc

# zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22

# rust
# Install Rust using rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# install ripgrep and tree-sitter CLI (needed for nvim-treesitter on 0.12+)
cargo install ripgrep tree-sitter-cli

# neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc

# claude
curl -fsSL https://claude.ai/install.sh | bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# codex
npm i -g @openai/codex

# github
git clone https://github.com/harmonbhasin/dotfiles /root/dotfiles

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

mkdir -p ~/.config
mkdir -p ~/.claude
ln -sf /root/dotfiles/git/.gitconfig /root/.gitconfig
ln -s /root/dotfiles/nvim /root/.config/
ln -s /root/dotfiles/claude/CLAUDE.md /root/.claude/
ln -s /root/dotfiles/claude/commands /root/.claude/
ln -s /root/dotfiles/claude/agents /root/.claude/
ln -s /root/dotfiles/claude/settings.json /root/.claude/
ln -s /root/dotfiles/claude/statusline-command.sh /root/.claude/

ln -s /root/dotfiles/claude/CLAUDE.md ~/.codex/AGENTS.md
ln -s /root/dotfiles/codex/config.toml ~/.codex/

# Set vim mode for Claude Code
jq '. + {"editorMode": "vim"}' ~/.claude.json > /tmp/claude.json && mv /tmp/claude.json ~/.claude.json

# Source common configuration from dotfiles
echo 'source /root/dotfiles/bash/.bashrc' >> ~/.bashrc
