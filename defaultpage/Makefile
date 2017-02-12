include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = defaultpage
defaultpage_FILES = DPRootListController.m
defaultpage_INSTALL_PATH = /Library/PreferenceBundles
defaultpage_FRAMEWORKS = UIKit MessageUI
defaultpage_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/defaultpage.plist$(ECHO_END)
