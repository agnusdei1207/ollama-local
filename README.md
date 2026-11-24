# 🐳 Local Ollama Quick Start Guide

This guide outlines the process for using a locally hosted Ollama instance (`gemma4:e4b`) in an offline environment.

## 🌐 Phase 1: Online Preparation (Internet Required)

1.  **Start Ollama:** Run the Docker container.
    ```bash
    docker run -d --name ollama --restart unless-stopped -p 11434:11434 -v ollama-local_ollama_data:/root/.ollama -e OLLAMA_CONTEXT_LENGTH=131072 ollama/ollama:latest
    ```
2.  **Pull Model:** Pull the desired model into the running container.
    ```bash
    docker exec ollama ollama pull gemma4:e4b
    ```
3.  **Connect Claude Code:** In your environment, configure the connection variables from `claude-config.md`.
    ```bash
    # From claude-config.md
    export ANTHROPIC_BASE_URL="http://localhost:11434"
    export ANTHROPIC_AUTH_TOKEN="ollama"
    export ANTHROPIC_MODEL="gemma4:e4b"
    export CLAUDE_CODE_AUTO_COMPACT_WINDOW=131704
    export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=80
    ```
4.  **Offline Transfer (Optional):** If working fully offline, transfer the `ollama.tar` and model archive generated in the original guide.

## ✈️ Phase 2: Offline Execution (No Internet Required)

1.  **Restore & Run:** Use the `docker run` command from Phase 1 and the configured environment variables.
2.  **Interact:** Run the model inside the container via CLI.
    ```bash
    docker exec -it ollama ollama run gemma4:e4b
    ```

## 🛠️ Quick Checks

*   **Check Ollama status:** `curl http://127.0.0.1:11434/api/ps`
*   **List models:** `docker exec ollama ollama list`

## 🛑 Shutdown

When finished, stop and remove the container:
```bash
docker stop ollama
docker rm ollama
```
**Note:** The volume (`ollama-local_ollama_data`) persists and retains your models and data.