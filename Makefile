VERSION=3.19.5
LINUX=linux-$(VERSION)

all::
	@echo
	@echo "Options:"
	@echo
	@echo -e "make usb\t\tBuilds a linux kernel that when flashed will boot a filesystem on a USB stick"
	@echo -e "make openwrt\t\tBuilds pri and alt OpenWRT firmware images for EA4500 / E4200v2 and EA3500"
	@echo -e "make openwrt4500\tBuilds pri and alt OpenWRT firmware images for EA4500 / E4200v2"
	@echo -e "make openwrt3500\tBuilds pri and alt OpenWRT firmware images for EA3500"
	@echo

usb:: .usb_built

.usb_fetched:
	wget https://www.kernel.org/pub/linux/kernel/v3.x/$(LINUX).tar.xz
	touch $@

.usb_extracted: .usb_fetched
	tar xvf $(LINUX).tar.xz
	touch $@

.usb_patched: .usb_extracted
	cd $(LINUX) && patch -p1 < ../patches/usb.patch > ../.usb_patchlog
	touch $@

.usb_configured: .usb_patched
	cd $(LINUX) && make oldconfig ARCH=arm
	touch $@

.usb_built: .usb_configured
	cd $(LINUX) && make -j4 ARCH=arm LOADADDR=0x00008000 uImage
	cd $(LINUX) && make ARCH=arm dtbs
	cat $(LINUX)/arch/arm/boot/zImage $(LINUX)/arch/arm/boot/dts/kirkwood-candyhouse.dtb > /tmp/zImage+kirkwood-candyhouse.dtb
	mkimage -A arm -O linux -T kernel -C none -a 0x00008000 -e 0x00008000 -n $(LINUX) -d /tmp/zImage+kirkwood-candyhouse.dtb uImage-$(VERSION)-ea4500
	touch $@

openwrt:: openwrt4500 openwrt3500

openwrt3500:: openwrt-kirkwood-ea3500-pri.ssa openwrt-kirkwood-ea3500-alt.ssa

openwrt4500:: openwrt-kirkwood-ea4500-pri.ssa openwrt-kirkwood-ea4500-alt.ssa

.openwrt_fetched:
	git clone git://git.openwrt.org/openwrt.git
	touch $@

.openwrt_luci: .openwrt_fetched
	cd openwrt && ./scripts/feeds update packages luci && ./scripts/feeds install -a -p luci
	touch $@

