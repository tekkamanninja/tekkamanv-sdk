# -*- coding:utf-8 -*-
## build env
ifeq ($(BUILD_HOST),$(CONFIG_TARGET_ARCH))
	BUILD_ENV :=
else
	BUILD_ENV := $(CROSS_COMPILE_ENV)
endif

ifneq ($(DEBUG_BUILD), y)
	MAKE += -j$(BUILD_HOST_CPU_N)
endif

SUFFIX_RV64 := '_rv64'
SUBFIX_DEFAULT := '_tekkamanv'

SDK_TIMESTAMP_TEMPLATE_1 := $(shell date +%Y%m%d%H%M%S)
SDK_BUILD_LOG := build-$(SDK_TIMESTAMP_TEMPLATE_1).log
SDK_ERROR_LOG := error-$(SDK_TIMESTAMP_TEMPLATE_1).log

SDK_DEPENDENT_PACKAGES := terminix tmux redhat-lsb-core
SDK_DEFAULT_TERMINAL := tmux new-window
