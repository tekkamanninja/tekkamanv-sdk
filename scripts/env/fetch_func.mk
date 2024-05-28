# -*- coding:utf-8 -*-
define fetch_remote
	pushd $(1);\
	echo Fetching remote : $(2);\
	git fetch $(2);\
	popd
endef

define fetch_submodules
	pushd $(1);\
	git submodule foreach 'git fetch $(2)';\
	popd
endef

define fetch_submodule
	pushd $(join $(1)/, $(2));\
	git fetch $(3);\
	popd
endef
