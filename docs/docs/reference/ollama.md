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
- `OLLAMA_KEEP_ALIVE = "24h"`: Keeps models resident in VRAM/RAM for 24 hours after a request (defaulting up from Ollama's 5-minute default), preventing repeated cold-start load delays for frequent small queries and background tasks like session title generation.

## Memory and Battery Considerations

When models are kept loaded in memory:

- **Zero Idle Power & Battery Drain**: While waiting for queries, the Ollama runner sits in an idle sleep state with 0% CPU and GPU utilization. The hardware (including iGPU and CPU cores on laptops like `ixo`) enters its deepest package low-power sleep C-states (e.g. C8/C10).
- **Energy Savings vs. Cold Starts**: Repeatedly unloading after 5 minutes forces full SSD read bursts and CPU frequency spikes on every new turn. Keeping lightweight models (such as `gemma4:e2b` at ~2 GB) resident avoids dynamic load energy spikes.
- **RAM Footprint**: The only resource consumed during idle is passive memory allocation (~2 GB for small models with 8-bit KV cache). If running memory-constrained workloads on a laptop, `services.ollama-extra.keepAlive = "5m";` can be overridden per host.
