#!/bin/bash
export HOME=/home/ubuntu
export USER=ubuntu
export LOGNAME=ubuntu

repair_home_ownership() {
  sudo find "$HOME" -xdev \( ! -user ubuntu -o ! -group ubuntu \) -exec chown -h ubuntu:ubuntu {} + 2>/dev/null || true
}

if [ "$(id -u)" -eq 0 ]; then
  find "$HOME" -xdev \( ! -user ubuntu -o ! -group ubuntu \) -exec chown -h ubuntu:ubuntu {} + 2>/dev/null || true
  exec sudo -E -H -u ubuntu env HOME="$HOME" USER=ubuntu LOGNAME=ubuntu bash "$0" "$@"
fi

cd "$HOME" || exit 1

# Append a line to ~/.bashrc only if it's not already there
add_to_bashrc() {
  grep -qxF "$1" ~/.bashrc 2>/dev/null || echo "$1" >> ~/.bashrc
}

# Detect architecture (release assets are arch-specific)
if [ "$(uname -m)" = "aarch64" ]; then
  NVIM_DIR=nvim-linux-arm64
  FZF_ARCH=linux_arm64
else
  NVIM_DIR=nvim-linux-x86_64
  FZF_ARCH=linux_amd64
fi

# Repair ownership if a prior cloud-init run left user-space files root-owned.
repair_home_ownership

# uv
if [ ! -x "$HOME/.local/bin/uv" ] && ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

python3 -c "import dbgpu" 2>/dev/null || pip install dbgpu
command -v b2 >/dev/null 2>&1 || pip3 install b2

# System packages
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y vim gh zoxide fzf tmux htop lsof net-tools jq strace xsel

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
command -v delta >/dev/null 2>&1 || cargo install git-delta  # git pager (see git/.gitconfig-remote)

# Neovim
if [ ! -d "/opt/$NVIM_DIR" ]; then
  curl -LO "https://github.com/neovim/neovim/releases/latest/download/$NVIM_DIR.tar.gz"
  sudo tar -C /opt -xzf "$NVIM_DIR.tar.gz"
  rm "$NVIM_DIR.tar.gz"
fi
add_to_bashrc "export PATH=\"\$PATH:/opt/$NVIM_DIR/bin\""

# fzf (apt ships an ancient build with no `--bash` keybinding support, so grab
# the latest release; /usr/local/bin shadows the apt binary)
if ! command -v fzf >/dev/null 2>&1 || ! fzf --bash >/dev/null 2>&1; then
  FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | jq -r '.tag_name')
  curl -LO "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION#v}-${FZF_ARCH}.tar.gz"
  tar -xzf "fzf-${FZF_VERSION#v}-${FZF_ARCH}.tar.gz"
  sudo mv fzf /usr/local/bin/fzf
  rm "fzf-${FZF_VERSION#v}-${FZF_ARCH}.tar.gz"
fi

# Claude CLI
if [ ! -x "$HOME/.local/bin/claude" ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
add_to_bashrc 'export PATH="$HOME/.local/bin:$PATH"'

# npm global tools
sudo chown -R 1000:1000 "/home/ubuntu/.npm"
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

mkdir -p ~/.config
mkdir -p ~/.claude
mkdir -p ~/.codex
ln -sfn "$HOME/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"
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

# tmux plugins (TPM) so the dotbar status line and other plugins load on first launch
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi

# Pre-install nvim plugins so first launch isn't a half-broken lazy bootstrap
if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
  sudo chown -R ubuntu:ubuntu /home/ubuntu/.local/ /home/ubuntu/.cache /home/ubuntu/.claude /home/ubuntu/.codex /home/ubuntu/.nvm
  "/opt/$NVIM_DIR/bin/nvim" --headless "+Lazy! sync" +qa
fi
