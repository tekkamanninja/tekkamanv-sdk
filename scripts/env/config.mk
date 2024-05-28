# -*- coding:utf-8 -*-
## main config file
MAIN_CONFIG := $(SDK_CONFIGS_DIR)/main.config
-include $(MAIN_CONFIG)

## load config file for a specific development board
CONFIG_FILE=$(SDK_BOARD_CONFIGS_DIR)/$(shell echo $(CONFIG_VENDOR_NAME))/$(shell echo $(CONFIG_CONFIG_FILE).config)
-include $(CONFIG_FILE)

__SDK_MK_VENDOR_DIR := $(SDK_MK_BOARDS_DIR)/$(shell echo $(CONFIG_VENDOR_NAME))
__SDK_MK_BOARD_DIR := $(__SDK_MK_VENDOR_DIR)/$(shell echo $(CONFIG_BOARD_NAME))
__SDK_BUILD_TARGET_PREFIX := $(shell echo $(CONFIG_VENDOR_NAME))_$(shell echo $(CONFIG_BOARD_NAME))

tekka_setup:
	export KCONFIG_CONFIG=$(MAIN_CONFIG); \
	export MENUCONFIG_STYLE="aquatic selection=fg:red,bg:green"; \
	$(SDK_KCONDIFLIB_DIR)/menuconfig.py $(SDK_MK_DIR)/Kconfig

$(__SDK_BUILD_TARGET_PREFIX)_config:
	mkdir -p $(SDK_BOARD_CONFIGS_DIR)/$(CONFIG_VENDOR_NAME); \
	export KCONFIG_CONFIG=$(CONFIG_FILE); \
	$(SDK_KCONDIFLIB_DIR)/menuconfig.py $(__SDK_MK_BOARD_DIR)/Kconfig
