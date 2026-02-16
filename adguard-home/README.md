### Building From Nothing
If you are building with docker compose and AdGuard (local DNS) is not running you can temporarily (until next reboot) update your DNS resolver to a public provider.

```shell
sudo resolvectl dns eth0 1.1.1.1
docker compose build
docker compose up -d
```

### Building the Docker Stages
```shell
docker build --target=unbound-builder --tag unbound-builder:latest .
docker build --target=adguard-builder --tag adguard-builder:latest .
docker build --tag adguard-home:latest .
```

### Debugging A Running Container
When running the docker image, you can gain a shell in it, but there are very few tools that you can use for network debugging. From the host you can switch networking namespaces to effectively run networking commands as if inside the container. 
```shell
sudo nsenter -t $(docker inspect -f '{{.State.Pid}}' adguard) -n
```
Then any commands you run with a network context, `nslookup`, `dig`, `netstat`, all work as if they were ran from inside the running container.
