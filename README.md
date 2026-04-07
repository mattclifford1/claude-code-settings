# LM Studio Setup

Machine: AMD 5950x, NVIDIA RTX 3090 (24 GB VRAM), Ubuntu with GDM/GNOME desktop, no iGPU.

---

## Using Claude Code with LM Studio

Set environment variables then run Claude:

```bash
export ANTHROPIC_BASE_URL=http://localhost:1234
export ANTHROPIC_AUTH_TOKEN=lmstudio
claude --model qwen/qwen3-coder-30b
```

---

## Inference Mode / Desktop Mode

The machine boots into the desktop normally (GDM on). When SSHing in for AI inference, run a script to stop the display manager and reclaim ~640 MiB of GPU VRAM.

### Commands

```bash
inference-mode    # stop GDM, confirm LM Studio server ready, free VRAM
desktop-mode      # start GDM, restore physical display
```

### What `inference-mode` does

1. Starts the LM Studio headless systemd service (if not already running)
2. Waits until the server responds on `http://localhost:1234`
3. Stops GDM, freeing ~290 MiB from Xorg + gnome-shell

### VRAM recovered

| Process | VRAM freed |
|---|---|
| Xorg (GDM) | ~73 MiB |
| gnome-shell | ~214 MiB |
| LM Studio Electron renderer (GPU mode → Xvfb) | ~350 MiB |
| **Total** | **~637 MiB** |

---

## How LM Studio Runs Headlessly

LM Studio runs as a **systemd user service** using a virtual framebuffer (Xvfb) on display `:99`. Xvfb is CPU-rendered and uses zero GPU VRAM.

Two services in `~/.config/systemd/user/`:

| Service | Purpose |
|---|---|
| `xvfb-lmstudio.service` | Virtual framebuffer on `:99` |
| `lmstudio.service` | LM Studio AppImage pointed at `:99` |

Both are enabled and start automatically at boot via **loginctl lingering** (no graphical login required).

AppImage location: `~/lmstudio/LM-Studio-0.4.6-1-x64.AppImage`

---

## One-Time Setup

Run these once if setting up on a fresh system:

```bash
# 1. Allow user services to run without a graphical session
loginctl enable-linger matt

# 2. Install virtual framebuffer
sudo apt install -y xvfb

# 3. Allow passwordless GDM start/stop over SSH
echo 'matt ALL=(ALL) NOPASSWD: /usr/bin/systemctl start gdm, /usr/bin/systemctl stop gdm' \
  | sudo tee /etc/sudoers.d/lmstudio-display
sudo chmod 440 /etc/sudoers.d/lmstudio-display

# 4. Enable and start the headless services
systemctl --user daemon-reload
systemctl --user enable --now xvfb-lmstudio.service lmstudio.service
```

---

## File Locations

| File | Purpose |
|---|---|
| `~/bin/inference-mode` | Switch to inference mode (stop GDM) |
| `~/bin/desktop-mode` | Restore desktop (start GDM) |
| `~/.config/systemd/user/xvfb-lmstudio.service` | Xvfb systemd unit |
| `~/.config/systemd/user/lmstudio.service` | LM Studio systemd unit |
| `/etc/sudoers.d/lmstudio-display` | Passwordless GDM control |
| `~/lmstudio/shutdown-lmstudio.sh` | Force-kill all LM Studio processes |

---

## Useful Commands

```bash
# Check service status
systemctl --user status lmstudio.service
systemctl --user status xvfb-lmstudio.service

# View LM Studio logs
journalctl --user -u lmstudio.service -f

# Check server is responding
curl http://localhost:1234/api/v1/models

# List loaded models
lms ps

# Check VRAM usage
nvidia-smi
```
