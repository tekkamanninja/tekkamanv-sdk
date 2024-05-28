# -*- coding:utf-8 -*-
__LINUX_N := linux
__LINUX_G := kernel
$(__LINUX_N)_REPO_DIR := $(CONFIG_LINUX_REPO_PATH)

$(__LINUX_N)_BUILD_DEPENDENT_PACKAGES := 

ifeq ($(CONFIG_LINUX_INSTALL_SUDO),y)
__INSTALL_SUDO := sudo
endif

ifeq ($(CONFIG_LINUX_BUILD_IN_TMPFS),y)
__LINUX_BUILD_IN_TMPFS := /tempfs
endif

ifneq ($(CONFIG_LINUX_RAW_SRC),y)
$(__LINUX_N)_SRC_DIR := $(join $(SDK_BUILD_DIR)$(__LINUX_BUILD_IN_TMPFS)/$(__LINUX_G)/$(__LINUX_N), $(CONFIG_BOARD_SUBFIX))
else
$(__LINUX_N)_SRC_DIR := $(CONFIG_UBOOT_SRC_PATH)
endif

$(__LINUX_N)_INSTALL_DIR := $(join $(SDK_OUTPUT_DIR)/$(__LINUX_G)/$(__LINUX_N), $(CONFIG_BOARD_SUBFIX))

#please don't use any " " in the path
$(__LINUX_N)_SRC_DIR := $(strip $($(__LINUX_N)_SRC_DIR))
$(__LINUX_N)_INSTALL_DIR := $(strip $($(__LINUX_N)_INSTALL_DIR))

__$(__LINUX_N)_fetch:
	@$(call fetch_remote, $($(__LINUX_N)_REPO_DIR), \
				$(CONFIG_LINUX_GIT_REMOTE))
#==============================================================================
# Build the Linux kernel for some board.
#==============================================================================
#$(1) linux src dir
#$(2) build_env
#$(3) config file list
define linux_merge_config
	cd $(1); $(2) scripts/kconfig/merge_config.sh $(3); cd -
endef

# We provide 
#1, *defconfig
#2, merge_config
#3, .config
#4, defconfig
#$(1) linux src dir
#$(2) build_env
#$(3) *defconfig string
#$(4) config file list
#$(5) .config path
define linux_defconfig
	if [ -n "$(strip $3)" ] ; then \
		$(call build_target, $(1), $2, $3);\
	else if [ -n "$(strip $4)" ] ; then \
		$(call linux_merge_config, $1, $2, $4); \
	else if [ -f "$5" ] ; then \
		cp $5 $(strip $(1))/.config; \
	else \
		echo default configs are not found, try "defconfig" ! ;\
		$(call build_target, $(1), $2, defconfig);\
	fi; fi; fi
endef

#$(1) linux src dir
#$(2) build_env
#$(3) des rootfs
define linux_install_modules
	pushd $(1);\
	$(__INSTALL_SUDO) $(2) $(MAKE) \
		$(join INSTALL_MOD_PATH=, $(3)/) \
		modules_install;\
	popd; sync
endef

#$(1) linux src dir
#$(2) build_env
#$(3) des rootfs
define linux_install_zimage
	mkdir -p $(3); \
	pushd $(1);\
	$(__INSTALL_SUDO)  $(2) $(MAKE) \
		$(join INSTALL_PATH=, $(3)/) \
		zinstall;\
	popd; sync
endef

#$(1) linux src dir
#$(2) build_env
#$(3) des rootfs
define linux_install_image
	mkdir -p $(3); \
	pushd $(1);\
	$(__INSTALL_SUDO)  $(2) $(MAKE) \
		$(join INSTALL_PATH=, $(3)/) \
		install;\
	popd; sync
endef

#$(1) linux src dir
#$(2) build_env
#$(3) des rootfs
#$(4) Image patch
define linux_install_all
	$(call install_bin, $(join $(1), $4), $(join $(3), /boot));\
	$(call linux_install_modules, $(1), $(2), $(3))
endef


