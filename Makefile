VERSION=3.19.3
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
	cd $(LINUX) && cp -f ../config/usb.config .config && make oldconfig ARCH=arm
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
	cd openwrt && patch -R -p1 < ../patches/openwrt3500-alt.patch > ../.openwrt3500_unpatchlog && rm ../.openwrt3500-alt_patched
endif
ifneq ("$(wildcard .openwrt4500-pri_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt4500-pri.patch > ../.openwrt4500_unpatchlog && rm ../.openwrt4500-pri_patched
endif
ifneq ("$(wildcard .openwrt4500-alt_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt4500-alt.patch > ../.openwrt4500_unpatchlog && rm ../.openwrt4500-alt_patched
endif
	cd openwrt && patch -p1 < ../patches/openwrt3500-pri.patch > ../.openwrt3500_patchlog 
	touch $@

.openwrt3500-alt_patched: .openwrt_luci 
ifneq ("$(wildcard .openwrt3500-pri_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt3500-pri.patch > ../.openwrt3500_unpatchlog && rm ../.openwrt3500-pri_patched
endif
ifneq ("$(wildcard .openwrt4500-pri_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt4500-pri.patch > ../.openwrt4500_unpatchlog && rm ../.openwrt4500-pri_patched
endif
ifneq ("$(wildcard .openwrt4500-alt_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt4500-alt.patch > ../.openwrt4500_unpatchlog && rm ../.openwrt4500-alt_patched
endif
	cd openwrt && patch -p1 < ../patches/openwrt3500-alt.patch > ../.openwrt3500_patchlog 
	touch $@

.openwrt4500-pri_patched: .openwrt_luci
ifneq ("$(wildcard .openwrt3500-pri_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt3500-pri.patch > ../.openwrt3500_unpatchlog && rm ../.openwrt3500-pri_patched
endif
ifneq ("$(wildcard .openwrt3500-alt_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt3500-alt.patch > ../.openwrt3500_unpatchlog && rm ../.openwrt3500-alt_patched
endif
ifneq ("$(wildcard .openwrt4500-alt_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt4500-alt.patch > ../.openwrt4500_unpatchlog && rm ../.openwrt4500-alt_patched
endif
	cd openwrt && patch -p1 < ../patches/openwrt4500-pri.patch > ../.openwrt4500_patchlog 
	touch $@

.openwrt4500-alt_patched: .openwrt_luci
ifneq ("$(wildcard .openwrt3500-pri_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt3500-pri.patch > ../.openwrt3500_unpatchlog && rm ../.openwrt3500-pri_patched
endif
ifneq ("$(wildcard .openwrt3500-alt_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt3500-alt.patch > ../.openwrt3500_unpatchlog && rm ../.openwrt3500-alt_patched
endif
ifneq ("$(wildcard .openwrt4500-pri_patched)","")
	cd openwrt && patch -R -p1 < ../patches/openwrt4500-pri.patch > ../.openwrt4500_unpatchlog && rm ../.openwrt4500-pri_patched
endif
	cd openwrt && patch -p1 < ../patches/openwrt4500-alt.patch > ../.openwrt4500_patchlog
	touch $@

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

clean::
	rm -rf .fetched $(LINUX) $(LINUX).tar.xz .extracted .patched .patchlog .configured .built uImage* openwrt .openwrt* *.ssa test.log
