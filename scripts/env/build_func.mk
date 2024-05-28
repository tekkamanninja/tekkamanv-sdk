# -*- coding:utf-8 -*-
##SDK_LOG_DIR
##SDK_BUILD_LOG
##SDK_ERROR_LOG
##CONFIG_SILENT_BUILD

#$(1) dir
#$(2) evn
#$(3) targets
define build_target
	pushd $(1);\
	$(2) $(MAKE) $(3);\
	popd
endef

define build_target_log
	LOG_DIR=$(join $(SDK_LOG_DIR)/,$(notdir $(shell echo $(1))));\
	BUILD_LOG=$(join $$LOG_DIR/,$(SDK_BUILD_LOG));\
	ERROR_LOG=$(join $$LOG_DIR/,$(SDK_ERROR_LOG));\
	__RESULT=0;\
	mkdir -p $$LOG_DIR;\
	pushd $(1);\
	$(2) $(MAKE) $(3) \
	1>$$BUILD_LOG \
	2>$$ERROR_LOG;\
	__RESULT=$$?;\
	if [ "X$(CONFIG_SILENT_BUILD)" != "Xy" ] ; then \
		whiptail \
		--title "Build Log" \
		--yesno "Build result: $$__RESULT \n\
		Buildlog: $$BUILD_LOG;\n\
		Errorlog: $$ERROR_LOG;\n\
		\nDo you want to check the logs?" \
		20 60 && vim $$BUILD_LOG $$ERROR_LOG;\
	fi;\
	echo ========================;\
	echo Buildresult: $$__RESULT;\
	echo Buildlog: $$BUILD_LOG;\
	echo Errorlog: $$ERROR_LOG;\
	echo ========================;\
	popd
endef

