#!/bin/bash

set -e

COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_RESET="\e[0m"

print_success() { echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $1"; }
print_fail() { echo -e "${COLOR_RED}[FAIL]${COLOR_RESET} $1"; }
print_warn() { echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $1"; }

if [[ $EUID -ne 0 ]]; then
    print_fail "Run this script as root (sudo)"
    exit 1
fi
print_success "Running as root"

# Check if certbot exists
if ! command -v certbot > /dev/null; then
    print_fail "Certbot is not installed. Run install_ssl.sh first."
    exit 1
fi

# Add auto-renewal cron job
CRON_JOB="0 3 * * * certbot renew --quiet --deploy-hook 'systemctl reload nginx'"

if crontab -l 2>/dev/null | grep -q "certbot renew"; then
    print_warn "A certbot renew cron job already exists."
else
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    print_success "Auto-renewal cron job added"
fi
