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

## Returning to the stock firmware for reflashing

Candyhouse routers have two seperate partitions for firmware and a failed boot counter that acts as a safety mechanism. After three failed boots, the bootloader automatically stops trying to boot the failing firmware image and switches to the other partition set -- the "last known good". This build of OpenWRT will reset it to 0 on a successful boot. Since firmware flashing is currently not possible from this OpenWRT build we need to return to the stock firmware to flash new OpenWRT builds.

You can switch firmware by convincing the router it has three bad boots, either by powering off the router 5 seconds after it starts repeatedly - 3 times in succession.

Or switch by disabling the boot counter reset in OpenWRT and doing three normal reboots. You can disable the reset by ssh'ing into the router: `ssh root@192.168.1.1` and removing executable permissions for the reset script 'chmod 644 /etc/init.d/linksys_recovery'. 


# Building / Installing Modules

No need.  All required functions are built into the kernel image.  No more mounting your router FS to you build box!

# Cleaning Up

```bash
$ make clean
```

This will remove all of the status files, the patchlog, the uImage, the downloaded kernel source and its extracted tree.
