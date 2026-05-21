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
2. Configure Claude: `claude` (a lot of the settings don't carry over anymore so you will need to manually change things)
3. Set UV cache: `export UV_CACHE_DIR=/workspace/.cache/uv`
4. If using SCP: `TERM=xterm-256color` (ghostty not recognized)

## Lambda

### Post-Installation Setup
Authenticate B2 by exporting your application key (b2 picks these up automatically):
```bash
export B2_APPLICATION_KEY_ID=<your-keyID>
export B2_APPLICATION_KEY=<your-applicationKey>
```

## Future work

- Consider adding rust download