#$(1) linux src dir
#$(2) build_env
#$(3) des rootfs
#$(4) kernel version string
define linux_install_dtbs
	mkdir -p $(3); \
	pushd $(1);\
	$(__INSTALL_SUDO) $(2) $(MAKE) \
		$(join INSTALL_DTBS_PATH=, $(3)/dtb$(4)) \
		dtbs_install;\
	popd; sync
endef

#$(1) src_path
#$(2) build_env

#$(3) remote and branch
#$(4) local brach/tag

#$(5) patchset directory(from git format-patch)

#$(6) *defconfig string
#$(7) config file list
#$(8) .config path

#$(9) binary to des-dir/boot
#$(10) install des-dir

#DON'T use "-j" for building
#work dir break
define build_linux
	whiptail \
	$(LINUX_WHIPTAIL_TITLE) \
	--yesno "Source: \n$1\n\n\
	Build ENV: \n$2 \n\n\
	make cmd: $(MAKE) \n\n\
	Branch (remote): $3\n\
	Branch  (local): $4\n\n\
	Git patchset: \n$5\n\n\
	Default config: $6\n\
	config files: \n$7\n\n\
	.config file: $8\n\n\
	Kernel binary: $9\n\n\
	target rootfs: \n$(10)\n\n\
	\nAre you sure to do this?" \
	40 80 || exit 1

	$(call checkout_src_full, $($(__LINUX_N)_REPO_DIR), $3, $4, $1);\
	$(call patch_src_git, $1, $5);\
	$(call linux_defconfig, $1, $2, $6, $7, $8);\
	$(call build_target, $1, $2, menuconfig);\
	$(call build_target_log, $1, $2, $(_LINUX_TARGET));\
	if [ -n "$(10)" ] ; then \
		__ROOTFS=$(10); \
	else \
		__ROOTFS=$(join $(SDK_OUTPUT_DIR), /$(notdir $(1)));\
	fi; \
	$(call linux_install_all, $1, $2, $$__ROOTFS, $9)
endef

