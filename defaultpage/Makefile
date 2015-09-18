GO_EASY_ON_ME = 1
include theos/makefiles/common.mk

BUNDLE_NAME = DefaultPage
DefaultPage_FILES = DefaultPage.mm
DefaultPage_INSTALL_PATH = /Library/PreferenceBundles
DefaultPage_FRAMEWORKS = UIKit MessageUI
DefaultPage_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DefaultPage.plist$(ECHO_END)
