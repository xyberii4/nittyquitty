package database

import (
	"database/sql"
	"log"
    "fmt"

	_ "github.com/go-sql-driver/mysql"
)

func connect() *sql.DB {
    database_username := "DB_USERNAME" // Find username somehow
    database_password := "DB_PASSWORD" // Find password somehow
    database_name := "DB_NAME" // Find database name somehow
    host := "DB_HOST" // Find host somehow
    port := "DB_PORT" // Find port somehow

    sql_connection := database_username + ":" + database_password + "@tcp(" + host + ":" + port + ")/" + database_name
    //Connect to database
    database, error := sql.Open("mysql", sql_connection)
    if error != nil {
        log.Fatal(error)
    }
    defer database.Close()
    return database
}

func insert(username string, email string, password string) {
    db := connect()
    _, error := db.Exec("INSERT INTO users (username, email, password) VALUES (?, ?, ?)", username, email, password)
    if error != nil {
        log.Fatal(error)
    }
}

func query(id int) {
    //Example query for instance getting first 10 users idk
    db := connect()
    var username, email string
    row := db.QueryRow("SELECT username, email FROM users WHERE id = ?", id)
    if err := row.Scan(&username, &email); err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Username: %s, Email: %s\n", username, email)
}