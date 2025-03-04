#!/usr/bin/env python3

import sys
import os
import importlib.util
import inspect
import types

def main():
    print("Starting podman-compose with Windows signal handling fix...")
    
    # Import the podman_compose module
    spec = importlib.util.find_spec('podman_compose')
    if spec is None:
        print("Error: podman-compose module not found. Please install it with 'pip install podman-compose'")
        sys.exit(1)
    
    podman_compose = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(podman_compose)
    
    # Find the compose_up function and monkey patch it to work on Windows
    if hasattr(podman_compose, 'compose_up'):
        original_compose_up = podman_compose.compose_up
        
        async def patched_compose_up(podman_compose_obj, args):
            # Windows-compatible implementation
            print("Running Windows-compatible compose_up...")
            
            try:
                # Execute the core functionality without signal handlers
                retcode = 0
                
                # Create service tasks
                if hasattr(podman_compose_obj, 'services'):
                    tasks = []
                    for service_name, service_desc in podman_compose_obj.services.items():
                        # Skip if depends_on and no_deps is not set
                        if not getattr(podman_compose_obj, "no_deps", False) and "depends_on" in service_desc:
                            continue
                        
                        # Add task for service
                        if hasattr(podman_compose_obj, 'up_service'):
                            tasks.append(podman_compose_obj.up_service(service_name, service_desc))
                    
                    # Wait for tasks to complete without signal handler
                    import asyncio
                    if tasks:
                        done, pending = await asyncio.wait(tasks)
                        for task in done:
                            try:
                                await task
                            except Exception as ex:
                                print(f"Error in service: {ex}")
                    
                    # Wait for healthchecks
                    if hasattr(podman_compose_obj, "no_start") and not podman_compose_obj.no_start:
                        if hasattr(podman_compose_obj, 'wait_on_service_healthchecks'):
                            await podman_compose_obj.wait_on_service_healthchecks(podman_compose_obj.services)
                
                return retcode
            except KeyboardInterrupt:
                print("Received keyboard interrupt, stopping containers...")
                if hasattr(podman_compose_obj, 'compose_down'):
                    podman_compose_obj.compose_down(args)
                return 1
            
        # Replace the original function with our patched version
        podman_compose.compose_up = patched_compose_up
    
    # Find and patch the async_main function to avoid signal handler issues
    if hasattr(podman_compose, 'async_main'):
        original_async_main = podman_compose.async_main
        
        async def patched_async_main():
            import asyncio
            # Create a PodmanCompose instance and run it without signal handlers
            if hasattr(podman_compose, 'PodmanCompose'):
                podman_compose_obj = podman_compose.PodmanCompose()
                return await podman_compose_obj.run()
            else:
                # Fallback to original implementation
                return await original_async_main()
        
        # Replace the original function
        podman_compose.async_main = patched_async_main
    
    # Call the original main function which will use our patched versions
    return podman_compose.main()

if __name__ == "__main__":
    sys.exit(main())
