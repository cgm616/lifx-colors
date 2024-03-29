export TARGET := iphone:clang
export ARCHS = armv7 arm64
THEOS_BUILD_DIR = Packages
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include theos/makefiles/common.mk

TWEAK_NAME = lifx
lifx_FILES = Tweak.xm
lifx_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
