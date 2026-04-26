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
    loadModels = [ "qwen3:8b"];
    package = pkgs.ollama-cuda.override { cudaArches = [ "61" ]; };
    host = "100.118.40.82";
  };
}
  
