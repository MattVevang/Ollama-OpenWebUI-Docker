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

... will add details

## ToDos

- Explore the ability to incorporate NPU support in addition to being able to use NVIDIA
GPU accelerators.
- See if it is possible to add support for AMD based GPUs as well.

## Features

- Added `models.txt` file to the directory so you can add as many models to the list
without having to add additional lines to the `docker-compose.yaml` file.
- Supports using NVIDIA GPUs (if installed and detected).
