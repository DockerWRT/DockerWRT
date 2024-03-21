PROXY ?=
ifeq ($(PROXY),)
    PROXY_SETTING :=  
else
    PROXY_SETTING := export all_proxy=$(PROXY) && export http_proxy=$(PROXY) && export https_proxy=$(PROXY) && 
endif

OPENWRT_URL := https://github.com/openwrt/openwrt.git
TARGET ?= x86_64
TAG ?= v23.05.2
JOBS ?= -j4
VISUAL ?= V=99

OPENWRT_PATH := openwrt_$(TARGET)_$(TAG)

all: openwrt

openwrt-src:
	if [ ! -d "$(OPENWRT_PATH)" ]; then \
		$(PROXY_SETTING) git clone $(OPENWRT_URL) $(OPENWRT_PATH); \
		cd $(OPENWRT_PATH) && git checkout $(TAG) && git checkout -b $(TAG); \
	fi

feeds: openwrt-src
	if [ ! -d $(OPENWRT_PATH)/feeds ]; then \
		cd $(OPENWRT_PATH) && ./scripts/feeds update -a && ./scripts/feeds install -a; \
	fi

config: openwrt-src
	if [ ! -f $(OPENWRT_PATH)/.config ]; then \
		cd $(OPENWRT_PATH) && cp ../products/$(TARGET)/$(TAG)/.config .config; \
	fi

openwrt: openwrt-src feeds config
	if [ -f $(OPENWRT_PATH)/.config ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL); \
	fi

clean:
	if [ -d $(OPENWRT_PATH) ]; then \
		cd $(OPENWRT_PATH) && $(MAKE) clean; \
	fi

distclean:
	if [ -d $(OPENWRT_PATH) ]; then \
		cd $(OPENWRT_PATH) && $(MAKE) distclean; \
	fi

toolchain: openwrt-src feeds config
	if [ -f $(OPENWRT_PATH)/.config ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL) toolchain/install; \
	fi

.PHONY: all openwrt openwrt-src feeds config clean distclean toolchain

