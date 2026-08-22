# cak-llm-nixos

A modular, scalable NixOS + Home Manager flake. Machines are defined by
**flipping feature toggles**, not by copy-pasting config. Target for now: a
lightweight Hyprland VM under QEMU/KVM (virt-manager) for browser +
light-medium workloads. Built to grow to bare-metal hosts later.

## Design in one picture

```
flake.nix                 # inputs + outputs; lists machines (one line each)
├── lib/                  # mkHost factory (the only place that wires a machine)
├── overlays/             # exposes pkgs.unstable.* everywhere
├── modules/
│   ├── nixos/            # system modules, each defines cak.* option toggles
│   │   ├── core boot networking fonts users audio
│   │   ├── desktop.nix       -> cak.desktop.environment = "hyprland"|"none"
│   │   ├── guest.nix         -> cak.guest.hypervisor    = "qemu"|"virtualbox"|...
│   │   ├── virtualisation.nix-> cak.virtualisation.{podman,libvirt}.enable
│   │   └── gaming.nix        -> cak.gaming.enable
│   └── home/             # Home Manager modules, cak.home.* toggles
│       ├── core browser
│       └── hyprland.nix      # bar, launcher, terminal, keybinds
├── hosts/
│   └── llm-vm/           # a machine = hardware-configuration.nix + toggles
└── home/cak.nix          # the user: which cak.home.* features to enable
```

Everything the base ships with is either a **foundation** (always on) or an
**opt-in feature** guarded by an option. A host file just says what it *is*.

## Quick start (test it with zero risk first)

With Nix + flakes on any Linux box:

```bash
nix run .#vm          # boots a throwaway graphical QEMU VM of llm-vm
nix flake check       # builds the machine + checks formatting
nix fmt               # format all .nix files
nix develop           # dev shell (nil/nixd, nixfmt, nvd, nom)
```

`nix run .#vm` uses its own scratch disk — nothing on your host is touched.
Login user `cak`, password `nixos`.

> Hyprland needs GPU acceleration. In virt-manager set **Video model = Virtio**
> and tick **3D acceleration** (and Display = Spice). Give the VM ~4 GB RAM /
> 2 vCPU for a comfortable experience.

## Installing into a real VM (from the latest NixOS ISO)

1. Boot the ISO. Partition the virtio disk (`/dev/vda`) as GPT and **label**
   the partitions to match `hosts/llm-vm/hardware-configuration.nix`:

   ```bash
   sudo -i
   parted /dev/vda -- mklabel gpt
   parted /dev/vda -- mkpart ESP fat32 1MiB 512MiB
   parted /dev/vda -- set 1 esp on
   parted /dev/vda -- mkpart primary 512MiB 100%

   mkfs.fat -F32 -n ESP /dev/vda1
   mkfs.btrfs -L nixos /dev/vda2

   # btrfs subvolumes
   mount /dev/disk/by-label/nixos /mnt
   btrfs subvolume create /mnt/@
   btrfs subvolume create /mnt/@home
   btrfs subvolume create /mnt/@nix
   umount /mnt

   mount -o subvol=@,compress=zstd:1,noatime /dev/disk/by-label/nixos /mnt
   mkdir -p /mnt/home /mnt/nix /mnt/boot
   mount -o subvol=@home,compress=zstd:1,noatime /dev/disk/by-label/nixos /mnt/home
   mount -o subvol=@nix,compress=zstd:1,noatime  /dev/disk/by-label/nixos /mnt/nix
   mount /dev/disk/by-label/ESP /mnt/boot
   ```

   (If you'd rather not label partitions, run `nixos-generate-config --root /mnt`
   and replace `hosts/llm-vm/hardware-configuration.nix` with the generated one.)

2. Get this repo and install:

   ```bash
   nix-shell -p git
   git clone <your-repo-url> /mnt/etc/nixos/cak-llm-nixos   # or scp it over
   nixos-install --flake /mnt/etc/nixos/cak-llm-nixos#llm-vm
   reboot
   ```

3. Log in as `cak` / `nixos`, then **change the password**: `passwd`.

## Day-to-day

```bash
sudo nixos-rebuild switch --flake ~/cak-llm-nixos#llm-vm   # apply changes
# alias `rebuild` is preconfigured in the shell
nix flake update                                           # bump inputs
```

## Adding a new machine

1. `cp -r hosts/llm-vm hosts/<name>` and edit its toggles +
   `hardware-configuration.nix` (or generate a fresh one).
2. Add it to `nixosConfigurations` in `flake.nix`:

   ```nix
   <name> = mylib.mkHost {
     hostname = "<name>";
     system = "x86_64-linux";
     username = "cak";
   };
   ```

That's it — the shared modules and the whole `cak.*` feature set come for free.

## Adding a feature to the base

Create `modules/nixos/<feature>.nix` with an `options.cak.<feature>` toggle and
a `config = lib.mkIf ...` body, then add it to `modules/nixos/default.nix`.
Every host can now opt in with one line. Same pattern under `modules/home/`.

## Handy knobs (defaults shown)

| Option                               | Default   | What it does                        |
| ------------------------------------ | --------- | ----------------------------------- |
| `cak.desktop.environment`            | `none`    | `hyprland` enables the GUI session  |
| `cak.audio.enable`                   | `true`    | PipeWire stack                      |
| `cak.guest.hypervisor`               | `none`    | `qemu`/`virtualbox`/`vmware`/`hyperv` guest tools |
| `cak.virtualisation.podman.enable`   | `false`   | Podman + docker CLI compat          |
| `cak.virtualisation.libvirt.enable`  | `false`   | libvirt + virt-manager              |
| `cak.gaming.enable`                  | `false`   | Steam + gamemode + gamescope        |
| `cak.home.hyprland.enable`           | `true`*   | User Hyprland session (bar/launcher)|
| `cak.home.browser.firefox.enable`    | `true`*   | Firefox                             |

\* set in `home/cak.nix`.

## Hyprland keybinds (defaults)

`SUPER`+`Return` terminal · `SUPER`+`D` launcher · `SUPER`+`B` Firefox ·
`SUPER`+`E` files · `SUPER`+`Q` close · `SUPER`+`F` fullscreen ·
`SUPER`+`1..9` workspaces · `PrintScr` screenshot region · `SUPER`+`L` lock.
