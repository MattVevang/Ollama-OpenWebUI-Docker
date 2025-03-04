#!/usr/bin/env python3
import sys
import os
import subprocess
import time

def run_command(cmd, capture_output=False):
    print(f"Running: {' '.join(cmd)}")
    try:
        if capture_output:
            # Use utf-8 encoding with errors='replace' to handle encoding issues
            process = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8', errors='replace')
            return process.returncode, process.stdout, process.stderr
        else:
            # For live output, don't capture
            process = subprocess.run(cmd)
            return process.returncode, None, None
    except Exception as e:
        print(f"Error executing command: {e}")
        return 1, None, None

def check_containers_status(engine):
    cmd = [engine, "ps", "--format", "{{.Names}} {{.Status}}"]
    returncode, stdout, stderr = run_command(cmd, capture_output=True)
    
    if returncode == 0 and stdout:
        print("\nContainer Status:")
        print(stdout)
    else:
        print(f"Failed to check container status. Error: {stderr}")

def main():
    if len(sys.argv) < 3:
        print("Usage: python container_manager.py [up|down|logs] [docker|podman] [profile]")
        return 1

    action = sys.argv[1]
    engine = sys.argv[2]
    profile = sys.argv[3] if len(sys.argv) > 3 else ""

    # Ensure we're in the directory with the docker-compose.yaml file
    script_dir = os.path.dirname(os.path.realpath(__file__))
    os.chdir(script_dir)
    
    # Verify compose file exists
    if not os.path.exists("docker-compose.yaml") and not os.path.exists("docker-compose.yml"):
        print("Error: docker-compose.yaml file not found in the current directory.")
        return 1
    
    # Base compose command - using the existing docker-compose.yaml file
    compose_cmd = [engine, "compose"]
    
    # Add profile if specified
    if profile == "gpu":
        compose_cmd.extend(["--profile", "gpu"])
    
    # Add action
    if action == "up":
        compose_cmd.append("up")
        compose_cmd.append("-d")  # Detached mode
        
        # Run the command
        returncode, _, _ = run_command(compose_cmd)
        
        # If successful, wait a moment and show status
        if returncode == 0:
            print("Waiting for containers to initialize...")
            time.sleep(5)  # Give containers time to start up
            check_containers_status(engine)
            
            # Determine which Ollama container should be running
            ollama_container = "ollama-gpu" if profile == "gpu" else "ollama-cpu"
            
            # Show connection instructions and status
            print("\nOllama WebUI should now be available at: http://localhost:3000")
            print(f"Ollama API should be available at: http://localhost:11434")
            print(f"Container logs can be viewed with: {engine} logs {ollama_container}")
            print(f"Container logs can be viewed with: {engine} logs open-webui")
            
            # Explicitly print success message for debugging
            print("\nContainers started successfully with exit code 0")
            
            # Always return 0 on successful container creation
            return 0
        else:
            print(f"\nContainer startup failed with exit code {returncode}")
            return returncode
    
    elif action == "down":
        compose_cmd.append("down")
        returncode, _, _ = run_command(compose_cmd)
        return returncode
    
    elif action == "logs":
        # Determine which Ollama container should be running
        ollama_container = "ollama-gpu" if profile == "gpu" else "ollama-cpu"
        
        # Get logs for Ollama container
        print(f"\n=== {ollama_container} Logs ===\n")
        run_command([engine, "logs", ollama_container])
        
        # Get logs for WebUI container
        print("\n=== open-webui Logs ===\n")
        run_command([engine, "logs", "open-webui"])
        
        # Show container status
        check_containers_status(engine)
        return 0
    
    else:
        print(f"Unknown action: {action}")
        return 1

if __name__ == "__main__":
    exit_code = main()
    print(f"Python script exiting with code: {exit_code}")
    sys.exit(exit_code)
