# 로컬 Ollama — gemma4:e4b (128K)

인터넷이 없는 환경에서 로컬로 Llama를 쓰기 위한 최소 설정이다. 컨테이너 하나, 이미지 하나, 볼륨 하나다.

- 이미지: `ollama/ollama:latest`
- 컨테이너: `ollama`
- 볼륨: `ollama-local_ollama_data` (모델 보관)
- 모델: `gemma4:e4b`
- 컨텍스트: 131072(128K)

## 실행 (어디서든 한 줄)

```bash
docker run -d --name ollama --restart unless-stopped -p 11434:11434 -v ollama-local_ollama_data:/root/.ollama -e OLLAMA_CONTEXT_LENGTH=131072 ollama/ollama:latest
```

볼륨에 모델이 이미 들어 있으면 추가 다운로드 없이 바로 시작된다. 빈 볼륨에서 처음 시작할 때만 아래를 한 번 실행한다.

```bash
docker exec ollama ollama pull gemma4:e4b
```

## 대화 (한 줄)

```bash
docker exec -it ollama ollama run gemma4:e4b          # 대화형
docker exec ollama ollama run gemma4:e4b "한 줄만 답해"  # 원샷
```

## 확인

```bash
docker exec ollama ollama list
curl http://127.0.0.1:11434/api/ps
```

`ollama ps`의 CONTEXT 값이 131072면 128K로 로드된 것이다.

## 종료

```bash
docker stop ollama
docker rm ollama
```

볼륨은 그대로 남는다. 다시 시작할 때는 위의 `docker run` 한 줄을 다시 쓰면 된다. 볼륨까지 지우면 재다운로드가 필요하다.

## 오프라인 반입

인터넷이 되는 머신에서 위 실행과 pull을 한 번 마친 뒤:

```bash
docker save ollama/ollama:latest -o ollama.tar
docker run --rm -v ollama-local_ollama_data:/data -v "$PWD":/out alpine tar czf /out/ollama-models.tgz -C /data .
```

두 파일을 대상 머신으로 옮겨:

```bash
docker load -i ollama.tar
docker volume create ollama-local_ollama_data
docker run --rm -v ollama-local_ollama_data:/data -v "$PWD":/in alpine tar xzf /in/ollama-models.tgz -C /data
```

그다음 위의 `docker run` 한 줄로 실행한다. 인터넷 없이 동작한다.
