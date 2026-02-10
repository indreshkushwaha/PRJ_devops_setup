# HTTPS (Let's Encrypt) for 01-nginx

This stack serves **ai.devroad.online** and **n8n.devroad.online** over HTTPS using a single certificate that covers both hostnames.

## First-time setup on the server

### 1. Create a self-signed cert so nginx can start (required once)

Nginx will not start without existing certificate files. On the **host** (as root):

```bash
mkdir -p /etc/letsencrypt/live/ai.devroad.online
openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
  -keyout /etc/letsencrypt/live/ai.devroad.online/privkey.pem \
  -out    /etc/letsencrypt/live/ai.devroad.online/fullchain.pem \
  -subj "/CN=ai.devroad.online"
```

Or run the script from the repo (from project root):

```bash
sudo bash 01-nginx/scripts/init-selfsigned-cert.sh
```

### 2. Create ACME webroot directory

From the project root (e.g. `~/PRJ_devops_setup`):

```bash
mkdir -p 01-nginx/acme
```

### 3. Start nginx

```bash
docker compose -f 01-nginx/docker-compose.yml up -d
```

### 4. Get a real certificate with Let's Encrypt (certbot on host)

Install certbot if needed:

```bash
apt update && apt install -y certbot
```

Obtain the certificate (use your real email):

```bash
certbot certonly --webroot \
  -w "$(pwd)/01-nginx/acme" \
  -d ai.devroad.online \
  -d n8n.devroad.online \
  --email your@email.com \
  --agree-tos \
  --non-interactive
```

### 5. Reload nginx to use the new certificate

```bash
docker exec nginx-router nginx -s reload
```

After this, **https://ai.devroad.online** and **https://n8n.devroad.online** will use the Let's Encrypt certificate. HTTP requests are redirected to HTTPS.

---

## Renewal (certbot)

Certificates expire after 90 days. Set up a cron job or systemd timer to renew:

```bash
certbot renew --quiet --deploy-hook "docker exec nginx-router nginx -s reload"
```

Or add to crontab (run daily):

```bash
0 3 * * * certbot renew --quiet --deploy-hook "docker exec nginx-router nginx -s reload"
```

---

## Troubleshooting

- **Nginx won't start:** Ensure `/etc/letsencrypt/live/ai.devroad.online/fullchain.pem` and `privkey.pem` exist (step 1).
- **502 on HTTPS:** Check that Open WebUI and n8n containers are on the `primary` network and running.
- **Certificate errors in browser:** After running certbot, reload nginx (step 5).
