# -*- coding:utf-8 -*-
#==============================================================================
# Build U-Boot for a platform in the Generic way
#==============================================================================
include $(SDK_MK_COMPONENTS_DIR)/u-boot.mk

$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_fetch: __$(__UBOOT_N)_fetch
$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_checkout: __$(__UBOOT_N)_checkout
$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_devel: __$(__UBOOT_N)_devel

$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_defconfig: __$(__UBOOT_N)_defconfig
$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_menuconfig: __$(__UBOOT_N)_menuconfig
$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_mkdefconfig: __$(__UBOOT_N)_mkdefconfig

$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_build: __$(__UBOOT_N)_build
$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_build_tools: __$(__UBOOT_N)_build_tools
$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_build_dtb: __$(__UBOOT_N)_build_dtb
$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_build_with_spl: __$(__UBOOT_N)_build_with_spl

$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_install: __$(__UBOOT_N)_install
$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_install_dtb: __$(__UBOOT_N)_install_dtb

$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_clean: __$(__UBOOT_N)_clean

$(__SDK_BUILD_TARGET_PREFIX)_$(__UBOOT_N)_all: __$(__UBOOT_N)_all

