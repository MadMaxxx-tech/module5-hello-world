package main
import (
	"fmt"
	"net/http"
)
var buildVersion string
func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello, World! Build version: %s\n", buildVersion)
	})
	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(err)
	}
}
