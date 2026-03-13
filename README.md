# LM studio

on machine
```
lms server start --port 1234
```

set vars
```
export ANTHROPIC_BASE_URL=http://localhost:1234
export ANTHROPIC_AUTH_TOKEN=lmstudio
```

run
```
claude --model qwen/qwen3-coder-30b
```
