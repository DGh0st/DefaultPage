export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:latest

PACKAGE_VERSION = 0.0.3

include theos/makefiles/common.mk

TWEAK_NAME = DefaultPage
DefaultPage_FILES = Tweak.xm
DefaultPage_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += defaultpage
include $(THEOS_MAKE_PATH)/aggregate.mk
