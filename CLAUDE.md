# Zephyr OS Development Project

## Environment Setup
- This project uses a Python virtual environment: `zephyr-env`
- Always activate the virtual environment before running commands: `source zephyr-env/bin/activate`
- Use `west` for Zephyr project management and building

## Build Commands
- `west build -b NUCLEO_H753zi <application>` - Build application for my board
- `west flash` - Flash built application to device
- `west build -t menuconfig` - Configure build options
- `west test` - Run tests

## Python Environment
- Virtual environment location: ./zephyr-env/
- Key tools: west, devicetree, kconfig
- Use `pip install -r requirements.txt` for dependencies

## Development Workflow
- Activate virtual environment first
- Use west commands for all Zephyr operations
- Test on hardware using west flash
- Use west build -t menuconfig for configuration

## Important Instructions
- NEVER offer to commit changes until explicitly asked by the user
