# Use Ubuntu as the base image
FROM ubuntu:latest

# Update the package list and install Go
RUN apt-get update && \
    apt-get install golang -y

# Set the working directory
WORKDIR /parse_adsb_messages

# Copy the parser file to the container
COPY main.go /parse_adsb_messages/

# Build the application
RUN go build .

# Run the application
CMD ["./parse_adsb_messages"]