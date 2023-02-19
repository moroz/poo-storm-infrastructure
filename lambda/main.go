package main

import (
	"context"

	runtime "github.com/aws/aws-lambda-go/lambda"
)

func handleRequest(ctx context.Context) (string, error) {
	return "OK", nil
}

func main() {
	runtime.Start(handleRequest)
}
