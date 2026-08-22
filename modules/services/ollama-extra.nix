{
  lib,
  ...
}:
let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.ollama-extra = mkService {
    name = "ollama-extra";
    description = "Ollama with shared performance optimizations";
    extraOptions = {
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Ollama package to use (e.g. ollama-rocm or ollama-vulkan).";
      };
      contextLength = lib.mkOption {
        type = lib.types.int;
        default = 8192;
        description = "Default context window size (OLLAMA_CONTEXT_LENGTH).";
      };
      kvCacheType = lib.mkOption {
        type = lib.types.str;
        default = "q8_0";
        description = "KV Cache quantization type (OLLAMA_KV_CACHE_TYPE).";
      };
      flashAttention = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Flash Attention (OLLAMA_FLASH_ATTENTION).";
      };
      numParallel = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = "Number of parallel inference slots (OLLAMA_NUM_PARALLEL).";
      };
      maxQueue = lib.mkOption {
        type = lib.types.int;
        default = 512;
        description = "Maximum request queue length (OLLAMA_MAX_QUEUE).";
      };
      keepAlive = lib.mkOption {
        type = lib.types.str;
        default = "24h";
        description = "How long models stay in memory after a request (OLLAMA_KEEP_ALIVE).";
      };
      environmentVariables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Extra host-specific environment variables for Ollama.";
      };
    };
    content =
      { cfg, pkgs, ... }:
      {
        services.ollama = {
          enable = true;
          package = if cfg.package != null then cfg.package else pkgs.ollama;
          environmentVariables = {
            OLLAMA_CONTEXT_LENGTH = toString cfg.contextLength;
            OLLAMA_KV_CACHE_TYPE = cfg.kvCacheType;
            OLLAMA_FLASH_ATTENTION = if cfg.flashAttention then "1" else "0";
            OLLAMA_NUM_PARALLEL = toString cfg.numParallel;
            OLLAMA_MAX_QUEUE = toString cfg.maxQueue;
            OLLAMA_KEEP_ALIVE = cfg.keepAlive;
          }
          // cfg.environmentVariables;
        };
      };
  };
}
