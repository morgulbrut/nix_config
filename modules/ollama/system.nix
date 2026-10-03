{
  # CPU-only: erebor has no GPU (Xeon E3-1275L v3, 31GB DDR3), so generation
  # speed is bound by memory bandwidth. Qwen3-Coder-30B-A3B is a MoE with ~3B
  # active params, which is what makes a 30B model usable here (~5-8 tok/s).
  services.ollama = {
    enable = true;
    host = "127.0.0.1";
    port = 11434;
    # Pulled declaratively on service start (~19GB, needs internet once).
    loadModels = [ "qwen3-coder:30b" ];
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_CONTEXT_LENGTH = "16384";
      # Drop the ~19GB from RAM after 10 idle minutes so Jellyfin/NAS get it back.
      OLLAMA_KEEP_ALIVE = "10m";
    };
  };

  # Hard cap so a runaway load can't starve the other services.
  systemd.services.ollama.serviceConfig.MemoryMax = "26G";

  # Reachable at http://ollama.erebor (OpenAI-compatible API under /v1).
  # Needs the same LAN/hosts-file name resolution as the other *.erebor names.
  services.caddy.virtualHosts."http://ollama.erebor".extraConfig = ''
    reverse_proxy localhost:11434
  '';
}
