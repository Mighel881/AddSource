ARCHS = armv7 armv7s arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = addsource
addsource_FILES = Tweak.xm
addsource_EXTRA_FRAMEWORKS += Cephei
addsource_FRAMEWORKS = UIKit
addsource_LIBRARIES = substrate
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Cydia"
SUBPROJECTS += AddSource
include $(THEOS_MAKE_PATH)/aggregate.mk
