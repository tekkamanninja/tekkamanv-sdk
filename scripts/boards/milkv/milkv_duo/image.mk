#==============================================================================
# Build the SD/flash image for 
#==============================================================================

#sophgo_sg2042_evb_uboot_all
#sophgo_sg2042_evb_linux_all
#$(initramfs)

#sophgo_sg2042_evb_uboot_build_tools
#make buildroot_rootfs -jx
#make DISK=/dev/sdX format-nvdla-rootfs && sync

#TF 卡分区信息：
SOPHGO_SG2042_EVB_BOOT_TYPE			= EBD0A0A2-B9E5-4433-87C0-68B6B72699C7
SOPHGO_SG2042_EVB_ROOTFS_TYPE		= 0FC63DAF-8483-4772-8E79-3D69D8477DE4
SOPHGO_SG2042_EVB_BOOTLOADER_TYPE		= 5B193300-FC78-40CD-8002-E86C45580B47


#for debug
#CONFIG_SOPHGO_SG2042_EVB_UENV_PATH=$(SDK_PREBUILD_DIR)/image$(CONFIG_BOARD_SUBFIX)/uEnv.txt
#CONFIG_SOPHGO_SG2042_EVB_ROOTFS_IMAGE_PATH=$(SDK_PREBUILD_DIR)/image$(CONFIG_BOARD_SUBFIX)/test.ext4

#CONFIG_SOPHGO_SG2042_EVB_BOOT_START=4096
#CONFIG_SOPHGO_SG2042_EVB_BOOT_SECTORS=466943

#CONFIG_SOPHGO_SG2042_EVB_BOOTLOADER_START=471040
#CONFIG_SOPHGO_SG2042_EVB_BOOTLOADER_SECTORS=2047

#CONFIG_SOPHGO_SG2042_EVB_ROOTFS_START=475136
#CONFIG_SOPHGO_SG2042_EVB_ROOTFS_SECTORS=409600
#for debug

SOPHGO_SG2042_EVB_BOOT_END=$(shell expr \
	$(CONFIG_SOPHGO_SG2042_EVB_BOOT_START) + \
	$(CONFIG_SOPHGO_SG2042_EVB_BOOT_SECTORS))

SOPHGO_SG2042_EVB_BOOTLOADER_END=$(shell expr \
	$(CONFIG_SOPHGO_SG2042_EVB_BOOTLOADER_START) + \
	$(CONFIG_SOPHGO_SG2042_EVB_BOOTLOADER_SECTORS))

#SOPHGO_SG2042_EVB_ROOTFS_END=$(shell expr \
#	$(CONFIG_SOPHGO_SG2042_EVB_ROOTFS_START) + \
#	$(CONFIG_SOPHGO_SG2042_EVB_ROOTFS_SECTORS))

#0 means 'to the end of image'
SOPHGO_SG2042_EVB_ROOTFS_END=0

SOPHGO_SG2042_EVB_SD_IMAGE_SECTORS_NUM=$(shell expr \
	$(CONFIG_SOPHGO_SG2042_EVB_ROOTFS_START) + \
	$(CONFIG_SOPHGO_SG2042_EVB_ROOTFS_SECTORS))

#4K = 512 * 8
SOPHGO_SG2042_EVB_SD_IMAGE_BLK_SECTORS=8
SOPHGO_SG2042_EVB_SD_IMAGE_COUNT=$(shell expr \
	$(SOPHGO_SG2042_EVB_SD_IMAGE_SECTORS_NUM) / \
	$(SOPHGO_SG2042_EVB_SD_IMAGE_BLK_SECTORS) + \
	1)

SOPHGO_SG2042_EVB_SD_IMAGE_DIR=$(SDK_OUTPUT_DIR)/image$(CONFIG_BOARD_SUBFIX)
SOPHGO_SG2042_EVB_SD_IMAGE_FILE=flash$(CONFIG_BOARD_SUBFIX).img

