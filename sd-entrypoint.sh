#!/bin/bash
# Print debugging information
echo "Models will be stored in: /home/sduser/app/models"
echo "Outputs will go to: /home/sduser/app/outputs"
echo "Running as user: $(whoami) with UID: $(id -u)"

# As root, we can properly set up permissions
echo "Creating directories and setting permissions..."

# Ensure all required directories exist
mkdir -p /home/sduser/app/models
mkdir -p /home/sduser/app/models/Stable-diffusion
mkdir -p /home/sduser/app/models/hypernetworks
mkdir -p /home/sduser/app/models/embeddings
mkdir -p /home/sduser/app/models/lora
mkdir -p /home/sduser/app/models/checkpoints 
mkdir -p /home/sduser/app/models/VAE
mkdir -p /home/sduser/app/models/controlnet
mkdir -p /home/sduser/app/outputs

# Set ownership to sduser
chown -R sduser:sduser /home/sduser/app/models
chown -R sduser:sduser /home/sduser/app/outputs

# Set permissions
chmod -R 777 /home/sduser/app/models
chmod -R 777 /home/sduser/app/outputs

# Check if the model file exists, if not, download it
MODEL_PATH="/home/sduser/app/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors"
if [ ! -f "$MODEL_PATH" ]; then
    echo "Model file not found. Downloading model..."
    wget -q -O "$MODEL_PATH" https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
    echo "Model downloaded successfully."
    # Ensure proper ownership of the downloaded file
    chown sduser:sduser "$MODEL_PATH"
else
    echo "Model file already exists. Skipping download."
fi

# Switch to sduser for running the actual application
echo "Switching to sduser..."
# exec su -c "./webui.sh --listen --port 7860 --api --api-auth admin:admin123 --enable-insecure-extension-access" sduser
exec su -c "./webui.sh --listen --port 7860 --api --enable-insecure-extension-access" sduser