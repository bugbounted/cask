# Use an official Go runtime as a parent image
FROM golang:1.20 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go source code into the container
COPY web.go .

# Install Cask
RUN git clone https://github.com/bugbounted/cask && \
    cd cask && \
    go install

# Build the Go application
RUN go build -o webservice web.go

# Start a new stage from scratch
FROM debian:bullseye-slim

# Copy the Go binary and Cask binary from the builder stage
COPY --from=builder /app/webservice /usr/local/bin/webservice
COPY --from=builder /go/bin/cask /usr/local/bin/cask

# Expose port 8080
EXPOSE 8080

# Run the Go application
ENTRYPOINT ["/usr/local/bin/webservice"]
