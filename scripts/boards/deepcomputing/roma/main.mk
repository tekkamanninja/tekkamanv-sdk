include $(SDK_MK_COMPONENTS_DIR)/linux_generic.mk

$(__SDK_BUILD_TARGET_PREFIX)_$(__LINUX_N)_deploy:
	sudo cp -rf $($(__LINUX_N)_INSTALL_DIR)/boot/* \
	$(CONFIG_LINUX_INSTALL_PATH)/
	sudo cp -rf $($(__LINUX_N)_INSTALL_DIR)/lib/modules/* \
	$(CONFIG_LINUX_INSTALL_MOD_PATH)/lib/modules/
	sync
	date

include $(__SDK_MK_BOARD_DIR)/firmware.mk
include $(__SDK_MK_BOARD_DIR)/image.mk
