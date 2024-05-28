# -*- coding:utf-8 -*-
#keep all the variables in the files of this dir to make this file simple
SDK_MK_ENV_DIR := $(SDK_MK_DIR)/env
include $(SDK_MK_ENV_DIR)/main.mk

#including mk file in other dirs
#we use */main.mk to include other mk files in the dir, in casue there is some
#order issue among mk files
## Components 
## the board specific mk file or *-generic.mk will include the component's *.mk
## main.mk has been abendoned
##include $(SDK_MK_COMPONENTS_DIR)/main.mk

ifneq ($(CONFIG_BOARD_NAME),"")
-include $(__SDK_MK_BOARD_DIR)/main.mk
else
$(warning Missing vendor/board configuration, please run 'make tekka_setup' first!)
endif

## distros
#include $(SDK_MK_DISTROS_DIR)/main.mk

