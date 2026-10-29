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
ollama/compose.yml      # Ollama 서버 (CPU 기본, 128K 컨텍스트, flash attention, KV cache q4_0)
ollama/compose.gpu.yml  # NVIDIA GPU 오버라이드 (GPU 환경에서만 사용)
opencode/opencode.jsonc # opencode 설정 → ~/.config/opencode/opencode.jsonc 로 복사
```

```bash
# NVIDIA 없는 환경
docker compose -f ollama/compose.yml up -d

# NVIDIA GPU 환경
docker compose -f ollama/compose.yml -f ollama/compose.gpu.yml up -d

# opencode 설정 적용
cp opencode/opencode.jsonc ~/.config/opencode/opencode.jsonc
```

- `OLLAMA_CONTEXT_LENGTH`(compose.yml)와 `limit.context`(opencode.jsonc)는 같은 값으로 맞출 것. Ollama 기본값은 4096이라 opencode 요청(약 8k 토큰)이 넘친다.
- 모델을 바꾸려면 compose.yml의 `ollama pull` 대상과 opencode.jsonc의 모델명을 함께 수정한다.
