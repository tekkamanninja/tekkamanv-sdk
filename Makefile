# -*- coding:utf-8 -*-
## make sure we are using bash for "make"
SHELL := /bin/bash
#DEBUG_BUILD=y
#Get the current dir path of this Makefile without '/'
__CUR_MK_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SDK_INSTALL_DIR := $(__CUR_MK_DIR:/=)

SDK_MK_DIR=$(SDK_INSTALL_DIR)/scripts
#basic helper calls and all the other main.mk files 
include $(SDK_MK_DIR)/Rlue.mk

# some other targets
include $(SDK_MK_DIR)/common.mk
#for debugging sdk scripts
#include $(SDK_MK_DIR)/sdk_debug.mk

PHONY += FORCE
FORCE:

# Declare the contents of the .PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)
