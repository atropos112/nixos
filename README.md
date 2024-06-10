<p align="center">
  <img src="./logo.png" width="350" />
</p>

# Devices

| Hostname | CPU             | RAM          | Details                                                                                                          |
| -------- | --------------- | ------------ | ---------------------------------------------------------------------------------------------------------------- |
| giant    | i9-12900K (x64) | 64 GB (DDR5) | My main home workstation, comes with Nvidia RTX3090.                                                             |
| surface  | i7-8650U (x64)  | 16 GB        | Travel laptop, Surface Book 2, comes with internal and external GPU, I don't use the external Nvidia GPU though. |
| rzr      | i7-6900K (x64)  | 32 GB        | K8s master node with GTX 1080 Ti GPU.                                                                            |
| a21      | i3-10100F (x64) | 32 GB        | K8s master node.                                                                                                 |
| smol     | i5-10210U (x64) | 16 GB        | K8s master node.                                                                                                 |
| opi1     | RK3588S (Arm64) | 16 GB        | Orange Pi 5, k8s worker node.                                                                                    |
| opi2     | RK3588S (Arm64) | 16 GB        | Orange Pi 5, k8s worker node.                                                                                    |
| opi3     | RK3588S (Arm64) | 16 GB        | Orange Pi 5, k8s worker node.                                                                                    |
| opi4     | RK3588S (Arm64) | 16 GB        | Orange Pi 5, k8s worker node.                                                                                    |

# Outline

My home infrastructure is composed of two types of devices, ones which are part of kubernetes cluster and desktop computers. Desktop come with

> [!NOTE]
>
> **System Information:**
>
> - **Window Manager:** Hyprland
> - **Shell:** ZSH
> - **Terminal:** Foot
> - **Editor:** Neovim (external for now)

Kubernetes nodes are a cut down version that do not come with a WM of any kind. I do however have a pikvm with ezCoo 4x1 HDMI switch that allows me to access the 3 master nodes in case something was to go wrong with them, look for details [here](https://docs.pikvm.org/multiport/), this is in case I can't connect to the machines via SSH directly.

I am able to deploy from both giant and surface machines to all machines, I do this with sudo because only my root user has ssh access to other root users, this isn't ideal still but is best I could come up with. To do such deployment to all orange pi's I would do

```bash
sudo colmena apply --on "opi-*"
```

# Building image for Orange Pi 5

There are very small differences between my Orange Pi 5's, I have 4 of them and other than hostnames the setups are effectively the same. To build an image, head to root directory of this repo and run

```bash
nix build .#sdImage-opi4
```

to build image for opi4 (Orange Pi 5 number 4), analogous commands to build for opi1, opi2 and opi3. This will take couple minutes and eventually produce a file in `result/sd-image` that ends with `.img.zst`.

At this point plug in the SD card, check `lsblk` to see where it is. Suppose its at `/dev/sda` then to flash you will have to run

```bash
zstdcat orangepi5-sd-image-24.05.20240314.d691274-aarch64-linux.img.zst | sudo dd status=progress bs=8M of=/dev/sda
```

where `orangepi5-sd-image-24.05.20240314.d691274-aarch64-linux.img.zst` is the name of the file that was generated with `nix build` command.

To flash onto nvme, yyou must first flash your SPI flash, to do this install official Orange Pi 5 os first and run `orangepi-config` and flash SPI there.

To flash this onto nvme, your best bet is to run Orangi Pi 5 of that SD card, copy over (using scp/rsync) the `.img.zst` file over SSH to the running Orange Pi 5 and then run the same command as above but instead of `/dev/sda` target the nvme drive. If you have flashed your SPI flash correctly, turning off Orange Pi and removing SD card should be all you need to do after that to force it to boot off nvme.

# How to install on a fresh machine

I use nixos-anywhere with disko and impermamence to install on my machines.
I need to have the `/persistent` to re-create the state, this usually comes from a backup or is copied across before I do a full on format. I then run

```bash
sudo nix run github:nix-community/nixos-anywhere -- --extra-files "/home/atropos/nixos/surface" --flake .#surface root@9.0.0.211
```

THis is ran with sudo to ensure we have sufficient permissions for whatever is in /home/atropos/nixos/surface to copy it over. the content of this surface folder should be one folder and that folder should be "persistent" which is to represent the /persistent folder on the host machine.

i had this fail on me once because i didn't have permission to all the stuff inside of the surface folder. Before doing this get fresh image and whack it on, so it is in livecd mode.

During this process if doing on desktop will be asked for password for zfs encryption. for ext4 nothing

once the machine reboots, need to apply config one more time, this is to get secrets across (the ssh keys should be there by then to read the said secrets)

# Work to be done

- Orange Pi Zero 2W setup is not working it needs fixing.
- My neovim setup should be ingested.

# Acknowledgements

- I have shamelessly copied a lot from [Srvos](https://github.com/nix-community/srvos), I am grateful for the work they have done.
