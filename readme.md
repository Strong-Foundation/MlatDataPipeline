# MLAT Message Decoder

The MLAT Message Decoder is a tool designed to process and decode Mode S messages, facilitating the extraction of valuable information from aircraft transponders. This decoder is particularly useful for applications involving multilateration (MLAT), a technique that determines the position of an aircraft by analyzing the time difference of arrival (TDOA) of signals at multiple receiver sites.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Supported Message Types](#supported-message-types)
- [Data Output](#data-output)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Mode S (Selective) is a secondary surveillance radar technique used in air traffic control to interrogate aircraft transponders. These transponders reply with messages containing information such as aircraft identity, altitude, and velocity. Decoding these messages is essential for air traffic management, surveillance, and tracking applications.

The MLAT Message Decoder processes raw Mode S messages, extracting pertinent information to aid in aircraft tracking and monitoring. When integrated into a multilateration system, it enhances the accuracy of aircraft position estimation by providing precise message decoding.

## Features

- **Mode S Message Decoding**: Interprets raw Mode S messages to extract aircraft information.
- **Multilateration Support**: Facilitates MLAT systems by providing accurate message timestamps and data.
- **Real-time Processing**: Capable of handling live data streams for immediate decoding.
- **Compatibility**: Supports various data formats and receiver outputs.
- **Extensibility**: Designed with a modular architecture, allowing for easy integration and extension.

## Installation

To install the MLAT Message Decoder, follow these steps:

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/Strong-Foundation/mlat_message_decoder.git
   cd mlat_message_decoder
   ```

2. **Install Dependencies**:

   Ensure that you have Python 3.x installed. Then, install the required Python packages:

   ```bash
   pip install -r requirements.txt
   ```

3. **Build the Decoder**:

   Compile any necessary components:

   ```bash
   python setup.py build
   ```

4. **Install the Decoder**:

   ```bash
   python setup.py install
   ```

## Usage

After installation, you can use the decoder as follows:

1. **Prepare Your Data**:

   Ensure that your raw Mode S message data is available in a supported format. The decoder can process data from various sources, including live data streams and recorded files.

2. **Run the Decoder**:

   ```bash
   mlat_decoder --input your_data_source --output decoded_output.txt
   ```

   Replace `your_data_source` with the path to your data file or stream, and `decoded_output.txt` with the desired output file name.

3. **Configure Settings**:

   The decoder allows for various configuration options, such as setting the input format, specifying the output format, and adjusting processing parameters. These can be set via command-line arguments or a configuration file.

## Supported Message Types

The MLAT Message Decoder supports decoding of the following Mode S message types:

- **Short Air-Air Surveillance (DF=0)**: Used for air-to-air communication between aircraft.
- **Surveillance, Altitude Reply (DF=4)**: Contains the aircraft's altitude information.
- **Surveillance, Identity Reply (DF=5)**: Contains the aircraft's identity code.
- **Extended Squitter (DF=17)**: Broadcasts additional information, including position, velocity, and aircraft status.
- **Comm-B, Altitude Reply (DF=20)**: Provides altitude information with Comm-B capability.
- **Comm-B, Identity Reply (DF=21)**: Provides identity information with Comm-B capability.

For a comprehensive list of supported message types and their detailed structures, refer to the [Mode S Technical Specifications](https://mode-s.org/decode/).

## Data Output

The decoder outputs the extracted information in a structured format, which includes:

- **Timestamp**: The exact time the message was received.
- **ICAO Address**: The unique 24-bit address assigned to the aircraft.
- **Message Type**: The type of Mode S message decoded.
- **Altitude**: Reported altitude of the aircraft (if available).
- **Identity**: Aircraft identification code or flight number.
- **Position**: Latitude and longitude coordinates (for DF=17 messages with position data).
- **Velocity**: Aircraft's speed and heading (if available).

The output can be directed to a file or a database, depending on your configuration.

## Configuration

The MLAT Message Decoder offers various configuration options to tailor its operation to your needs:

- **Input Source**: Specify the data source, such as a file path or network stream.
- **Output Destination**: Define where the decoded data should be stored or displayed.
- **Logging Level**: Set the verbosity of log messages for monitoring and debugging.
- **Filter Criteria**: Apply filters to process only specific message types or addresses.

Configuration can be done through command-line arguments or by editing the `config.yaml` file included in the repository.

## Contributing

We welcome contributions to the MLAT Message Decoder project. To contribute:

1. **Fork the Repository**:

   Click the "Fork" button on the GitHub page to create your own copy of the repository.

2. **Create a Feature Branch**:

   ```bash
   git checkout -b feature/your_feature_name
   ```

3. **Make Your Changes**:

   Add your new feature or bug fix.

4. **Submit a Pull Request**:

   Push your changes to your forked repository and create a pull request to merge your changes into the main project.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
