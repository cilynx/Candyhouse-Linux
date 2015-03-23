# Candyhouse Routers

_Candyhouse_ is the codename for the Cisco board that powers the Cisco/Linksys EA4500, E4200v2, and EA3500 WiFi routers.  I have an EA4500 and an E4200v2 that I test these kernels on.  If you happen to have an EA3500 and would be open to testing builds, please [let me know](mailto:randall.will@gmail.com?subject=Candyhouse-Linux).

# Building uImages

```bash
$ make
```

Yup, it really is that simple.  The included [Makefile](Makefile) will fetch the kernel source from [kernel.org](http://kernel.org), extract the source, patch with the included [candyhouse.patch](patches/candyhouse.patch), configure using the included [linux.config](linux.config), run the build, and copy the uImage to your `pwd`.

You can flash the uImage to your router like you would any normal SSA and it will look for a root filesystem on `/dev/sda1` -- e.g. a USB stick.

# Building / Installing Modules

No need.  All required functions are built into the kernel image.  No more mounting your router FS to you build box!

# Cleaning Up

```bash
$ make clean
```

This will remove all of the status files, the patchlog, the uImage, the downloaded kernel source and its extracted tree.
