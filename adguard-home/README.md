# Unbound Docker Image

This Docker image builds and runs the Unbound DNS resolver from source.

## Building the Image

```bash
docker build -t unbound:latest .
```

## Running the Container

### Basic Usage

Run Unbound on the standard DNS port (requires root/sudo):

```bash
docker run -d --name unbound -p 53:53/udp -p 53:53/tcp unbound:latest
```

### With Custom Configuration

Mount your own configuration file:

```bash
docker run -d --name unbound \
  -p 53:53/udp -p 53:53/tcp \
  -v /path/to/unbound.conf:/usr/local/etc/unbound/unbound.conf:ro \
  unbound:latest
```
## Image Details
- Base: Debian Bookworm Slim
- Unbound Version: Built from source
- Size: ~139MB
- Features enabled:
  - libevent support
  - POSIX threads
  - EDNS subnet support
  - DNSTap support
  - DNSCrypt support
  - Cache DB support

## Security Notes

- The container runs as a non-root user (unbound)
- Buffer size warnings are normal and don't affect functionality
- For production use, customize the configuration to restrict access appropriately
