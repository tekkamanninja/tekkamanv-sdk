# -*- coding:utf-8 -*-
define devel_init
	pushd $(1); ctags -R .;\
	if [ ! -d .git ] ; then \
		echo $(1) is NOT a git repo, init git info. ;\
		git init; git add .; git commit -m "init" ;\
	else \
		echo $(1) is already a git repo. ;\
	fi; \
	popd
endef

#$(1) config file path
#$(2) template file path
#$(3) dest file path
define config_file_gen
	cp $(2) $(3); \
	egrep -v '^#' $(1) | \
	while read LN; do \
		KEY=$$(echo $$LN | sed -e 's/^\s*//g' -e 's/\s*$$//g' | tr '=' ' ' | awk '{printf $$1}'); \
		VALUE=$$(echo $$LN  | sed -e 's/^\s*//g' -e 's/\s*$$//g' | tr '=' ' ' | awk '{printf $$2}'); \
		sed -i -e "s*@@$${KEY}@@*$${VALUE}*g" $(3); \
	done
endef

#mk_%:
#	vim $(MAKEFILE_DIR)/$*.mk

