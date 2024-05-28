# -*- coding:utf-8 -*-
## Host info
BUILD_HOST=$(shell uname -m)
#depend on redhat-lsb-core
BUILD_HOST_OS = $(shell lsb_release -i -s)
BUILD_HOST_CPU_N=$(shell nproc)
#BUILD_HOST_OS = $(shell lsb_release -i | awk '{print $3}')
#BUILD_HOST_CPU_N=$(shell grep 'processor' /proc/cpuinfo | sort -u | wc -l)

ifeq ($(BUILD_HOST_OS), Fedora)
PKG_CMD = yum
CONFIG_DEPENDENT_PACKAGES = whiptail
TOOLCHAIN_DEPENDENT_PACKAGES = 
ACPI_DEPENDENT_PACKAGES = acpica-tools
UEFI_DEPENDENT_PACKAGES = libuuid-devel
DTB_DEPENDENT_PACKAGES = dtc
LINUX_DEPENDENT_PACKAGES = ncurses-devel expect sparse
VALIDATION_DEPENDENT_PACKAGES = tmux
else
$(shell echo "Please run this on a Fedora/CentOS/RHELS/RHELSA")
endif
#lzop
#zlib-devel.i686 gcc-c++.i686
#	PKG_CMD = apt-get
#	TOOLCHAIN_DEPENDENT_PACKAGES = lib32z1 lib32ncurses5 lib32bz2-1.0 lib32stdc++6
#	ACPI_DEPENDENT_PACKAGES=acpica-tools
#	UEFI_DEPENDENT_PACKAGES=uuid-dev
#	DTB_DEPENDENT_PACKAGES=device-tree-compiler
#	LINUXKERNEL_DEPENDENT_PACKAGES=libncurses5-dev expect

#we may need this for debug build
#BUILD_HOST_CPU_N=2
