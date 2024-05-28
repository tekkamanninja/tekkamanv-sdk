# -*- coding:utf-8 -*-
__GRUB_N := grub
__GRUB_G := bootloader
$(__GRUB_N)_REPO_DIR := $(CONFIG_GRUB_REPO_PATH)

$(__GRUB_N)_BUILD_DEPENDENT_PACKAGES := texinfo texlive texinfo-tex

#need efi compiler
ifeq ($(CONFIG_GRUB_WITH_CUSTOM_CROSS_COMPILE),y)
$(__GRUB_N)_BUILD_ENV := ARCH=$(CONFIG_ARCH) CROSS_COMPILE=$(CONFIG_GRUB_CUSTOM_CROSS_COMPILE)
$(__GRUB_N)_BUILD_ENV += PATH=$(CONFIG_GRUB_CUSTOM_CROSS_COMPILE_DIR):$${PATH}
endif

ifeq ($(CONFIG_GRUB_WITH_DEFAULT_CROSS_COMPILE),y)
$(__GRUB_N)_BUILD_ENV := $(BUILD_ENV)
endif

ifeq ($(CONFIG_GRUB_BUILD_IN_TMPFS),y)
__GRUB_BUILD_IN_TMPFS=/tempfs
endif

ifneq ($(CONFIG_GRUB_RAW_SRC),y)
$(__GRUB_N)_SRC_DIR := $(join $(SDK_BUILD_DIR)$(__GRUB_BUILD_IN_TMPFS)/$(__GRUB_G)/$(__GRUB_N), $(CONFIG_BOARD_SUBFIX))
else
$(__GRUB_N)_SRC_DIR := $(CONFIG_GRUB_SRC_PATH)
endif

$(__GRUB_N)_INSTALL_DIR := $(join $(SDK_OUTPUT_DIR)/$(__GRUB_G)/$(__GRUB_N), $(CONFIG_BOARD_SUBFIX))

#please don't use any " " in the path
$(__GRUB_N)_SRC_DIR := $(strip $($(__GRUB_N)_SRC_DIR))
$(__GRUB_N)_INSTALL_DIR := $(strip $($(__GRUB_N)_INSTALL_DIR))

###################GRUB functions####################
#$(1) src_path
#$(2) build_env
#$(3) build_config
#	rm -r $(GRUB_INSTALL_DIR);
define grub_config
	pushd $(1); \
	$(2) ./autogen.sh; \
	$(2) ./configure $(3) ; \
	popd
endef

define grub_bootstrap
	pushd $(1); \
	$(2) ./bootstrap; \
	popd
endef

#	sudo apt-get install texinfo texlive
#	sudo yum install $(GRUB_DEPENDENT_PACKAGES)
#$(1) src_path(not docs included)
GRUB_WHIPTAIL_TITLE=--title "tekkamanv_sdk GRUB2 Build System"
define build_grub_doc
	whiptail \
	$(GRUB_WHIPTAIL_TITLE) \
	--yesno "Are you sure you have finished config stage?" \
	8 80 || exit 1
	echo $($(__GRUB_N)_SRC_DIR)
	$(call build_target_log, $(join $(1), /docs),,pdf)
endef

#$(1) src_path
#$(2) binary name
#$(3) binary format
#$(4) more args
GRUB_MKSTANDALONE=./bin/grub-mkstandalone
define grub_mkimage_standalone
	pushd $(1); \
	$(GRUB_MKSTANDALONE) -v -o $(2) -O $(3) $4;\
	popd
endef

#$(1) src_path
#$(2) binary name
#$(3) binary format
#$(4) -p prefix
#$(5) more args
GRUB_MKIMAGE=./bin/grub-mkimage
define grub_mkimage
	pushd $(1); \
	$(GRUB_MKIMAGE) -v -o $(2) -O $(3) -p $4 $5;\
	popd
endef

#$(1) src_path
#$(2) build_env

#$(3) remote and branch
#$(4) local brach/tag

#$(5) patchset directory(from git format-patch)

#$(6) build config

#$(7) image binary name
#$(8) image binary format
#$(9) image prefix

#DON'T use "-j" for building
#work dir break
define build_grub
	whiptail \
	$(GRUB_WHIPTAIL_TITLE) \
	--yesno "Source: \n$1\n\n\
	Build ENV: \n$2 \n\n\
	make cmd: $(MAKE) \n\n\
	Branch (remote): $3\n\
	Branch  (local): $4\n\n\
	Git patchset: \n$5\n\n\
	Build config: \n$6\n\n\
	Image name: $7\n\n\
	Image format: $8\n\n\
	Image prefix: $9\n\n\
	More mkimage args: \n$(10)\n\n\
	\nAre you sure to do this?" \
	40 80 || exit 1

	$(call checkout_src_full, $(GRUB_REPO_DIR), $3, $4, $1);\
	$(call patch_src_git, $1, $5);\
	$(call grub_config, $1, $2, $6);\
	$(call build_target_log, $1, $2, install);\
	$(call grub_mkimage_standalone, $1, $7, $8, $9)
