package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os/exec"
)

func handleRequest(w http.ResponseWriter, r *http.Request) {
	// Extract the 'prompt' query parameter from the request
	prompt := r.URL.Query().Get("prompt")
	if prompt == "" {
		http.Error(w, "Missing 'prompt' parameter", http.StatusBadRequest)
		return
	}

	// Run the Cask command
	cmd := exec.Command("cask", prompt)
	output, err := cmd.CombinedOutput()
	if err != nil {
		http.Error(w, fmt.Sprintf("Error running Cask: %s", err), http.StatusInternalServerError)
		return
	}

	// Write the output to the HTTP response
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	w.Write(output)
}

func main() {
	http.HandleFunc("/", handleRequest)
	port := "8080"
	fmt.Printf("Starting server on port %s...\n", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
