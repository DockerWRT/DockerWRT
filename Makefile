PROXY ?=
ifeq ($(PROXY),)
    PROXY_SETTING :=  
else
    PROXY_SETTING := export all_proxy=$(PROXY) && export http_proxy=$(PROXY) && export https_proxy=$(PROXY) && 
endif

OPENWRT_URL := https://github.com/openwrt/openwrt.git
TARGET ?= "x86_64"
TAG ?= "v23.05.3"
JOBS ?= 
VISUAL ?= "V=99"
AUTO_SCRIPT ?= auto_menuconfig.sh

OPENWRT_PATH := openwrt_src

all: firmware

openwrt-src:
	if [ ! -d "$(OPENWRT_PATH)" ]; then \
		$(PROXY_SETTING) git clone $(OPENWRT_URL) $(OPENWRT_PATH); \
		cd $(OPENWRT_PATH) && git checkout $(TAG) && git checkout -b $(TAG); \
	fi

feeds: openwrt-src
	if [ ! -d $(OPENWRT_PATH)/feeds ]; then \
		cd $(OPENWRT_PATH) && ./scripts/feeds update -a && ./scripts/feeds install -a; \
	fi

config: feeds
	if [ ! -f $(OPENWRT_PATH)/.config ]; then \
		cd $(OPENWRT_PATH) && cp ../products/$(TARGET)/$(TAG)/.config .config && make defconfig; \
	fi

toolchain: config
	if [ -d "$(OPENWRT_PATH)" ] && [ -d $(OPENWRT_PATH)/feeds ] && [ -f $(OPENWRT_PATH)/.config ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL) toolchain/install; \
	fi

kernel: config
	if [ -d "$(OPENWRT_PATH)" ] && [ -d $(OPENWRT_PATH)/feeds ] && [ -f $(OPENWRT_PATH)/.config ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL) target/linux/compile; \
	fi

firmware: config
	if [ -d "$(OPENWRT_PATH)" ] && [ -d $(OPENWRT_PATH)/feeds ] && [ -f $(OPENWRT_PATH)/.config ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL) world; \
	fi

clean:
	if [ -d $(OPENWRT_PATH) ]; then \
		cd $(OPENWRT_PATH) && $(MAKE) clean; \
	fi

distclean:
	if [ -d $(OPENWRT_PATH) ]; then \
		cd $(OPENWRT_PATH) && $(MAKE) distclean; \
	fi

.PHONY: openwrt openwrt-src feeds config clean distclean toolchain kernel firmware all

