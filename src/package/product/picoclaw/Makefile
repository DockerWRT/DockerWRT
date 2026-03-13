include $(TOPDIR)/rules.mk

PKG_NAME:=picoclaw
PKG_VERSION:=0.2.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/sipeed/picoclaw.git
PKG_SOURCE_VERSION:=main
PKG_MIRROR_HASH:=skip

# 依赖
PKG_BUILD_DEPENDS:=golang/host node/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

# Go 包定义 - 只构建主程序，backend 单独处理
GO_PKG:=github.com/sipeed/picoclaw
GO_PKG_BUILD_PKG:= $(GO_PKG)/cmd/picoclaw
# 设置 Go 编译器路径（基于 find 命令的结果）
GO_CMD = $(STAGING_DIR_HOSTPKG)/lib/go-1.26/bin/go

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/picoclaw
	SECTION:=product
	CATEGORY:=product
	TITLE:=PicoClaw AI assistant
	URL:=https://github.com/sipeed/picoclaw
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/picoclaw/description
	PicoClaw is an ultra-lightweight AI assistant implemented in Go.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	# 准备 workspace
	rm -rf $(PKG_BUILD_DIR)/cmd/picoclaw/internal/onboard/workspace
	cp -r $(PKG_BUILD_DIR)/workspace $(PKG_BUILD_DIR)/cmd/picoclaw/internal/onboard/workspace
endef

# 完全自定义构建过程，不使用 GoPackage/Build/Compile
define Build/Compile
	echo "######## Building picoclaw package ########"

	# 1. 安装 pnpm
	(which pnpm) || npm install -g pnpm

	# 2. 构建前端
	echo "Building frontend..."
	cd $(PKG_BUILD_DIR)/web/frontend && \
		pnpm install --no-frozen-lockfile && \
		pnpm run build:backend

	# 3. 编译 backend (picoclaw-launcher) - 使用 OpenWrt 的 Go 编译器
	echo "Building picoclaw-launcher..."
	cd $(PKG_BUILD_DIR)/web/backend && \
		CGO_ENABLED=0 \
		GOOS=linux \
		GOARCH=$(GO_ARCH) \
		$(GO_CMD) build -o picoclaw-launcher .

	# 4. 编译主程序 - 使用 OpenWrt 的 Go 编译器
	echo "Building main picoclaw binary..."
	cd $(PKG_BUILD_DIR)/cmd/picoclaw && \
		CGO_ENABLED=0 \
		GOOS=linux \
		GOARCH=$(GO_ARCH) \
		$(GO_CMD) build -o picoclaw .

	echo "######## Build complete ########"
endef

define Package/picoclaw/install
	# 安装目录
	$(INSTALL_DIR) $(1)/usr/bin

	# 安装主程序
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cmd/picoclaw/picoclaw $(1)/usr/bin/

	# 安装 launcher
	@if [ -f "$(PKG_BUILD_DIR)/web/backend/picoclaw-launcher" ]; then \
		echo "Installing picoclaw-launcher..."; \
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/web/backend/picoclaw-launcher $(1)/usr/bin/; \
	else \
		echo "Error: picoclaw-launcher not found!"; \
		exit 1; \
	fi

	# 安装 init 脚本
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/picoclaw-launcher.init $(1)/etc/init.d/
endef

# 验证二进制文件
define Build/InstallDev
	@echo "Final build artifacts:"
	@ls -la $(PKG_BUILD_DIR)/cmd/picoclaw/picoclaw 2>/dev/null || echo "picoclaw not found"
	@ls -la $(PKG_BUILD_DIR)/web/backend/picoclaw-launcher 2>/dev/null || echo "picoclaw-launcher not found"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))