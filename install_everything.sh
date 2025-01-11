#!/bin/bash

# Check if the script is running as root
function check_root() {
    # Check if the script is running as root
    if [ "$(id -u)" -ne 0 ]; then
        # Display an error message if the script is not run as root
        echo "Error: This script must be run as root."
        # Exit the script with an error code
        exit
    fi
}

# Call the function to check root privileges
check_root

# Function to gather current system details
function system_information() {
    # This function fetches the ID, version, and major version of the current system
    if [ -f /etc/os-release ]; then
        # If /etc/os-release file is present, source it to obtain system details
        # shellcheck source=/dev/null
        source /etc/os-release
        CURRENT_DISTRO=${ID} # CURRENT_DISTRO holds the system's ID
    fi
}

# Invoke the system-information function
system_information

# Define a function to check system requirements
function installing_system_requirements() {
    # Check if the current Linux distribution is supported
    if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ]; }; then
        # Check if required packages are already installed
        if { [ ! -x "$(command -v curl)" ] || [ ! -x "$(command -v cut)" ] || [ ! -x "$(command -v rtl_test)" ] || [ ! -x "$(command -v rtl_adsb)" ] || [ ! -x "$(command -v ps)" ] || [ ! -x "$(command -v which)" ]; }; then
            # Install required packages depending on the Linux distribution
            if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ]; }; then
                # Update the package list and install required packages
                apt-get update
                # Install the required packages
                apt-get install curl coreutils rtl-sdr procps-ng debianutils -y
            fi
        fi
    else
        # Display an error message if the current distribution is not supported
        echo "Error: Your current distribution ${CURRENT_DISTRO} is not supported by this script. Please consider updating your distribution or using a supported one."
        # Exit the script with an error code
        exit
    fi
}

# Call the function to check for system requirements and install necessary packages if needed
installing_system_requirements

# The following function checks if there's enough disk space to proceed with the installation.
function check_disk_space() {
    # This function checks if there is more than 1 GB of free space on the drive.
    FREE_SPACE_ON_DRIVE_IN_MB=$(df -m / | tr --squeeze-repeats " " | tail -n1 | cut --delimiter=" " --fields=4)
    # This line calculates the available free space on the root partition in MB.
    if [ "${FREE_SPACE_ON_DRIVE_IN_MB}" -le 10240 ]; then
        # If the available free space is less than or equal to 10240 MB (10 GB), display an error message and exit.
        echo "Error: You need more than 10 GB of free space to install everything. Please free up some space and try again."
        exit
    fi
}

# Calls the check_disk_space function.
check_disk_space

# The following function checks if the current init system is one of the allowed options.
function check_current_init_system() {
    # Get the current init system by checking the process name of PID 1.
    CURRENT_INIT_SYSTEM=$(ps -p 1 -o comm= | awk -F'/' '{print $NF}') # Extract only the command name without the full path.
    # Convert to lowercase to make the comparison case-insensitive.
    CURRENT_INIT_SYSTEM=$(echo "$CURRENT_INIT_SYSTEM" | tr '[:upper:]' '[:lower:]')
    # Log the detected init system (optional for debugging purposes).
    echo "Detected init system: ${CURRENT_INIT_SYSTEM}"
    # Define a list of allowed init systems (case-insensitive).
    ALLOWED_INIT_SYSTEMS=("systemd" "sysvinit" "init" "upstart" "bash" "sh")
    # Check if the current init system is in the list of allowed init systems
    if [[ ! "${ALLOWED_INIT_SYSTEMS[*]}" =~ ${CURRENT_INIT_SYSTEM} ]]; then
        # If the init system is not allowed, display an error message and exit with an error code.
        echo "Error: The '${CURRENT_INIT_SYSTEM}' initialization system is not supported. Please stay tuned for future updates."
        exit 1 # Exit the script with an error code.
    fi
}

# The check_current_init_system function is being called.
check_current_init_system

