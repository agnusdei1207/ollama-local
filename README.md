# 로컬 Ollama — gemma4:e4b (128K)

인터넷 클라우드 AI를 쓸 수 없는 금융권·폐쇄망 환경에서 로컬 모델을 쓰기 위한 저장소다. 모델 서버만 있으면 바로 대화할 수 있고, 데이터는 이 머신 밖으로 나가지 않는다.

- 모델: `gemma4:e4b`
- 컨텍스트: 131072 토큰(128K), flash attention, KV cache `q4_0`
- 서버 주소: `http://127.0.0.1:11434` (OpenAI 호환 API: `/v1`)

opencode 같은 코딩 에이전트 설정은 없다. 모델 서버만 있다.

## 시작

저장소 루트에서:

```bash
docker compose up -d
```

최초 1회는 이미지와 모델(약 6.6GB)을 내려받는다. 아래 명령으로 모델이 보일 때까지 기다린다.

```bash
curl http://127.0.0.1:11434/api/tags
```

`gemma4:e4b`가 보이면 끝이다. 두 번째부터는 이미 받아 둔 볼륨을 쓰므로 바로 시작된다.

`compose.yml`은 `build: .`로 `Dockerfile`에서 이미지를 만든다. 최초 `up`이 빌드까지 한다. `Dockerfile`이나 `entrypoint.sh`를 고친 뒤에는 `docker compose up -d --build`로 다시 빌드한다.

## 대화하기

서버 컨테이너는 `up -d`로 이미 떠 있어야 한다. 가장 간단한 한 줄은 래퍼다.

```bat
ollama.bat run gemma4:e4b        :: CMD
.\ollama.bat run gemma4:e4b      :: PowerShell
```

Compose 명령을 쓰려면:

```bash
docker compose exec ollama ollama run gemma4:e4b             # 대화형
docker compose exec ollama ollama run gemma4:e4b "한 줄만 답해"  # 원샷
```

`docker compose run`은 서버가 없는 일회용 컨테이너라 모델에 접속하지 못한다. `exec`가 없는 Compose라면 `docker exec -it ollama ollama run gemma4:e4b`를 쓴다.

`ollama run`을 시작하면 프롬프트가 뜬다. `Ctrl+D` 또는 `/bye`로 나간다.

## API로 호출하기

Windows CMD에서:

```bat
curl http://127.0.0.1:11434/v1/chat/completions -H "Content-Type: application/json" -d "{\"model\":\"gemma4:e4b\",\"messages\":[{\"role\":\"user\",\"content\":\"안녕\"}]}"
```

OpenAI SDK에서는 `base_url`을 `http://127.0.0.1:11434/v1`로, 모델을 `gemma4:e4b`로 지정한다. API 키는 필요 없다.

## 웹 채팅 UI

`docker compose up -d`가 모델 서버와 Open WebUI를 함께 띄운다. 브라우저에서 `http://localhost:3000`에 접속하면 채팅할 수 있다. 모델 목록이 보이지 않으면 `OLLAMA_BASE_URL`이 `http://ollama:11434`인지 확인한다.

## CPU 실행

GPU 설정 파일은 없다. AMD CPU·메모리 32GB 환경을 기준으로 CPU에서 바로 실행된다.

## 컨텍스트 설정

`compose.yml`의 `OLLAMA_CONTEXT_LENGTH=131072`가 128K다. Ollama 기본값은 4096이라 이를 바꾸지 않으면 긴 입력을 받을 수 없다. 모델을 로드한 뒤 실제값은 다음으로 확인한다.

```bash
curl http://127.0.0.1:11434/api/ps
```

128K 컨텍스트는 메모리를 많이 쓴다. 이 머신은 32GB 메모리다. 메모리가 부족하면 `OLLAMA_CONTEXT_LENGTH`를 줄이고 이 문서의 값도 같이 고친다.

## 종료와 데이터

```bash
docker compose stop        # 컨테이너만 멈춤, 모델은 유지
docker compose down        # 컨테이너·네트워크 제거, 모델은 유지
docker compose down -v     # 모델 볼륨까지 삭제 (재다운로드 필요)
```

## 폐쇄망 반입

인터넷이 되는 머신에서 위 시작 절차를 한 번 실행해 이미지와 모델을 받는다. 옮길 때:

```bash
docker save ollama/ollama:latest ollama-local:latest ghcr.io/open-webui/open-webui:main alpine:latest -o ollama.tar
docker run --rm -v ollama-local_ollama_data:/data -v "$PWD":/out alpine tar czf /out/ollama-local.tgz -C /data .
docker run --rm -v ollama-local_open_webui_data:/data -v "$PWD":/out alpine tar czf /out/open-webui.tgz -C /data .
```

세 파일(`ollama.tar`, `ollama-local.tgz`, `open-webui.tgz`)을 대상 머신으로 옮긴 뒤:

```bash
docker load -i ollama.tar
docker volume create ollama-local_ollama_data
docker volume create ollama-local_open_webui_data
docker run --rm -v ollama-local_ollama_data:/data -v "$PWD":/in alpine tar xzf /in/ollama-local.tgz -C /data
docker run --rm -v ollama-local_open_webui_data:/data -v "$PWD":/in alpine tar xzf /in/open-webui.tgz -C /data
docker compose up -d
```

모델 파일은 볼륨 안에 있으므로 재다운로드 없이 실행된다. 볼륨 이름은 compose 프로젝트 이름(`ollama`)을 따른다. 다른 디렉터리에서 받았다면 `docker compose config`로 실제 볼륨 이름을 확인한다.

## 문제 확인

```bash
docker compose logs --tail 100 ollama
curl http://127.0.0.1:11434/api/tags
docker compose ps -a
```

컨테이너는 떠 있는데 `ollama list`가 비어 있으면 최초 모델 pull이 아직 진행 중이거나 실패한 것이다. 실패하면 컨테이너가 자동 재시작해 다시 받는다.
