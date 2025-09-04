### CodeMuse – AI‑Powered Coding Assistant in Go
Build, test, document, and share your code locally—never leave the IDE.

##🚀 What is CodeMuse?
CodeMuse is a self‑contained, Go‑based AI coding assistant that plugs into your workflow and runs entirely on‑premise.
* Chat with a LLM (OpenAI, Claude, Ollama, Mistral, Gemini…)*
* Let it read‑write your files, run tests, generate docs, and even execute code in a sandbox.*
* Let a human approve every change—no accidental code injection.*
* Pull in the latest news, embed your own docs, and keep everything audit‑ready.*

TL;DR – A “local agent” that turns natural language into safe, verified Go code and documentation, all from the comfort of your editor or a tiny desktop app.

📚 Table of Contents
Demo
Why Go?
Core Concepts
Architecture
Features
File Layout
Prerequisites
Local Setup
Running the Agent
Using the CLI
Using the Desktop UI
Extending CodeMuse
Adding a New LLM Provider
Implementing a New Tool
Creating a New Persona
Plugging a Vector Store
Configuration
Audit & Security
Frequently Asked Questions
Troubleshooting
Testing
Build & Release
License
Contributing
📹 Demo
Watch a 2‑minute video that demonstrates creating a web server from a single prompt and running it in a sandbox.

✨ Why Go?

| Reason | Impact |
|--------|--------|
| Performance | compiled binaries, static linking, fast startup. |
| One binary | no runtime, no node/python dependencies. |
| Strong type safety | fewer runtime panics. |
| Rich ecosystem | Docker & DB drivers, CLI & GUI libraries, LLM SDKs. |
| Cross-platform | works out-of-the-box on Linux, macOS, windows. |

🧩 Core Concepts

| Component | What it does |
|-----------|-------------|
| Event Loop | drives the conversation, handles tool calls, and keeps state local. |
| Provider Layer | an abstraction over any LLM (OpenAI, Claude, Ollama, etc.). |
| Tool Registry | read, list, edit, run shell, upload, sandbox execute. |
| Federation | multiple "sub-agents" (Planner, DocGen, Tester) that the core delegates to. |
| RAG / Context Builder | queries a vector store (Weaviate/Chroma) to prep the prompt with the latest docs or news. |
| Persona System | injects a prompt prefix and filters accessible tools. |
| Audit Log | every message, tool call and result is stored in SQLite for compliance & debugging. |
| HILO (Human-in-the-Loop) | pop-up approvals and edits in the UI. |
| UI (Fyne) | modern desktop interface or HTTP/HTMX UI. |

⚙️ Architecture Diagram
┌──────────────────────────────────────────────────┐
│             CodeMuse (Go backend)              │
│   ┌───────────────────────┬─────────────────┐ │
│   │  Event Loop (agent)   │  UI (Fyne/Gin) │ │
│   │  ┌───────┐       │  │  ┌───────┐       │ │
│   │  │ Provider │◀──────┤  │  │ Editor│       │ │
│   │  └───────┘       │  │  └───────┘       │ │
│   │  ┌───────┐        │  │  ┌──────────┐     │ │
│   │  │ Tool   │◀───── │  │  │ Vector   │-----│ │
│   │  │ Reg    │        │  │  │ Store    │     │ │
│   │  └───────┘        │  │  └──────────┘     │ │
│   │  ┌───────┐        │  │  ┌───────────────┐ │ │
│   │  │ Audit  │◀───── │  │  │ Federation    │ │ │
│   │  └───────┘        │  │  └───────────────┘ │ │
│   └──────────────────────┴─────────────────┘ │
└──────────────────────────────────────────────────┘
📦 File Layout
go-coding-agent/
├─ cmd/
│  ├─ agent/      # CLI binary (chat + tool exec)
│  ├─ ui/         # Desktop GUI (Fyne)
│  └─ web/        # Optional: Gin/HTMX web UI
├─ internal/
│  ├─ agent/      # Event loop, tool registry
│  ├─ llm/        # Provider interface + OpenAI/Claude/Ollama stubs
│  ├─ tools/      # read, edit, bash, upload, exec, etc.
│  ├─ federation/ # Sub‑agents (Planner, Tester, DocGen)
│  ├─ personas/   # Persona registry
│  ├─ rag/        # Context builder + vector store abstraction
│  ├─ storage/    # Audit DB + vector store client
│  └─ config/     # Config loader (Viper)
├─ Dockerfile
├─ Makefile
├─ .gitignore
├─ README.md
├─ go.mod
└─ go.sum
🛠️ Prerequisites

| Item | Minimum Version |
|------|-----------------|
| Go | 1.24+ |
| Docker | 20.10+ (for sandboxed exec) |
| (Optional) Weaviate | 23.3+ (or any vector store) |
| (Optional) Node | 18+ (if you enable the web UI and install htmx assets) |

Tip – Use our devenv.sh script from the workshop repo for a ready-to-go dev environment that bundles all of the above.

🚀 Local Setup

# 1️⃣ Clone

git clone https://github.com/yourorg/go-coding-agent
cd go-coding-agent

# 2️⃣ Install dependencies

go mod tidy

# 3️⃣ Set environment variables

export ANTHROPIC_API_KEY="your-claude-key"
export OPENAI_API_KEY="your-openai-key"
export MISTRAL_API_KEY="your-mistral-key"

# 4️⃣ (Optional) Start a vector DB

docker run -d --name weaviate -p 8081:8080 semitechnologies/weaviate

# 5️⃣ Create a dev config (if you prefer YAML over env)

cat > config.yaml <<EOF
provider: openai
api_key: $OPENAI_API_KEY
port: 8080
EOF

