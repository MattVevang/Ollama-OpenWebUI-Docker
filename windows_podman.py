#!/usr/bin/env python3

import sys
import subprocess
import os
import time
import json

def get_running_containers(profile_args):
    """Get list of running containers for this compose project"""
    try:
        # Get the list of running containers
        cmd = ["podman-compose"] + profile_args + ["ps", "--format", "json"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode != 0:
            print("Error getting container list.")
            return []
            
        # Parse the JSON output
        try:
            container_data = json.loads(result.stdout)
            # Extract container names
            if isinstance(container_data, list):
                return [container['Names'] if isinstance(container['Names'], str) else container['Names'][0] for container in container_data]
            return []
        except json.JSONDecodeError:
            # For older versions of podman-compose that might not support JSON
            # Fall back to checking for specific containers
            return ["ollama-cpu", "ollama-gpu", "open-webui"]
    except Exception as e:
        print(f"Error getting container list: {e}")
        # Return default containers as fallback
        return ["open-webui"]

def main():
    print("Windows Podman Compose Helper")
    print("=============================")
    
    # Get all arguments passed to this script
    args = sys.argv[1:]
    
    if len(args) == 0 or "help" in args or "-h" in args:
        print("Usage: python windows_podman.py [up|down] [--profile gpu]")
        print()
        print("Commands:")
        print("  up      - Start containers")
        print("  down    - Stop containers")
        print()
        print("Options:")
        print("  --profile gpu  - Use GPU profile")
        return 0
    
    if "up" in args:
        # Extract the args to keep any profile flags
        up_args = [arg for arg in args if arg != "up"]
        
        # First run detached to avoid signal handling issues
        cmd = ["podman-compose"] + up_args + ["up", "-d"]
        print("Starting containers...")
        print(f"Running: {' '.join(cmd)}")
        
        result = subprocess.run(cmd)
        if result.returncode != 0:
            print(f"Error starting containers: {result.returncode}")
            return result.returncode
            
        print("Containers started successfully!")
        print("Following logs (press Ctrl+C to exit without stopping containers)...")
        
        # Wait a moment for containers to start
        print("Waiting a few seconds for containers to initialize...")
        time.sleep(3)
        
        # Get the list of running containers
        containers = get_running_containers(up_args)
        
        if not containers:
            print("No running containers found. Please check if they started correctly.")
            return 1
            
        print(f"Found running containers: {', '.join(containers)}")
        
        try:
            # Follow logs for each container
            log_cmd = ["podman-compose"] + up_args + ["logs", "-f"] + containers
            print(f"Running: {' '.join(log_cmd)}")
            subprocess.run(log_cmd)
        except KeyboardInterrupt:
            print("\nExiting log view. Containers are still running.")
            print("To stop containers, run: python windows_podman.py down")
            
    elif "down" in args:
        # Extract the args to keep any profile flags
        down_args = [arg for arg in args if arg != "down"]
        
        cmd = ["podman-compose"] + down_args + ["down"]
        print("Stopping containers...")
        print(f"Running: {' '.join(cmd)}")
        
        result = subprocess.run(cmd)
        return result.returncode
    else:
        # For any other command, just pass through to podman-compose
        cmd = ["podman-compose"] + args
        print(f"Running: {' '.join(cmd)}")
        
        result = subprocess.run(cmd)
        return result.returncode
        
    return 0

if __name__ == "__main__":
    sys.exit(main())
