FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update the OS
RUN apt-get update && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    apt-get install -f -y

# Install required dependencies
RUN apt-get install bash sudo wget gpg apt-transport-https curl coreutils nano -y

# Import the Elasticsearch PGP Key
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | \
    gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# Install the APT repo sources for Elasticsearch
RUN echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | \
    tee /etc/apt/sources.list.d/elastic-8.x.list

# Install Elasticsearch and Kibana
RUN sudo apt-get update && \
    sudo apt-get install elasticsearch kibana -y

# Create a non-root user, set a password, and add to the sudo group
RUN useradd -ms /bin/bash kibanauser && \
    echo "kibanauser:yourpassword" | chpasswd && \
    usermod -aG sudo kibanauser && \
    mkdir -p /var/log/elasticsearch && \
    mkdir -p /var/log/kibana /run/kibana && \
    chown -R kibanauser:kibanauser /usr/share/elasticsearch /var/lib/elasticsearch /var/log/elasticsearch /etc/default/elasticsearch && \
    chown -R kibanauser:kibanauser /usr/share/kibana /etc/elasticsearch /etc/kibana /var/log/kibana /run/kibana && \
    chmod -R 755 /etc/default/elasticsearch /run/kibana

# Switch to the new user
USER kibanauser

# Expose the necessary ports
EXPOSE 9200 5601

# Start Elasticsearch and Kibana
CMD ["/bin/bash", "-c", "/usr/share/elasticsearch/bin/elasticsearch & /usr/share/kibana/bin/kibana"]

# Build the image
# docker build -t elastic-kibana .

# Run the container
# docker run -p 9200:9200 -p 5601:5601 elastic-kibana