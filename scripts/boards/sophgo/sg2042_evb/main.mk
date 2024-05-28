
include $(__SDK_MK_BOARD_DIR)/firmware.mk
include $(SDK_MK_COMPONENTS_DIR)/u-boot_generic.mk
include $(SDK_MK_COMPONENTS_DIR)/linux_generic.mk
include $(SDK_MK_COMPONENTS_DIR)/grub_generic.mk
#include $(__SDK_MK_BOARD_DIR)/image.mk

#$(__SDK_BUILD_TARGET_PREFIX)_all:
#	@_EXISTED_DIR=''; \
#	if [ -d $(_BOARD_OPENSBI_SRC_DIR) ]; then \
#		_EXISTED_DIR+=$(_BOARD_OPENSBI_SRC_DIR); \
#		_EXISTED_DIR+="\n"; \
#	fi; \
#	if [ -d $(_BOARD_UBOOT_SRC_DIR) ]; then \
#		_EXISTED_DIR+=$(_BOARD_UBOOT_SRC_DIR); \
#		_EXISTED_DIR+="\n"; \
#	fi; \
#	if [ -d $(_BOARD_LINUX_SRC_DIR) ]; then \
#		_EXISTED_DIR+=$(_BOARD_LINUX_SRC_DIR); \
#		_EXISTED_DIR+="\n"; \
#	fi; \
#	if [ "X$$_EXISTED_DIR" != "X" ]; then \
#		whiptail \
#		--title "!!!Warning: Work dir will be OVERWRITED!!!" \
#		--yesno "Work dir existed: $${_EXISTED_DIR} \n\
#		\nDo you really want to OVERWRITED it/them?\
#		\nPlease make sure that you have backed up your work!" \
#		20 60 || exit 0;\
#	fi; \
#	make sophgo_sg2042_evb_all_silent

#$(__SDK_BUILD_TARGET_PREFIX)_silent: $(__SDK_BUILD_TARGET_PREFIX)_uboot_all_silent $(__SDK_BUILD_TARGET_PREFIX)_linux_all_silent $(__SDK_BUILD_TARGET_PREFIX)_fit
