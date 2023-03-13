# **1.0** *First Steps in the Live Environment*

## **1.1** *Check Internet and Time*

    # ping archlinux.org
    # timedatectl status

If there's no internet, check your wired connection or use `iwctl` to
connect to WIFI.

    # iwctl
    # device list
    # station DEVICE scan
    # station DEVICE get-networks
    # station DEVICE connect SSID

## **1.2** *Partition Disks*

List disks using any of below.

    # lsblk
    # fdisk -l
    # parted -l

And then actually partition the device.

    # cfdisk /dev/DEVICE

I recommend three partitions. The home partition is not necessary, but it's nice
to have.

- EFI partition (500 MB).
- Root partiton (50 - 100 GB).
- Home partition (the rest of your storage).

## **1.3** *Format Partitions*

Your EFI partition needs to be FAT32.

    # mkfs.fat -F 32 /dev/EFI-SYSTEM-PARTITION

Your other partition(s) can just be ext4 or whatever you want.

    # mkfs.ext4 /dev/OTHER-PARTITION

--------------------------------------------------------------------------------

# **2.0** *Configuring the New System*

## **2.1** *Mount the Filesystem*

You want to mount your root partition first.

    # mount /dev/ROOT-PARTITION /mnt

And then mount the other stuff. You probably need to include the `--mkdir`
argument if the directories don't already exist. You might not have a home
partition, or you might have other partitions for some reason. In those cases,
just mount as required. You're smart you'll figure it out.

    # mount --mkdir /dev/EFI-PARTITION /mnt/boot
    # mount --mkdir /dev/HOME-PARTITION /mnt/home


## **2.2** *Install Essential Packages*

We're going to install only the most essential packages first for the sake of
speed. We'll add the other packages after the system can boot on its own.

    # reflector // For best mirrors.
    # pacstrap -K /mnt base base-devel linux linux-firmware man-db man-pages networkmanager refind vi vim

## **2.3** *Generate the fstab File*

Generate `fstab` and then check for errors. Make sure `fstab` is properly
mounting all the partitions you manually mounted in step 2.1.

    # genfstab -U /mnt >> /mnt/etc/fstab
    # vim /mnt/etc/fstab

## **2.4** *Change Root*

After you change root, you'll no longer be in the live environment. You
will only have the packages you installed in step 2.2.

    # arch-chroot /mnt

## **2.5** *Configure Time*

Configure the timezone.

    # ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

Generate /etc/adjtime

    # hwclock --systohc

## **2.6** *Configure Locale*

To set localization, uncomment `en_US.UTF-8 UTF-8` from `/etc/locale.gen`

    # vim /etc/locale.gen
    # locale-gen

Then create `locale.conf` and save `LANG=en_US.UTF-8` to its contents.

    # vim /etc/locale.conf

## *2.7* *Configure Networking*

Set the hostname and then enable NetworkManager.

    # vim /etc/hostname
    # systemctl enable NetworkManager.service

## *2.8* *Create root Password*

    # passwd

--------------------------------------------------------------------------------

# **3.0** *Setting up the rEFInd Boot Manager*

## **3.1** *Run the Install Script*

The install script will not be enough. It does not properly configure rEFInd
when run in chroot, and instead tries to populate the kernel options from the
live system instead of the system we're trying to install it on.

    # refind-install

## **3.2** *Configure rEFInd to Work Properly*

When booting, rEFInd uses refind_linux.conf to determine the kernel options.
This file shoot be in the directory you mounted your EFI partition to. If you
followed this guide exactly, it should be located at `/boot/refind_linux.conf`
since your EFI partition should have been mounted to `/boot`.
`refind_linux.conf` should look something like the following:

```
"Standard Boot"	"root=PARTUUID=636464e7-c5e6-1646-a8b4-2d2a59a590dc rw initrd=initramfs-linux.img"
"Fallback Boot"	"root=PARTUUID=636464e7-c5e6-1646-a8b4-2d2a59a590dc rw initrd=initramfs-linux-fallback.img"
```

