# Ollama-OpenWebUI-Docker

A simple working docker container to run Ollama and OpenWebUI locally.
(and dabble with GitHub as I haven't done much of anything here)

## Goal

Share a simple working docker container that will setup Ollama
and OpenWebUI that just works.
In the initial version this does not require setting up local admin
(or separate) user accounts and is intended to simply work and let you
interact with the LLM of your choosing (and that your computer can run).

## Reason

Setting this up I came upon many pages that went into the weeds about
Docker commands or Ollama etc and I just wanted something that would work.

## How to use

- When you use `docker compose --profile gpu up`, Docker will start `ollama-nvidia` with proper GPU access
- When you use `docker compose up`, Docker will start `ollama` without GPU passthrough

- When shutting down, if you used the `--profile gpu up` command to start you must then down that profile too.
  - `docker compose --profile gpu down`
- When using CPU only mode you can use the basic `docker compose down` command.

## ToDos

- Determine future ToDos after further runtime and use.

## Features

- Added `models.txt` file to the directory so you can add as many models to the list
without having to add additional lines to the `docker-compose.yaml` file.
- Supports using NVIDIA GPUs (if installed and detected).
