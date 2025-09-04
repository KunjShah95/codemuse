# CodeMuse – AI‑Powered Coding Assistant in Go

Build, test, document, and share your code locally—never leave the IDE.

---

## 🚀 What is CodeMuse?

**CodeMuse** is a self‑contained, Go‑based AI coding assistant that plugs into your workflow and runs entirely on‑premise.

- **Chat with an LLM** (OpenAI, Claude, Ollama, Mistral, Gemini…)
- **Read/write your files, run tests, generate docs, and execute code in a sandbox**
- **Human-in-the-loop:** Every change is approved—no accidental code injection
- **Pull in the latest news, embed your docs, and keep everything audit-ready**

> *TL;DR*: A “local agent” that turns natural language into safe, verified Go code and documentation, all from your editor or a tiny desktop app.

---

## 📚 Table of Contents

- [Demo](#demo)
- [Why Go?](#why-go)
- [Core Concepts](#core-concepts)
- [Architecture](#architecture)
- [Features](#features)
- [File Layout](#file-layout)
- [Prerequisites](#prerequisites)
- [Local Setup](#local-setup)
- [Running the Agent](#running-the-agent)
- [Using the CLI](#using-the-cli)
- [Using the Desktop UI](#using-the-desktop-ui)
- [Extending CodeMuse](#extending-codemuse)
- [Adding a New LLM Provider](#adding-a-new-llm-provider)
- [Implementing a New Tool](#implementing-a-new-tool)
- [Creating a New Persona](#creating-a-new-persona)
- [Plugging a Vector Store](#plugging-a-vector-store)
- [Configuration](#configuration)
- [Audit & Security](#audit--security)
- [FAQ](#faq)
- [Troubleshooting](#troubleshooting)
- [Testing](#testing)
- [Build & Release](#build--release)
- [License](#license)
- [Contributing](#contributing)

---

## 📹 Demo

Watch a 2‑minute video that demonstrates creating a web server from a single prompt and running it in a sandbox.

(*[Demo video link placeholder]*)

---

## ✨ Why Go?

| Reason            | Impact                                              |
|-------------------|-----------------------------------------------------|
| Performance       | Compiled binaries, static linking, fast startup      |
| One binary        | No runtime, no Node/Python dependencies             |
| Strong type safety| Fewer runtime panics                                |
| Rich ecosystem    | Docker & DB drivers, CLI & GUI libraries, LLM SDKs  |
| Cross-platform    | Works out-of-the-box on Linux, macOS, Windows       |

---

## 🧩 Core Concepts

| Component      | What it does                                                       |
|----------------|--------------------------------------------------------------------|
| Event Loop     | Drives the conversation, handles tool calls, and keeps state local |
| Provider Layer | Abstracts over any LLM (OpenAI, Claude, Ollama, etc.)             |
| Tool Registry  | read, list, edit, shell, upload, sandbox execute, etc.             |
| Federation     | Multiple "sub-agents" (Planner, DocGen, Tester)                    |
| RAG/Context    | Vector store queries (Weaviate/Chroma) for prompt context          |
| Persona System | Prompt prefix + tool access filtering                              |
| Audit Log      | Every message/tool call/result stored in SQLite                    |
| HILO           | Human-in-the-loop: approvals and edits in UI                       |
| UI (Fyne)      | Modern desktop or HTTP/HTMX web UI                                 |

---

## ⚙️ Architecture

```
┌──────────────────────────────────────────────────┐
│                 CodeMuse (Go backend)            │
│   ┌───────────────────────┬─────────────────┐    │
│   │  Event Loop (agent)   │  UI (Fyne/Gin)  │    │
│   │  ┌───────┐            │  ┌───────┐      │    │
│   │  │Provider│◀──────────┤  │Editor │      │    │
│   │  └───────┘            │  └───────┘      │    │
│   │  ┌───────┐            │  ┌──────────┐   │    │
│   │  │ Tool  │◀────────── │  │Vector    │---│    │
│   │  │ Reg   │            │  │Store     │   │    │
│   │  └───────┘            │  └──────────┘   │    │
│   │  ┌───────┐            │  ┌──────────────┐    │
│   │  │ Audit │◀────────── │  │ Federation   │    │
│   │  └───────┘            │  └──────────────┘    │
│   └───────────────────────┴─────────────────┘    │
└──────────────────────────────────────────────────┘
```

---

## 📦 File Layout

```
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
```

---

## 🛠️ Prerequisites

| Item           | Minimum Version             |
|----------------|----------------------------|
| Go             | 1.24+                      |
| Docker         | 20.10+ (for sandboxed exec)|
| (Optional) Weaviate | 23.3+ (or any vector store) |
| (Optional) Node    | 18+ (if enabling web UI/htmx)|

> **Tip:** Use `devenv.sh` from our workshop repo for a bundled dev environment.

---

## 🚀 Local Setup

### 1️⃣ Clone

```bash
git clone https://github.com/yourorg/go-coding-agent
cd go-coding-agent
```

### 2️⃣ Install dependencies

```bash
go mod tidy
```

### 3️⃣ Set environment variables

```bash
export ANTHROPIC_API_KEY="your-claude-key"
export OPENAI_API_KEY="your-openai-key"
export MISTRAL_API_KEY="your-mistral-key"
```

### 4️⃣ (Optional) Start a vector DB

```bash
docker run -d --name weaviate -p 8081:8080 semitechnologies/weaviate
```

### 5️⃣ Create a dev config (YAML alternative to env)

```bash
cat > config.yaml <<EOF
provider: openai
api_key: $OPENAI_API_KEY
port: 8080
EOF
```

---

## 🔧 Running the Agent

### CLI

Start the conversation loop:

```bash
go run cmd/agent/main.go
```

Sample session:

```
> create a simple Go HTTP server
Assistant: (running plan)
...
> execute the plan
Assistant: (tool result)
...
Assistant: Done! The code is at server/main.go
```

### Desktop UI

```bash
go run cmd/ui/main.go
```

- Click the chat pane, type a prompt, hit “Send”
- UI shows chat history, tool outputs, file explorer side‑pane

> **Note**: The UI uses Fyne; you can also run a web UI with Gin + HTMX (`cmd/web/main.go`).

---

## 👩‍💻 Sample Conversation

```
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
```

---

## 🔋 Extending CodeMuse

### Adding a New LLM Provider

1. Create a file `internal/llm/mistral.go`.
2. Implement `LLMProvider` – follow `openai.go`.
3. Register in `llm/factory.go`:

    ```go
    case "mistral":
        return NewMistralProvider()
    ```

4. Add `MISTRAL_API_KEY=...` to your environment.

---

### Implementing a New Tool

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

Register in `tools/register_all.go`.

---

### Creating a New Persona

```go
personaReg.Register(&personas.Persona{
    ID:          "translator",
    Description: "Translates user prompts into the target language.",
    Prompt:      "You are a professional translator…",
    Allowed:     []string{}, // all tools allowed
})
```

---

### Plugging a Vector Store

1. Implement `rag.VectorStore` in e.g. `internal/storage/weaviate.go`.
2. In `cmd/agent/main.go`:

    ```go
    vector, err := storage.NewWeaviateClient("http://localhost:8081")
    if err != nil { log.Fatal(err) }

    contextBuilder := rag.NewContextBuilder(vector)
    ```

---

## ⚙️ Configuration

| Variable    | Default     | Description                                     |
|-------------|-------------|-------------------------------------------------|
| PROVIDER    | openai      | Backend LLM (openai, claude, ollama, etc)       |
| API_KEY     | –           | API key for provider                            |
| PORT        | 8080        | HTTP port for web UI                            |
| VECTOR_URL  | –           | Base URL of vector store                        |
| WORKSPACE   | ./workspace | Root directory for agent's R/W access           |

> **Tip:** Store keys in `.env` and use dotenv or viper to load them.

---

## 🛡️ Audit & Security

- **Audit DB:** Every message logged to `audit/audit.db` (SQLite)

    ```go
    db := storage.NewAuditDB("./audit/audit.db")
    db.Log(event)
    ```

- **Sandboxed execution:** Code runs in Docker (`golang:1.24-alpine`) with no network and strict CPU/memory limits.
- **HILO:** All file/shell changes require human approval via UI.

---

## ❓ FAQ

| Question                                    | Answer                                                                                      |
|----------------------------------------------|---------------------------------------------------------------------------------------------|
| Can I run it on a low-end laptop?           | Yes – single Go binary (~15 MB), Docker sandbox optional                                    |
| How to add another vector store?            | Implement `rag.VectorStore` and register in `rag/context.go`                                |
| I get "unknown tool: xyz"                   | Tool not registered in `tools/register_all.go`. Add/register it.                            |
| How to run as a background service?         | Use `systemd` or `pm2` to launch the binary; expose via `--port 8080` for web API.          |
| Is it safe with a public API key?           | Yes; agent never pushes code remotely unless you explicitly call `git push`.                |

---

## 🔧 Troubleshooting

| Symptom                                           | Likely Cause                          | Fix                                                  |
|---------------------------------------------------|---------------------------------------|------------------------------------------------------|
| LLM returns "Invalid API Key"                     | Env variable not loaded               | `export OPENAI_API_KEY=…` or set in `config.yaml`    |
| Docker sandbox fails with "permission denied"     | Docker not installed/running or user not in docker group | `sudo systemctl start docker` and `sudo usermod -aG docker $USER` |
| Vector store returns no hits                      | Embeddings not indexed                | Run `scripts/fetch_news.sh` or embed files manually  |
| Agent locks up on tool call                       | Long-running command                  | Increase Docker `--memory/--cpus` or add a timeout   |

---

## ✅ Testing

- **Unit tests for core components:**

    ```bash
    go test ./internal/... -run Test
    ```

- **End‑to‑end test (uses MockProvider, no external API calls):**

    ```bash
    go test ./cmd/agent -run TestChatLoop
    ```

---

## 📦 Build & Release

- **Build binaries for all OSes:**

    ```bash
    go build -o bin/agent ./cmd/agent
    go build -o bin/ui ./cmd/ui
    ```

- **Build Docker image:**

    ```bash
    docker build -t ghcr.io/yourorg/codemuse:latest .
    ```

- **Push to GitHub Container Registry:**

    ```bash
    docker push ghcr.io/yourorg/codemuse:latest
    ```

---

## 📜 License

MIT – see [LICENSE](LICENSE).

---

## 🤝 Contributing

- Fork & clone
- Create a feature branch
- Add tests
- Open a PR (CI runs `make test`)
- Update README & CHANGES as needed

**Guidelines:** Keep changes self‑contained, document all new providers/tools, and update the demo if you add UI features.

---

Happy coding with CodeMuse!
