### CodeMuse – AI‑Powered Coding Assistant in Go
Build, test, document, and share your code locally—never leave the IDE.

##🚀 What is CodeMuse?
CodeMuse is a self‑contained, Go‑based AI coding assistant that plugs into your workflow and runs entirely on‑premise.
* Chat with a LLM (OpenAI, Claude, Ollama, Mistral, Gemini…)*
* Let it read‑write your files, run tests, generate docs, and even execute code in a sandbox.*
* Let a human approve every change—no accidental code injection.*
* Pull in the latest news, embed your own docs, and keep everything audit‑ready.*

TL;DR – A “local agent” that turns natural language into safe, verified Go code and documentation, all from the comfort of your editor or a tiny desktop app.

## 📚 Table of Contents

- [Demo](#-demo)
- [Why Go?](#-why-go)
- [Core Concepts](#-core-concepts)
- [Architecture](#️-architecture)
- [File Layout](#-file-layout)
- [Prerequisites](#️-prerequisites)
- [Local Setup](#-local-setup)
- [Running the Agent](#-running-the-agent)
- [Sample Conversation](#-sample-conversation)
- [Extending CodeMuse](#-extending-codemuse)
  - [Adding a New LLM Provider](#adding-a-new-llm-provider)
  - [Implementing a New Tool](#implementing-a-new-tool)
  - [Creating a New Persona](#creating-a-new-persona)
  - [Plugging a Vector Store](#plugging-a-vector-store)
- [Configuration](#️-configuration)
- [Audit & Security](#️-audit--security)
- [Frequently Asked Questions](#-faq)
- [Troubleshooting](#-troubleshooting)
- [Testing](#-testing)
- [Build & Release](#-build--release)
- [License](#-license)
- [Contributing](#-contributing)
## 📹 Demo

CodeMuse is currently in active development. Once the core agent implementation is complete, we'll provide:

- **2-minute video demo** showing the agent creating a web server from a single prompt
- **Interactive examples** you can try locally
- **Live playground** for testing different LLM providers
- **Tutorial walkthroughs** for common development tasks

### Try It Now (Current State)

```bash
# Clone and setup
git clone https://github.com/KunjShah95/codemuse
cd codemuse
go mod tidy

# Verify installation
make test
make config

# Start with Docker Compose
docker-compose up
```

**Coming Soon**: Full conversational AI coding assistant with sandbox execution!

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
## 📦 File Layout

```
codemuse/
├─ internal/
│  └─ config/           # Configuration management with Viper
├─ Dockerfile           # Container build configuration  
├─ Makefile            # Build automation
├─ config.yaml         # Default configuration file
├─ docker-compose.yml  # Multi-service setup with Weaviate
├─ go.mod              # Go module definition
├─ go.sum              # Go module checksums
├─ go.work             # Go workspace file
└─ readme.md           # This documentation

**Note**: This is a foundational structure. Additional directories like `cmd/`, `tools/`, `llm/`, etc. will be added as the project develops.
```
## 🛠️ Prerequisites

| Item | Minimum Version | Notes |
|------|-----------------|-------|
| Go | 1.24+ | Required for building and running the application |
| Docker | 20.10+ | Optional - for sandboxed execution and vector store |
| Git | 2.0+ | For cloning and version control |

**Optional Dependencies:**
- **Weaviate** 23.3+ or **Chroma** - for vector store functionality
- **Node.js** 18+ - if you plan to extend with web UI features

**API Keys** (choose one or more):
- OpenAI API key for GPT models
- Anthropic API key for Claude models  
- Mistral API key for Mistral models
- Or use Ollama for local models (no API key required)

## 🚀 Local Setup

### Step 1: Clone the Repository
```bash
git clone https://github.com/KunjShah95/codemuse
cd codemuse
```

### Step 2: Install Dependencies
```bash
go mod tidy
```

### Step 3: Configure Environment
Choose one of the following methods:

**Method A: Environment Variables**
```bash
# For OpenAI (recommended for beginners)
export OPENAI_API_KEY="your-openai-key-here"

# For Claude
export ANTHROPIC_API_KEY="your-claude-key-here"

# For Mistral  
export MISTRAL_API_KEY="your-mistral-key-here"

# For local models (no API key needed)
# Just use Ollama - see config.yaml
```

**Method B: Configuration File**
Copy and customize the configuration:
```bash
cp config.yaml my-config.yaml
# Edit my-config.yaml with your preferred settings
```

### Step 4: Verify Setup
```bash
# Check available commands
make help

# View current configuration
make config

# Run tests to verify everything works
make test
```

### Step 5: Optional - Start Vector Database
If you want to use RAG (Retrieval-Augmented Generation) features:
```bash
# Using Docker Compose (recommended)
docker-compose up weaviate -d

# Or manually with Docker
docker run -d --name weaviate -p 8081:8080 semitechnologies/weaviate:latest
```

## 🔧 Running the Agent

**Current Status**: CodeMuse is in active development. The core architecture and configuration system are in place.

### Available Commands

```bash
# View all available commands
make help

# Check current configuration
make config

# Run tests
make test

# Build (when agent is implemented)
make build

# Docker deployment
docker-compose up
```

### Using Docker Compose (Recommended for Development)

```bash
# Start all services (agent + weaviate vector store)
docker-compose up

# Start just the vector store
docker-compose up weaviate -d

# View logs
docker-compose logs -f agent
```

### Configuration Example

The project includes a working `config.yaml` with Ollama setup:

```yaml
provider: ollama                # openai | claude | ollama | mistral | gemini
port: 11434
models:
  assistant: "gpt-oss:20b"
  planner:   "gpt-oss:20b"
  critic:    "gpt-oss:20b"
  evaluator: "gpt-oss:20b"
  expert:    "gpt-oss:20b"
  user:      "gpt-oss:20b"
```

**Coming Soon**: CLI and UI interfaces will be available as the implementation progresses.

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

## 👩‍💻 Future: Sample Conversation
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

## ⚙️ Configuration

CodeMuse supports configuration through both environment variables and YAML configuration files.

### Configuration Methods

**Method 1: Environment Variables**
```bash
# Provider selection
export PROVIDER=openai              # openai, claude, ollama, mistral, gemini

# API Keys (choose based on provider)
export OPENAI_API_KEY=sk-...
export ANTHROPIC_API_KEY=sk-ant-...
export MISTRAL_API_KEY=...

# Optional settings
export PORT=8080                    # Web UI port
export VECTOR_URL=http://localhost:8081  # Vector store URL
export WORKSPACE=./workspace        # Work directory
```

**Method 2: YAML Configuration**
```yaml
# config.yaml
provider: ollama                    # or openai, claude, mistral, gemini
port: 11434                        # API/UI port
workspace: ./workspace             # Working directory

# Model configuration
models:
  assistant: "gpt-oss:20b"
  planner:   "gpt-oss:20b"
  critic:    "gpt-oss:20b"
  evaluator: "gpt-oss:20b"
  expert:    "gpt-oss:20b"
  user:      "gpt-oss:20b"

# Vector store (optional)
vector_store:
  url: "http://localhost:8081"
  type: "weaviate"                  # or chroma
```

### Configuration Options

| Setting | Default | Description |
|---------|---------|-------------|
| `provider` | `openai` | LLM provider (openai, claude, ollama, mistral, gemini) |
| `api_key` | – | API key for the selected provider (not needed for Ollama) |
| `port` | `8080` | HTTP port for web interface |
| `workspace` | `./workspace` | Directory where the agent can read/write files |
| `vector_url` | – | Base URL of your vector store (Weaviate/Chroma) |
| `models.*` | – | Model names for different roles (assistant, planner, etc.) |

### Loading Configuration

CodeMuse uses [Viper](https://github.com/spf13/viper) for configuration management:
1. Loads `config.yaml` if present
2. Environment variables override YAML settings
3. Environment variables use `CODEMUSE_` prefix

**Example**: `CODEMUSE_PROVIDER=claude` overrides `provider: openai` in YAML.

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

docker build -t ghcr.io/kunjshah95/codemuse:latest .

# Push to GitHub Container Registry

docker push ghcr.io/kunjshah95/codemuse:latest
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
