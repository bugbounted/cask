# Stage 1: Build the Go application
FROM golang:1.20 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download all dependencies
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go application
RUN go build -o web

# Stage 2: Create the final image with Cask installed
FROM debian:bullseye-slim

# Install dependencies and Go
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && wget https://dl.google.com/go/go1.20.7.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.20.7.linux-amd64.tar.gz \
    && rm go1.20.7.linux-amd64.tar.gz \
    && echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile \
    && /bin/bash -c "source /etc/profile"

# Install Cask
RUN git clone https://github.com/bugbounted/cask \
    && cd cask \
    && go install \
    && cd .. \
    && rm -rf cask

# Set the Working Directory inside the container
WORKDIR /app

# Copy the Go application from the builder stage
COPY --from=builder /app/web .

# Expose port 8080
EXPOSE 8080

# Run the Go application
CMD ["./web"]
