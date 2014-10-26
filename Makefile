ARCHS = armv7 arm64
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
export TARGET = iphone:clang:7.1
include theos/makefiles/common.mk

TWEAK_NAME = WebsiteDataABC
WebsiteDataABC_FILES = Tweak.xm
WebsiteDataABC_FRAMEWORKS = UIKit
WebsiteDataABC_PRIVATE_FRAMEWORKS = Preferences
WebsiteDataABC_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk


