# GPU Setup


## Runpod



1. Run `runpod.sh`
2. Run `gh auth`
3. Run `claude`

### Seems buggy

Start a pod `runpodctl create pod --gpuType 'NVIDIA RTX A4500' --imageName 'runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04'`
See pods `runpodctl get pod`
Sadly it seems you can't get the ssh from here?
However remove a pod using `runpodctl remove pod [podId]`