endef

#==============================================================================
# Build the GRUB2
#==============================================================================

__$(__GRUB_N)_fetch:
	@$(call fetch_remote, $($(__GRUB_N)_REPO_DIR), \
				$(CONFIG_GRUB_GIT_REMOTE))

$(__GRUB_N)_BIN_PATH=$($(__GRUB_N)_INSTALL_DIR)/

__$(__GRUB_N)_checkout:
ifneq ($(CONFIG_GRUB_RAW_SRC),y)
	$(call checkout_src_full, $($(__GRUB_N)_REPO_DIR),\
				  $(CONFIG_GRUB_GIT_REMOTE) \
				  $(CONFIG_GRUB_GIT_RBRANCH), \
				  $(CONFIG_GRUB_GIT_LBRANCH), \
				  $($(__GRUB_N)_SRC_DIR),) && echo Success!
else
	@echo "IN RAW SOUCE mode:the src is in $($(__GRUB_N)_SRC_DIR)" 
endif

__$(__GRUB_N)_devel:
	$(call devel_init, $($(__GRUB_N)_SRC_DIR))

__$(__GRUB_N)_clean:
	$(call build_target, \
		$($(__GRUB_N)_SRC_DIR), \
		$($(__GRUB_N)_BUILD_ENV), \
		clean)

# __$(__GRUB_N)_install:
# 	$(call install_bin, \
# 		$($(__GRUB_N)_SRC_DIR)/u-boot*, \
# 		$($(__GRUB_N)_INSTALL_DIR))

__$(__GRUB_N)_all: __$(__GRUB_N)_checkout __$(__GRUB_N)_config __$(__GRUB_N)_build __$(__GRUB_N)_doc __$(__GRUB_N)_mkimage_standalone
###################GRUB#####################
CONFIG_GRUB_BINARY_NAME=grubriscv64.efi
CONFIG_GRUB_BINARY_FORMAT=riscv64-efi
CONFIG_GRUB_PREFIX_DIR=$($(__GRUB_N)_INSTALL_DIR)

# GRUB_BUILD_CONFIG_ARMV8=--target=aarch64-linux-gnu --with-platform=efi --prefix=$($(__GRUB_N)_INSTALL_DIR)
# GRUB_BUILD_CONFIG_ARMV7=--target=arm-linux-gnueabihf --with-platform=efi --prefix=$($(__GRUB_N)_INSTALL_DIR)
CONFIG_GRUB_BUILD_CONFIG=--target=riscv64-linux-gnu --with-platform=efi --prefix=$($(__GRUB_N)_INSTALL_DIR)
# CONFIG_GRUB_UEFI_IMAGE_MODULES=boot chain configfile configfile efinet ext2 fat gettext help hfsplus loadenv lsefi normal normal ntfs ntfscomp part_gpt part_msdos part_msdos read search search_fs_file search_fs_uuid search_label terminal terminfo tftp linux hello
CONFIG_GRUB_UEFI_IMAGE_MODULES=acpi adler32 affs afs afsplitter all_video archelp bfs bitmap bitmap_scale blocklist bli boot bswap_test btrfs bufio cat cbfs chain cmdline_cat_test cmp cmp_test configfile cpio_be cpio crc64 cryptodisk crypto ctz_test datehook date datetime diskfilter disk div div_test dm_nv echo efifwsetup efi_gop efinet elf eval exfat exfctest ext2 extcmd f2fs fat fdt file font fshelp functional_test gcry_arcfour gcry_blowfish gcry_camellia gcry_cast5 gcry_crc gcry_des gcry_dsa gcry_idea gcry_md4 gcry_md5 gcry_rfc2268 gcry_rijndael gcry_rmd160 gcry_rsa gcry_seed gcry_serpent gcry_sha1 gcry_sha256 gcry_sha512 gcry_tiger gcry_twofish gcry_whirlpool geli gettext gfxmenu gfxterm_background gfxterm_menu gfxterm gptsync gzio halt hashsum hello help hexdump hfs hfspluscomp hfsplus http iso9660 jfs jpeg json keystatus ldm linux loadenv loopback lsacpi lsefimmap lsefi lsefisystab lsmmap ls lssal luks2 luks lvm lzopio macbless macho mdraid09_be mdraid09 mdraid1x memdisk memrw minicmd minix2_be minix2 minix3_be minix3 minix_be minix mmap mpi msdospart mul_test net newc nilfs2 normal ntfscomp ntfs odc offsetio part_acorn part_amiga part_apple part_bsd part_dfly part_dvh part_gpt part_msdos part_plan part_sun part_sunpc parttool password password_pbkdf2 pbkdf2 pbkdf2_test pgp png priority_queue probe procfs progress raid5rec raid6rec read reboot regexp reiserfs romfs scsi search_fs_file search_fs_uuid search_label search serial setjmp setjmp_test sfs shift_test signature_test sleep sleep_test smbios squash4 strtoull_test syslinuxcfg tar terminal terminfo test_blockarg testload test testspeed tftp tga time tpm trig tr true udf ufs1_be ufs1 ufs2 video_colors video_fb videoinfo video videotest_checksum videotest xfs xnu_uuid xnu_uuid_test xzio zfscrypt zfsinfo zfs zstd
CONFIG_GRUB_DEFAULT_CFG=$(SDK_PREBUILD_DIR)/GRUB/default_riscv64.cfg
#-c $(CONFIG_GRUB_DEFAULT_CFG)
CONFIG_GRUB_MKIMAGE_ARG=--config $(CONFIG_GRUB_DEFAULT_CFG) $(CONFIG_GRUB_UEFI_IMAGE_MODULES)

