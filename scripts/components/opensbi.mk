# -*- coding:utf-8 -*-
__OPENSBI_N := opensbi
__OPENSBI_G := firmware
$(__OPENSBI_N)_REPO_DIR := $(CONFIG_OPENSBI_REPO_PATH)

ifeq ($(CONFIG_OPENSBI_INSTALL_SUDO),y)
__OPENSBI_INSTALL_SUDO := sudo
endif

ifeq ($(CONFIG_OPENSBI_BUILD_IN_TMPFS),y)
__OPENSBI_BUILD_IN_TMPFS := /tempfs
endif

ifneq ($(CONFIG_OPENSBI_RAW_SRC),y)
$(__OPENSBI_N)_SRC_DIR := $(join $(SDK_BUILD_DIR)$(__OPENSBI_BUILD_IN_TMPFS)/$(__OPENSBI_G)/$(__OPENSBI_N), $(CONFIG_BOARD_SUBFIX))
else
$(__OPENSBI_N)_SRC_DIR := $(CONFIG_OPENSBI_SRC_PATH)
endif

$(__OPENSBI_N)_INSTALL_DIR := $(join $(SDK_OUTPUT_DIR)/$(__OPENSBI_G)/$(__OPENSBI_N), $(CONFIG_BOARD_SUBFIX))

#please don't use any " " in the path
$(__OPENSBI_N)_SRC_DIR := $(strip $($(__OPENSBI_N)_SRC_DIR))
$(__OPENSBI_N)_INSTALL_DIR := $(strip $($(__OPENSBI_N)_INSTALL_DIR))

__$(__OPENSBI_N)_fetch:
	@$(call fetch_remote, $($(__OPENSBI_N)_REPO_DIR), \
				$(CONFIG_OPENSBI_GIT_REMOTE))
#==============================================================================
# Build the OpenSBI FW
#==============================================================================

ifneq ($(CONFIG_OPENSBI_BUILD_ARGS),"")
$(__OPENSBI_N)_BUILD_ARGS=$(shell echo $(CONFIG_OPENSBI_BUILD_ARGS))
endif

#for testing only
#$(__OPENSBI_N)_BIN_PATH=$($(__OPENSBI_N)_INSTALL_DIR)/u-boot.bin
#$(__OPENSBI_N)_DTB_PATH=$($(__OPENSBI_N)_INSTALL_DIR)/u-boot.dtb

ifneq ($(CONFIG_OPENSBI_PREBUILD_UBOOT_BIN),"")
$(__OPENSBI_N)_BUILD_ARGS += FW_PAYLOAD_PATH=$(shell echo $(CONFIG_OPENSBI_PREBUILD_UBOOT_BIN))
#$(__OPENSBI_N)_BUILD_ARGS += FW_PAYLOAD_PATH=$(__OPENSBI_N)_BIN_PATH
endif

ifneq ($(CONFIG_OPENSBI_PREBUILD_DTB),"")
$(__OPENSBI_N)_BUILD_ARGS += FW_FDT_PATH=$(shell echo $(CONFIG_OPENSBI_PREBUILD_DTB))
#$(__OPENSBI_N)_BUILD_ARGS += FW_FDT_PATH=$(__OPENSBI_N)_DTB_PATH
else

ifeq ($(CONFIG_OPENSBI_PLATFORM_GENERIC),y)
$(warning Missing dtb file for building generic platform)
endif

endif


__$(__OPENSBI_N)_checkout:
ifneq ($(CONFIG_OPENSBI_RAW_SRC),y)
	$(call checkout_src_full, $($(__OPENSBI_N)_REPO_DIR),\
				  $(CONFIG_OPENSBI_GIT_REMOTE) \
				  $(CONFIG_OPENSBI_GIT_RBRANCH), \
				  $(CONFIG_OPENSBI_GIT_LBRANCH), \
				  $($(__OPENSBI_N)_SRC_DIR),) && echo Success!
else
	@echo "IN RAW SOUCE mode:the src is in $($(__OPENSBI_N)_SRC_DIR)" 
endif

__$(__OPENSBI_N)_devel:
	@$(call devel_init, $($(__OPENSBI_N)_SRC_DIR))

__$(__OPENSBI_N)_defconfig:
	$(call build_target, $($(__OPENSBI_N)_SRC_DIR), \
			      $(BUILD_ENV) \
				PLATFORM=$(shell echo $(CONFIG_OPENSBI_BUILD_PLATFORM)) \
				PLATFORM_DEFCONFIG=$(shell echo $(CONFIG_OPENSBI_BUILD_TARGET))defconfig, menuconfig)

__$(__OPENSBI_N)_menuconfig:
	$(call build_target, $($(__OPENSBI_N)_SRC_DIR), \
			      $(BUILD_ENV) \
				PLATFORM=$(shell echo $(CONFIG_OPENSBI_BUILD_PLATFORM)), \
			      menuconfig)

__$(__OPENSBI_N)_mkdefconfig:
	$(call build_target, $($(__OPENSBI_N)_SRC_DIR), \
			      $(BUILD_ENV) \
				PLATFORM=$(shell echo $(CONFIG_OPENSBI_BUILD_PLATFORM)), \
			      savedefconfig)
				  
__$(__OPENSBI_N)_build:
	$(call build_target_log, $($(__OPENSBI_N)_SRC_DIR), \
				  $(BUILD_ENV), \
				  PLATFORM=$(shell echo $(CONFIG_OPENSBI_BUILD_PLATFORM)) \
				  $($(__OPENSBI_N)_BUILD_ARGS))

__$(__OPENSBI_N)_install:
	@$(call build_target_log, $($(__OPENSBI_N)_SRC_DIR), \
				  $(BUILD_ENV) \
				  PLATFORM=$(shell echo $(CONFIG_OPENSBI_BUILD_PLATFORM)) \
				  I=$($(__OPENSBI_N)_INSTALL_DIR), install)
	tree --timefmt "%Y/%m/%d %H:%M:%S" $($(__OPENSBI_N)_INSTALL_DIR)
#	@$(call install_bin, \
#		$($(__OPENSBI_N)_SRC_DIR)/build/platform/$(CONFIG_OPENSBI_BUILD_PLATFORM)/firmware/fw_*.bin, \
#		$($(__OPENSBI_N)_INSTALL_DIR))

__$(__OPENSBI_N)_all: __$(__OPENSBI_N)_checkout __$(__OPENSBI_N)_build __$(__OPENSBI_N)_install

sdk_opensbi_mk:
	@vim $(SDK_MK_COMPONENTS_DIR)/$(__OPENSBI_N).mk

