CUSTOM_PROXY ?=
ifeq ($(CUSTOM_PROXY),)
    PROXY_SETTING :=  
else
    PROXY_SETTING := export all_proxy=$(CUSTOM_PROXY) && export http_proxy=$(CUSTOM_PROXY) && export https_proxy=$(CUSTOM_PROXY) && 
endif

ifeq ($(PRODUCT_TARGET),r2s)
	K_CONFIG_PATH	:= target/linux/rockchip/armv8/
	K_PATCHES_PATH	:= target/linux/rockchip/patches-5.15/
else
	K_CONFIG_PATH	:=	none
	K_PATCHES_PATH	:=	none
endif


CURRENT_TIME		:=	$(shell date +"%y%m%d-%H%M%S")

OPENWRT_URL			:=	https://github.com/openwrt/openwrt.git
PRODUCT_TARGET		?=	"x86_64"
OPENWRT_TAG			?=	"v23.05.2"
COMPILE_JOBS		?=	"-j1"
COMPILE_VISUAL		?=	"V=99"

PRODUCT_PATH	:=	$(PWD)/src
OPENWRT_PATH		:=	$(PWD)/build_$(PRODUCT_TARGET)
OUTPUT_PATH			:=	$(PWD)/output/$(PRODUCT_TARGET)/$(CURRENT_TIME)

all: firmware

openwrt-src:
	if [ ! -d "$(OPENWRT_PATH)" ]; then \
		$(PROXY_SETTING) git clone $(OPENWRT_URL) $(OPENWRT_PATH); \
		cd $(OPENWRT_PATH) && git checkout $(OPENWRT_TAG) && git checkout -b $(OPENWRT_TAG); \
	fi

package: openwrt-src
	if [ -d "$(PRODUCT_PATH)/package" ]; then \
		cd $(OPENWRT_PATH) && cp -r $(PRODUCT_PATH)/package/* package/; \
	fi
	if [ -f "$(PRODUCT_PATH)/feeds.conf.default" ]; then \
		cd $(OPENWRT_PATH) && cp $(PRODUCT_PATH)/feeds.conf.default ./; \
	fi

feeds: package
	cd $(OPENWRT_PATH) && $(PROXY_SETTING) ./scripts/feeds update -a && $(PROXY_SETTING) ./scripts/feeds install -a; \

config: feeds
	if [ ! -f $(OPENWRT_PATH)/.config ]; then \
		cd $(OPENWRT_PATH) && cp $(PRODUCT_PATH)/$(PRODUCT_TARGET)/$(OPENWRT_TAG)/.config .config;\
	fi

	cd $(OPENWRT_PATH) && sed -i 's/^\(CONFIG_VERSION_NUMBER="\)[^"]*"/\1$(CURRENT_TIME)"/' .config;

	if [ -d "$(OPENWRT_PATH)/$(K_CONFIG_PATH)" ]; then \
		cd $(OPENWRT_PATH) && cp $(PRODUCT_PATH)/$(PRODUCT_TARGET)/$(OPENWRT_TAG)/config-* $(K_CONFIG_PATH); \
	fi

	if [ -d "$(OPENWRT_PATH)/$(K_PATCHES_PATH)" ]; then \
		cd $(OPENWRT_PATH) && cp $(PRODUCT_PATH)/$(PRODUCT_TARGET)/$(OPENWRT_TAG)/kernel_patches/* $(K_PATCHES_PATH); \
	fi

toolchain: config
	if [ -d "$(OPENWRT_PATH)" ] && [ -d $(OPENWRT_PATH)/feeds ] && [ -f $(OPENWRT_PATH)/.config ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(COMPILE_JOBS) $(COMPILE_VISUAL) toolchain/install; \
	fi


kernel: config toolchain
	if [ -d "$(OPENWRT_PATH)" ] && [ -d $(OPENWRT_PATH)/feeds ] && [ -f $(OPENWRT_PATH)/.config ]; then \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(COMPILE_JOBS) $(COMPILE_VISUAL) target/linux/compile; \
	fi

docker: config kernel
	$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(COMPILE_JOBS) $(COMPILE_VISUAL) package/docker/compile;

python3: config kernel
	$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(COMPILE_JOBS) $(COMPILE_VISUAL) package/python3/compile;

firmware: config docker python3
	if [ -d "$(OPENWRT_PATH)" ] && [ -d $(OPENWRT_PATH)/feeds ] && [ -f $(OPENWRT_PATH)/.config ]; then \
		rm -rf $(OPENWRT_PATH)/bin/*; \
		$(PROXY_SETTING) cd $(OPENWRT_PATH) && $(MAKE) $(COMPILE_JOBS) $(COMPILE_VISUAL) world && mkdir -p $(OUTPUT_PATH) && cp -r bin/targets/ $(OUTPUT_PATH)/; \
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
