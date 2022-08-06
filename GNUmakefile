ARCH ?= x86_64
KERN_FILE = kernel.sys
CFILES = $(shell find kernel/src/ -name "*.c")

# Check that the architecture is supported and set relevant variables.
ifeq ($(ARCH),x86_64)
    override EFI_ARCH := X64
else
    $(error Architecture $(ARCH) not supported)
endif

.PHONY: all
all: Iridium.iso

.PHONY: run
run: Iridium.iso
	qemu-system-$(ARCH) -M q35 -m 2G -drive file=Iridium.iso -boot d -monitor stdio --enable-kvm -serial telnet:localhost:4321,server,nowait

.PHONY: debug1
debug1:
	qemu-system-$(ARCH) -M q35 -m 2G -drive file=Iridium.iso -boot d -monitor stdio -d int -D logfile.txt -s -S

setup:
	git clone https://github.com/limine-bootloader/limine.git --branch=v3.0-branch-binary --depth=1

.PHONY: kernel
kernel: linkobj

Iridium.iso: kernel
	make -C limine
	mkdir -p base/internals/
	rm -rf iso_root
	mkdir -p iso_root
	mkdir -p iso_root/Iridium
	cp base/limine.cfg \
		limine/limine.sys limine/limine-cd.bin limine/limine-cd-efi.bin iso_root/
	cp kernel/$(KERN_FILE) base/internals/* iso_root/Iridium/
	xorriso -as mkisofs -b limine-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot limine-cd-efi.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		iso_root -o Iridium.iso
	limine/limine-deploy Iridium.iso
	@ rm -rf iso_root
	bash kernel/clean

.PHONY: linkobj
linkobj: buildcfiles
	x86_64-elf-ld *.o -Tkernel/linker.ld          \
	-nostdlib              \
	-zmax-page-size=0x1000 \
	-static                \
    -o kernel.sys         
	rm *.o *.d
	mv kernel.sys kernel/

.PHONY: buildcfiles
buildcfiles: $(CFILES)
	x86_64-elf-gcc $^ -Iinclude/ \
	    -std=gnu11           \
	    -ffreestanding       \
	    -fno-stack-protector \
	    -fno-pic             \
        -Werror=implicit     \
        -Werror=implicit-function-declaration  \
        -Werror=implicit-int \
        -Werror=int-conversion \
        -Werror=incompatible-pointer-types \
        -Werror=int-to-pointer-cast        \
	    -mabi=sysv           \
	    -mno-80387           \
	    -mno-mmx             \
	    -mno-3dnow           \
	    -mno-sse             \
	    -mno-sse2            \
	    -mno-red-zone        \
	    -mcmodel=kernel      \
	    -MMD                 \
        -Ikernel/include            \
        -c                  


.PHONY: clean
clean:
	rm -rf iso_root Iridium.iso Iridium.hdd
	bash kernel/clean

.PHONY: distclean
distclean: clean
	rm -rf limine ovmf-$(EFI_ARCH)
	$(MAKE) -C kernel distclean
