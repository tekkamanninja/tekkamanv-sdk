# -*- coding:utf-8 -*-
#==============================================================================
# Build OpenSBI for a platform in the Generic way
#==============================================================================
include $(SDK_MK_COMPONENTS_DIR)/opensbi.mk

$(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_fetch: __$(__OPENSBI_N)_fetch
$(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_checkout: __$(__OPENSBI_N)_checkout
$(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_devel: __$(__OPENSBI_N)_devel
$(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_defconfig: __$(__OPENSBI_N)_defconfig
$(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_menuconfig: __$(__OPENSBI_N)_menuconfig
$(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_mkdefconfig: __$(__OPENSBI_N)_mkdefconfig
$(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_build: __$(__OPENSBI_N)_build
$(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_install: __$(__OPENSBI_N)_install

$(__SDK_BUILD_TARGET_PREFIX)_$(__OPENSBI_N)_all: __$(__OPENSBI_N)_all

