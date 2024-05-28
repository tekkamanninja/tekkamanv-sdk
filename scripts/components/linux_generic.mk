# -*- coding:utf-8 -*-
#==============================================================================
# Build Linux kernel for a platform in the Generic way
#==============================================================================
include $(SDK_MK_COMPONENTS_DIR)/linux.mk

$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_fetch: __$(__LINUX_N)_fetch
$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_checkout: __$(__LINUX_N)_checkout
$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_devel: __$(__LINUX_N)_devel

$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_defconfig: __$(__LINUX_N)_defconfig
$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_menuconfig: __$(__LINUX_N)_menuconfig
$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_mkdefconfig: __$(__LINUX_N)_mkdefconfig

$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_build_all: __$(__LINUX_N)_build_all
$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_build_dtbs: __$(__LINUX_N)_build_dtbs
$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_build_rpm: __$(__LINUX_N)_build_rpm

$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_install_image: __$(__LINUX_N)_install_image
$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_install_zimage: __$(__LINUX_N)_install_zimage
$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_install_modules: __$(__LINUX_N)_install_modules
$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_install_dtbs: __$(__LINUX_N)_install_dtbs

$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_install_all: __$(__LINUX_N)_install_all
$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_deploy: __$(__LINUX_N)_deploy

$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_clean: __$(__LINUX_N)_clean

$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_all: __$(__LINUX_N)_all
