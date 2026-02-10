# Nginx routing on the server

Config for nginx reverse proxy and routing on your server.

## Quick deploy (on the server)

### 1. Install nginx (if not installed)

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install nginx -y
```

**RHEL/CentOS/Rocky:**
```bash
sudo dnf install nginx -y
# or: sudo yum install nginx -y
```

### 2. Copy configs to the server

From your machine (replace `user@your-server` and paths as needed):

```bash
scp -r nginx/nginx.conf user@your-server:/tmp/
scp -r nginx/conf.d user@your-server:/tmp/
```

### 3. On the server: place configs and reload

```bash
# Backup existing config (if any)
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak 2>/dev/null || true

# Copy new configs
sudo cp /tmp/nginx.conf /etc/nginx/nginx.conf
sudo cp /tmp/conf.d/*.conf /etc/nginx/conf.d/

# Edit server name and backend port if needed
sudo nano /etc/nginx/conf.d/default.conf

# Test config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### 4. Enable and start nginx

```bash
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx
```

## Config overview

| File | Purpose |
|------|---------|
| `nginx.conf` | Main nginx config (worker processes, logs, includes). |
| `conf.d/default.conf` | Default server: routes HTTP to your app (reverse proxy to port 3000). |
| `conf.d/static-only.conf.example` | Example for static-only site (rename to `.conf` to use). |

## Customize routing

- **Backend port:** In `conf.d/default.conf`, change `proxy_pass http://127.0.0.1:3000` to your app’s port (e.g. 5000, 8080).
- **Domain:** Set `server_name your-domain.com www.your-domain.com;` or use `_` for default server.
- **HTTPS:** Use certbot: `sudo apt install certbot python3-certbot-nginx -y` then `sudo certbot --nginx -d your-domain.com`.

## Firewall

Allow HTTP/HTTPS:

```bash
# Ubuntu (ufw)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload

# firewalld
sudo firewall-cmd --permanent --add-service=http --add-service=https
sudo firewall-cmd --reload
```

## Useful commands

```bash
sudo nginx -t          # Test config
sudo systemctl reload nginx
sudo systemctl restart nginx
sudo tail -f /var/log/nginx/error.log
```
