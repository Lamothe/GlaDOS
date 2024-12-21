#!/bin/sh
#
# Simple install script built for WSL to install the required components for the GLaDOS peoject
# https://github.com/dnhkng/GlaDOS

sudo apt install -y pulseaudio-module-jack jackd2 portaudio19-dev espeak-ng git-lfs

python -m venv venv > /dev/null
source venv/bin/activate > /dev/null
python -m pip install -r requirements_cuda.txt

# Installing Whisper and llama
echo "Installing Whisper and llama"
git submodule update --init --recursive

# Compiling Whisper
echo "Compiling Whisper"
cd submodules/whisper.cpp
make libwhisper.so -j
cd ..
cd ..

# Compiling llama
echo "Compiling llama"
cd submodules/llama.cpp
make llama-server LLAMA_CUDA=1
cd ..
cd ..

# Downloading ASR and LLM models
echo "Downloading Models"
curl -L "https://huggingface.co/distil-whisper/distil-medium.en/resolve/main/ggml-medium-32-2.en.bin" --output  "models/ggml-medium-32-2.en.bin"
curl -L "https://huggingface.co/bartowski/Meta-Llama-3-8B-Instruct-GGUF/resolve/main/Meta-Llama-3-8B-Instruct-Q6_K.gguf?download=true" --output "models/Meta-Llama-3-8B-Instruct-Q6_K.gguf"

# Fixes ggml-metal.metal
echo Fixing Whisper.cpp
sed -i "1,6s|ggml-common.h|$SCRIPT_DIR/submodules/whisper.cpp/ggml-common.h|" submodules/whisper.cpp/ggml-metal.metal
