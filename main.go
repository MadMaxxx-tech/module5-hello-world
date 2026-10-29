package main

import (
	"fmt"
	"net/http"

	"github.com/google/uuid"
)

var buildVersion string

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		requestID := uuid.NewString()

		w.Header().Set("X-Request-ID", requestID)
		fmt.Fprintf(w, "Hello, World! Build version: %s\n", buildVersion)
	})

	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(err)
	}
}
