export HOME=/root

# Detect architecture
if [ "$(uname -m)" = "aarch64" ]; then
  ARCH=aarch64
  NVIM_ARCH=arm64
else
  ARCH=x86_64
  NVIM_ARCH=x86_64
fi

# Append a line to ~/.bashrc only if it's not already there
add_to_bashrc() {
  grep -qxF "$1" ~/.bashrc 2>/dev/null || echo "$1" >> ~/.bashrc
}

# Install uv
if [ ! -x "$HOME/.local/bin/uv" ] && ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Miniconda
if [ ! -d /root/miniconda3 ]; then
  wget -O "/root/Miniconda3-latest-Linux-${ARCH}.sh" "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${ARCH}.sh"
  bash "/root/Miniconda3-latest-Linux-${ARCH}.sh" -b -p /root/miniconda3
  /root/miniconda3/bin/conda init bash
fi

# Other stuff
apt update
DEBIAN_FRONTEND=noninteractive apt install -y vim gh npm zoxide tmux htop redis-server lsof net-tools iperf3 jq strace kitty-terminfo libclang-dev python3.12-venv python3-pip btop atop unzip

# aws
if ! command -v aws >/dev/null 2>&1; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip"
  unzip -o awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip aws
fi

# fzf
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
~/.fzf/install --all --no-update-rc

# zoxide
if ! command -v zoxide >/dev/null 2>&1; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# NVM
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
\. "$HOME/.nvm/nvm.sh"
nvm install 22

# rust
# Install Rust using rustup
if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "$HOME/.cargo/env"

# install ripgrep and tree-sitter CLI (needed for nvim-treesitter on 0.12+)
command -v rg >/dev/null 2>&1 || cargo install ripgrep
command -v tree-sitter >/dev/null 2>&1 || cargo install tree-sitter-cli

# neovim
if [ ! -d "/opt/nvim-linux-${NVIM_ARCH}" ]; then
  curl -LO "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"
  tar -C /opt -xzf "nvim-linux-${NVIM_ARCH}.tar.gz"
  rm "nvim-linux-${NVIM_ARCH}.tar.gz"
fi
add_to_bashrc "export PATH=\"\$PATH:/opt/nvim-linux-${NVIM_ARCH}/bin\""

# claude
if [ ! -x "$HOME/.local/bin/claude" ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
add_to_bashrc 'export PATH="$HOME/.local/bin:$PATH"'
source ~/.bashrc

# codex
if ! command -v codex >/dev/null 2>&1; then
  npm i -g @openai/codex
fi

# github
if [ ! -d /root/dotfiles ]; then
  git clone https://github.com/harmonbhasin/dotfiles /root/dotfiles
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
mkdir -p ~/.codex
ln -sf /root/dotfiles/git/.gitconfig /root/.gitconfig
ln -sfn /root/dotfiles/nvim /root/.config/nvim
ln -sfn /root/dotfiles/claude/CLAUDE.md /root/.claude/CLAUDE.md
ln -sfn /root/dotfiles/claude/commands /root/.claude/commands
ln -sfn /root/dotfiles/claude/agents /root/.claude/agents
ln -sfn /root/dotfiles/claude/settings.json /root/.claude/settings.json
ln -sfn /root/dotfiles/claude/statusline-command.sh /root/.claude/statusline-command.sh

ln -sfn /root/dotfiles/claude/CLAUDE.md ~/.codex/AGENTS.md
ln -sfn /root/dotfiles/codex/config.toml ~/.codex/config.toml

# Set vim mode for Claude Code
if [ -f ~/.claude.json ]; then
  jq '. + {"editorMode": "vim"}' ~/.claude.json > /tmp/claude.json && mv /tmp/claude.json ~/.claude.json
fi

# Source common configuration from dotfiles
add_to_bashrc 'source /root/dotfiles/bash/.bashrc'

# Pre-install nvim plugins so first launch isn't a half-broken lazy bootstrap
"/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" --headless "+Lazy! sync" +qa
