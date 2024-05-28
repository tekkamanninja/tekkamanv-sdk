# -*- coding:utf-8 -*-
include $(__SDK_MK_VENDOR_DIR)/zsbl_generic.mk
include $(SDK_MK_COMPONENTS_DIR)/opensbi_generic.mk

__EFI_PATH := $(shell echo $(CONFIG_EFI_PATH))
__EFI_RISCV64_PATH := $(__EFI_PATH)/riscv64

$(__OPENSBI_N)_BIN_DIR := /share/opensbi/lp64/$(CONFIG_OPENSBI_BUILD_PLATFORM)/firmware
$(__SDK_BUILD_TARGET_PREFIX)_BIN_PATH := $(SDK_PREBUILD_DIR)/$(shell echo $(CONFIG_VENDOR_NAME))/$(shell echo $(CONFIG_BOARD_NAME))/$(__OPENSBI_G)

$(__SDK_BUILD_TARGET_PREFIX)_opensbi_deploy:
	sudo mkdir -p $(__EFI_RISCV64_PATH)
	sudo cp $($(__OPENSBI_N)_INSTALL_DIR)/$($(__OPENSBI_N)_BIN_DIR)/fw_jump.bin \
	$(__EFI_RISCV64_PATH)/fw_jump.bin
	sync
	tree --timefmt "%Y/%m/%d %H:%M:%S" $(__EFI_PATH)
	date

$(__SDK_BUILD_TARGET_PREFIX)_fip_deploy:
	sudo mkdir -p $(__EFI_PATH)/BOOT
	sudo cp $(CONFIG_FW_ARM_TF_FIP_PATH) $(__EFI_PATH)/fip.bin
	sync
	tree --timefmt "%Y/%m/%d %H:%M:%S" $(__EFI_PATH)
	date

$(__SDK_BUILD_TARGET_PREFIX)_zsbl_deploy:
	sudo cp $($(__ZSBL_N)_INSTALL_DIR)/zsbl.bin $(__EFI_PATH)/zsbl.bin
	sync
	tree --timefmt "%Y/%m/%d %H:%M:%S" $(__EFI_PATH)
	date

$(__SDK_BUILD_TARGET_PREFIX)_u-boot_deploy:
	sudo cp $($(__UBOOT_N)_INSTALL_DIR)/u-boot.bin $(__EFI_RISCV64_PATH)/u-boot.bin
	sync
	tree --timefmt "%Y/%m/%d %H:%M:%S" $(__EFI_RISCV64_PATH)
	date

$(__SDK_BUILD_TARGET_PREFIX)_dtb_deploy:
	sudo mkdir -p $(__EFI_RISCV64_PATH)
	sudo cp -rf $(CONFIG_FW_DTB_PATH)/* $(__EFI_RISCV64_PATH)/
#	sudo cp -rf $(CONFIG_FW_DTB_PATH)/* $(CONFIG_BOOT_PATH)/dtb/sophgo/
	sync
	tree --timefmt "%Y/%m/%d %H:%M:%S" $(__EFI_RISCV64_PATH)
	date

#	sudo cp $($(__SDK_BUILD_TARGET_PREFIX)_BIN_PATH)/zsbl.bin $(__EFI_PATH)/

$(__SDK_BUILD_TARGET_PREFIX)_linuxboot_deploy:
	sudo mkdir -p $(__EFI_RISCV64_PATH)
	sudo cp $(CONFIG_FW_LINUXBOOT_DIR)/riscv64_Image $(__EFI_RISCV64_PATH)/
	sudo cp $(CONFIG_FW_LINUXBOOT_DIR)/initrd.img $(__EFI_RISCV64_PATH)/
	sync
	tree --timefmt "%Y/%m/%d %H:%M:%S" $(__EFI_RISCV64_PATH)
	date

$(__SDK_BUILD_TARGET_PREFIX)_firmware_deploy: $(__SDK_BUILD_TARGET_PREFIX)_fip_deploy \
$(__SDK_BUILD_TARGET_PREFIX)_zsbl_deploy \
$(__SDK_BUILD_TARGET_PREFIX)_opensbi_deploy \
$(__SDK_BUILD_TARGET_PREFIX)_u-boot_deploy

