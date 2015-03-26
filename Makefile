VERSION=3.18.2
LINUX=linux-$(VERSION)

all::	.built

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
	cd $(LINUX) && cp -f ../linux.config .config && make oldconfig ARCH=arm
	touch $@

.built:	.configured
	cd $(LINUX) && make -j4 ARCH=arm LOADADDR=0x00008000 uImage
	cd $(LINUX) && make ARCH=arm dtbs
	cat $(LINUX)/arch/arm/boot/zImage $(LINUX)/arch/arm/boot/dts/kirkwood-candyhouse.dtb > /tmp/zImage+kirkwood-candyhouse.dtb 
	mkimage -A arm -O linux -T kernel -C none -a 0x00008000 -e 0x00008000 -n $(LINUX) -d /tmp/zImage+kirkwood-candyhouse.dtb uImage-$(VERSION)-candyhouse
	touch $@

clean::
	rm -rf .fetched $(LINUX) $(LINUX).tar.xz .extracted .patched .patchlog .configured .built .depends uImage-$(VERSION)-candyhouse
