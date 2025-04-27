# ElectrumX - Python Electrum Server

```
Licence: MIT
Original Author: Neil Booth
Current Maintainers: The Electrum developers
Language: Python (>= 3.10)
```

[![Latest PyPI package](https://badge.fury.io/py/e_x.svg)](https://pypi.org/project/e-x/)
[![Build Status](https://api.cirrus-ci.com/github/spesmilo/electrumx.svg?branch=master)](https://cirrus-ci.com/github/spesmilo/electrumx)
[![Test coverage statistics](https://coveralls.io/repos/github/spesmilo/electrumx/badge.svg?branch=master)](https://coveralls.io/github/spesmilo/electrumx)

This project is a fork of [kyuupichan/electrumx](https://github.com/kyuupichan/electrumx).
The original author dropped support for Bitcoin, which we intend to keep.

ElectrumX allows users to run their own Electrum server. It connects to your
full node and indexes the blockchain, allowing efficient querying of the history of
arbitrary addresses. The server can be exposed publicly, and joined to the public network
of servers via peer discovery. As of May 2020, a significant chunk of the public
Electrum server network runs ElectrumX.

## Quick Start Guide

### 1. Install Dependencies

```bash
sudo apt update
sudo apt install python3-pip python3-venv libleveldb-dev
```

### 2. Clone the Repository

```bash
git clone https://github.com/spesmilo/electrumx.git
cd electrumx
```

### 3. Create and Configure Python Environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install -e .
```

### 4. Create Configuration File

Create a file named `electrumx.conf` with essential settings:

```ini
# Cryptocurrency to serve
COIN=Bitcoin

# Database directory
DB_DIRECTORY=/path/to/electrumx/db

# Daemon URL - replace username:password with your credentials
DAEMON_URL=http://username:password@127.0.0.1:8332/

# Services - TCP (unencrypted), SSL (encrypted), and RPC (control interface)
SERVICES=tcp://:50001,ssl://:50002,rpc://:8000

# Public-facing services - Replace with your own domain name
REPORT_SERVICES=tcp://your-domain.example.com:50001,ssl://your-domain.example.com:50002

# SSL certificate and key - required for SSL connections
SSL_CERTFILE=/etc/letsencrypt/live/your-domain.example.com/fullchain.pem
SSL_KEYFILE=/etc/letsencrypt/live/your-domain.example.com/privkey.pem

# Enable peer discovery to connect with other servers
PEER_DISCOVERY=on
```

See the [electrumx.conf.example](electrumx.conf.example) file for a working template.

For detailed environment variable documentation, refer to [docs/environment.rst](docs/environment.rst).

### 5. Setting Up SSL Certificates (Required for SSL/WSS)

For production servers, you should use proper SSL certificates from a Certificate Authority. Let's Encrypt provides free certificates that are recognized by all clients.

```bash
# Install Certbot
sudo apt update
sudo apt install certbot

# Obtain certificates (standalone method)
sudo certbot certonly --standalone -d your-domain.example.com

# The certificates will be saved to:
# /etc/letsencrypt/live/your-domain.example.com/fullchain.pem
# /etc/letsencrypt/live/your-domain.example.com/privkey.pem

# Update your electrumx.conf to point to these files:
SSL_CERTFILE=/etc/letsencrypt/live/your-domain.example.com/fullchain.pem
SSL_KEYFILE=/etc/letsencrypt/live/your-domain.example.com/privkey.pem
```

Remember to set up automatic renewal:
```bash
# Test renewal process
sudo certbot renew --dry-run

# Add to crontab to check twice daily
sudo crontab -e
# Add this line:
0 0,12 * * * certbot renew --quiet
```

### 6. Running ElectrumX

#### Option A: Direct Run with Start Script

Create a start script similar to [start-electrumx.sh](start-electrumx.sh):

```bash
#!/bin/bash
cd ~/electrumx
# Clean bad env first
unset HOST
# Export config variables
export $(grep -v '^#' electrumx.conf | xargs)
# Launch server
./electrumx_server
```

Make it executable:
```bash
chmod +x start-electrumx.sh
./start-electrumx.sh
```

#### Option B: Using Systemd (Recommended)

ElectrumX includes systemd service examples in the [contrib/systemd](contrib/systemd) directory.

Create a systemd service file:

```bash
sudo nano /etc/systemd/system/electrumx.service
```

Add the following content:

```ini
[Unit]
Description=ElectrumX Server
After=network.target

[Service]
Type=simple
# Environment variables for ElectrumX
Environment=COIN=Bitcoin
Environment=DB_DIRECTORY=/path/to/electrumx/db
Environment=DAEMON_URL=http://username:password@127.0.0.1:8332/
Environment=SERVICES=tcp://:50001,ssl://:50002,rpc://:8000
Environment=REPORT_SERVICES=tcp://your-domain.example.com:50001,ssl://your-domain.example.com:50002
Environment=SSL_CERTFILE=/etc/letsencrypt/live/your-domain.example.com/fullchain.pem
Environment=SSL_KEYFILE=/etc/letsencrypt/live/your-domain.example.com/privkey.pem
Environment=PEER_DISCOVERY=on

ExecStart=/path/to/electrumx/electrumx_server
User=electrumx
Group=electrumx
WorkingDirectory=/path/to/electrumx
LimitNOFILE=8192
TimeoutStopSec=30min
Restart=on-failure
RestartSec=60

# Security settings
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable electrumx.service
sudo systemctl start electrumx.service
```

## Monitoring

```bash
# Check service status
sudo systemctl status electrumx.service

# View logs
sudo journalctl -u electrumx.service -f
```

## Performance Considerations

- ElectrumX requires a substantial amount of disk space to store the transaction index
- Initial sync can take several days depending on your hardware
- Recommended minimum: 4+ CPU cores, 16GB+ RAM, SSD storage

For detailed performance notes, see [docs/PERFORMANCE-NOTES](docs/PERFORMANCE-NOTES).

## Additional Resources

- [Architecture Overview](docs/architecture.rst) - How ElectrumX is designed
- [Features List](docs/features.rst) - Supported features and coins
- [Protocol Documentation](docs/protocol.rst) - Details of the Electrum protocol
- [RPC Interface](docs/rpc-interface.rst) - Available RPC commands
- [Peer Discovery](docs/peer_discovery.rst) - How servers find each other

### Docker Support

ElectrumX includes Docker support. See the [contrib/Dockerfile](contrib/Dockerfile) for details.

### Alternative Service Managers

Besides systemd, ElectrumX also includes examples for:
- [Daemontools](contrib/daemontools) - For daemontools service management
- [Raspberry Pi](contrib/raspberrypi3) - Optimized for Raspberry Pi deployments

## Full Documentation

For complete details, see [readthedocs](https://electrumx-spesmilo.readthedocs.io).

## Community

- IRC: `#electrum` on Libera Chat
- Issues: [GitHub Issues](https://github.com/spesmilo/electrumx/issues)