.openwrt3500-pri_patched: .openwrt_luci
ifneq ("$(wildcard .openwrt3500-alt_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-alt.patch 
	rm .openwrt3500-alt_patched
	cd openwrt && patch -p1 < ../patches/openwrt-pri.patch 
	touch $@
else ifneq ("$(wildcard .openwrt4500-pri_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-4500.patch 
	rm .openwrt4500-pri_patched
	cd openwrt && patch -p1 < ../patches/openwrt-3500.patch 
	touch $@
else ifneq ("$(wildcard .openwrt4500-alt_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-4500.patch 
	cd openwrt && patch -p1 -R < ../patches/openwrt-alt.patch 
	rm .openwrt4500-alt_patched
	cd openwrt && patch -p1 < ../patches/openwrt-3500.patch 
	cd openwrt && patch -p1 < ../patches/openwrt-pri.patch 
	touch $@
else
	cd openwrt && patch -p1 < ../patches/openwrt.patch
	cd openwrt && patch -p1 < ../patches/openwrt-3500.patch 
	cd openwrt && patch -p1 < ../patches/openwrt-pri.patch 
	touch $@
endif

.openwrt3500-alt_patched: .openwrt_luci
ifneq ("$(wildcard .openwrt3500-pri_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-pri.patch 
	rm .openwrt3500-pri_patched
	cd openwrt && patch -p1 < ../patches/openwrt-alt.patch 
	touch $@
else ifneq ("$(wildcard .openwrt4500-pri_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-4500.patch 
	cd openwrt && patch -p1 -R < ../patches/openwrt-pri.patch 
	rm .openwrt4500-pri_patched
	cd openwrt && patch -p1 < ../patches/openwrt-3500.patch 
	cd openwrt && patch -p1 < ../patches/openwrt-alt.patch 
	touch $@
else ifneq ("$(wildcard .openwrt4500-alt_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-4500.patch 
	rm .openwrt4500-alt_patched
	cd openwrt && patch -p1 < ../patches/openwrt-3500.patch 
	touch $@
else	
	cd openwrt && patch -p1 < ../patches/openwrt.patch
	cd openwrt && patch -p1 < ../patches/openwrt-3500.patch 
	cd openwrt && patch -p1 < ../patches/openwrt-alt.patch 
	touch $@
endif

.openwrt4500-pri_patched: .openwrt_luci
ifneq ("$(wildcard .openwrt3500-pri_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-3500.patch 
	rm .openwrt3500-pri_patched
	cd openwrt && patch -p1 < ../patches/openwrt-4500.patch
	touch $@
else ifneq ("$(wildcard .openwrt3500-alt_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-3500.patch
	cd openwrt && patch -p1 -R < ../patches/openwrt-alt.patch
	rm .openwrt3500-alt_patched
	cd openwrt && patch -p1 < ../patches/openwrt-4500.patch
	cd openwrt && patch -p1 < ../patches/openwrt-pri.patch 
	touch $@
else ifneq ("$(wildcard .openwrt4500-alt_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-alt.patch
	rm .openwrt4500-alt_patched
	cd openwrt && patch -p1 < ../patches/openwrt-pri.patch 
	touch $@
else
	cd openwrt && patch -p1 < ../patches/openwrt.patch
	cd openwrt && patch -p1 < ../patches/openwrt-4500.patch
	cd openwrt && patch -p1 < ../patches/openwrt-pri.patch
	touch $@
endif

.openwrt4500-alt_patched: .openwrt_luci
ifneq ("$(wildcard .openwrt3500-pri_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-3500.patch
	cd openwrt && patch -p1 -R < ../patches/openwrt-pri.patch
	rm .openwrt3500-pri_patched
	cd openwrt && patch -p1 < ../patches/openwrt-4500.patch
	cd openwrt && patch -p1 < ../patches/openwrt-alt.patch
	touch $@
else ifneq ("$(wildcard .openwrt3500-alt_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-3500.patch
	rm .openwrt3500-alt_patched 
	cd openwrt && patch -p1 < ../patches/openwrt-4500.patch
	touch $@
else ifneq ("$(wildcard .openwrt4500-pri_patched)","")
	cd openwrt && patch -p1 -R < ../patches/openwrt-pri.patch 
	rm .openwrt4500-pri_patched 
	cd openwrt && patch -p1 < ../patches/openwrt-alt.patch 
	touch $@
else
	cd openwrt && patch -p1 < ../patches/openwrt.patch 
	cd openwrt && patch -p1 < ../patches/openwrt-4500.patch 
	cd openwrt && patch -p1 < ../patches/openwrt-alt.patch 
	touch $@
endif

.openwrt3500-pri_built: .openwrt3500-pri_patched
	cd openwrt && make target/linux/clean
	cd openwrt && make oldconfig && make -j4
	touch $@

.openwrt3500-alt_built: .openwrt3500-alt_patched
	cd openwrt && make target/linux/clean
	cd openwrt && make oldconfig && make -j4
	touch $@

.openwrt4500-pri_built: .openwrt4500-pri_patched
	cd openwrt && make target/linux/clean
	cd openwrt && make oldconfig && make -j4
	touch $@

.openwrt4500-alt_built: .openwrt4500-alt_patched
	cd openwrt && make target/linux/clean
	cd openwrt && make oldconfig && make -j4
	touch $@

openwrt-kirkwood-ea3500-pri.ssa: .openwrt3500-pri_built
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea3500.ssa openwrt-kirkwood-ea3500-pri.ssa

openwrt-kirkwood-ea3500-alt.ssa: .openwrt3500-alt_built
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea3500.ssa openwrt-kirkwood-ea3500-alt.ssa

openwrt-kirkwood-ea4500-pri.ssa: .openwrt4500-pri_built
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea4500.ssa openwrt-kirkwood-ea4500-pri.ssa

openwrt-kirkwood-ea4500-alt.ssa: .openwrt4500-alt_built
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea4500.ssa openwrt-kirkwood-ea4500-alt.ssa

usb-clean::
	rm -rf .usb_extracted .usb_patched .usb_configured .usb_built $(LINUX) uImage-$(VERSION)-ea4500

usb-distclean: usb-clean
	rm -rf $(LINUX).tar.xz .usb*

openwrt-clean::
	rm -rf *.ssa

openwrt-distclean: openwrt-clean
	rm -rf openwrt/ .openwrt*

clean: usb-clean openwrt-clean

distclean: usb-distclean openwrt-distclean
