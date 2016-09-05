export ARCHS = armv7 arm64
export TARGET = iphone:clang:8.1:latest

PACKAGE_VERSION = 0.0.12

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DefaultPage
DefaultPage_FILES = Tweak.xm
DefaultPage_FRAMEWORKS = UIKit
DefaultPage_LDFLAGS += -Wl,-segalign,4000
DefaultPage_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += defaultpage
include $(THEOS_MAKE_PATH)/aggregate.mk
