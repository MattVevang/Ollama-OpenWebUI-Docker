#!/usr/bin/env python3

import sys
import subprocess
import os
import signal
import time

def signal_handler(sig, frame):
    print("\nCtrl+C pressed, stopping containers...")
    # Run podman-compose down
    subprocess.run(["podman-compose", "down"])
    sys.exit(0)

def main():
    # Get command-line arguments
    args = sys.argv[1:]
    
    if not args or args[0] != "up":
        # Just pass through to podman-compose for commands other than "up"
        cmd = ["podman-compose"] + args
        process = subprocess.run(cmd)
        return process.returncode
    
    # For "up" command, we use a special approach
    # Remove "up" from args to process other flags
    args.remove("up")
    cmd = ["podman-compose"] + args + ["up", "-d"]  # Run in detached mode
    
    try:
        # Start containers in detached mode
        print("Starting containers in detached mode...")
        process = subprocess.run(cmd)
        if process.returncode != 0:
            print(f"Error starting containers, return code: {process.returncode}")
            return process.returncode
            
        # Now follow logs
        print("Containers started, showing logs (press Ctrl+C to exit)...")
        
        # Register signal handler for Ctrl+C
        signal.signal(signal.SIGINT, signal_handler)
        
        # Follow logs
        log_cmd = ["podman-compose"] + args + ["logs", "-f"]
        log_process = subprocess.Popen(log_cmd)
        
        # Wait for log process to complete
        log_process.wait()
        
        return 0
    except KeyboardInterrupt:
        print("\nCtrl+C pressed, stopping containers...")
        # Run podman-compose down
        subprocess.run(["podman-compose"] + args + ["down"])
        return 0

if __name__ == "__main__":
    sys.exit(main())
