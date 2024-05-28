# -*- coding:utf-8 -*-
#==============================================================================
# Build U-Boot for a platform in the Generic way
#==============================================================================
include $(SDK_MK_COMPONENTS_DIR)/grub.mk

$(__SDK_BUILD_TARGET_PREFIX)_$(__GRUB_N)_fetch: __$(__GRUB_N)_fetch
$(__SDK_BUILD_TARGET_PREFIX)_$(__GRUB_N)_checkout: __$(__GRUB_N)_checkout
$(__SDK_BUILD_TARGET_PREFIX)_$(__GRUB_N)_devel: __$(__GRUB_N)_devel

$(__SDK_BUILD_TARGET_PREFIX)_$(__GRUB_N)_config: __$(__GRUB_N)_config
$(__SDK_BUILD_TARGET_PREFIX)_$(__GRUB_N)_doc: __$(__GRUB_N)_doc

$(__SDK_BUILD_TARGET_PREFIX)_$(__GRUB_N)_build: __$(__GRUB_N)_build

$(__SDK_BUILD_TARGET_PREFIX)_$(__GRUB_N)_mkimage_standalone: __$(__GRUB_N)_mkimage_standalone
$(__SDK_BUILD_TARGET_PREFIX)_$(__GRUB_N)_mkimage: __$(__GRUB_N)_mkimage

$(__SDK_BUILD_TARGET_PREFIX)_$(__GRUB_N)_clean: __$(__GRUB_N)_clean

$(__SDK_BUILD_TARGET_PREFIX)_$(__GRUB_N)_all: __$(__GRUB_N)_all

