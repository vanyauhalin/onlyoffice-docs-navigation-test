package main

import (
	"fmt"
	"os"

	"github.com/google/brotli/go/cbrotli"
)

func main() {
	n, err := os.ReadFile("nav.html")
	check(err)

	e, err := cbrotli.Encode(n, cbrotli.WriterOptions{Quality: 11})
	check(err)

	d, err := cbrotli.Decode(e)
	check(err)

	fmt.Println()
	fmt.Printf("from\n  len: %v\n  kb: %v\n", len(d), float64(len(d)) / 1024.0)
	fmt.Printf("to\n  len: %v\n  kb: %v\n", len(e), float64(len(e)) / 1024.0)
	fmt.Println()

	panic("done")
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
