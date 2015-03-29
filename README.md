# Candyhouse Routers

_Candyhouse_ is the codename for the Cisco board that powers the Cisco/Linksys EA4500, E4200v2, and EA3500 WiFi routers.  I have an EA4500 and an E4200v2 that I test these kernels on.  If you happen to have an EA3500 and would be open to testing builds, please [let me know](mailto:randall.will@gmail.com?subject=Candyhouse-Linux).

# IPFire

[IPFire](http://www.ipfire.org) is a hardened Linux appliance distribution designed for use as a firewall.  This build is based on the pre-existing [ARM/Kirkwood port](http://wiki.ipfire.org/en/hardware/arm/kirkwood?rev=1423351976).

# Building uImages

```bash
$ make
```

Yup, it really is that simple.  The included [Makefile](Makefile) will fetch the kernel source from [kernel.org](http://kernel.org), extract the source, patch with the included [candyhouse.patch](patches/candyhouse.patch), configure using the included [linux.config](linux.config), run the build, and copy the uImage to your `pwd`.

You can flash the uImage to your router like you would any normal SSA and it will look for a root filesystem on `/dev/sda3` on your USB stick.

For more info and discussion about making these kernels work in practice, check out:

http://www.wolfteck.com/projects/candyhouse/ipfire/

# Setting up your Root Filesystem

Get the IPFire ARM image from the source:

http://downloads.ipfire.org/releases/ipfire-2.x/2.15-core85/ipfire-2.15.1gb-ext4-scon.armv5tel-full-core85.img.gz

Zcat that compressed image to a blank USB stick, 1G or larger.  It'll make two partitions, `sdX1` and `sdX3` on your USB stick.  We'll be booting off of `sdX3`.

# Building / Installing Modules

No need.  All required functions are built into the kernel image.  Don't worry about IPFire complaining when it can't find the module directory during boot.  We don't need it.  Really.

# Cleaning Up

```bash
$ make clean
```

This will remove all of the status files, the patchlog, the uImage, the downloaded kernel source and its extracted tree.