sophgo_sg2042_evb_create_image:
	mkdir -p $(SOPHGO_SG2042_EVB_SD_IMAGE_DIR)/
	dd iflag=fullblock bs=4K count=$(SOPHGO_SG2042_EVB_SD_IMAGE_COUNT) \
		if=/dev/zero \
		of=$(SOPHGO_SG2042_EVB_SD_IMAGE_DIR)/$(SOPHGO_SG2042_EVB_SD_IMAGE_FILE)
	tree -h --timefmt "%Y/%m/%d %H:%M:%S" $(SOPHGO_SG2042_EVB_SD_IMAGE_DIR)

sophgo_sg2042_evb_format_image: sophgo_sg2042_evb_create_image
	sgdisk --clear -g \
		--new=1:$(CONFIG_SOPHGO_SG2042_EVB_BOOT_START):$(SOPHGO_SG2042_EVB_BOOT_END) \
			--change-name=1:"Vfat Boot" \
			--typecode=1:$(SOPHGO_SG2042_EVB_BOOT_TYPE) \
		--new=2:$(CONFIG_SOPHGO_SG2042_EVB_BOOTLOADER_START):$(SOPHGO_SG2042_EVB_BOOTLOADER_END) \
			--change-name=2:uboot \
			--typecode=2:$(SOPHGO_SG2042_EVB_BOOTLOADER_TYPE) \
		--new=3:$(CONFIG_SOPHGO_SG2042_EVB_ROOTFS_START):$(SOPHGO_SG2042_EVB_ROOTFS_END) \
			--change-name=3:root \
			--typecode=3:$(SOPHGO_SG2042_EVB_ROOTFS_TYPE) \
		$(SOPHGO_SG2042_EVB_SD_IMAGE_DIR)/$(SOPHGO_SG2042_EVB_SD_IMAGE_FILE)

sophgo_sg2042_evb_make_image:
	pushd  $(SOPHGO_SG2042_EVB_SD_IMAGE_DIR); \
	mkdir -p mnt;\
	LOOP_DEVS=`sudo kpartx -av $(SOPHGO_SG2042_EVB_SD_IMAGE_FILE) | awk '{print $$3}'`;\
	BOOT_LOOP_DEV=$${LOOP_DEVS%p1*}p1; \
	BL_LOOP_DEV=$${LOOP_DEVS%p1*}p2; \
	ROOT_LOOP_DEV=$${LOOP_DEVS%p1*}p3; \
	sudo mkfs.vfat /dev/mapper/$${BOOT_LOOP_DEV};\
	mkdir -p mnt/boot;\
	sudo mount /dev/mapper/$${BOOT_LOOP_DEV} mnt/boot; sleep 3; \
	sudo cp -rf $(SDK_OUTPUT_DIR)/$(CONFIG_CONFIG_FILE).fit \
	$(CONFIG_SOPHGO_SG2042_EVB_UENV_PATH) mnt/boot/ ;\
	tree -h --timefmt "%Y/%m/%d %H:%M:%S" mnt/boot/; \
	sync; sleep 3; sudo umount mnt/boot; \
	rm -rf mnt; \
	sudo dd if=$(join $(UBOOT_INSTALL_DIR), $(CONFIG_BOARD_SUBFIX))/u-boot.bin \
	of=/dev/mapper/$${BL_LOOP_DEV} bs=4K; sync; \
	sudo dd if=$(CONFIG_SOPHGO_SG2042_EVB_ROOTFS_IMAGE_PATH) \
	of=/dev/mapper/$${ROOT_LOOP_DEV} bs=4K; sync; \
	sudo resize2fs /dev/mapper/$${ROOT_LOOP_DEV}; \
	sudo fsck.ext4 /dev/mapper/$${ROOT_LOOP_DEV}; \
	sudo kpartx -d $(SOPHGO_SG2042_EVB_SD_IMAGE_FILE); sync; \
	sudo growpart $(SOPHGO_SG2042_EVB_SD_IMAGE_FILE) 3 ; \
	popd

