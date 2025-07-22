-- Advanced Go snippets

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  -- HTTP server
  s(
    "httpserver",
    fmt(
      [[
package main

import (
	"fmt"
	"log"
	"net/http"
)

func {}(w http.ResponseWriter, r *http.Request) {{
	fmt.Fprintf(w, "Hello, World!")
}}

func main() {{
	http.HandleFunc("/", {})
	log.Println("Server starting on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}}
]],
      { i(1, "handler"), rep(1) }
    )
  ),

  -- Gin router
  s(
    "gin",
    fmt(
      [[
package main

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

func main() {{
	r := gin.Default()
	
	r.GET("/", func(c *gin.Context) {{
		c.JSON(http.StatusOK, gin.H{{
			"message": "{}",
		}})
	}})
	
	r.Run(":8080")
}}
]],
      { i(1, "Hello, World!") }
    )
  ),

  -- Database connection
  s(
    "db",
    fmt(
      [[
package main

import (
	"database/sql"
	"log"
	
	_ "github.com/lib/pq"
)

func connectDB() (*sql.DB, error) {{
	db, err := sql.Open("postgres", "{}")
	if err != nil {{
		return nil, err
	}}
	
	if err := db.Ping(); err != nil {{
		return nil, err
	}}
	
	return db, nil
}}

func main() {{
	db, err := connectDB()
	if err != nil {{
		log.Fatal(err)
	}}
	defer db.Close()
	
	{}
}}
]],
      { i(1, "postgres://user:password@localhost/dbname?sslmode=disable"), i(2, "// Use database") }
    )
  ),

  -- Context with timeout
  s(
    "ctx",
    fmt(
      [[
ctx, cancel := context.WithTimeout(context.Background(), {}*time.Second)
defer cancel()

{}
]],
      { i(1, "30"), i(2, "// Use context") }
    )
  ),

  -- Worker pool
  s(
    "worker",
    fmt(
      [[
func worker(id int, jobs <-chan {}, results chan<- {}) {{
	for j := range jobs {{
		fmt.Printf("Worker %d processing job %v\n", id, j)
		{}
		results <- {}
	}}
}}

func main() {{
	jobs := make(chan {}, 100)
	results := make(chan {}, 100)
	
	// Start workers
	for w := 1; w <= {}; w++ {{
		go worker(w, jobs, results)
	}}
	
	// Send jobs
	for j := 1; j <= {}; j++ {{
		jobs <- {}
	}}
	close(jobs)
	
	// Collect results
	for a := 1; a <= {}; a++ {{
		<-results
	}}
}}
]],
      {
        i(1, "Job"),
        i(2, "Result"),
        i(3, "// Process job"),
        i(4, "result"),
        rep(1),
        rep(2),
        i(5, "3"),
        i(6, "5"),
        i(7, "j"),
        rep(6),
      }
    )
  ),

  -- Table-driven test
  s(
    "tabletest",
    fmt(
      [[
func Test{}(t *testing.T) {{
	tests := []struct {{
		name     string
		input    {}
		expected {}
	}}{{
		{{
			name:     "{}",
			input:    {},
			expected: {},
		}},
	}}
	
	for _, tt := range tests {{
		t.Run(tt.name, func(t *testing.T) {{
			result := {}(tt.input)
			if result != tt.expected {{
				t.Errorf("{}() = %v, want %v", result, tt.expected)
			}}
		}})
	}}
}}
]],
      {
        i(1, "FunctionName"),
        i(2, "string"),
        i(3, "string"),
        i(4, "test case"),
        i(5, '"input"'),
        i(6, '"expected"'),
        i(7, "functionName"),
        rep(7),
      }
    )
  ),

  -- Middleware
  s(
    "middleware",
    fmt(
      [[
func {}(next http.Handler) http.Handler {{
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {{
		// Before
		{}
		
		next.ServeHTTP(w, r)
		
		// After
		{}
	}})
}}
]],
      { i(1, "middlewareName"), i(2, "// Pre-processing"), i(3, "// Post-processing") }
    )
  ),
}
