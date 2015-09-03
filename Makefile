VERSION=3.19.5
LINUX=linux-$(VERSION)

all::
	@echo
	@echo "Options:"
	@echo
	@echo "make usb\t\tBuilds a linux kernel that when flashed will boot a filesystem on a USB stick"
	@echo
	@echo "make openwrt\t\tBuilds pri and alt OpenWRT firmware images for EA4500 / E4200v2 and EA3500"
	@echo "make openwrt4500\tBuilds pri and alt OpenWRT firmware images for EA4500 / E4200v2"
	@echo "make openwrt3500\tBuilds pri and alt OpenWRT firmware images for EA3500"
	@echo
	@echo "make openwrt-kirkwood-ea3500-pri.ssa \tBuilds pri OpenWRT firmware image for EA3500"
	@echo "make openwrt-kirkwood-ea3500-alt.ssa \tBuilds alt OpenWRT firmware image for EA3500"
	@echo "make openwrt-kirkwood-ea4500-pri.ssa \tBuilds pri OpenWRT firmware image for EA4500 / E4200v2"
	@echo "make openwrt-kirkwood-ea4500-alt.ssa \tBuilds alt OpenWRT firmware image for EA4500 / E4200v2"
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
	git clone git://git.openwrt.org/15.05/openwrt.git
	touch $@

.openwrt_luci: .openwrt_fetched
	cd openwrt && ./scripts/feeds update packages luci && ./scripts/feeds install -a -p luci
	touch $@

openwrt-kirkwood-ea3500-pri.ssa: .openwrt_luci
	cp openwrt/.config openwrt/.config-orig
	cd openwrt && patch -p1 < ../patches/openwrt-config.patch
	cd openwrt && patch -p1 < ../patches/openwrt-3500-config.patch
	cd openwrt && patch -p1 < ../patches/openwrt.patch
	cd openwrt && patch -p1 < ../patches/openwrt-3500.patch
	cd openwrt && patch -p1 < ../patches/openwrt-pri.patch
	cd openwrt && chmod 755 target/linux/kirkwood/base-files/etc/init.d/linksys_recovery
	cd openwrt && make target/linux/clean
	cd openwrt && make menuconfig
	cd openwrt && make oldconfig && make -j4
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea3500.ssa openwrt-kirkwood-ea3500-pri.ssa
	cp openwrt/.config-orig openwrt/.config
	cd openwrt && patch -p1 -R < ../patches/openwrt-pri.patch
	cd openwrt && patch -p1 -R < ../patches/openwrt-3500.patch
	cd openwrt && patch -p1 -R < ../patches/openwrt.patch


openwrt-kirkwood-ea3500-alt.ssa: .openwrt_luci
	cp openwrt/.config openwrt/.config-orig
	cd openwrt && patch -p1 < ../patches/openwrt-config.patch
	cd openwrt && patch -p1 < ../patches/openwrt-3500-config.patch
	cd openwrt && patch -p1 < ../patches/openwrt.patch
	cd openwrt && patch -p1 < ../patches/openwrt-3500.patch
	cd openwrt && patch -p1 < ../patches/openwrt-alt.patch
	cd openwrt && chmod 755 target/linux/kirkwood/base-files/etc/init.d/linksys_recovery
	cd openwrt && make target/linux/clean
	cd openwrt && make oldconfig && make -j4
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea3500.ssa openwrt-kirkwood-ea3500-alt.ssa
	cp openwrt/.config-orig openwrt/.config
	cd openwrt && patch -p1 -R < ../patches/openwrt-alt.patch
	cd openwrt && patch -p1 -R < ../patches/openwrt-3500.patch
	cd openwrt && patch -p1 -R < ../patches/openwrt.patch

openwrt-kirkwood-ea4500-pri.ssa: .openwrt_luci
	cd openwrt && patch -p1 < ../patches/openwrt.patch
	cd openwrt && patch -p1 < ../patches/openwrt-4500.patch
	cd openwrt && patch -p1 < ../patches/openwrt-pri.patch
	cd openwrt && chmod 755 target/linux/kirkwood/base-files/etc/init.d/linksys_recovery
	cd openwrt && make target/linux/clean
	cd openwrt && make oldconfig && make -j4
	cd openwrt && patch -p1 -R < ../patches/openwrt-pri.patch
	cd openwrt && patch -p1 -R < ../patches/openwrt-4500.patch
	cd openwrt && patch -p1 -R < ../patches/openwrt.patch
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea4500.ssa openwrt-kirkwood-ea4500-pri.ssa

openwrt-kirkwood-ea4500-alt.ssa: .openwrt_luci
	cd openwrt && patch -p1 < ../patches/openwrt.patch
	cd openwrt && patch -p1 < ../patches/openwrt-4500.patch
	cd openwrt && patch -p1 < ../patches/openwrt-alt.patch
	cd openwrt && chmod 755 target/linux/kirkwood/base-files/etc/init.d/linksys_recovery
	cd openwrt && make target/linux/clean
	cd openwrt && make oldconfig && make -j4
	cd openwrt && patch -p1 -R < ../patches/openwrt-alt.patch
	cd openwrt && patch -p1 -R < ../patches/openwrt-4500.patch
	cd openwrt && patch -p1 -R < ../patches/openwrt.patch
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

