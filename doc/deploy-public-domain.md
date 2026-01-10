# Licode public domain deploy (Caddy)

This guide configures Licode to be reachable via a public domain using Caddy as the TLS-terminating reverse proxy.

## 1) DNS
- Create A/AAAA records for your domain pointing to the server public IP.

## 2) Update Licode config
From the Licode repo on the target server:
```
./scripts/configure-licode.sh \
  --public-ip <PUBLIC_IP> \
  --domain <PUBLIC_DOMAIN> \
  --turn-host <TURN_HOST> \
  --turn-username <TURN_USER> \
  --turn-password <TURN_PASS> \
  --turn-port 5349
```

Notes:
- `--stun-host` and `--stun-port` default to the TURN host/port.
- By default the script updates `licode_config.js` and `licode_config.js.workingnow` if it exists.
- Backups are created with a `.bak-<timestamp>` suffix.

## 3) Configure Caddy
Edit `/etc/caddy/Caddyfile` and add a site block for your Licode domain (replace placeholders):
```
<PUBLIC_DOMAIN> {
  handle_path /nuve/* {
    reverse_proxy localhost:3000
  }

  handle /socket.io/* {
    reverse_proxy localhost:8080
  }

  handle {
    reverse_proxy localhost:3001
  }
}
```

Reload Caddy:
```
sudo systemctl reload caddy
```

## 4) Open firewall ports
Ensure these ports are reachable from the Internet:
- TCP 80/443 (Caddy HTTP/HTTPS)
- UDP 30000-30050 (default Licode ICE/RTCP ports)
- UDP 5349 (or your TURN/STUN port)

## 5) Restart Licode
If Licode is already running, restart it so the new config is loaded.
```
./stoplicode.sh
./scripts/initLicode.sh
```

## 6) Verify
- Open `https://<PUBLIC_DOMAIN>/` (basic example server if running).
- Confirm ICE connectivity using your browser WebRTC internals.
