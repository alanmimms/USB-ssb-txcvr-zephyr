# Project Summary and Specifications

This document outlines the development process and final configuration
for the Zephyr-based SDR transceiver firmware prototype.

1. Project Goal & Requirements Evolution

The project began with a simple requirement: create a basic "blinky"
application in C++ for the NUCLEO-H753ZI evaluation board using the
Zephyr RTOS. The initial goal was to establish a working development
and flashing workflow.

The requirements quickly expanded to include advanced connectivity
features essential for the final SDR application:

* *USB Serial*: A virtual COM port for debugging and control.

* *USB Ethernet*: A primary requirement to establish a high-speed,
  low-latency network connection to a host computer using only a USB
  cable.

* *IPv6 Link-Local*: The USB Ethernet interface should operate using
  IPv6 link-local addressing, providing a simple, zero-configuration
  network for communication between the device and the host.

* *Custom USB Identity*: The device should enumerate on the host with
  a custom product name ("WB7NAB SDR Txcvr") to be easily
  identifiable.

2. Discoveries & Zephyr Version-Specific Challenges

Throughout the development process, we encountered several challenges
that revealed specifics about my Zephyr environment (v4.2.99). The
primary difficulties were related to the Kconfig system, where symbols
and dependencies have changed across Zephyr versions.

* *Kconfig Symbol Deprecation*: We discovered that several Kconfig
  symbols used in older Zephyr versions or examples were deprecated or
  had been renamed. Key examples include:

* `CONFIG_LOG_IMMEDIATE` was replaced by CONFIG_LOG_MODE_IMMEDIATE=y.

* `CONFIG_USB_DEVICE_STACK` is deprecated, and its dependencies have
  changed, requiring a careful selection of related symbols to enable
  the USB subsystem correctly. Symbols for setting USB string descriptors
  (`CONFIG_USB_DEVICE_STRING_DESCRIPTORS`,
  `CONFIG_USB_DEVICE_SERIAL_NUMBER`) were found to be unavailable or
  have unmet dependencies in the initial configurations.

* *Device Tree Dependencies*: Enabling certain USB classes,
  specifically `CONFIG_USB_CDC_ACM` (virtual COM port), required a
  corresponding node (`zephyr,cdc-acm-uart`) to be explicitly defined in
  a device tree overlay.

* *Runtime Initialization Order*: A significant runtime issue was a
  network initialization timeout. The default configuration caused the
  networking stack to wait indefinitely for the USB interface, which
  had not yet been fully initialized by the host. This was resolved by
  disabling the blocking auto-initialization
  (`CONFIG_NET_CONFIG_AUTO_INIT`).

3. Final Code Specifications

The iterative debugging process resulted in a stable and functional
base application with the following components:

## `prj.conf` (Canvas Title: "prj.conf")

* *Core*: Enables C++20, the C standard library, and basic GPIO
  support.

* *Logging*: Configured for immediate-mode logging to the UART backend
  for real-time debugging.

* *Networking*: Enables the core networking stack, Layer 2 Ethernet
  emulation, and IPv6 with support for link-local address
  configuration. The blocking network auto-init is disabled to prevent
  boot hangs.

* *USB Stack*: Enables the core USB device stack, sets a custom Vendor
  ID (0x1209) and Product ID (0x0001), and configures the necessary
  STM32 USB device controller driver. It enables automatic
  initialization of the stack at boot.

* *USB Classes*: Enables both the CDC-ECM (USB Ethernet) and CDC-ACM
  (Virtual COM Port) classes.

## `main.cpp` (Canvas Title: "src/main.cpp")

* Implements a simple C++ application structure.

* Initializes the Zephyr logging subsystem for the main application
  module.

* Includes a `Blinker` class that toggles an LED to provide a visual
  "heartbeat," confirming the application is running.

* The main function logs startup messages and then enters the
  blinker's infinite loop. It relies entirely on the Kconfig settings
  for system initialization.

## `nucleo_h753zi.overlay`

* Contains the necessary device tree fragment to enable the usbotg_fs
  peripheral on the STM32H753 MCU.

* Includes the `cdc_acm_uart` node, which is a required dependency for
  the `CONFIG_USB_CDC_ACM` Kconfig option.

This configuration successfully builds and provides a stable USB
Ethernet interface with an IPv6 link-local address, meeting all the
specified requirements.

4. Future Firmware Update Strategy

For the production SDR transceiver, a firmware update capability is
planned with the following design decisions:

* *Serial-based Recovery*: A small recovery bootloader (~32-64KB) that
  provides firmware update capability via the USB CDC-ACM (virtual COM
  port) interface.

* *YMODEM Protocol*: Use YMODEM for cross-platform compatibility,
  supporting standard terminal programs on Windows (TeraTerm, PuTTY),
  macOS/Linux (minicom, screen). YMODEM provides built-in error
  correction and automatic file transfer.

* *Single Firmware Copy*: With only 2MB of flash available, the design
  will use a single firmware partition rather than dual-banking. The
  recovery bootloader can reflash the main application area directly.

* *Recovery Activation*: If the main application fails to boot or a
  special button sequence is detected, the device remains in recovery
  mode, presenting as a virtual COM port for firmware updates.

This approach prioritizes user accessibility across all major operating
systems while maintaining a small flash footprint suitable for the
STM32H753 constraints.
