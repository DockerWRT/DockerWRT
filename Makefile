PROXY ?=
ifeq ($(PROXY),)
	PROXY_SETTING :=  
else
	PROXY_SETTING := export all_proxy=$(PROXY) && export http_proxy=$(PROXY) && export https_proxy=$(PROXY) &&
endif
OPENWRT_URL := https://github.com/openwrt/openwrt.git

TARGET ?= x86_64
BRANCH ?= openwrt-23.05
JOBS ?= -j4
VISUAL ?= "V=99"

OPENWRT_PATH := openwrt_$(TARGET)_$(BRANCH)

all: openwrt

openwrt-src:
	if [ ! -d "$(OPENWRT_PATH)" ]; then \
                $(PROXY_SETTING) git clone $(OPENWRT_URL) $(OPENWRT_PATH); \
                cd $(OPENWRT_PATH) && git checkout --track origin/$(BRANCH); \
        else \
                $(PROXY_SETTING) cd $(OPENWRT_PATH) && git pull; \
        fi

feeds:
	cd $(OPENWRT_PATH) && ./scripts/feeds update -a && ./scripts/feeds install -a

config:
	if [ ! -f $(OPENWRT_PATH)/.config ]; then \
		cd $(OPENWRT_PATH) && cp ../products/$(TARGET)_$(BRANCH).config .config; \
	fi

openwrt: openwrt-src feeds config
	if [ -f $(OPENWRT_PATH)/.config ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL); \
	fi

clean:
	cd $(OPENWRT_PATH) && $(MAKE) clean

toolchain: openwrt-src config
	$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(JOBS) $(VISUAL) toolchain/install

.PHONY: openwrt	feeds toolchain config openwrt-src
