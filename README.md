# Self Hosted Blog

This is a self-hosted blog solution powered by Docker, Nginx, Let's Encrypt, Ghost, and other self-managed components on Linux (tested on Ubuntu Server). This stack is designed to run on real hardware in your home — no cloud required.

---

### ⚠️ Pre-setup Safety

If you plan to fork or push this repo, **make sure Git ignores your secrets**:

```bash
git update-index --skip-worktree bin/secrets/*
```

Double-check nothing sensitive is staged via `git status`.

---

### 🔧 What You'll Be Deploying

![](https://github.com/nkorai/SelfHostedBlog/blob/main/docker-compose-volumes.png)  
via https://github.com/pmsipilot/docker-compose-viz

---

## ✅ Setup Instructions

### 1. System Requirements

- A Linux machine (e.g. Ubuntu Server on an Intel Mac Mini)
- Public internet access (with port forwarding)
- A domain name you control (e.g. `nkorai.com`)
- Docker installed: [Install Docker](https://docs.docker.com/engine/install/)

---

### 2. Networking & DNS

- **Port forward** ports `80` and `443` from your home router to your server's internal IP.
- **Enable Dynamic DNS (DDNS)** with your domain provider.
- Store your DDNS password in:  
  `bin/secrets/ddns_secret.txt`

---

### 3. Configure Environment

Edit the top of `bin/run.sh` to define:

```bash
export DOMAIN_NAME="yourdomain.com"
export EMAIL_ADDRESS="your@email.com"
export GHOST_CONTENT_DIRECTORY="/ghost_content"
```

---

### 4. Seed Secrets

Create these files:

```bash
bin/secrets/
├── aws_access_key_id.txt
├── aws_secret_access_key.txt
├── ddns_secret.txt
├── mailgun_user.txt
└── mailgun_password.txt
```

---

### 5. First-Time Run

```bash
./bin/user_run.sh
```

This will:

- Initialize the folder structure
- Inject your secrets
- Set up nginx, Ghost, Let's Encrypt, DDNS, and backups
- Start your Docker containers

You should be able to visit your blog at:  
📍 `https://yourdomain.com`

---

## 🚀 Make It Run On Boot (systemd)

Enable automatic restarts after power loss or reboots:

1. Create the systemd service:

```ini
# /etc/systemd/system/selfhostedblog.service
[Unit]
Description=Self Hosted Ghost Blog Stack
After=network-online.target docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/youruser/SelfHostedBlog
ExecStart=/home/youruser/SelfHostedBlog/bin/run.sh
ExecStop=/home/youruser/SelfHostedBlog/bin/clean.sh
TimeoutStartSec=300
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target
```

2. Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable selfhostedblog.service
sudo systemctl start selfhostedblog.service
```

Now the stack auto-starts after reboots.

---

## 🪩 Cleaning & Resetting

To stop everything and clean up:

```bash
./bin/user_clean.sh
```

This removes containers and deletes the `./build` directory (but not your Ghost content).

---

## 🔧 Troubleshooting

- If something breaks, run `user_clean.sh` followed by `user_run.sh`
- Check `docker ps` and `docker logs <container>` for issues
- Confirm DNS is correctly resolving your domain name
- Check `journalctl -u selfhostedblog.service` for systemd issues

---

## 🌍 Supported Domain Providers

This setup uses [qmcgaw/ddns-updater](https://github.com/qdm12/ddns-updater) — most major providers are supported (Namecheap, Cloudflare, GoDaddy, etc.).

Update `bin/ddns/config.json` format as needed. If your provider uses a `token` instead of a `password`, you can still assign that to the `DDNS_PASSWORD` placeholder in your secret file.

---

## 🔮 About the Dummy SSL Certs

Certs in `bin/ssl/` are **placeholders only**, used so nginx can boot on first run. These are replaced by real Let's Encrypt certs after the stack launches.

Real certs are stored in:  
`./build/ssl/private/` (gitignored)

No real secrets are exposed by default.

---

## 💬 Want to Contribute or Report an Issue?

Create a GitHub Issue and include:
- Logs
- Your OS version
- What you’ve tried so far

I’ll do my best to help.

---


