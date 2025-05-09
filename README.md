# SimpleCert Documentation

---

> ### SimpleCert – `install_ssl.sh` & `setup_ssl_renewal.sh`
> 
> **Author:** Brian Kittrell  
> **Created:** 2025-05-08  
> **Updated:** 2025-05-09  
> **License:** [CC BY 4.0 (Attribution International)](https://creativecommons.org/licenses/by/4.0/)  
> **Contact:** [kittrellbj@gmail.com](mailto:kittrellbj@gmail.com?subject=%5BGithub%5D%20SimpleCert) (Email is not for product support; file an issue instead.)
> 
> ---
> 
> **License**: This documentation is released under [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).  
> You are free to share, adapt, and redistribute with attribution.

---

## Overview

`install_ssl.sh` is a self-contained, interactive Bash script that sets up HTTPS using **Let's Encrypt** with a **Cloudflare DNS challenge**. It installs all required packages, requests a certificate for one or more domains, and generates a reusable Nginx configuration snippet.

A companion script, `setup_ssl_renewal.sh`, configures auto-renewal to keep your certificates valid long-term.

---

## Requirements

- Linux system with `sudo` or root access
- Outbound internet access
- A Cloudflare API Token with read and write access to your Cloudflare API:
  - `Zone.DNS:Edit`
  - `Zone.Zone:Read` (usually granted automatically with DNS:Edit)

> ⚠️ **NOTE:**  
> **Do NOT share your Cloudflare API token with anyone.** I don't need it to help you. No one else needs it to help you if you have problems.
> 
> Make sure to **remove it (and all other secrets, keys, or access codes) from any code, logs, issues, or comments** you post publicly.

---

## Installation Instructions

### 🔹 Step 1: Clone the GitHub Repo

```bash
git clone https://github.com/kittrellbj/simplecert.git
cd simplecert
chmod +x install_ssl.sh setup_ssl_renewal.sh
```

### 🔹 Step 2: Run the SSL Setup Script

```bash
sudo ./install_ssl.sh
```

During execution, the script will prompt you for:
- One or more domain names (space-separated FQDNs)
- A valid email address for certificate registration and renewal notices
- Your Cloudflare API token (if not already saved)

The script:
- Installs Certbot and its Cloudflare plugin
- Uses the DNS-01 challenge to validate domain ownership
- Saves certbot logs to `/var/log/certbot_simplecert.log`
- Generates `/etc/letsencrypt/simplecert_nginx_snippet.conf` with `ssl_certificate` directives for each domain

### 🔹 Step 3: Configure Auto-Renewal

```bash
sudo ./setup_ssl_renewal.sh
```

This adds a cron job for automatic renewal and reloads Nginx after success.

---

## Nginx Configuration

After running the script, you'll have:

```nginx
include /etc/letsencrypt/simplecert_nginx_snippet.conf;
```

This snippet will contain one block per domain like:

```nginx
# For host1.domain.tld
ssl_certificate /etc/letsencrypt/live/host1.domain.tld/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/host1.domain.tld/privkey.pem;
```

You can safely include this in any `server` block across multiple vhosts.

---

## Test Auto-Renewal

To test renewals manually:

```bash
sudo certbot renew --dry-run
```

---

## Troubleshooting

- **No certificate issued**: Ensure DNS records exist and are publicly resolvable.
- **Token or permissions error**: Make sure your API token is valid and scoped properly.
- **Running in WSL**: This works for local testing, but WSL is not recommended for production due to networking constraints.

---

## Directory Summary

- `install_ssl.sh` – One-time setup script for certificate issuance and Nginx integration
- `setup_ssl_renewal.sh` – Adds cron-based auto-renew
- `/etc/letsencrypt/simplecert_nginx_snippet.conf` – Reusable Nginx snippet with all SSL paths
- `/var/log/certbot_simplecert.log` – Log output from Certbot operations