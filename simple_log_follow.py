#!/usr/bin/env python3

import subprocess
import sys
import time

def main():
    """Simple log follower for Ollama setup"""
    print("Simple Log Follower")
    print("==================")
    
    # Get profile argument if provided
    profile = "gpu" if "--profile" in sys.argv and "gpu" in sys.argv else "cpu"
    
    # Define container names based on profile
    ollama_container = f"ollama-{profile}"
    containers = [ollama_container, "open-webui"]
    
    print(f"Running in {profile.upper()} mode")
    print(f"Following logs for: {', '.join(containers)}")
    print("Press Ctrl+C to exit logs (containers will keep running)")
    print()
    
    # Wait a bit for any containers that might be starting
    time.sleep(2)
    
    try:
        # Run podman logs directly (doesn't require podman-compose)
        cmd = ["podman", "logs", "-f"] + containers
        subprocess.run(cmd)
    except KeyboardInterrupt:
        print("\nLog following stopped. Containers are still running.")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
