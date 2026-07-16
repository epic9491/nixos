{
  fileSystems."/mnt/manga" = {
    device = "192.168.0.2:/mediapool/media/manga";
    fsType = "nfs";
    options = [
      "noatime"
      "nofail"
    ];
  };
  fileSystems."/mnt/photos" = {
    device = "192.168.0.2:/mediapool/media/photos";
    fsType = "nfs";
    options = [
      "noatime"
      "nofail"
    ];
  };
  fileSystems."/mnt/music" = {
    device = "192.168.0.2:/mediapool/media/music/lossless";
    fsType = "nfs";
    options = [
      "noatime"
      "nofail"
    ];
  };
}
