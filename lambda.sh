# Append a line to ~/.bashrc only if it's not already there
add_to_bashrc() {
grep -qxF "$1" ~/.bashrc 2>/dev/null || echo "$1" >> ~/.bashrc
}

# UV stuff
pip install uv
pip3 install --upgrade b2

# Other stuff
sudo apt update
sudo apt install -y vim gh zoxide fzf tmux htop lsof net-tools jq strace clang-18 libclang-18-dev libclang-common-18-dev

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22

# rust
# Install Rust using rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.bashrc
# Verify the installation
rustc --version
cargo --version

cargo install ripgrep
cargo install tree-sitter-cli

# neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc

curl -fsSL https://claude.ai/install.sh | bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
npm install -g tldr

npm i -g @openai/codex

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
ln -s ~/dotfiles/nvim ~/.config/
ln -s ~/dotfiles/claude/CLAUDE.md ~/.claude/
ln -s ~/dotfiles/claude/commands ~/.claude/
ln -s ~/dotfiles/claude/agents ~/.claude/

# Source common configuration from dotfiles
add_to_bashrc 'source ~/dotfiles/bash/.bashrc'


