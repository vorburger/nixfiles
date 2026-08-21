# Ollama

`services.ollama-extra` configures [Ollama](https://ollama.com/) with shared performance and memory optimization defaults for workstations and laptops.

## Configuration

To enable Ollama on a host:

```nix
services.ollama-extra = {
  enable = true;
  # Optional: specify package variant (e.g. ollama-rocm or ollama-vulkan)
  package = pkgs.ollama-rocm;
};
```

## Shared Optimization Defaults

The module configures the following environment variables:

- `OLLAMA_FLASH_ATTENTION = "1"`: Enables Flash Attention for accelerated inference and reduced VRAM overhead.
- `OLLAMA_KV_CACHE_TYPE = "q8_0"`: Quantizes the Key-Value (KV) attention cache to 8-bit, cutting KV cache memory consumption in half without noticeable output degradation.
- `OLLAMA_CONTEXT_LENGTH = "8192"`: Sets a safe default context window size to prevent running out of VRAM/RAM on local desktop and laptop machines.
- `OLLAMA_NUM_PARALLEL = "1"`: Restricts concurrent inference slots to 1 to avoid multiplying KV cache memory consumption.
- `OLLAMA_MAX_QUEUE = "512"`: Configures queue depth for batch requests and embedding tasks.
