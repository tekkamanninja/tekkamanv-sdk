# -*- coding:utf-8 -*-
__ZSBL_N := zsbl
__ZSBL_G := firmware
$(__ZSBL_N)_REPO_DIR := $(CONFIG_ZSBL_REPO_PATH)

#need efi compiler
ifeq ($(CONFIG_ZSBL_WITH_CUSTOM_CROSS_COMPILE),y)
$(__ZSBL_N)_BUILD_ENV := ARCH=$(CONFIG_ARCH) CROSS_COMPILE=$(CONFIG_ZSBL_CUSTOM_CROSS_COMPILE)
$(__ZSBL_N)_BUILD_ENV += PATH=$(CONFIG_ZSBL_CUSTOM_CROSS_COMPILE_DIR):$${PATH}
endif

ifeq ($(CONFIG_ZSBL_WITH_DEFAULT_CROSS_COMPILE),y)
$(__ZSBL_N)_BUILD_ENV := $(BUILD_ENV)
endif

ifeq ($(CONFIG_ZSBL_INSTALL_SUDO),y)
__ZSBL_INSTALL_SUDO := sudo
endif

ifeq ($(CONFIG_ZSBL_BUILD_IN_TMPFS),y)
__ZSBL_BUILD_IN_TMPFS := /tempfs
endif

ifneq ($(CONFIG_ZSBL_RAW_SRC),y)
$(__ZSBL_N)_SRC_DIR := $(join $(SDK_BUILD_DIR)$(__ZSBL_BUILD_IN_TMPFS)/$(__ZSBL_G)/$(__ZSBL_N), $(CONFIG_BOARD_SUBFIX))
else
$(__ZSBL_N)_SRC_DIR := $(CONFIG_ZSBL_SRC_PATH)
endif

$(__ZSBL_N)_INSTALL_DIR := $(join $(SDK_OUTPUT_DIR)/$(__ZSBL_G)/$(__ZSBL_N), $(CONFIG_BOARD_SUBFIX))

#please don't use any " " in the path
$(__ZSBL_N)_SRC_DIR := $(strip $($(__ZSBL_N)_SRC_DIR))
$(__ZSBL_N)_INSTALL_DIR := $(strip $($(__ZSBL_N)_INSTALL_DIR))

__$(__ZSBL_N)_fetch:
	@$(call fetch_remote, $($(__ZSBL_N)_REPO_DIR), \
				$(CONFIG_ZSBL_GIT_REMOTE))
#==============================================================================
# Build the zsbl FW
#==============================================================================

ifneq ($(CONFIG_ZSBL_BUILD_ARGS),"")
$(__ZSBL_N)_BUILD_ARGS=$(shell echo $(CONFIG_ZSBL_BUILD_ARGS))
endif

__$(__ZSBL_N)_checkout:
ifneq ($(CONFIG_ZSBL_RAW_SRC),y)
	@$(call checkout_src_full, $($(__ZSBL_N)_REPO_DIR),\
				  $(CONFIG_ZSBL_GIT_REMOTE) \
				  $(CONFIG_ZSBL_GIT_RBRANCH), \
				  $(CONFIG_ZSBL_GIT_LBRANCH), \
				  $($(__ZSBL_N)_SRC_DIR),) && echo Success!
else
	@echo "IN RAW SOUCE mode:the src is in $($(__ZSBL_N)_SRC_DIR)" 
endif

__$(__ZSBL_N)_devel:
	@$(call devel_init, $($(__ZSBL_N)_SRC_DIR))

__$(__ZSBL_N)_defconfig:
	$(call build_target, $($(__ZSBL_N)_SRC_DIR), \
			     $($(__ZSBL_N)_BUILD_ENV), \
			     $(shell echo $(CONFIG_ZSBL_BUILD_TARGET))_defconfig)

__$(__ZSBL_N)_menuconfig:
	$(call build_target, $($(__ZSBL_N)_SRC_DIR), \
			      $($(__ZSBL_N)_BUILD_ENV), \
			      menuconfig)

__$(__ZSBL_N)_mkdefconfig:
	$(call build_target, $($(__ZSBL_N)_SRC_DIR), \
			      $($(__ZSBL_N)_BUILD_ENV), \
			      savedefconfig)
				  
__$(__ZSBL_N)_build:
	$(call build_target_log, $($(__ZSBL_N)_SRC_DIR), \
				  $($(__ZSBL_N)_BUILD_ENV) \
				  $($(__ZSBL_N)_BUILD_ARGS), )

__$(__ZSBL_N)_install:
	@$(call install_bin, \
		$($(__ZSBL_N)_SRC_DIR)/zsbl.bin, \
		$($(__ZSBL_N)_INSTALL_DIR))
	tree --timefmt "%Y/%m/%d %H:%M:%S" $($(__ZSBL_N)_INSTALL_DIR)

__$(__ZSBL_N)_clean:
	$(call build_target, $($(__ZSBL_N)_SRC_DIR), \
			     $($(__ZSBL_N)_BUILD_ENV) \
			     $($(__ZSBL_N)_BUILD_ARGS), clean)

__$(__ZSBL_N)_all: __$(__ZSBL_N)_checkout __$(__ZSBL_N)_defconfig __$(__ZSBL_N)_build __$(__ZSBL_N)_install

sdk_zsbl_mk:
	@vim $(__SDK_MK_BOARD_DIR)/$(__ZSBL_N).mk

