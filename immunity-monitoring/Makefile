# immunity.org
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=immunity-monitoring
PKG_VERSION:=$(shell cat ../VERSION)
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_SOURCE_SUBDIR)
PKG_MAINTAINER:=Federico Capoano <f.capoano@immunity.io>
PKG_LICENSE:=GPL-3.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/immunity-monitoring
	TITLE:=Immunity Monitoring agent
	CATEGORY:=Administration
	SECTION:=admin
	SUBMENU:=immunity
	DEPENDS:=+netjson-monitoring +immunity-config
	PKGARCH:=all
	URL:=http://immunity.org
endef

define Package/netjson-monitoring
	TITLE:=NetJson Monitoring
	CATEGORY:=Administration
	SECTION:=admin
	SUBMENU:=immunity
	DEPENDS:=+libubus-lua +lua-cjson +rpcd +rpcd-mod-iwinfo
	PKGARCH:=all
	URL:=http://immunity.org
endef

define Build/Compile
endef

define Package/immunity-monitoring/conffiles
/etc/config/immunity-monitoring
endef

define Package/netjson-monitoring/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/usr/libexec \
		$(1)/usr/lib/lua/immunity-monitoring \
		$(1)/usr/lib/immunity-monitoring

	$(INSTALL_BIN) \
		files/sbin/netjson-monitoring.lua \
		$(1)/usr/libexec/netjson-monitoring

	$(INSTALL_BIN) \
		files/netjson-monitoring \
		$(1)/usr/sbin/netjson-monitoring

	$(INSTALL_DATA) \
		files/lib/immunity-monitoring/dhcp.lua \
		$(1)/usr/lib/lua/immunity-monitoring/dhcp.lua

	$(INSTALL_DATA) \
		files/lib/immunity-monitoring/interfaces.lua \
		$(1)/usr/lib/lua/immunity-monitoring/interfaces.lua

	$(INSTALL_DATA) \
		files/lib/immunity-monitoring/monitoring.lua \
		$(1)/usr/lib/lua/immunity-monitoring/monitoring.lua

	$(INSTALL_DATA) \
		files/lib/immunity-monitoring/utils.lua \
		$(1)/usr/lib/lua/immunity-monitoring/utils.lua

	$(INSTALL_DATA) \
		files/lib/immunity-monitoring/neighbors.lua \
		$(1)/usr/lib/lua/immunity-monitoring/neighbors.lua

	$(INSTALL_DATA) \
		files/lib/immunity-monitoring/resources.lua \
		$(1)/usr/lib/lua/immunity-monitoring/resources.lua

	$(INSTALL_DATA) \
		files/lib/immunity-monitoring/wifi.lua \
		$(1)/usr/lib/lua/immunity-monitoring/wifi.lua

	$(CP) ../VERSION $(1)/usr/lib/immunity-monitoring/

endef

define Package/immunity-monitoring/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/etc/init.d \
		$(1)/etc/config \
		$(1)/usr/lib/immunity-monitoring \
		$(1)/etc/hotplug.d/immunity

	$(INSTALL_BIN) \
		files/monitoring.agent \
		$(1)/usr/sbin/immunity-monitoring

	$(INSTALL_BIN) \
		files/monitoring.init \
		$(1)/etc/init.d/immunity-monitoring
	
	$(INSTALL_BIN) \
		files/immunity-monitoring.hotplug \
		$(1)/etc/hotplug.d/immunity/immunity-monitoring

	$(INSTALL_CONF) \
		files/monitoring.config \
		$(1)/etc/config/immunity-monitoring

endef

$(eval $(call BuildPackage,immunity-monitoring))
$(eval $(call BuildPackage,netjson-monitoring))
