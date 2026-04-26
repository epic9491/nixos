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
    host = "100.118.40.82";
  };
}
  
