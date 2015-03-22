INSTALL_MOD_PATH = /mnt # Generally, this should point to your rootfs USB stick

export CC=gcc

CROSS_COMPILE=arm-none-eabi-
CC=$(CROSS_COMPILE)gcc
CXX=$(CROSS_COMPILE)g++
LD=$(CROSS_COMPILE)ld
ARCH=arm
LOADADDR=0x00008000

VERSION=3.17.2
LINUX=linux-$(VERSION)

all::	.built
install:: .installed

.fetched:
	wget https://www.kernel.org/pub/linux/kernel/v3.x/$(LINUX).tar.xz
	touch $@

.extracted: .fetched 
	tar xvf $(LINUX).tar.xz 
	touch $@

.patched: .extracted
	> .patchlog
	cd $(LINUX) && for n in ../patches/*; do echo; echo $$n; patch -p1 < $$n; done > ../.patchlog
	touch $@

.configured: .patched
	cd $(LINUX) && cp -f ../linux.config .config && make oldconfig ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) 
	touch $@

.built:	.configured
	cd $(LINUX) && make -j4 ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) LOADADDR=$(LOADADDR) uImage #modules
	cd $(LINUX) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) dtbs
	cat $(LINUX)/arch/arm/boot/zImage $(LINUX)/arch/arm/boot/dts/kirkwood-candyhouse.dtb > /tmp/zImage+kirkwood-candyhouse.dtb 
	mkimage -A arm -O linux -T kernel -C none -a $(LOADADDR) -e $(LOADADDR) -n $(LINUX) -d /tmp/zImage+kirkwood-candyhouse.dtb uImage-${VERSION}-candyhouse
	touch $@

.installed: .built
	cd $(LINUX) && sudo make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(PREFIX) modules_install
	touch $@

clean::
	rm -rf .fetched ${LINUX} ${LINUX}.tar.xz .extracted .patched .patchlog .configured .built .depends uImage-${VERSION}-candyhouse
