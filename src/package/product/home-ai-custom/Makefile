include $(TOPDIR)/rules.mk

PKG_NAME:=home-ai-custom
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/home-ai-custom
  SECTION:=product
  CATEGORY:=product
  TITLE:=Home AI Custom Package
  DEPENDS:=+nginx-util +luci +luci-base +luci-lib-jsonc +luci-theme-openwrt-2020
  INSTALL:=1
endef

define Package/home-ai-custom/description
	This is a custom package for Home AI.
endef

define Build/Compile
	# Add any custom build instructions here
	echo "Building home-ai-custom package"
endef

define Package/home-ai-custom/install
	$(INSTALL_DIR) $(1)/etc/nginx
	$(INSTALL_BIN) ./files/uci.conf.template $(1)/etc/nginx/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/init/01_init_product $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/www
	$(INSTALL_BIN) ./files/web/index.html $(1)/www/
	$(INSTALL_DIR) $(1)/usr/share/ucode/luci/template/
	$(INSTALL_BIN) ./files/web/sysauth.ut $(1)/usr/share/ucode/luci/template/
	$(INSTALL_DIR) $(1)/usr/share/ucode/luci/template/themes/openwrt2020/
	$(INSTALL_BIN) ./files/web/footer.ut $(1)/usr/share/ucode/luci/template/themes/openwrt2020/
	$(INSTALL_BIN) ./files/web/header.ut $(1)/usr/share/ucode/luci/template/themes/openwrt2020/
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/status/include/
	$(INSTALL_BIN) ./files/web/10_system.js $(1)/www/luci-static/resources/view/status/include/
endef

$(eval $(call BuildPackage,home-ai-custom))

