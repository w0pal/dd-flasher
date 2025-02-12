# dd-flasher

`dd-flasher` is a simple bash script to flash ISO/IMG files to USB drives or other block devices.

## Requirements

- `bash`
- `lsblk`
- `dd`
- `sync`

## Installation

### Debian/Ubuntu

```sh
sudo apt update
sudo apt install coreutils util-linux
```

### Fedora

```sh
sudo dnf install coreutils util-linux
```

### Arch Linux

```sh
sudo pacman -S coreutils util-linux
```

### Gentoo

```sh
sudo emerge sys-apps/coreutils sys-apps/util-linux
```

### Termux

```sh
pkg update
pkg install coreutils util-linux
```

### Void Linux

```sh
sudo xbps-install -S coreutils util-linux
```

## Usage

1. Clone the repository or download the `dd-flasher.sh` script.
2. Make the script executable:
   ```sh
   chmod +x dd-flasher.sh
   ```
3. Run the script:
   ```sh
   ./dd-flasher.sh
   ```

Follow the on-screen prompts to select the ISO/IMG file and the target device. The script will guide you through the flashing process.