🔧 Running the Agent

CLI

# start the conversation loop

go run cmd/agent/main.go

# Sample session

> create a simple Go HTTP server
Assistant: (running plan)
...

> execute the plan
Assistant: (tool result)
...
Assistant: Done! The code is at server/main.go

Desktop UI

go run cmd/ui/main.go

# Click the chat pane, type a prompt, hit “Send”

# The UI shows chat history, tool outputs, and the file explorer side‑pane.

Note – The UI uses a simple Fyne app; it can be turned into a web UI with Gin + HTMX (cmd/web/main.go).

👩‍💻 Sample Conversation
User: Create a Go Gin HTTP router that responds “Hello, world!” to GET /hello
Assistant: I’ll plan the steps. (Uses planner sub‑agent)
Assistant (plan):

  1. Install Gin
  2. Create main.go with router
  3. Write unit test
  4. Run sandboxed tests

Assistant: All set. Do you want me to generate tests? (yes/no)
User: yes
Assistant: Running sandboxed tests… PASS
Assistant: Created main.go and main_test.go in the workspace.
🔋 Extending CodeMuse
Adding a New LLM Provider
Create a file internal/llm/mistral.go.
Implement LLMProvider – follow the pattern from openai.go.
Register it in llm/factory.go:

```go
case "mistral":
    return NewMistralProvider()
```

Add the API key in env: MISTRAL_API_KEY=....
Implementing a New Tool

```go
// internal/tools/rename_file.go
type RenameTool struct{}

func NewRenameTool() *RenameTool { return &RenameTool{} }

func (t *RenameTool) Name() string { return "rename_file" }
func (t *RenameTool) Description() string { return "Rename a file in the workspace" }
func (t *RenameTool) Run(ctx context.Context, payload string) (string, error) {
    // payload: {"old":"foo.go","new":"bar.go"}
    var req struct{ Old, New string }
    json.Unmarshal([]byte(payload), &req)
    return os.Rename(req.Old, req.New)
}
```

Register it in tools/register_all.go.

Creating a New Persona

```go
personaReg.Register(&personas.Persona{
    ID:          "translator",
    Description: "Translates user prompts into the target language.",
    Prompt:      "You are a professional translator…",
    Allowed:     []string{}, // all tools are allowed
})
```

Plugging a Vector Store
Pick a client (weaviate/chroma). Create internal/storage/weaviate.go implementing rag.VectorStore.

Then, in cmd/agent/main.go:

```go
vector, err := storage.NewWeaviateClient("http://localhost:8081")
if err != nil { log.Fatal(err) }

contextBuilder := rag.NewContextBuilder(vector)
```

⚙️ Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| PROVIDER | openai | Backend model (openai, claude, ollama, mistral, gemini) |
| API_KEY | – | API key for the selected provider. |
| PORT | 8080 | HTTP port if you run the web UI (cmd/web). |
| VECTOR_URL | – | Base URL of your vector store (Weaviate/Chroma). |
| WORKSPACE | ./workspace | Root directory that the agent can read/write. |

Tip – Store keys in a .env file and use dotenv or viper to load them.

🛡️ Audit & Security
Audit DB – every message is committed to a SQLite log (audit/audit.db).

```go
db := storage.NewAuditDB("./audit/audit.db")
db.Log(event)
```

Sandboxed execution – every code run spawns a Docker container (golang:1.24-alpine) with no network and a tight CPU/memory limit.
HILO – every tool call that rewrites files or runs shell commands is presented to the user for approval via the UI.
❓ FAQ

| Question | Answer |
|----------|--------|
| Can I run it on a low-end laptop? | Yes – it's a single Go binary, ~15 MB, and the Docker sandbox can be disabled if you trust the input. |
| How to add another vector store? | Implement the rag.VectorStore interface and register it in rag/context.go. |
| I get "unknown tool: xyz" | The tool wasn't registered in tools/register_all.go. Add it or register it manually. |
| What if I want to run the agent as a background service? | systemd or pm2 can launch the binary; expose the socket (--port 8080) and call it via the web API. |
| Is it safe to run with the public API key? | The agent never pushes code to a remote repo automatically; everything stays local unless you explicitly call git push. |

🔧 Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| LLM returns "Invalid API Key" | Environment variable not loaded. | Ensure export OPENAI_API_KEY=… or set api_key in config.yaml. |
| Docker sandbox fails with "permission denied" | Docker not installed/running or user not in docker group. | sudo systemctl start docker and sudo usermod -aG docker $USER. |
| Vector store returns no hits | Embeddings not indexed yet. | Run scripts/fetch_news.sh or manually embed sample files. |
| Agent locks up on tool call | Tool has a long-running command. | Increase Docker's --memory/--cpus or add a timeout in tools/*.go. |

✅ Testing

# Unit tests for core components

go test ./internal/... -run Test

# End‑to‑end using the mock provider

go test ./cmd/agent -run TestChatLoop
All tests use the MockProvider so they run instantly and don’t hit external APIs.

📦 Build & Release

# Build binaries for all OSes

go build -o bin/agent ./cmd/agent
go build -o bin/ui ./cmd/ui

# Build Docker image

docker build -t ghcr.io/yourorg/codemuse:latest .

# Push to GitHub Container Registry

docker push ghcr.io/yourorg/codemuse:latest
📜 License
MIT – see LICENSE.

🤝 Contributing
Fork & clone.
Create a feature branch.
Add tests.
Open a PR; we’ll run make test in CI.
Keep the README and CHANGES up‑to‑date.
Guidelines – keep changes self‑contained, document new providers or tools, and update the demo video if you add UI features.

Happy coding with CodeMuse!
