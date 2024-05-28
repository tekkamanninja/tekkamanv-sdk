# -*- coding:utf-8 -*-
#==============================================================================
# Build zsbl for a Sophgo platform in the Generic way
#==============================================================================
include $(__SDK_MK_VENDOR_DIR)/zsbl.mk

$(__SDK_BUILD_TARGET_PREFIX)_$(__ZSBL_N)_fetch: __$(__ZSBL_N)_fetch
$(__SDK_BUILD_TARGET_PREFIX)_$(__ZSBL_N)_checkout: __$(__ZSBL_N)_checkout
$(__SDK_BUILD_TARGET_PREFIX)_$(__ZSBL_N)_devel: __$(__ZSBL_N)_devel

$(__SDK_BUILD_TARGET_PREFIX)_$(__ZSBL_N)_defconfig: __$(__ZSBL_N)_defconfig
$(__SDK_BUILD_TARGET_PREFIX)_$(__ZSBL_N)_menuconfig: __$(__ZSBL_N)_menuconfig
$(__SDK_BUILD_TARGET_PREFIX)_$(__ZSBL_N)_mkdefconfig: __$(__ZSBL_N)_mkdefconfig
$(__SDK_BUILD_TARGET_PREFIX)_$(__ZSBL_N)_build: __$(__ZSBL_N)_build
$(__SDK_BUILD_TARGET_PREFIX)_$(__ZSBL_N)_install: __$(__ZSBL_N)_install
$(__SDK_BUILD_TARGET_PREFIX)_$(__ZSBL_N)_clean: __$(__ZSBL_N)_clean

$(__SDK_BUILD_TARGET_PREFIX)_$(__ZSBL_N)_all: __$(__ZSBL_N)_all

