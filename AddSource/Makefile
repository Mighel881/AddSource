ARCHS = armv7 armv7s arm64 arm64e
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AddSource
AddSource_FILES = addsourceRootListController.m
AddSource_INSTALL_PATH = /Library/PreferenceBundles
AddSource_FRAMEWORKS = UIKit
AddSource_PRIVATE_FRAMEWORKS = Preferences
AddSource_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/addsource.plist$(ECHO_END)
