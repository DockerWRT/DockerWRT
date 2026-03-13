
# 1. 基础配置与包含规则
include $(TOPDIR)/rules.mk

PKG_NAME:=picoclaw
PKG_VERSION:=0.2.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/sipeed/picoclaw.git
PKG_SOURCE_VERSION:=main
PKG_MIRROR_HASH:=skip

# 4. 构建依赖和参数
PKG_BUILD_DEPENDS:=golang/host          # 指定依赖 Go 语言主机工具链
PKG_BUILD_PARALLEL:=1                    # 启用并行编译
PKG_BUILD_FLAGS:=no-mips16               # 禁用 MIPS16 指令，提升兼容性

# 5. Go 语言特有变量
GO_PKG:=github.com/sipeed/picoclaw
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/picoclaw/... $(GO_PKG)/web/backend
GO_PKG_GO_GENERATE:=1
GO_PKG_INSTALL_EXTRA:=^workspace/|^cmd/picoclaw/internal/onboard/workspace/|^web/backend/dist/

#GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)  # 向代码注入版本信息

# 6. 包含 Go 和 OpenWrt 的核心构建规则
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

# 7. 定义软件包信息（在OpenWrt菜单中的显示）
define Package/picoclaw
	SECTION:=product
	CATEGORY:=product
	TITLE:=PicoClaw AI assistant
	URL:=https://github.com/sipeed/picoclaw
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

# 8. 软件包详细描述
define Package/picoclaw/description
	PicoClaw is an ultra-lightweight AI assistant implemented in Go.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	rm -rf $(PKG_BUILD_DIR)/cmd/picoclaw/internal/onboard/workspace
	cp -r $(PKG_BUILD_DIR)/workspace $(PKG_BUILD_DIR)/cmd/picoclaw/internal/onboard/workspace
endef

define Build/Compile
	echo "######## Building picoclaw package ########"
	$(call GoPackage/Build/Compile)
endef

define Package/picoclaw/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/picoclaw $(1)/usr/bin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/backend $(1)/usr/bin/picoclaw-launcher
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/picoclaw-launcher.init $(1)/etc/init.d/picoclaw-launcher
endef

# 10. 最终评估：生成构建规则
$(eval $(call GoBinPackage,$(PKG_NAME)))   # 生成 Go 二进制包的构建规则
$(eval $(call BuildPackage,$(PKG_NAME)))    # 生成 OpenWrt 包管理器的构建规则