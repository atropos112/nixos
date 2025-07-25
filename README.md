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

To flash this onto nvme, your best bet is to run Orangi Pi 5 of that SD card, copy over (using scp/rsync) the `.img.zst` file over SSH to the running Orange Pi 5 and then run the same command as above but instead of `/dev/sda` target the nvme drive.
If you have flashed your SPI flash correctly, turning off Orange Pi and removing SD card should be all you need to do after that to force it to boot off nvme.

# How to install on a fresh machine

I use nixos-anywhere with disko and impermamence to install on my machines.

For simplicity one can use either minimal NixOS image from NixOS website or the purpose made for this from [nixos-images](https://github.com/nix-community/nixos-images?tab=readme-ov-file#iso-installer-images).

I need to have the `/persistent` to re-create the state, this usually comes from a backup or is copied across before I do a full on format.

First I do some preparation

- Get /persistent folder for the machine I am installing from (somehow).
- Boot into livecd mode and run passwd as root setting some password easy to remember. Run `ip a` to get the IP address of the machine (the machine must be connected to internet, ideally via cable).
- From machine you are installing from run `sudo ssh <IP-OF-THE-MACHINE>` and accept the fingerprint.

Once the prep is done, simply run

```bash
sudo nix run github:nix-community/nixos-anywhere -- --extra-files "/home/atropos/nixos/surface" --flake .#surface root@9.0.0.211
```

This is ran with sudo to ensure we have sufficient permissions for whatever is in /home/atropos/nixos/surface to copy it over. the content of this surface folder should be one folder and that folder should be "persistent" which is to represent the /persistent folder on the host machine.

I had this fail on me once because i didn't have permission to all the stuff inside of the surface folder. Before doing this get fresh image and whack it on, so it is in livecd mode.

During this process if doing on desktop will be asked for password for zfs encryption. for ext4 nothing

# Work to be done

- Orange Pi Zero 2W setup is not working it needs fixing.
- My neovim setup should be ingested.

# What happens when Orange Pi 5 goes belly up

Sometimes an update is so bad the screen is just dark and there is no way to turn back on. On typical AMD64 machine you can just select older version of nixos config in the grub but not on Orange Pi 5's.
To fix this I do the following:

- Get any nixos (ryan4yin one or one built with `nix build .#sdImage-opi4` say) image and flash it onto SD card.
- Boot into this SD card.
- Mount the nvme drive into `/mnt`.
- Copy over nixos configuration to `/mnt/root/nixos`.
- Run `sudo su` to get root.
- Run `nixos-enter --root /mnt` to enter the system.
- Optionally login to attic (to get remote cache).
- Run `nixos-rebuild boot --flake .#opi4 --rollback --option sandbox false` to rollback to previous version.
- Shutdown and remove SD card and boot into nvme normally.

Note, you have to use `--option sandbox false` to prevent the

```
error: cloning builder process: Operation not permitted
error: unable to start build process
```

error. Also have to use `boot` isntead of `switch` because `switch` will try to switch now (rather than after reboot) and will need dbus process with pid 1 to be running which is not the case when you are in chroot.
More about this can be found [here](https://nixos.wiki/wiki/Change_root).

# Insepct NixOS configuration

To inspect my NixOS configuration, you can use the following command in the root directory of this repository:

```bash
nix repl .
```

or start with `nix repl` (without the `.`) and then run `:lf .`

Then follow this up with:

```nix
nix-repl> colmenaHive.nodes.giant.config
```

This naturally extends to all other nodes, and gets lazily evaluated.

To refresh the NixOS configuration, you can run:

```nix
nix-repl> :r
```

# How to verify all is good

You kind of have to "just try" at some point but before that you can run

```bash
nix flake check --all-systems
```

optionally passing in `--no-build`.

# Adding a new node

All new nodes should be using impermanence.

You should:

1. Add a line in `flake.nix` something like

```nix
nixosConfigurations = {
    ...
    orth = mkHost "orth" "x86_64-linux";
    ...
};
```

2. Create a new diretory in `hosts` matching the name of the node with `default.nix` and `hardware.nix` files in it. Look at other nodes to get an idea what you need. Typically some imports and

```nix
networking = {
    hostName = "orth";
};
```

For `hardware.nix` it will very likely look like

```nix
_: {
  imports = [
    ../../profiles/impermanence/basic.nix
  ];

  atro = {
    boot.enable = true;

    disko = {
      enable = true;
      hostId = "1676722a"; # Id you just made up of same size.
      mode = "raidz1"; # Depends on how many drives you have.
      drives = [
        # Get These by running `ls /dev/disk/by-id/` on the machine you are adding.
        "nvme-Lexar_SSD_NM620_2TB_NM6760R003099P111D"
        "nvme-Lexar_SSD_NM620_2TB_NM6760R003317P111D"
        "nvme-Lexar_SSD_NM620_2TB_NM6760R003360P111D"
        "nvme-Lexar_SSD_NM620_2TB_NM6760R003472P111D"
      ];
    };
  };
}
```

3. Make persistend directory that will be passed into nixos anywhere call it `persistent` and put it in your directory of choice e.g. `/home/atropos/orth/persistent`. In there make `home/atropos/.ssh` and `/root/.ssh` directories and generate ssh keys for both using `ssh-keygen -f id_ed25519 -C "some-menaningful-name"`. Do note the final directory must be called `peristent` so that `/home/atropos/orth/persistent` is ok but `/home/atropos/orth/persistent2` is not. This is because `nixos-anywhere` will map it to directories on the machine and we need that directory to be mapped to `/persistent`.

4. Run `nix-shell -p ssh-to-age --run "ssh-to-age < root/.ssh/id_ed25519.pub"` (pointing at the root ssh key you just generated) and add a line to `nixos/.sops.yaml`, you will need to copy the `secrets.yaml` file contents delete the file and run `edit-secrets` and paste them in so it "accounts" for the new node.

5. `ssh-keygen -f id_ed25519 -C "<some-name>"` and `ssh-keygen -t rsa -f rsa -C "<some-name>"` somewhere, and store those keys in `hostKeys` directory in sops secrets, you can use `edit-secrets` to do this. Delete the files you just generated once you are done.

6. Run `nixos-anywhere` command like so:

```nix
 sudo nix run github:nix-community/nixos-anywhere -- --extra-files "/home/atropos/orth" --flake .#orth root@9.0.0.134
```

If you forgot about something, like say, the fact that tailscale key is out of date then you will likely have to run something like

```nix
sudo nixos-rebuild --flake .#orth --target-host 9.0.0.135 --verbose --build-host localhost switch
```

after finding out what the IP is of course. I think it might be a good idea to run this once anyway just in case.

Don't forget to disable expiry key in tailscale admin console.

# I've updated and am now seeing "a package is broken" how to deal with this?

You have a package that has a broken dependency, probably need to remove the app or use an older version (or newer if possible).

Run

```bash
nix-tree '.#nixosConfigurations.giant.config.system.build.toplevel' --impure --derivation
```

(or other node) and then '/' and search for the broken package you saw in the error message to see what depends on it.

# Acknowledgements

- I have shamelessly copied a lot from [Srvos](https://github.com/nix-community/srvos), I am grateful for the work they have done.