In this case, the long string is the PARTUUID of my EFI partition. In the
standard boot, rEFInd is booting from `initramfs-linux.img`. This file is
located at `/boot/initramfs-linux.img`, but I don't have to include /boot in its
path since my EFI partition is already mounted at `/boot`. To find your EFI
partition's PARTUUID, you can use the following command:

    # ls -la /dev/disk/by-partuuid

And you can feed the output of that command right into `refind_linux.conf` so
you don't have any typos.

    # ls -la /dev/disk/by-partuuid | grep EFI-PARTITION >> /boot/refind_linux.conf

## **3.3** *Exit and Reboot*

If you configured rEFInd correctly, you should now be able to exit from chroot
and reboot the system. You should then be able to use rEFInd to boot into
your new system. If you can't, you'll need to boot from the live environment
again and re-mount all your disks and chroot to fix any potential problems.

--------------------------------------------------------------------------------

# **4.0** *Post-Install Steps*

## **4.1** *Set up WIFI*

    # nmcli device wifi list
    # nmcli device wifi connect SSID password PASSWORD

## **4.2** *Update the System*

    # pacman -Syu

## **4.3** *Configure pacman*

Uncomment Color, Parallel Downloads, and the multilib repository from
`/etc/pacman.conf`.

    # vim /etc/pacman.conf

## **4.4** *Make a New User*

First uncomment the wheel group from `visudo`. Then, make a new user in the
wheel group, and make them use the bash shell.

    # visudo
    # useradd -m -G wheel -s /bin/bash USERNAME
    # passwd USERNAME

## **4.5** *Configure reflector*

Reflector will help choose the best mirrors for your system.

    # pacman -S reflector

You don't really need to set the country in `reflector.conf`, just be sure to
set `--latest 10` and `--sort rate`

    # vim /etc/xdg/reflector/reflector.conf
    # systemctl start reflector.timer
    # systemctl enable reflector.timer
    # systemctl start reflector.service

`reflector.timer` will run `reflector.service`. Above we're running
`reflector.service` once just to make sure `reflector.conf` isn't creating any
errors.

## **4.6** *Configure Microcode*

From the Arch Linux wiki:

> Microcode updates are usually shipped with the motherboard's firmware and 
> applied during firmware initialization. Since OEMs might not release firmware
> updates in a timely fashion and old systems do not get new firmware updates
> at all, the ability to apply CPU microcode updates during boot was added to
> the Linux kernel.

So it's probably good to have microcode. Do **one** of the below commands
depending on your CPU's manufacturer.

    # pacman -S amd-ucode
    # pacman -S intel-ucode

Then add `initrd=amd-ucode.img` or `initrd=intel-ucode.img` to 
`refind_linux.conf` depending on your CPU's manufacturer. Your
`refind_linux.conf` should look something like the following:

```
"Standard Boot"	"root=PARTUUID=636464e7-c5e6-1646-a8b4-2d2a59a590dc rw initrd=amd-ucode.img initrd=initramfs-linux.img"
"Fallback Boot"	"root=PARTUUID=636464e7-c5e6-1646-a8b4-2d2a59a590dc rw initrd=amd-ucode.img initrd=initramfs-linux-fallback.img"
```

Reboot your system, and then verify that it worked with the following:

    # journalctl -k --grep=microcode

## **4.7** *Graphics Drivers*

Below is obviously only for nvidia graphics cards.

    # pacman -S nvidia

--------------------------------------------------------------------------------

# **5.0** *Install a Minimal Desktop Environment*

# **5.1** *Gnome*

    # pacman -S gdm gnome-backgrounds gnome-console gnome-control-center gnome-disk-utility gnome-system-monitor gnome-tweaks nautilus baobab cheese eog evince file-roller firefox vlc
    # systemctl enable gdm.service
    # systemctl start gdm.service

# **5.2** *todo: KDE*

--------------------------------------------------------------------------------

# **6.0** *todo: Post-Install Recommendations*