# -*- coding:utf-8 -*-
include $(SDK_MK_COMPONENTS_DIR)/opensbi_generic.mk
include $(SDK_MK_COMPONENTS_DIR)/u-boot_generic.mk

__EFI_PATH := $(shell echo $(CONFIG_EFI_PATH))
__BOOT_PATH := $(shell echo $(CONFIG_BOOT_PATH))
__EFI_RISCV64_PATH := $(__EFI_PATH)/riscv64
$(__OPENSBI_N)_BIN_DIR := /share/opensbi/lp64/$(CONFIG_OPENSBI_BUILD_PLATFORM)/firmware
$(__SDK_BUILD_TARGET_PREFIX)_BIN_PATH := $(SDK_PREBUILD_DIR)/$(shell echo $(CONFIG_VENDOR_NAME))/$(shell echo $(CONFIG_BOARD_NAME))/$(__OPENSBI_G)

$(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_deploy:
	sudo cp $($(__OPENSBI_N)_INSTALL_DIR)/$($(__OPENSBI_N)_BIN_DIR)/fw_dynamic.bin \
	$(__BOOT_PATH)/
	sync
	tree --timefmt "%Y/%m/%d %H:%M:%S" $(__BOOT_PATH)
	date

$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_deploy_smode:
	sudo mkdir -p $(__EFI_RISCV64_PATH)
	sudo cp $($(__UBOOT_N)_INSTALL_DIR)/u-boot.bin \
	$(__EFI_RISCV64_PATH)/
	sync
	tree --timefmt "%Y/%m/%d %H:%M:%S" $(__EFI_PATH)
	date

$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_deploy_mmode:
	sudo fastboot flash ram $($(__UBOOT_N)_INSTALL_DIR)/u-boot-with-spl.bin
	sudo fastboot reboot
	sleep 10
	sudo fastboot flash uboot $($(__UBOOT_N)_INSTALL_DIR)/u-boot-with-spl.bin

$(__SDK_BUILD_TARGET_PREFIX)_firmware_deploy: $(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_deploy \
$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_deploy

