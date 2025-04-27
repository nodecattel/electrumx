# ElectrumX Systemd Service Template

This document provides instructions for setting up ElectrumX as a systemd service, ensuring it runs reliably and automatically starts on system boot.

## Quick Setup Instructions

1. **Create the service file**:
   ```bash
   sudo nano /etc/systemd/system/electrumx.service
   ```
   Copy and paste the template from below, adjusting all values to match your setup.

2. **Set proper permissions**:
   ```bash
   sudo chmod 644 /etc/systemd/system/electrumx.service
   ```

3. **Reload systemd daemon**:
   ```bash
   sudo systemctl daemon-reload
   ```

4. **Enable the service to start at boot**:
   ```bash
   sudo systemctl enable electrumx.service
   ```

5. **Start the service**:
   ```bash
   sudo systemctl start electrumx.service
   ```

## Configuration Variables Explained

### Required Environment Variables

- `COIN`: The cryptocurrency this ElectrumX instance serves (eg. Bitcoin, BitcoinCash, Litecoin)
- `DB_DIRECTORY`: Path to the database directory
- `DAEMON_URL`: URL to connect to the coin daemon (format: `http://username:password@hostname:port/`)

### Service Configuration

- `SERVICES`: Comma-separated list of services ElectrumX will accept incoming connections for
  - Format: `protocol://host:port` (e.g., `tcp://:50001,ssl://:50002,rpc://:8000`)
- `REPORT_SERVICES`: Services advertised to other ElectrumX servers
  - Should include your public domain/IP
  - Example: `tcp://your.domain.com:50001,ssl://your.domain.com:50002`

### SSL Configuration (if using SSL/WSS)

- `SSL_CERTFILE`: Path to SSL certificate file
- `SSL_KEYFILE`: Path to SSL key file

### Optional Settings

- `PEER_DISCOVERY`: Set to "on" to enable peer discovery
- `CACHE_MB`: Size of cache in MB (default: 1,200)
- `BANNER_FILE`: Path to a banner file to display to clients

## Common Management Commands

- Check service status:
  ```bash
  sudo systemctl status electrumx.service
  ```

- View logs:
  ```bash
  sudo journalctl -u electrumx.service -f
  ```

- Restart the service:
  ```bash
  sudo systemctl restart electrumx.service
  ```

## Troubleshooting

If your service fails to start, check the logs for specific error messages:

```bash
sudo journalctl -u electrumx.service -n 50
```

Common issues include:
- Incorrect paths or permissions
- Missing or obsolete environment variables
- Daemon connection problems
- Port conflicts

## Security Considerations

The service file includes basic security hardening:
- `NoNewPrivileges`: Prevents the service from gaining additional privileges
- `PrivateTmp`: Uses a private /tmp directory
- Running as a dedicated user rather than root

Consider creating a dedicated user for running ElectrumX:
```bash
sudo useradd -r -m -s /bin/false electrumx
```
