#!/bin/sh
set -e

echo "Starting Ollama in CPU mode..."
ollama serve &
OLLAMA_PID=$!

# Wait for Ollama to be ready
echo "Waiting for Ollama server to start..."
until ollama list >/dev/null 2>&1; do
  sleep 1
done
echo "Ollama server is running!"

# Load models from models.txt
if [ -f "/models.txt" ]; then
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
  
  echo "Finished loading models"
fi

# Keep container running
wait $OLLAMA_PID