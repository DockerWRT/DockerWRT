PROXY ?=
ifeq ($(PROXY),)
	PROXY_SETTING :=  
else
	PROXY_SETTING := export all_proxy=$(PROXY) && export http_proxy=$(PROXY) && export https_proxy=$(PROXY) &&
endif
OPENWRT_URL := https://github.com/openwrt/openwrt.git
OPENWRT_PATH := openwrt-src
OPENWRT_BACKUP := openwrt-backup

TAG ?= master

TARGET := x86_64

JOBS := -j4

VISUAL := "V=99"

all: clean openwrt

feeds:
	$(PROXY_SETTING) cd $(OPENWRT_PATH) && ./scripts/feeds update -a && ./scripts/feeds install -a

toolchain: openwrt-src config
	$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL) toolchain/install

openwrt: openwrt-src feeds config
	$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL)
config:
	cd $(OPENWRT_PATH) && cp ../products/$(TARGET).config .config

openwrt-src:
	if [ ! -d "$(OPENWRT_PATH)" ]; then \
		git clone $(OPENWRT_URL) $(OPENWRT_PATH); \
		cd $(OPENWRT_PATH) && git checkout $(TAG) && git checkout -b $(TAG); \
	else \
		echo "######## no need to pull"; \
	fi

clean:
	cd $(OPENWRT_PATH) && $(MAKE) clean

.PHONY: openwrt	feeds toolchain config openwrt-src
