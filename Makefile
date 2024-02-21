.PHONY: all clean

PROXY ?=
ifeq ($(PROXY),)
	PROXY_SETTING :=  
else
	PROXY_SETTING := export all_proxy=$(PROXY) && export http_proxy=$(PROXY) && export https_proxy=$(PROXY) &&
endif
OPENWRT_URL := https://github.com/openwrt/openwrt.git
OPENWRT_BRANCH := master

TARGET := x86_64

JOBS := -j4 V=99

all: openwrt

toolchain: openwrt-src config
	$(PROXY_SETTING) cd openwrt-src && $(MAKE) $(JOBS) toolchain/install

openwrt: openwrt-src config
	$(PROXY_SETTING) cd openwrt-src && $(MAKE) $(JOBS)
config:
	cd openwrt-src && cp ../products/$(TARGET).config .config

openwrt-src:
	git clone --branch $(OPENWRT_BRANCH) $(OPENWRT_URL) openwrt-src

clean:
	cd openwrt-src && $(MAKE) clean

.PHONY: openwrt	
