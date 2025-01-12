// main.go
package main

import (
	"fmt"
	"net/http"

	"github.com/alleem18/Chat-Application/backend/pkg/websocket"
)

func serveWs(pool *websocket.Pool, w http.ResponseWriter, r *http.Request) {
	fmt.Println("WebSocket Endpoint Hit")
	conn, err := websocket.Upgrade(w, r)
	if err != nil {
		fmt.Fprintf(w, "%+v\n", err)
	}

	client := &websocket.Client{
		Conn: conn,
		Pool: pool,
	}

	pool.Register <- client
	client.Read()
}

func setupRoutes() {
	pool := websocket.NewPool()
	go pool.Start()

	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		serveWs(pool, w, r)
	})

	// Serve React build folder
	http.Handle("/", http.FileServer(http.Dir("./frontend")))
}

func main() {
	fmt.Println("Chat App Server started on port :8080")
	setupRoutes()
	http.ListenAndServe(":8080", nil)
}
