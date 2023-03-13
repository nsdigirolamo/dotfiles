# Nick DiGirolamo's Self-Help Guide for Arch Linux Installations

## First Steps in the Live Environment

1. Check internet and time.

    ```
        # ping archlinux.org
        # timedatectl status
    ```

    * If there's no internet, check your wired connection or use `iwctl` to connect to WIFI

    ```
        # iwctl
        # device list
        # station DEVICE scan
        # station DEVICE get-networks
        # station DEVICE connect SSID
    ```

2. Partition Disks

    * List disks using any of below.
        * `# lsblk`
        * `# fdisk -l`



