$(__SDK_BUILD_TARGET_PREFIX)_SPL_TYPE := 2E54B353-1271-4842-806F-E436D6AF6985
$(__SDK_BUILD_TARGET_PREFIX)_UBOOT_TYPE := 5B193300-FC78-40CD-8002-E86C45580B47
$(__SDK_BUILD_TARGET_PREFIX)_BOOT_TYPE := EBD0A0A2-B9E5-4433-87C0-68B6B72699C7
$(__SDK_BUILD_TARGET_PREFIX)_ROOTFS_TYPE := 0FC63DAF-8483-4772-8E79-3D69D8477DE4

$(__SDK_BUILD_TARGET_PREFIX)_IMAGE_DIR := $(SDK_OUTPUT_DIR)/image$(CONFIG_BOARD_SUBFIX)
$(__SDK_BUILD_TARGET_PREFIX)_IMAGE_FILE := flash$(CONFIG_BOARD_SUBFIX).img
$(__SDK_BUILD_TARGET_PREFIX)_IMAGE_PATH := $($(__SDK_BUILD_TARGET_PREFIX)_IMAGE_DIR)/$($(__SDK_BUILD_TARGET_PREFIX)_IMAGE_FILE)

$(__SDK_BUILD_TARGET_PREFIX)_BIN_PATH := $(SDK_PREBUILD_DIR)/$(shell echo $(CONFIG_VENDOR_NAME))/$(shell echo $(CONFIG_BOARD_NAME))

$(__SDK_BUILD_TARGET_PREFIX)_create_image:
	mkdir -p $($(__SDK_BUILD_TARGET_PREFIX)_IMAGE_DIR)
	fallocate -l $(CONFIG_DEEPCOMPUTING_ROMA_ROOTFS_SIZE)M \
		$($(__SDK_BUILD_TARGET_PREFIX)_IMAGE_PATH)
	tree -h --timefmt "%Y/%m/%d %H:%M:%S" $($(__SDK_BUILD_TARGET_PREFIX)_IMAGE_DIR)

$(__SDK_BUILD_TARGET_PREFIX)_format_image: $(__SDK_BUILD_TARGET_PREFIX)_create_image
	sgdisk --clear -g \
		--new=1:4096:8191 \
			--change-name=1:spl \
			--typecode=1:$($(__SDK_BUILD_TARGET_PREFIX)_SPL_TYPE) \
		--new=2:8192:16383 \
			--change-name=2:u-boot \
			--typecode=2:$($(__SDK_BUILD_TARGET_PREFIX)_UBOOT_TYPE) \
		--new=3:16384:614399 \
			--change-name=3:boot \
			--typecode=3:$($(__SDK_BUILD_TARGET_PREFIX)_BOOT_TYPE) \
		--new=4:614400:0 \
			--change-name=4:rootfs \
			--typecode=4:$($(__SDK_BUILD_TARGET_PREFIX)_ROOTFS_TYPE) \
		$($(__SDK_BUILD_TARGET_PREFIX)_IMAGE_PATH)

$(__SDK_BUILD_TARGET_PREFIX)_make_image:
	pushd $($(__SDK_BUILD_TARGET_PREFIX)_IMAGE_DIR); \
	LOOP_DEVS=`sudo kpartx -av $($(__SDK_BUILD_TARGET_PREFIX)_IMAGE_FILE) | awk '{print $$3}'`; \
	SPL_LOOP_DEV=$${LOOP_DEVS%p1*}p1; \
	UBOOT_LOOP_DEV=$${LOOP_DEVS%p1*}p2; \
	BOOT_LOOP_DEV=$${LOOP_DEVS%p1*}p3; \
	ROOTFS_LOOP_DEV=$${LOOP_DEVS%p1*}p4; \
	mkdir -p mnt; \
	mkfs.ext4 /dev/mapper/$${ROOTFS_LOOP_DEV}; \
	mount /dev/mapper/$${ROOTFS_LOOP_DEV} mnt; sleep 3; \
	mkdir -p mnt/boot; \
	mkfs.vfat /dev/mapper/$${BOOT_LOOP_DEV}; \
	mount /dev/mapper/$${BOOT_LOOP_DEV} mnt/boot; sleep 3; \
	dd if=$($(__SDK_BUILD_TARGET_PREFIX)_BIN_PATH)/spl.img of=/dev/mapper/$${SPL_LOOP_DEV} bs=4K; \
	dd if=$($(__SDK_BUILD_TARGET_PREFIX)_BIN_PATH)/uboot.img of=/dev/mapper/$${UBOOT_LOOP_DEV} bs=4K; \
	sync; \
	kpartx -d $($(__SDK_BUILD_TARGET_PREFIX)_IMAGE_FILE); \
	popd
