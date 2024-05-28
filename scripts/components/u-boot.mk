# -*- coding:utf-8 -*-
__UBOOT_N := u-boot
__UBOOT_G := bootloader
$(__UBOOT_N)_REPO_DIR := $(CONFIG_UBOOT_REPO_PATH)

$(__UBOOT_N)_BUILD_DEPENDENT_PACKAGES := dtc

ifeq ($(CONFIG_UBOOT_BUILD_IN_TMPFS),y)
__UBOOT_BUILD_IN_TMPFS=/tempfs
endif

ifneq ($(CONFIG_UBOOT_RAW_SRC),y)
$(__UBOOT_N)_SRC_DIR := $(join $(SDK_BUILD_DIR)$(__UBOOT_BUILD_IN_TMPFS)/$(__UBOOT_G)/$(__UBOOT_N), $(CONFIG_BOARD_SUBFIX))
else
$(__UBOOT_N)_SRC_DIR := $(CONFIG_UBOOT_SRC_PATH)
endif

$(__UBOOT_N)_INSTALL_DIR := $(join $(SDK_OUTPUT_DIR)/$(__UBOOT_G)/$(__UBOOT_N), $(CONFIG_BOARD_SUBFIX))

#please don't use any " " in the path
$(__UBOOT_N)_SRC_DIR := $(strip $($(__UBOOT_N)_SRC_DIR))
$(__UBOOT_N)_INSTALL_DIR := $(strip $($(__UBOOT_N)_INSTALL_DIR))

__$(__UBOOT_N)_fetch:
	@$(call fetch_remote, $($(__UBOOT_N)_REPO_DIR), \
				$(CONFIG_UBOOT_GIT_REMOTE))
#==============================================================================
# Build the U-Boot for some board.
#==============================================================================

$(__UBOOT_N)_BIN_PATH=$($(__UBOOT_N)_INSTALL_DIR)/u-boot.bin
$(__UBOOT_N)_DTB_PATH=$($(__UBOOT_N)_INSTALL_DIR)/u-boot.dtb

__$(__UBOOT_N)_checkout:
ifneq ($(CONFIG_UBOOT_RAW_SRC),y)
	$(call checkout_src_full, $($(__UBOOT_N)_REPO_DIR),\
				  $(CONFIG_UBOOT_GIT_REMOTE) \
				  $(CONFIG_UBOOT_GIT_RBRANCH), \
				  $(CONFIG_UBOOT_GIT_LBRANCH), \
				  $($(__UBOOT_N)_SRC_DIR),) && echo Success!
else
	@echo "IN RAW SOUCE mode:the src is in $($(__UBOOT_N)_SRC_DIR)" 
endif

__$(__UBOOT_N)_devel:
	$(call devel_init, $($(__UBOOT_N)_SRC_DIR))

__$(__UBOOT_N)_defconfig:
	$(call build_target, $($(__UBOOT_N)_SRC_DIR), \
			      $(BUILD_ENV), \
			      $(CONFIG_UBOOT_BUILD_TARGET)_defconfig)

__$(__UBOOT_N)_menuconfig:
	$(call build_target, $($(__UBOOT_N)_SRC_DIR), \
			      $(BUILD_ENV), \
			      menuconfig)

__$(__UBOOT_N)_mkdefconfig:
	$(call build_target, $($(__UBOOT_N)_SRC_DIR), \
			      $(BUILD_ENV), \
			      savedefconfig)

__$(__UBOOT_N)_build_dtb:
	$(call build_target, $($(__UBOOT_N)_SRC_DIR), \
			      $(BUILD_ENV), \
			      u-boot.dtb)

__$(__UBOOT_N)_install_dtb:
	$(call install_bin, \
		$($(__UBOOT_N)_SRC_DIR)/u-boot.dtb, \
		$($(__UBOOT_N)_INSTALL_DIR))

__$(__UBOOT_N)_build:
	$(call build_target_log, $($(__UBOOT_N)_SRC_DIR), \
				  $(BUILD_ENV), \
				  u-boot.bin u-boot.dtb)

__$(__UBOOT_N)_build_with_spl:
	$(call build_target_log, $($(__UBOOT_N)_SRC_DIR), \
				  $(BUILD_ENV), \
				  u-boot-with-spl.bin)

__$(__UBOOT_N)_build_tools:
	$(call build_target_log, $($(__UBOOT_N)_SRC_DIR), \
				  $(BUILD_ENV), \
				  tools)

__$(__UBOOT_N)_clean:
	$(call build_target, $($(__UBOOT_N)_SRC_DIR), \
			       $(BUILD_ENV), \
			       clean)

__$(__UBOOT_N)_install:
	$(call install_bin, \
		$($(__UBOOT_N)_SRC_DIR)/u-boot*, \
		$($(__UBOOT_N)_INSTALL_DIR))

__$(__UBOOT_N)_all: __$(__UBOOT_N)_checkout __$(__UBOOT_N)_defconfig __$(__UBOOT_N)_menuconfig __$(__UBOOT_N)_build __$(__UBOOT_N)_install
# _board_opensbi_checkout _board_opensbi_build _board_opensbi_install

