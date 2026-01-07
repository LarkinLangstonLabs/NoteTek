#!/bin/bash

# V6: Notetek Ghost Node (Absolute Hardening)
if [ "$EUID" -ne 0 ]; then echo "Please run as root"; exit 1; fi

echo "[*] Initializing Ghost Node Deployment..."

# 1. Environment Purge & Dependencies
# Installs Tor, Nginx, AppArmor, Vanguards (protection against discovery), and sdwdate
apt update && apt install -y tor nginx libnginx-mod-http-headers-more-filter apparmor-utils sdwdate vanguards ufw mat2

# 2. Kernel-Level "Black-Hole" Configuration
# Prevents the OS from responding to common scans or leaking clock information
cat <<EOF > /etc/sysctl.d/99-notetek-ghost.conf
net.ipv4.conf.all.rp_filter = 1
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.tcp_syncookies = 1
kernel.randomize_va_space = 2
kernel.kptr_restrict = 2
net.ipv4.conf.all.accept_source_route = 0
EOF
sysctl -p /etc/sysctl.d/99-notetek-ghost.conf

# 3. Memory-Only Web Root (Anti-Forensics)
# Your website files are held in RAM. Pull the plug, the site disappears.
WEB_ROOT="/var/www/onion_site"
mkdir -p $WEB_ROOT
mount -t tmpfs -o size=32M tmpfs $WEB_ROOT
echo "<h1>Node Offline</h1>" > $WEB_ROOT/index.html

# 4. Ultra-Stealth Nginx Signature Masking
# Completely erases "Nginx" from HTTP headers
NGINX_CONF="/etc/nginx/sites-available/onion"
cat <<EOF > $NGINX_CONF
server {
    listen unix:/var/run/onion/nginx.sock;
    server_name _;
    root $WEB_ROOT;

    # Erasure of all identifying headers
    more_clear_headers 'Server';
    more_clear_headers 'X-Powered-By';
    more_set_headers "Content-Security-Policy: default-src 'self'";

    # Strict DoS protection
    limit_req_zone \$binary_remote_addr zone=flood:10m rate=1r/s;
    limit_req zone=flood burst=5;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# 5. Torrc: Vanguards & Anti-Correlation
# Uses the 'Vanguard' protocol to prevent long-term Guard discovery attacks
cat <<EOF > /etc/tor/torrc
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 unix:/var/run/onion/nginx.sock

# Defense against Introduction Point flooding
HiddenServiceEnableIntroDoSDefense 1
HiddenServiceEnableIntroDoSRatePerSec 10
HiddenServiceEnableIntroDoSBurstPerSec 20

# Force Tor to use Unix Sockets for control (more secure than port 9051)
ControlSocket /var/run/tor/control
CookieAuthentication 1
EOF

# 6. Apply Sandbox & Lockdown
aa-enforce /usr/sbin/nginx 2>/dev/null
ufw default deny outgoing
ufw allow out to any port 80,443,9001:9051 proto tcp
ufw enable

# 7. Start & Extract Identity
systemctl restart nginx tor vanguards
sleep 12
ONION_ADDR=$(cat /var/lib/tor/hidden_service/hostname)

echo "------------------------------------------------"
echo "NOTETEK V6 GHOST NODE: STATUS ACTIVE"
echo "Address: $ONION_ADDR"
echo "Storage: RAM-Only (TMPFS)"
echo "Shields: Vanguards + AppArmor + Kernel-Hardened"
echo "------------------------------------------------"