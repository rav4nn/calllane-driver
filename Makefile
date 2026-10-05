# Builds the CallLane audio driver exactly as the CallLane app ships it.
# VERSION matches the CallLane app version that bundles this driver.
APP     = CallLane
VERSION ?= 0.3.2
BUILD   = build
DRIVER  = $(BUILD)/$(APP).driver
PKG     = $(BUILD)/$(APP)Driver.pkg
HAL_DIR = /Library/Audio/Plug-Ins/HAL
SIGN    ?= -
CODESIGN = codesign --force --sign "$(SIGN)" $(if $(filter -,$(SIGN)),,--options runtime --timestamp)
# The device the call apps pick is output only; its hidden twin is the input the app reads.
# Both share one ring inside coreaudiod. 48 kHz only: the app's engine assumes it.
DRIVER_DEFINES = \
	-DkDriver_Name='"$(APP)"' \
	-DkPlugIn_BundleID='"dev.rav4nn.calllane.driver"' \
	-DkHas_Driver_Name_Format=false \
	-DkDevice_Name='"$(APP)"' \
	-DkDevice_HasInput=false \
	-DkDevice2_Name='"$(APP) Tap"' \
	-DkDevice2_HasOutput=false \
	-DkDevice2_IsHidden=true \
	-DkEnableVolumeControl=false \
	-DkManufacturer_Name='"$(APP)"' \
	-DkNumber_Of_Channels=2 \
	-DkLatency_Frame_Size=0 \
	-DkSampleRates=48000

.PHONY: driver pkg install-driver clean

driver:
	rm -rf $(DRIVER)
	mkdir -p $(DRIVER)/Contents/MacOS
	clang -bundle -O2 -framework CoreAudio -framework CoreFoundation -framework Accelerate \
		$(DRIVER_DEFINES) -o $(DRIVER)/Contents/MacOS/$(APP) BlackHole.c
	sed 's/@VERSION@/$(VERSION)/' Info.plist > $(DRIVER)/Contents/Info.plist
	mkdir -p $(DRIVER)/Contents/Resources
	cp LICENSE NOTICE $(DRIVER)/Contents/Resources/
	$(CODESIGN) $(DRIVER)

pkg: driver
	rm -rf $(BUILD)/pkgroot && mkdir -p $(BUILD)/pkgroot
	cp -R $(DRIVER) $(BUILD)/pkgroot/
	pkgbuild --root $(BUILD)/pkgroot --component-plist pkg/component.plist \
		--install-location $(HAL_DIR) --identifier dev.rav4nn.calllane.driver \
		--version $(VERSION) --scripts pkg/scripts $(PKG)

install-driver: pkg
	sudo installer -pkg $(PKG) -target /

clean:
	rm -rf $(BUILD)
