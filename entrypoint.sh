#!/bin/sh
set -e

ollama serve &
until ollama list >/dev/null 2>&1; do
  sleep 1
done

ollama pull gemma4:e4b
wait
