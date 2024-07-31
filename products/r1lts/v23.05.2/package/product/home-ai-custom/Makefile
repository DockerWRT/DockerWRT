include $(TOPDIR)/rules.mk

PKG_NAME:=home-ai-custom
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/home-ai-custom
  SECTION:=product
  CATEGORY:=product
  TITLE:=Home AI Custom Package
  DEPENDS:=+nginx-util
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
	$(INSTALL_BIN) ./files/* $(1)/etc/nginx/
endef

$(eval $(call BuildPackage,home-ai-custom))

