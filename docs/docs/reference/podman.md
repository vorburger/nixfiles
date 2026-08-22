# Podman

`services.podman-extra` enables rootless [Podman](https://podman.io/) with Docker CLI and socket compatibility on NixOS.

## Configuration

To enable Podman on a host:

```nix
services.podman-extra.enable = true;
```

### Options

- `services.podman-extra.dockerCompat`: (default: `true`) Creates `docker` symlink/alias pointing to Podman.
- `services.podman-extra.dockerSocket`: (default: `false`) Enables the Docker socket compatibility for tools that require `/var/run/docker.sock`.
- `services.podman-extra.autoPrune`: (default: `true`) Runs weekly automated pruning of unused containers, images, and volumes.
- `services.podman-extra.searchRegistries`: (default: `[ "docker.io" ]`) Registries used to resolve unqualified short image names like `ubuntu` or `alpine`.
