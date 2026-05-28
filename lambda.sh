#!/bin/bash
export HOME=/home/ubuntu

# Append a line to ~/.bashrc only if it's not already there
add_to_bashrc() {
  grep -qxF "$1" ~/.bashrc 2>/dev/null || echo "$1" >> ~/.bashrc
}

# Repair ownership if a prior run (or accidental sudo) left user-space tool dirs root-owned.
# Without this, nvm/npm/cargo fail with EACCES on the next run.
for _d in "$HOME/.npm" "$HOME/.cargo" "$HOME/.rustup" "$HOME/.nvm" "$HOME/.local" "$HOME/.cache" "$HOME/.config"; do
  if [ -d "$_d" ]; then
    # chown if dir itself is wrong, OR if any file inside is root-owned (covers tarballs etc.)
    if [ "$(stat -c '%U' "$_d")" != "ubuntu" ] || find "$_d" -xdev ! -user ubuntu -print -quit 2>/dev/null | grep -q .; then
      sudo chown -R ubuntu:ubuntu "$_d"
    fi
  fi
done
unset _d

# uv
if [ ! -x "$HOME/.local/bin/uv" ] && ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

python3 -c "import dbgpu" 2>/dev/null || pip install dbgpu
command -v b2 >/dev/null 2>&1 || pip3 install b2

# System packages
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y vim gh zoxide fzf tmux htop lsof net-tools jq strace

# clang-18
if ! command -v clang-18 >/dev/null 2>&1; then
  wget -q https://apt.llvm.org/llvm.sh
  chmod +x llvm.sh
  sudo ./llvm.sh 18 all <<< ""
  rm llvm.sh
fi

# NVM
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
\. "$HOME/.nvm/nvm.sh"
nvm ls 22 >/dev/null 2>&1 || nvm install 22

# Rust
if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "$HOME/.cargo/env"

command -v rg >/dev/null 2>&1 || cargo install ripgrep
command -v tree-sitter >/dev/null 2>&1 || cargo install tree-sitter-cli

# Neovim
if [ ! -d "/opt/nvim-linux-x86_64" ]; then
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  rm nvim-linux-x86_64.tar.gz
fi
add_to_bashrc 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"'

# Claude CLI
if [ ! -x "$HOME/.local/bin/claude" ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
add_to_bashrc 'export PATH="$HOME/.local/bin:$PATH"'

# npm global tools
\. "$HOME/.nvm/nvm.sh"
command -v tldr >/dev/null 2>&1 || npm install -g tldr
command -v codex >/dev/null 2>&1 || npm i -g @openai/codex
command -v hunkdiff >/dev/null 2>&1 || npm i -g hunkdiff

# Git config
git config --global user.email "harmonprograms@protonmail.com"
git config --global user.name "harm0n"

# Dotfiles
if [ ! -d "$HOME/dotfiles" ]; then
  git clone https://github.com/harmonbhasin/dotfiles "$HOME/dotfiles"
fi

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
setw -g pane-base-index 1

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
is_vim="ps -o state= -o comm= -t '\''#{pane_tty}'\'' | grep -iqE '\''^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'\''"
bind-key -n '\''C-h'\'' if-shell "$is_vim" '\''send-keys C-h'\'' '\''select-pane -L'\''
bind-key -n '\''C-j'\'' if-shell "$is_vim" '\''send-keys C-j'\'' '\''select-pane -D'\''
bind-key -n '\''C-k'\'' if-shell "$is_vim" '\''send-keys C-k'\'' '\''select-pane -U'\''
bind-key -n '\''C-l'\'' if-shell "$is_vim" '\''send-keys C-l'\'' '\''select-pane -R'\''

# Show pane number on each pane'\''s border
set -g pane-border-status top
set -g pane-border-format " #P "' > ~/.tmux.conf

mkdir -p ~/.config
mkdir -p ~/.claude
mkdir -p ~/.codex
ln -sfn "$HOME/dotfiles/git/.gitconfig" "$HOME/.gitconfig"
ln -sfn "$HOME/dotfiles/nvim" "$HOME/.config/nvim"
ln -sfn "$HOME/dotfiles/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sfn "$HOME/dotfiles/claude/commands" "$HOME/.claude/commands"
ln -sfn "$HOME/dotfiles/claude/agents" "$HOME/.claude/agents"
ln -sfn "$HOME/dotfiles/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfn "$HOME/dotfiles/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

ln -sfn "$HOME/dotfiles/claude/CLAUDE.md" ~/.codex/AGENTS.md
ln -sfn "$HOME/dotfiles/codex/config.toml" ~/.codex/config.toml

# Set vim mode for Claude Code
if [ -f ~/.claude.json ]; then
  jq '. + {"editorMode": "vim"}' ~/.claude.json > /tmp/claude.json && mv /tmp/claude.json ~/.claude.json
fi

# Source common configuration from dotfiles
add_to_bashrc "source $HOME/dotfiles/bash/.bashrc"

# Pre-install nvim plugins so first launch isn't a half-broken lazy bootstrap
if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
  "/opt/nvim-linux-x86_64/bin/nvim" --headless "+Lazy! sync" +qa
fi
