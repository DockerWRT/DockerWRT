PROXY ?=
ifeq ($(PROXY),)
	PROXY_SETTING :=  
else
	PROXY_SETTING := export all_proxy=$(PROXY) && export http_proxy=$(PROXY) && export https_proxy=$(PROXY) &&
endif
OPENWRT_URL := https://github.com/openwrt/openwrt.git
OPENWRT_PATH := openwrt-src
OPENWRT_BACKUP := openwrt-backup

TARGET ?= x86_64
BRANCH ?= openwrt-23.05
JOBS ?= -j4
VISUAL ?= "V=99"

all: clean openwrt

openwrt-src:
	if [ ! -d "$(OPENWRT_PATH)" ]; then \
                git clone $(OPENWRT_URL) $(OPENWRT_PATH); \
                cd $(OPENWRT_PATH) && git checkout --track origin/$(BRANCH); \
        else \
                cd $(OPENWRT_PATH) && git pull; \
        fi

feeds:
	cd $(OPENWRT_PATH) && ./scripts/feeds update -a && ./scripts/feeds install -a

config:
	cd $(OPENWRT_PATH) && cp ../products/$(TARGET)_$(BRANCH).config .config

openwrt: openwrt-src feeds config
	if [ -n ".config" ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL); \
	fi

clean:
	cd $(OPENWRT_PATH) && $(MAKE) clean

toolchain: openwrt-src
        $(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL) toolchain/install TARGET=$(TARGET)

.PHONY: openwrt	feeds toolchain config openwrt-src
