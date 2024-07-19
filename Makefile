PROXY ?=
ifeq ($(PROXY),)
    PROXY_SETTING :=  
else
    PROXY_SETTING := export all_proxy=$(PROXY) && export http_proxy=$(PROXY) && export https_proxy=$(PROXY) && 
endif

OPENWRT_URL := https://github.com/openwrt/openwrt.git
PRODUCT_TARGET ?= "x86_64"
TAG ?= "v23.05.2"
JOBS ?= 
VISUAL ?= "V=99"

OPENWRT_PATH := $(PWD)/src_$(PRODUCT_TARGET)
PRODUCT_VERSION := $(shell date +"%y%m%d%H%M%S")
OUTPUT_PATH := $(PWD)/output/$(TARGET)/$(PRODUCT_VERSION)

all: firmware

openwrt-src:
	if [ ! -d "$(OPENWRT_PATH)" ]; then \
		$(PROXY_SETTING) git clone $(OPENWRT_URL) $(OPENWRT_PATH); \
		cd $(OPENWRT_PATH) && git checkout $(TAG) && git checkout -b $(TAG); \
	fi

feeds: openwrt-src
	cd $(OPENWRT_PATH) && $(PROXY_SETTING) ./scripts/feeds update -a && $(PROXY_SETTING) ./scripts/feeds install -a; \

config: feeds
	if [ ! -f $(OPENWRT_PATH)/.config ]; then \
		cd $(OPENWRT_PATH) && cp ../products/$(TARGET)/$(TAG)/.config .config && make defconfig; \
	fi

toolchain: config
	if [ -d "$(OPENWRT_PATH)" ] && [ -d $(OPENWRT_PATH)/feeds ] && [ -f $(OPENWRT_PATH)/.config ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL) toolchain/install; \
	fi

kernel: config toolchain
	if [ -d "$(OPENWRT_PATH)" ] && [ -d $(OPENWRT_PATH)/feeds ] && [ -f $(OPENWRT_PATH)/.config ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL) target/linux/compile; \
	fi

docker: config kernel
	$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(VISUAL) package/docker/clean && $(MAKE) -j1 $(VISUAL) package/docker/compile;

firmware: config docker
	if [ -d "$(OPENWRT_PATH)" ] && [ -d $(OPENWRT_PATH)/feeds ] && [ -f $(OPENWRT_PATH)/.config ]; then \
		rm -rf $(OPENWRT_PATH)/bin/*; \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL) world && mkdir -p $(OUTPUT_PATH); \
		cd $(OPENWRT_PATH) && cp -r bin/targets/ $(OUTPUT_PATH)/; \
	fi

clean:
	if [ -d $(OPENWRT_PATH) ]; then \
		cd $(OPENWRT_PATH) && $(MAKE) clean; \
	fi

distclean:
	if [ -d $(OPENWRT_PATH) ]; then \
		rm -rf $(OPENWRT_PATH); \
	fi

.PHONY: openwrt openwrt-src feeds config clean distclean toolchain kernel firmware all

