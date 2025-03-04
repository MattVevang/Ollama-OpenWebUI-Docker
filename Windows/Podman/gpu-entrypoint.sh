#!/bin/sh
set -e

echo "GPU detection starting..."

# Initialize GPU detection flag
GPU_DETECTED=0

# Check for NVIDIA GPU
if command -v nvidia-smi >/dev/null 2>&1; then
    echo "NVIDIA GPU detected"
    export OLLAMA_USE_NVIDIA=1
    GPU_DETECTED=1
fi

# Check for AMD GPU (ROCm)
if [ -e "/dev/kfd" ] && [ -e "/dev/dri" ]; then
    echo "AMD GPU with ROCm detected"
    export OLLAMA_USE_ROCM=1
    GPU_DETECTED=1
fi

# Check if any GPU was found
if [ $GPU_DETECTED -eq 0 ]; then
    echo "No compatible GPUs detected - falling back to CPU-only mode"
    echo "Note: CPU-only operation will be significantly slower"
fi

echo "Starting Ollama service..."
ollama serve &
OLLAMA_PID=$!

# Rest of the script remains unchanged
while ! ollama list > /dev/null 2>&1; do
    echo 'Waiting for Ollama to start...'
    sleep 5
done

echo 'Reading models from models.txt:'
cat /models.txt
echo
echo '------------------------------'
echo 'Processing models (excluding comments and empty lines):'
grep -v '^#' /models.txt | grep -v '^$' > /tmp/filtered_models.txt
cat /tmp/filtered_models.txt
echo
echo '------------------------------'

while IFS= read -r line; do
    # Trim whitespace and carriage returns
    model=$(echo "$line" | tr -d '\r' | xargs)
    [ -z "$model" ] && continue
    echo "Pulling model: '$model'"
    ollama pull $model
done < /tmp/filtered_models.txt

# Keep the container running
wait $OLLAMA_PID