# -*- coding:utf-8 -*-
##CONFIG_OVERWRITED_CHK

define checkout_src
	rm -rf $(2); mkdir -p $(2);\
	pushd $(1);\
	echo Checking out branch: $(3) from $(1) to $(2);\
	if [ -f .gitattributes ] ; then \
		echo You may lose something because of .gitattributes in the worktree;\
	fi; \
	git archive --format=tar --worktree-attributes $(3) | (cd $(2) && tar xf -);\
	popd
endef

#$(1) repo
#$(2) remote _ brach
#$(3) local brach
#$(4) des_dir
#$(5) update remote or not
define checkout_src_full
	if [ -d $(4) ] && [ "X$(CONFIG_OVERWRITED_CHK)" = "Xy" ] ; then \
		whiptail \
		--title "!!!Warning: Work dir will be OVERWRITED!!!" \
		--yesno "Work dir existed: $(4) \n\
		\nDo you really want to OVERWRITED it?\n\
		\nPlease make sure that you have backed up your work!" \
		20 60 || exit 0;\
	fi;\
	if [ -n "$(strip $2)" ] ; then \
		REMOTE=$(shell echo $2 | awk  '{print $$1}'); \
		BRANCH=$(shell echo $2 | awk  '{print $$2}'); \
		if [ "X$(strip $5)" = "XY" ] ; then \
			$(call fetch_remote, $1, $$REMOTE) ;\
		fi; \
		if [ -z $$BRANCH ] ; then \
			BRANCH=master ;\
		fi; \
		echo Using remote branch: $$REMOTE/$$BRANCH;\
		$(call checkout_src, $1, $4, $$REMOTE/$$BRANCH) ;\
	else if [ -n "$(strip $3)" ] ; then \
		echo Using local branch: $3;\
		$(call checkout_src, $1, $4, $3) ;\
	else \
		echo source install error! ;\
		exit 1;\
	fi; fi
endef

define checkout_submodules
	pushd $(1);\
	git submodule foreach 'git archive --format=tar $(3) | \
	(mkdir ${2}/$$path && cd ${2}/$$path && tar xf -)';\
	popd
endef

#$(1) repo
#$(2) submodule path
#$(3) remote _ brach
#$(4) local brach
#$(5) des_dir
#$(6) update remote or not
define checkout_submodule_full
	$(call checkout_src_full, $(join $(1)/, $(2)), \
				  $(3), $(4), \
				  $(join $(5)/, $(2)), $(6))
endef

