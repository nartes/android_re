KERNEL_IMAGE_PARTITION=mmcblk0p5

RECOVERY_IMAGE_PARTITION=mmcblk0p6

ifndef REBOOT_DEVICE
    REBOOT_DEVICE=0
endif

init:
	mkdir -p build

ADB_REBOOT = if [[ ${REBOOT_DEVICE} -eq 1 ]]; then echo Device Reboot!; adb reboot bootloader; fi
ADB_REBOOT_RECOVERY = if [[ ${REBOOT_DEVICE} -eq 1 ]]; then echo Device Reboot!; adb reboot recovery; fi

kernel_unpack:
	cp tmp/${KERNEL_IMAGE_PARTITION} build/kernel.img &&\
	rm -fr build/kernel-original-image &&\
	mkdir build/kernel-original-image &&\
	cd build/kernel-original-image &&\
	bootimgtool -x ../kernel.img &&\
	mkdir ramdisk &&\
	cd ramdisk &&\
	gunzip -c ../ramdisk.img | cpio -iu

kernel_patch:
	cp -v -T -rp src/patched-kernel-image/ build/kernel-original-image/ramdisk
	install -Dm750 tmp/busybox-armv6l build/kernel-original-image/ramdisk/sbin/busybox

kernel_pack_:
	cd build/kernel-original-image &&\
	cd ramdisk &&\
	find . | cpio -o -H newc | gzip > ../ramdisk-v2.img

kernel_pack: kernel_pack_
	cd build/kernel-original-image &&\
	bootimgtool -r ramdisk-v2.img -c ../kernel-v2.img

kernel_pack_with_uboot: kernel_pack_
	cd build/kernel-original-image &&\
	bootimgtool -r ramdisk-v2.img -c ../kernel-v2.img -s u-boot.img

kernel_build_and_flash: kernel_unpack kernel_patch kernel_pack
	adb push build/kernel-v2.img /dev/block/${KERNEL_IMAGE_PARTITION}
	${ADB_REBOOT}

kernel_flash_to_recovery:
	adb push build/kernel-v2.img /dev/block/${RECOVERY_IMAGE_PARTITION}
	${ADB_REBOOT_RECOVERY}

kernel_flash_to_kernel:
	adb push build/kernel-v2.img /dev/block/${KERNEL_IMAGE_PARTITION}
	${ADB_REBOOT}

recovery_unpack:
	cp tmp/${RECOVERY_IMAGE_PARTITION} build/recovery.img &&\
	rm -fr build/recovery-original-image &&\
	mkdir build/recovery-original-image &&\
	cd build/recovery-original-image &&\
	bootimgtool -x ../recovery.img &&\
	mkdir ramdisk &&\
	cd ramdisk &&\
	gunzip -c ../ramdisk.img | cpio -iu

recovery_patch:
	cp -v -T -rp src/patched-recovery-image/ build/recovery-original-image/ramdisk
	install -Dm750 tmp/busybox-armv6l build/recovery-original-image/ramdisk/sbin/busybox

recovery_pack:
	cd build/recovery-original-image &&\
	cd ramdisk &&\
	find . | cpio -o -H newc | gzip > ../ramdisk-v2.img &&\
	cd .. &&\
	bootimgtool -r ramdisk-v2.img -c ../recovery-v2.img

recovery_build_and_flash: recovery_unpack recovery_patch recovery_pack
	adb push build/recovery-v2.img /dev/block/${RECOVERY_IMAGE_PARTITION}
	${ADB_REBOOT}

helpers: src/helpers/strcopy.s
	arm-none-eabi-as -o build/strcopy.o src/helpers/strcopy.s
	arm-none-eabi-ld -s -o build/strcopy build/strcopy.o

flash_stock_i9082:
	export ROOT=$$PWD && \
	cd build/kernel-original-image && \
	bootimgtool -r ramdisk-v2.img -p parameters.cfg \
	-k $$ROOT/../android_kernel_samsung_i9082/arch/arm/boot/zImage \
	-c ../kernel-v2.img && \
	file ../kernel-v2.img && \
	adb reboot recovery && \
	sleep 20 && \
	adb push ../kernel-v2.img /dev/block/mmcblk0p5 && \
	adb reboot bootloader

flash_upstream:
	export ROOT=$$PWD && \
	cd build/kernel-original-image && \
	bootimgtool -r ramdisk-v2.img -p parameters.cfg \
	-k $$ROOT/../linux/arch/arm/boot/zImage \
	-c ../kernel-v2.img && \
	file ../kernel-v2.img && \
	adb reboot recovery && \
	sleep 20 && \
	adb push ../kernel-v2.img /dev/block/mmcblk0p5 && \
	adb reboot bootloader

check:
	sha256sum -c res/sha256sums.txt