__$(__GRUB_N)_config:
	if [ -d $(CONFIG_GRUB_GNULIB_PATH) ] ; then \
		pushd $(CONFIG_GRUB_GNULIB_PATH); \
		git fetch origin; \
		popd ; \
		cp -rf  $(CONFIG_GRUB_GNULIB_PATH)  $($(__GRUB_N)_SRC_DIR)/gnulib; \
	fi
	@$(call grub_bootstrap, $($(__GRUB_N)_SRC_DIR), $($(__GRUB_N)_BUILD_ENV))
	@$(call grub_config, $($(__GRUB_N)_SRC_DIR), \
			    $($(__GRUB_N)_BUILD_ENV), $(CONFIG_GRUB_BUILD_CONFIG) --prefix=$($(__GRUB_N)_INSTALL_DIR))

__$(__GRUB_N)_doc:
	@$(call build_grub_doc, $($(__GRUB_N)_SRC_DIR))

__$(__GRUB_N)_build:
	$(call build_target_log, $($(__GRUB_N)_SRC_DIR), \
				 $($(__GRUB_N)_BUILD_ENV), install)

__$(__GRUB_N)_mkimage:
	$(call grub_mkimage, \
		$($(__GRUB_N)_INSTALL_DIR), \
		$(CONFIG_GRUB_BINARY_NAME), \
		$(CONFIG_GRUB_BINARY_FORMAT), \
		efi, \
		$(CONFIG_GRUB_MKIMAGE_ARG))

__$(__GRUB_N)_mkimage_standalone:
	$(call grub_mkimage_standalone, \
		$($(__GRUB_N)_INSTALL_DIR), \
		$(CONFIG_GRUB_BINARY_NAME), \
		$(CONFIG_GRUB_BINARY_FORMAT), \
		--modules="part_gpt part_msdos ext2 configfile fat linux echo" \
		boot/grub/grub.cfg=$(CONFIG_GRUB_DEFAULT_CFG))
#$(CONFIG_GRUB_MKIMAGE_ARG)
# __$(__GRUB_N)_all:
# 	@$(call build_grub, \
# 		$($(__GRUB_N)_INSTALL_DIR), \
# 		$($(__GRUB_N)_BUILD_ENV), \
# 		$(CONFIG_GRUB_GIT_REMOTE) \
# 		$(CONFIG_GRUB_GIT_RBRANCH), \
# 		$(CONFIG_GRUB_GIT_LBRANCH),, \
# 		$(CONFIG_GRUB_BUILD_CONFIG), \
# 		$(CONFIG_GRUB_BINARY_NAME), \
# 		$(CONFIG_GRUB_BINARY_FORMAT), \
# 		$(CONFIG_GRUB_MKIMAGE_ARG))

sdk_$(__GRUB_N)_mk:
	@vim $(MAKEFILE_DIR)/components/$(__GRUB_N).mk

sdk_$(__GRUB_N)_deps_install:
	@sudo dnf install $($(__GRUB_N)_BUILD_DEPENDENT_PACKAGES)
