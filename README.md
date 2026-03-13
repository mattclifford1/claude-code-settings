# LM studio

on machine start from the GUI or run the command
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

## daemon
edit at `/etc/systemd/system/lmstudio.service` and follow the start stop etc. on https://lmstudio.ai/docs/developer/core/headless_llmster

Most importantly to start
```
sudo systemctl daemon-reload
sudo systemctl enable lmstudio.service
sudo systemctl start lmstudio.service
```