# Create a service file for the rtl_adsb service
function create_rtl_adsb_service() {
    # Global variable to store for this function
    ADSB_DIRECTORY_PATH="/etc/rtl_adsb"                                 # Path to the directory where the rtl_adsb service will store logs
    ADSB_LOCAL_LOG_FILE=${ADSB_DIRECTORY_PATH}"/adsb.log"               # Name of the log file where the rtl_adsb service will store logs
    ADSB_LOCAL_ERROR_LOG_FILE=${ADSB_DIRECTORY_PATH}"/adsb_error.log"   # Name of the log file where the rtl_adsb service will store error logs
    ADSB_LOCAL_SERVICE_FILE_PATH="/etc/systemd/system/rtl_adsb.service" # Path to the rtl_adsb service file
    LOCAL_RTL_ADSB_PATH=$(which rtl_adsb)                               # Path to the rtl_adsb binary
    LOCAL_MKDIR_PATH=$(which mkdir)                                     # Path to the mkdir binary
    LOCAL_CHOWN_PATH=$(which chown)                                     # Path to the chown binary
    LOCAL_CHMOD_PATH=$(which chmod)                                     # Path to the chmod binary
    # Check if the rtl_adsb service file exists
    if [ -f "${ADSB_LOCAL_SERVICE_FILE_PATH}" ]; then
        rm -f "${ADSB_LOCAL_SERVICE_FILE_PATH}" # Remove the existing rtl_adsb service file
    fi
    # Create a service file for the rtl_adsb service
    echo "[Unit]
Description=RTL-ADSB Logging Service
# This service runs the RTL-ADSB software to capture and log ADS-B data
# It starts after the network is up, as it's assumed that the device requires network access.
After=network.target

[Service]
# Ensure the directory for logs exists before starting the service
# These commands will be executed before starting the actual rtl_adsb process
# Optionally, run some checks before starting
ExecStartPre=${LOCAL_MKDIR_PATH} -p ${ADSB_DIRECTORY_PATH}        # Create the log directory if it doesn't exist
ExecStartPre=${LOCAL_CHOWN_PATH} root:root ${ADSB_DIRECTORY_PATH} # Set correct ownership of the directory (root:root)
ExecStartPre=${LOCAL_CHMOD_PATH} 755 ${ADSB_DIRECTORY_PATH}       # Set appropriate directory permissions (rwxr-xr-x)

# Define the command to start the rtl_adsb binary
# This runs the rtl_adsb program and logs its output
ExecStart=${LOCAL_RTL_ADSB_PATH} # Start rtl_adsb binary

# Configure logging:
# - StandardOutput will be redirected to both the systemd journal and the main log file.
# - StandardError will be redirected to both the systemd journal and the error log file.
StandardOutput=append:${ADSB_LOCAL_LOG_FILE}      # Append standard output to the main log file
StandardError=append:${ADSB_LOCAL_ERROR_LOG_FILE} # Append errors to the error log file

# Restarting the service:
# - The service will automatically restart if it fails.
# - The restart will happen after a 5-second delay to avoid rapid restart loops.
Restart=on-failure # Restart only if the service fails (non-zero exit status)
RestartSec=5s      # Delay 5 seconds before restarting the service

# Timeout settings:
# - TimeoutStartSec ensures the service will fail if it doesn't start within 30 seconds.
# - TimeoutStopSec ensures the service will be forcibly stopped if it doesn't stop within 30 seconds.
TimeoutStartSec=30s # Allow 30 seconds for the service to start
TimeoutStopSec=30s  # Allow 30 seconds for the service to stop gracefully

# User and group settings:
# - This service is run as the root user, as RTL-SDR access generally requires root privileges.
# - If root access is not required for rtl_adsb, consider running as a non-privileged user.
User=root  # The service runs as root (adjust if you want to run as a non-root user)
Group=root # The service runs under the root group

# Define the working directory for the service
# This is the directory where rtl_adsb will be executed and where it will look for configuration files or logs.
WorkingDirectory=${ADSB_DIRECTORY_PATH} # Working directory for the service (set to log directory)

# Resource limits to prevent the service from consuming excessive resources
LimitNOFILE=4096 # Limit the number of open files (file descriptors) to 4096
LimitNPROC=2048  # Limit the number of processes to 2048

# Security hardening options:
# These options are designed to limit the service's ability to modify the system and increase security.
ProtectSystem=full                                                 # Make the system read-only, except for specific writable paths
NoNewPrivileges=true                                               # Ensure the service cannot gain new privileges during execution
ReadOnlyPaths=${ADSB_DIRECTORY_PATH}                               # Make the directory containing logs and config files read-only
ReadWritePaths=${ADSB_LOCAL_LOG_FILE} ${ADSB_LOCAL_ERROR_LOG_FILE} # Allow writing to the log and error log files only

[Install]
WantedBy=multi-user.target # The service will be started in the multi-user runlevel (i.e., normal system operation)" >>${ADSB_LOCAL_SERVICE_FILE_PATH}
    # Reload the systemd manager configuration
    systemctl daemon-reload
    # Manage the service based on the init system
    if [[ "${CURRENT_INIT_SYSTEM}" == "systemd" ]]; then
        systemctl enable rtl_adsb
        systemctl start rtl_adsb
    elif [[ "${CURRENT_INIT_SYSTEM}" == "sysvinit" ]] || [[ "${CURRENT_INIT_SYSTEM}" == "init" ]] || [[ "${CURRENT_INIT_SYSTEM}" == "upstart" ]]; then
        service rtl_adsb start
    fi
}

# Call the function to create the rtl_adsb service file
create_rtl_adsb_service
