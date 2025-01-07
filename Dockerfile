# Use the latest Debian image as the base
FROM debian:latest

# Update package list and install dependencies
RUN apt-get update && \
    apt-get install python3-pip -y && \
    apt-get install python3-dev -y && \
    apt-get install curl -y && \
    apt-get install python3-venv -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3 -m venv /venv

# Upgrade pip inside the virtual environment
RUN /venv/bin/pip install --upgrade pip

# Install JupyterLab inside the virtual environment
RUN /venv/bin/pip install jupyterlab

# Expose port 8888 for JupyterLab
EXPOSE 8888

# Set the working directory (optional)
WORKDIR /mlat_message_decoder

# Copy the test data and the source code into the container
COPY adsb_raw_data.txt /mlat_message_decoder

# Copy the JupyterLab configuration file into the container
COPY decode_adsb.ipynb /mlat_message_decoder

# Start JupyterLab using the virtual environment
CMD ["/venv/bin/jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]

# Build the Docker image and run the container
# docker build -t jupyterlab-debian-latest .
# Run the container and map the host port 8888 to the container port 8888
# docker run -d -p 8888:8888 --name jupyterlab-container jupyterlab-debian-latest
