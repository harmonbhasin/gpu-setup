# GPU Setup

Personal settings for GPU development projects.

## Runpod

### Installation
Run `./runpod.sh` to install:
- nvm (Node Version Manager)
- uv (Package Manager)
- Claude CLI
- Neovim
- tmux
- NVIDIA Nsight tools
- Development utilities

### Post-Installation Setup
Run `source ~/.bashrc` first, then:
1. Authenticate GitHub: `gh auth login`
2. Configure Claude: `claude`
3. Set UV cache: `export UV_CACHE_DIR=/workspace/.cache/uv`
4. If using SCP: `TERM=xterm-256color` (ghostty not recognized)

## Future work

- Consider adding rust download
