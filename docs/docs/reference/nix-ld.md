# nix-ld

`services.nix-ld` configures [nix-ld](https://github.com/nix-community/nix-ld) on NixOS to execute unpatched dynamically linked ELF binaries.

## Motivation

Standard pre-compiled Linux binaries (such as vendor tarballs, [extracted embedded databases like MariaDB in MariaDB4j](https://github.com/MariaDB4j/MariaDB4j/issues/1380), or downloaded CLI tools) expect the standard Linux dynamic loader at `/lib64/ld-linux-x86-64.so.2` and shared libraries at standard FHS paths (`/lib`, `/usr/lib`).

On NixOS, `/lib64/ld-linux-x86-64.so.2` defaults to a `stub-ld` shim (see [https://nix.dev/permalink/stub-ld](https://nix.dev/permalink/stub-ld)) that intercepts executions of unpatched binaries and prints an error:

```text
Could not start dynamically linked executable: (...)
NixOS cannot run dynamically linked executables intended for generic
linux environments out of the box. For more information, see:
https://nix.dev/permalink/stub-ld
```

`nix-ld` provides a dynamic linker shim that intercepts calls and provides necessary runtime libraries via the `NIX_LD_LIBRARY_PATH` environment variable.

## Configuration

To enable `nix-ld` on a host (e.g. `titan.nix`):

```nix
services.nix-ld.enable = true;
```

### Options

- `services.nix-ld.enable`: (default: `false`) Enables `nix-ld` and installs default common libraries.
- `services.nix-ld.libraries`: (default: `[ ]`) List of additional packages/libraries to make available to dynamic binaries.

### Default Libraries

The module bundles commonly required dynamic libraries out of the box:

- `stdenv.cc.cc.lib` (C/C++ runtime: `libstdc++.so.6`)
- `zlib`
- `ncurses` and `ncurses5` (`libtinfo.so.5`, `libncurses.so.5/6`)
- `libxcrypt-legacy` (`libcrypt.so.1`)
- `libaio` (Asynchronous I/O, needed by MariaDB/MySQL)
- `liburing` (io_uring)

## Drawbacks

While `nix-ld` is convenient on workstations, it introduces trade-offs:

1. **Purity & Hermeticity**: NixOS packages typically declare and pin all dependencies hermetically inside `/nix/store`. `nix-ld` creates an exception to this model by injecting an ambient, system-wide set of shared libraries for foreign binaries.
2. **ABI & Version Conflicts**: `nix-ld` provides a single global set of shared libraries for all unpatched binaries on the host. If two foreign binaries require incompatible versions of the same shared library (e.g. OpenSSL 1.1 vs 3.0), a single ambient library path cannot satisfy both. In such cases, per-tool isolated environments (such as `buildFHSEnv` or containers) or fully static binaries are cleaner solutions.
3. **Hidden Runtime Failures**: Dependencies of unpatched binaries running via `nix-ld` are not tracked by the Nix store or garbage collector; any missing shared library will fail at runtime when the executable is launched rather than being verified at configuration/build time.
