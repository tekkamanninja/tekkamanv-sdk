# -*- coding:utf-8 -*-
#$(1) binary
#$(2) des_dir
#$(3) cp args
#$(4) rename
define install_bin
	install -d $(2);\
	cp $(3) $(1) $(2);\
	if [ -n "$(4)" ] ; then \
		mv $(2)/$(notdir $(1)) $(join $(2)/, $(4)) ;\
	fi;\
	sync;\
	tree --timefmt "%Y/%m/%d %H:%M:%S" $(2)
endef

#$(1) binaries list
#$(2) des_dir
#$(3) cp args
define install_bins
	install -d $(2); \
	for binary in $(1); do \
		cp $(3) $$binary $(2); \
	done; \
	sync; \
	tree --timefmt "%Y/%m/%d %H:%M:%S" $(2)
endef

