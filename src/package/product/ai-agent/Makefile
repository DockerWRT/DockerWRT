include $(TOPDIR)/rules.mk

PKG_NAME:=ai-agent
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/ai-agent
  SECTION:=product
  CATEGORY:=product
  TITLE:=AI Agent Package
  DEPENDS:=+luci +luci-base +luci-lib-jsonc +luci-theme-openwrt-2020 +rpcd +dropbear
  INSTALL:=1
endef

define Package/ai-agent/description
	This is a custom package for AI Agent.
endef

define Build/Compile
	# Add any custom build instructions here
	echo "Building ai-agent package"
endef

define Package/ai-agent/install
	$(INSTALL_DIR) $(1)/usr/share/ai-agent/config
	$(INSTALL_CONF) ./files/config/rpcd.config $(1)/usr/share/ai-agent/config/rpcd.config
	$(INSTALL_CONF) ./files/config/dropbear.config $(1)/usr/share/ai-agent/config/dropbear.config
	$(INSTALL_CONF) ./files/config/dropbear.config.25.12.0 $(1)/usr/share/ai-agent/config/dropbear.config

	$(INSTALL_DIR) $(1)/usr/share/ai-agent/system
	$(INSTALL_BIN) ./files/init/login.sh $(1)/usr/share/ai-agent/system/login.sh
	$(INSTALL_DATA) ./files/init/shadow $(1)/usr/share/ai-agent/system/shadow
	$(INSTALL_DATA) ./files/init/passwd $(1)/usr/share/ai-agent/system/passwd

	$(INSTALL_DIR) $(1)/usr/share/ai-agent/web
	$(INSTALL_DATA) ./files/web/index.html $(1)/usr/share/ai-agent/web/index.html
	$(INSTALL_DATA) ./files/web/logo.png $(1)/usr/share/ai-agent/web/logo.png
	$(INSTALL_DATA) ./files/web/logo.svg $(1)/usr/share/ai-agent/web/logo.svg
	$(INSTALL_DATA) ./files/web/wechat_id.jpg $(1)/usr/share/ai-agent/web/wechat_id.jpg

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/init/01_init_product $(1)/etc/uci-defaults/01_ai_agent

endef

$(eval $(call BuildPackage,ai-agent))

