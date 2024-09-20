package main

import (
	"fmt"
	"net/http"
	"os"
	"strings"
)

const (
	BaseURL         = "https://api.chaton.ai"
	Path            = "/chats/stream"
	DefaultModel    = "gpt-4o"
	MaxTokens       = 4096
	SystemPrompt    = "You are ChatGPT, a large language model trained by OpenAI, based on the GPT-4o architecture. You are here to assist and provide information."
	CMDSystemPrompt = "You are ChatGPT, a large language model trained by OpenAI, based on the GPT-4o architecture..."
	APIVersion      = "1.43.441"
	Version         = "1.0"
)

var (
	client = &http.Client{}
)

func printHelp() {
	fmt.Printf("// cask - AI-powered chat interface - v%s - API v%s\n", Version, APIVersion)
	fmt.Println("usage: cask [args] <prompt> ")
	fmt.Println("arguments:")
	fmt.Println("\t-h, --help\t\tshow this help message and exit")
	fmt.Println("\t-v, --version\t\tshow version information and exit")
	fmt.Println("\t-c, --cmd\t\tenable the command mode")
	fmt.Println("\t-m, --model <model name>\t\tset the model to use")
	fmt.Println("\t-r, --raw\t\tonly output the response from the model")
}

// handleCLI is extracted from main.go and will be called from web.go if CLI is used
func handleCLI() {
	mode := "default"
	model := DefaultModel
	raw := false
	promptStart := 0

	if len(os.Args) < 2 {
		printHelp()
		os.Exit(1)
	}

	for i := 1; i < len(os.Args); i++ {
		switch os.Args[i] {
		case "-v", "--version":
			fmt.Println(APIVersion)
			os.Exit(0)

		case "-h", "--help":
			printHelp()
			os.Exit(0)

		case "-c", "--cmd":
			mode = "cmd"
			break

		case "-m", "--model":
			i++
			if model != DefaultModel {
				printHelp()
				os.Exit(1)
			}
			model = os.Args[i]
			break
		case "-r", "--raw":
			raw = true
		default:
			promptStart = i
			break
		}

		if promptStart != 0 {
			break
		}
	}

	if len(os.Args) < promptStart+1 {
		printHelp()
		os.Exit(1)
	}

	args := strings.Join(os.Args[promptStart:], " ")

	if raw && mode == "cmd" {
		fmt.Println("Error: raw mode cannot be used with command mode.")
		os.Exit(1)
	}

	handleChat(args, model, mode, raw)
}
