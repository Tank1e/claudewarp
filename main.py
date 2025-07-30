#!/usr/bin/env python3
"""
ClaudeWarp - Claude API proxy management tool

Main entry point for ClaudeWarp CLI application.
Provides full command-line functionality for managing Claude API proxies.
"""

import sys


def main() -> int:
    """Main entry point for ClaudeWarp application"""
    try:
        # Import CLI modules with full functionality
        from claudewarp.cli.main import main as cli_main

        return cli_main()

    except ImportError as e:
        print(f"Error: Failed to import CLI modules: {e}")
        print("Please ensure typer and rich are installed")
        return 1
    except KeyboardInterrupt:
        print("\nOperation cancelled by user")
        return 130
    except Exception as e:
        print(f"Application execution failed: {e}")
        if "--debug" in sys.argv:
            import traceback

            traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
