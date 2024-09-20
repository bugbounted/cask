# Use the official Golang 1.23 image as the base
FROM golang:1.23

# Set the working directory inside the container
WORKDIR /app

# Install dependencies and cask
RUN git clone https://github.com/lumaaaaaa/cask && \
    cd cask && \
    go install

# Create the web.go file dynamically within the Dockerfile
RUN echo 'package main \
import ( \
    "fmt" \
    "io/ioutil" \
    "log" \
    "net/http" \
    "os/exec" \
) \
func handleRequest(w http.ResponseWriter, r *http.Request) { \
    prompt := r.URL.Query().Get("prompt") \
    if prompt == "" { \
        http.Error(w, "Missing \'prompt\' parameter", http.StatusBadRequest) \
        return \
    } \
    cmd := exec.Command("cask", prompt) \
    output, err := cmd.CombinedOutput() \
    if err != nil { \
        http.Error(w, fmt.Sprintf("Error running Cask: %s", err), http.StatusInternalServerError) \
        return \
    } \
    w.Header().Set("Content-Type", "text/plain") \
    w.WriteHeader(http.StatusOK) \
    w.Write(output) \
} \
func main() { \
    http.HandleFunc("/", handleRequest) \
    port := "8080" \
    fmt.Printf("Starting server on port %s...\\n", port) \
    log.Fatal(http.ListenAndServe(":"+port, nil)) \
}' > web.go

# Build the Go web service binary
RUN go build -o webservice web.go

# Expose port 8080 for the web service
EXPOSE 8080

# Run the web service
CMD ["./webservice"]
