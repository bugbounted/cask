# Use the official Go image as the base image
FROM golang:1.20 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
RUN go build -o web

# Start a new stage from scratch
FROM debian:bullseye-slim

# Install the Cask package
RUN apt-get update && apt-get install -y \
    git \
    && git clone https://github.com/lumaaaaaa/cask \
    && cd cask \
    && go install \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the binary and any required files from the builder stage
COPY --from=builder /app/web .

# Expose port 8080 to the outside world
EXPOSE 8080

# Run the web service
CMD ["./web"]
