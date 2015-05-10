# Candyhouse Routers

_Candyhouse_ is the codename for the Cisco board that powers the Cisco/Linksys EA4500, E4200v2, and EA3500 WiFi routers.  I have an EA4500 and an E4200v2 that I test these kernels on.  If you happen to have an EA3500 and would be open to testing builds, please [let me know](mailto:randall.will@gmail.com?subject=Candyhouse-Linux).

# Building USB uImages

```bash
$ make usb
```

Yup, it really is that simple.  The included [Makefile](Makefile) will fetch the kernel source from [kernel.org](http://kernel.org), extract the source, patch with the included [usb.patch](patches/usb.patch), configure using the included linux.config, run the build, and copy the uImage to your `pwd`.

You can flash the uImage to your router like you would any normal SSA and it will look for a root filesystem on `/dev/sda1` -- e.g. a USB stick.

For more info and discussion about making these kernels work in practice, check out:

[http://www.wolfteck.com/projects/candyhouse/install/](http://www.wolfteck.com/projects/candyhouse/install/)

# Building OpenWRT SSAs

```bash
$ make openwrt
```

The included [Makefile](Makefile) will clone OpenWRT, patch it as appropriate, and build SSAs for the EA4500 / E4200v2 / EA3500.

You can also limit the build to your desired platform:

```bash
$ make openwrt3500
```

```bash
$ make openwrt4500
```

For more info and disucssion about OpenWRT on Candyhouse routers, please visit:

[http://www.wolfteck.com/projects/candyhouse/openwrt/](http://www.wolfteck.com/projects/candyhouse/openwrt/)

# Building / Installing Modules

No need.  All required functions are built into the kernel image.  No more mounting your router FS to you build box!

# Cleaning Up

```bash
$ make clean
```

This will remove all of the status files, the patchlog, the uImage, the downloaded kernel source and its extracted tree.
