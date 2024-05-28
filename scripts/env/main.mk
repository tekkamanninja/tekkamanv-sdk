# -*- coding:utf-8 -*-
#Please be careful for the order of *.mk
include $(SDK_MK_ENV_DIR)/base.mk
include $(SDK_MK_ENV_DIR)/host.mk

#This must be included ealier for other mk file 
include $(SDK_MK_ENV_DIR)/config.mk

include $(SDK_MK_ENV_DIR)/toolchain.mk
include $(SDK_MK_ENV_DIR)/build_env.mk

#########################################
include $(SDK_MK_ENV_DIR)/fetch_func.mk

#
include $(SDK_MK_ENV_DIR)/checkout_func.mk
#
include $(SDK_MK_ENV_DIR)/build_func.mk

include $(SDK_MK_ENV_DIR)/install_func.mk
include $(SDK_MK_ENV_DIR)/misc_func.mk
#########################################

