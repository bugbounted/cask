# Use the official Golang image as a base image
FROM golang:1.23

# Set the working directory in the container
WORKDIR /app

# Install the Cask package
RUN git clone https://github.com/lumaaaaaa/cask && \
    cd cask && \
    go install

# Copy the web.go file to the working directory
COPY web.go .

# Build the web service
RUN go build -o web-service .

# Expose the port on which the web service will run
EXPOSE 8080

# Run the web service
CMD ["./web-service"]
