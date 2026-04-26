{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
  {
  services.ollama = {
    enable = true;
    loadModels = [ "qwen3:30b-a3b"];
    package = pkgs.ollama-cuda.override { cudaArches = [ "61" ]; };
  };
}
  
