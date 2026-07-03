{
  fileSystems."/mnt/manga" = {
    device = "192.168.0.183:/mnt/jelly/manga";
    fsType = "nfs";
    options = [
      "noatime"
      "nofail"
    ];
  };
  fileSystems."/mnt/photos" = {
    device = "192.168.0.183:/mnt/jelly/photos";
    fsType = "nfs";
    options = [
      "noatime"
      "nofail"
    ];
  };
}
