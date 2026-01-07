cat <<EOF > README.md
# 🧅 Notetek Ghost Node (V6)
### *Ultra-Hardened Deep Web Deployment Engine*

Notetek is a high-security automation script designed to deploy a **Tor Onion Service** using a hardened **Nginx** backend. It is optimized for Kali Linux and Debian-based systems, focusing on anti-forensics, signature masking, and network isolation.

---

## 🛡️ Security Features

* **RAM-Only Execution**: The web root and sensitive logs are mounted via \`tmpfs\`. Content is automatically wiped on power loss or reboot.
* **Signature Masking**: Uses \`headers-more\` to strip all Nginx identification. The server responds as "Unknown" to fingerprinting attempts.
* **Network Kill-Switch**: Pre-configured \`UFW\` rules prevent any outbound traffic that is not routed through the Tor process.
* **Kernel Hardening**: Custom \`sysctl\` parameters to prevent ICMP snooping, IP spoofing, and memory-based exploits.
* **Vanguard Integration**: Protection against "Guard Discovery" attacks using the Vanguard secondary guard protocol.

---

## 🚀 Quick Start

### 1. Prerequisites
Ensure you are running a Debian-based OS (Kali, Parrot, or Ubuntu) and have root privileges.

### 2. Installation
\`\`\`bash
chmod +x notetek_v6.sh
sudo ./notetek_v6.sh
\`\`\`

### 3. Usage
Once the script completes, it will output your unique \`.onion\` address.
* **Web Root**: \`/var/www/onion_site\` (Note: This is in RAM)
* **Tor Config**: \`/etc/tor/torrc\`
* **Nginx Config**: \`/etc/nginx/sites-available/onion\`

---

## 📋 Operational Rules (OpSec)

> **Data Persistence**: Because this node uses \`tmpfs\`, any files placed in the web root will be **permanently deleted** upon reboot. Always keep backups on an encrypted volume.

1. **Strict Isolation**: Do not use this machine for personal browsing.
2. **No Clearnet Links**: Ensure HTML code contains no links to external "Clearnet" images.
3. **Clock Drift**: This script installs \`sdwdate\`. Do not manually change the system time.

---

## 🛠️ Architecture Overview



| Component | Responsibility |
| :--- | :--- |
| **Tor** | Manages the .onion circuit and hidden service keys. |
| **Nginx** | Serves content via a Unix Domain Socket (No open TCP ports). |
| **UFW** | Acts as the "Kill-Switch" for non-Tor traffic. |
| **AppArmor** | Restricts Nginx to its own directory. |

---

## ⚖️ Disclaimer
This tool is for educational and authorized testing purposes only. Usage for illegal activities is strictly prohibited.
EOF
