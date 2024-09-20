# Stage 1: Build the Go application
FROM golang:1.20 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go application
RUN go build -o web

# Stage 2: Create the final image with Cask installed
FROM debian:bullseye-slim

# Install Cask
RUN apt-get update && apt-get install -y \
    git \
    && git clone https://github.com/bugbounted/cask \
    && cd cask \
    && go install \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the Working Directory inside the container
WORKDIR /app

# Copy the Go application from the builder stage
COPY --from=builder /app/web .

# Expose port 8080
EXPOSE 8080

# Run the Go application
CMD ["./web"]
