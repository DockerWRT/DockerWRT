.PHONY: all clean

PROXY ?=
ifeq ($(PROXY),)
	PROXY_SETTING :=  
else
	PROXY_SETTING := export all_proxy=$(PROXY) && export http_proxy=$(PROXY) && export https_proxy=$(PROXY) &&
endif
OPENWRT_URL := https://github.com/openwrt/openwrt.git
OPENWRT_PATH := openwrt-src

TAG ?= master

TARGET := x86_64

JOBS := -j4 V=99

all: openwrt

toolchain: openwrt-src config
	$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) toolchain/install

openwrt: openwrt-src config
	$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS)
config:
	cd $(OPENWRT_PATH) && cp ../products/$(TARGET).config .config

openwrt-src:
	git clone $(OPENWRT_URL) $(OPENWRT_PATH)
	cd $(OPENWRT_PATH) && git checkout $(TAG)

clean:
	cd $(OPENWRT_PATH) && $(MAKE) clean

.PHONY: openwrt	