#$(1) Path of Image
#$(2) linux src dir(built)
#$(3) Kernel Image path
#$(4) Image install subfix
#$(5) build_env
define update_image_linux
	whiptail \
	$(LINUX_WHIPTAIL_TITLE) \
	--yesno "Image file: \n$(1)\n\n\
	Source: \n$2\n\n\
	Image : $3\n\n\
	Des Image subfix : $4\n\
	Build ENV: \n$5\n\n\
	\nAre you sure to do this?" \
	40 80 || exit 1

	pushd  $(dir $(1)); mkdir -p boot rootfs;\
	sudo qemu-nbd -f raw --connect $(CONFIG_NDB_DEV) $(shell basename $(1)) \
	BOOT_NDB_DEV=$(CONFIG_NDB_DEV)p2; \
	ROOT_NDB_DEV=$(CONFIG_NDB_DEV)p3; \
	sudo mount /dev/mapper/$${BOOT_NDB_DEV} boot; \
	sudo mount /dev/mapper/$${ROOT_NDB_DEV} rootfs; \
	sudo cp -f $(join $(2)/, $(3)) boot/$(join $(notdir $(3)), $(4));\
	tree --timefmt "%Y/%m/%d %H:%M:%S" boot; \
	sync; sleep 3; \
	sudo rm -rf mnt/lib/modules/*; \
	$(call linux_install_modules, $(2), $(5), $(dir $(1))/rootfs); \
	tree --timefmt "%Y/%m/%d %H:%M:%S" rootfs/lib/modules/; \
	sync; sleep 3; \
	sudo umount ./boot; \
	sudo umount ./rootfs; \
	rm -rf boot rootfs; \
	sudo qemu-nbd --disconnect $(CONFIG_NDB_DEV)
endef


#==============================================================================
# Build the test Linux kernel.
#==============================================================================
linux_build_deps_install:
	sudo $(PKG_CMD) install $(LINUX_DEPENDENT_PACKAGES)

#linux_clean:
#	@$(call build_target, $(join $(LINUX_SRC_DIR), $(_LINUX_SRC_SUFFIX)),, \
#			      mrproper clean)

__$(__LINUX_N)_checkout:
	@$(call checkout_src_full, $($(__LINUX_N)_REPO_DIR),\
				  $(CONFIG_LINUX_GIT_REMOTE) \
				  $(CONFIG_LINUX_GIT_RBRANCH), \
				  $(CONFIG_LINUX_GIT_LBRANCH), \
				  $($(__LINUX_N)_SRC_DIR),)

__$(__LINUX_N)_devel:
	$(call devel_init, $($(__LINUX_N)_SRC_DIR))

__$(__LINUX_N)_defconfig:
	$(call build_target, $($(__LINUX_N)_SRC_DIR), \
			      $(BUILD_ENV), \
			      $(shell echo $(CONFIG_LINUX_BUILD_TARGET))defconfig)

__$(__LINUX_N)_menuconfig:
	$(call build_target, $($(__LINUX_N)_SRC_DIR), \
			      $(BUILD_ENV), \
			      menuconfig)

__$(__LINUX_N)_mkdefconfig:
	$(call build_target, $($(__LINUX_N)_SRC_DIR), \
			      $(BUILD_ENV), \
			      savedefconfig)

__$(__LINUX_N)_build_dtbs:
	$(call build_target, $($(__LINUX_N)_SRC_DIR), \
			      $(BUILD_ENV), \
			      dtbs)

__$(__LINUX_N)_install_dtbs:
	$(call linux_install_dtbs, \
		$($(__LINUX_N)_SRC_DIR), \
		$(BUILD_ENV), \
		$($(__LINUX_N)_INSTALL_DIR)/boot)

__$(__LINUX_N)_build_all:
	$(call build_target_log, $($(__LINUX_N)_SRC_DIR), \
				  $(BUILD_ENV),)

__$(__LINUX_N)_build_rpm:
	$(call build_target_log, $($(__LINUX_N)_SRC_DIR), \
				  $(BUILD_ENV), rpm-pkg)
	echo "please check /tmp/rpmbuild/ for results"

__$(__LINUX_N)_clean:
	$(call build_target, $($(__LINUX_N)_SRC_DIR), \
			       $(BUILD_ENV), \
			       clean)

__$(__LINUX_N)_install_zimage:
	$(call linux_install_zimage, \
		$($(__LINUX_N)_SRC_DIR), \
		$(BUILD_ENV), \
		$($(__LINUX_N)_INSTALL_DIR)/boot)

__$(__LINUX_N)_install_image:
	$(call linux_install_image, \
		$($(__LINUX_N)_SRC_DIR), \
		$(BUILD_ENV), \
		$($(__LINUX_N)_INSTALL_DIR)/boot)

__$(__LINUX_N)_install_modules:
	$(call linux_install_modules, \
		$($(__LINUX_N)_SRC_DIR), \
		$(BUILD_ENV), \
		$($(__LINUX_N)_INSTALL_DIR))

__$(__LINUX_N)_install_all: __$(__LINUX_N)_install_zimage __$(__LINUX_N)_install_modules __$(__LINUX_N)_install_dtbs

__$(__LINUX_N)_all: __$(__LINUX_N)_checkout __$(__LINUX_N)_defconfig __$(__LINUX_N)_menuconfig __$(__LINUX_N)_build_all __$(__LINUX_N)_install_all

__$(__LINUX_N)_deploy:
	$(call linux_install_modules, \
		$($(__LINUX_N)_SRC_DIR), \
		$(BUILD_ENV), \
		$(CONFIG_ROOT_PATH))
	$(call linux_install_zimage, \
		$($(__LINUX_N)_SRC_DIR), \
		$(BUILD_ENV), \
		$(CONFIG_BOOT_PATH))
	$(call linux_install_dtbs, \
		$($(__LINUX_N)_SRC_DIR), \
		$(BUILD_ENV), \
		$(CONFIG_BOOT_PATH))

sdk_linux_mk:
	@vim $(SDK_MK_COMPONENTS_DIR)/$(__LINUX_N).mk

