# Ollama with Open WebUI - Windows Launcher

This project provides a simple way to run Ollama with Open WebUI using Docker or Podman on Windows.

## Prerequisites

- Docker or Podman installed and in your PATH
- Python 3.x installed
- Python dependencies: `pip install -r requirements.txt`

## Requirements

- Windows 10/11
- Either Docker Desktop or Podman installed
- Python 3.6+ (for the helper scripts)
- NVIDIA GPU with drivers installed (for GPU acceleration)

## Getting Started

1. Clone this repository to your local machine
2. Edit `models.txt` to specify which models you want to automatically download
3. Run `run.bat` and follow the prompts

## Usage

### Running the Application

1. Double-click `run.bat`
2. Select CPU or GPU profile
3. Select Start, Stop, or Logs
4. The application will automatically detect whether Docker or Podman is installed and use the appropriate engine

### Accessing the WebUI

Once the application is running, you can access the WebUI at:
http://localhost:3000

## Configuration

### Adding Models

Edit the `models.txt` file to specify which models you want to automatically download when the container starts.

### GPU Support

To use GPU acceleration:

- Make sure NVIDIA drivers are properly installed
- Select the "GPU" profile when launching
- GPU support requires a compatible NVIDIA graphics card

## Quick Start
1. Run `run.bat`
2. Choose Docker as the container engine
3. Choose CPU or GPU profile (GPU requires NVIDIA GPU with CUDA)
4. Select "Start containers"
5. Access WebUI at http://localhost:3000

## Troubleshooting

### WebUI can't connect to Ollama
- Check if both containers are running: `docker ps`
- Verify logs to see if Ollama started correctly: `docker logs ollama-cpu` or `docker logs ollama-gpu`
- Make sure port 11434 isn't being used by another Ollama instance
- Restart both containers: Select "Stop containers" and then "Start containers" again

### Environment Variables Not Applied
If the WebUI container is not respecting environment variables:
1. Stop all containers with `run.bat`
2. Remove the containers: `docker compose down`
3. Remove the open-webui volume: `docker volume rm open-webui`
4. Start containers again with `run.bat`

### Connection Errors
Make sure both containers are in the same network:
```
docker network inspect ollama-network
```
Both the Ollama and WebUI containers should be listed.

### Manual Commands
If the script doesn't work, try running these commands directly:

For CPU:
```
docker compose up -d
```

For GPU:
```
docker compose --profile gpu up -d
```

## License

This project is provided as-is under the terms of the license included with the original Ollama and Open WebUI projects.
