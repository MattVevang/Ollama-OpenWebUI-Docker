# Ollama with Open WebUI for Windows using Podman

This repository contains a modified setup of Ollama and Open WebUI containers that works with podman-compose on Windows.

## Goal

Share a simple working docker container that will setup Ollama
and OpenWebUI that just works.
In the initial version this does not require setting up local admin
(or separate) user accounts and is intended to simply work and let you
interact with the LLM of your choosing (and that your computer can run).

## Reason

Setting this up I came upon many pages that went into the weeds about
Docker commands or Ollama etc and I just wanted something that would work.

## Usage

### Starting the containers

Use the custom Python wrapper script to start the containers:

```bash
python custom_podman_compose.py up
```

### Using GPU support

To use GPU support (if available):

```bash
python custom_podman_compose.py --profile gpu up
```

### Stopping the containers

```bash
python custom_podman_compose.py down
```

## Troubleshooting

If you encounter any issues, check that:

1. Podman is installed and running on Windows
2. The Python script has permission to execute
3. Models.txt and entrypoint scripts are present in the same directory

## Notes

This setup uses the default network in podman-compose and sets hostnames to ensure proper communication between containers.

## How to use

- Install Podman or Docker on your system.
  - Both perform the same activity so it is up to your choosing as to which you select.
  - For Podman: `winget install --id RedHat.Podman`
    - Install Python: `winget install -e --id Python.Python.3.13`
    - Using PIP install `podman-compose` using `pip install podman-compose`
  - For Docker: `winget install --id Docker.DockerDesktop`
- Clone this repo to your local system.
  - `git clone https://github.com/MattVevang/Ollama-OpenWebUI-Docker.git`
- Change location into this new directory `Ollama-OpenWebUI-Docker`.
- Use the following commands to start the container:
  - With GPU access: `python custom_podman_compose.py --profile gpu up` or `docker compose --profile gpu up`
  - Without GPU access: `python custom_podman_compose.py up` or `docker compose up`

- After starting the container, wait until you see this output return in the terminal.

```text
open-webui  |
open-webui  |  ██████╗ ██████╗ ███████╗███╗   ██╗    ██╗    ██╗███████╗██████╗ ██╗   ██╗██╗
open-webui  | ██╔═══██╗██╔══██╗██╔════╝████╗  ██║    ██║    ██║██╔════╝██╔══██╗██║   ██║██║
open-webui  | ██║   ██║██████╔╝█████╗  ██╔██╗ ██║    ██║ █╗ ██║█████╗  ██████╔╝██║   ██║██║
open-webui  | ██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║    ██║███╗██║██╔══╝  ██╔══██╗██║   ██║██║
open-webui  | ╚██████╔╝██║     ███████╗██║ ╚████║    ╚███╔███╔╝███████╗██████╔╝╚██████╔╝██║
open-webui  |  ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝     ╚══╝╚══╝ ╚══════╝╚═════╝  ╚═════╝ ╚═╝
open-webui  |
open-webui  |
open-webui  | vX.X.XX - building the best open-source AI user interface.
open-webui  |
open-webui  | https://github.com/open-webui/open-webui
open-webui  |
```

- Navigate to <http://localhost:3000> in order to access the web interface.
- Select the model you wish to interact with at the top of the screen (or you can choose to run more than one at once).

- When shutting down, use the following commands:
  - With GPU access: `python custom_podman_compose.py --profile gpu down` or `docker compose --profile gpu down`
  - Without GPU access: `python custom_podman_compose.py down` or `docker compose down`

## Note

We are using a custom script `custom_podman_compose.py` located in this folder to handle the `NotImplementedError` on Windows. This approach avoids altering files in the system folders and ensures compatibility with both Docker and Podman.

## ToDos

- Determine future ToDos after further runtime and use.

## Features

- Added `models.txt` file to the directory so you can add as many models to the list
without having to add additional lines to the `docker-compose.yaml` file.
- Supports using NVIDIA GPUs (if installed and detected).
