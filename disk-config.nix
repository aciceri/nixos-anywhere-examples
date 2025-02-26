{ lib, disks ? [ "/dev/nvme0n1" "/dev/nvme1n1" ], ... }: {
    disk = {
    x = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
            name = "ESP";
            start = "0";
            end = "960MiB";
            fs-type = "fat32";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            type = "partition";
            name = "zfs";
            start = "1GiB";
            end = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          }
        ];
      };
    };
    y = {
      type = "disk";
      device = builtins.elemAt disks 1;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
            name = "zfs";
            start = "1GiB";
            end = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          }
        ];
      };
    };
  };
  zpool = {
    zroot = {
      type = "zpool";
      mode = "mirror";
      rootFsOptions = {
        compression = "lz4";
        "com.sun:auto-snapshot" = "false";
      };
      datasets = {
        root = {
          zfs_type = "filesystem";
          options.mountpoint = "legacy";
          mountpoint = "/";
        };
      };
    };
  };
}
