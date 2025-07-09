# GPU Setup


## Runpod


If using scp support, run `TERM=xterm-256color` as ghostty won't be recognized

1. Run `runpod.sh`
2. Run `gh auth`
3. Run `claude`
4. Mason install pyright + ruff
5. export UV_CACHE_DIR=/workspace/.cache/uv

### Seems buggy

Start a pod `runpodctl create pod --gpuType 'NVIDIA RTX A4500' --imageName 'runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04'`
See pods `runpodctl get pod`
Sadly it seems you can't get the ssh from here?
However remove a pod using `runpodctl remove pod [podId]`

