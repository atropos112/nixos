_: let
  filesystems = [
    "btrfs"
    "ext4"
    "zfs"
  ];
in {
  boot = {
    supportedFilesystems = filesystems;
    initrd = {
      supportedFilesystems = filesystems;
    };
  };
}
