# Copyright(c) 2012-2018 Intel Corporation
# SPDX-License-Identifier: BSD-3-Clause-Clear

SHELL := /bin/bash
.DEFAULT_GOAL := all
CMAKE_FILE=CMakeLists.txt

OPT_DIR=/opt/octf

ifdef DEBUG
	BUILD_DIR=build/debug
	BUILD_TYPE=DEBUG
	ifndef PREFIX
		PREFIX=./rootfs
	endif
else
	BUILD_DIR=build/release
	BUILD_TYPE=RELEASE
	ifndef PREFIX
		PREFIX=/
	endif
endif

ifneq ("$(wildcard $(OPT_DIR)/cmake/bin/cmake)","")
	# Found our installation of cmake in opt dir
	CMAKE=$(OPT_DIR)/cmake/bin/cmake
else
	CMAKE=cmake
endif

SOURCE_PATH:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: init all clean

init:
	mkdir -p $(BUILD_DIR)

all: init
	cd $(BUILD_DIR) && $(CMAKE) $(SOURCE_PATH) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_INSTALL_PREFIX=$(PREFIX)
	$(MAKE) -C $(BUILD_DIR) all

install: all
	$(MAKE) uninstall
	$(CMAKE) -DCOMPONENT=octf-install -P $(BUILD_DIR)/cmake_install.cmake
	$(CMAKE) -DCOMPONENT=octf-post-install -P $(BUILD_DIR)/cmake_install.cmake
	$(CMAKE) -DCOMPONENT=iotrace-install -P $(BUILD_DIR)/cmake_install.cmake
	$(CMAKE) -DCOMPONENT=iotrace-post-install -P $(BUILD_DIR)/cmake_install.cmake


uninstall: init
	cd $(BUILD_DIR) && $(CMAKE) $(SOURCE_PATH) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_INSTALL_PREFIX=$(PREFIX)
	$(MAKE) -C $(BUILD_DIR) iotrace-uninstall
	$(MAKE) -C $(BUILD_DIR) octf-uninstall

uninstall-tracer: init
	cd $(BUILD_DIR) && $(CMAKE) $(SOURCE_PATH) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_INSTALL_PREFIX=$(PREFIX)
	$(MAKE) -C $(BUILD_DIR) iotrace-uninstall

test:

clean:
	$(info Cleaning $(BUILD_DIR))
	@if [ -d $(BUILD_DIR) ] ; \
	then \
		$(MAKE) -C $(BUILD_DIR) clean ; \
		$(MAKE) -C $(BUILD_DIR) clean-module ; \
		rm -rf $(BUILD_DIR) ; \
	fi
