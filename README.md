# Gemma 4 E4B One-Liner

```bash
docker rm -f ollama-e4b >/dev/null 2>&1 || true; mkdir -p "$PWD/.ollama"; docker pull ollama/ollama:latest && docker run --rm -d --name ollama-e4b -p 11435:11434 -v "$PWD/.ollama:/root/.ollama" ollama/ollama && until curl -fsS http://127.0.0.1:11435/api/version >/dev/null 2>&1; do sleep 1; done && docker exec ollama-e4b ollama pull gemma4:e4b && printf 'URL=http://127.0.0.1:11435/v1\nAPI_KEY=YOUR_KEY_HERE\nMODEL=gemma4:e4b\nSTOP=docker stop ollama-e4b\n'
```

```bash
curl http://127.0.0.1:11435/v1/chat/completions -H 'Content-Type: application/json' -H 'Authorization: Bearer YOUR_KEY_HERE' -d '{"model":"gemma4:e4b","messages":[{"role":"user","content":"hello"}]}'
```

# ollama-local

## Compose + opencode (gemma4:e2b)

```
ollama/compose.yml      # Ollama server (CPU by default, 128K context, flash attention, KV cache q4_0)
ollama/compose.gpu.yml  # NVIDIA GPU override (use only on hosts with an NVIDIA GPU)
opencode/opencode.jsonc # opencode config; copy to ~/.config/opencode/opencode.jsonc
```

```bash
# Without an NVIDIA GPU
docker compose -f ollama/compose.yml up -d

# With an NVIDIA GPU
docker compose -f ollama/compose.yml -f ollama/compose.gpu.yml up -d

# Apply the opencode config
cp opencode/opencode.jsonc ~/.config/opencode/opencode.jsonc
```

- Keep `OLLAMA_CONTEXT_LENGTH` (compose.yml) and `limit.context` (opencode.jsonc) at the same value. Ollama defaults to 4096, which an opencode request (about 8k tokens) overflows.
- To switch models, change both the `ollama pull` target in compose.yml and the model name in opencode.jsonc.
