EXECUTABLE=xcp
BUILD_PRODUCT=XcodeProjectCLI

build:
	swift build
	rm -rf .bin
	mkdir -p .bin
	cp .build/debug/$(BUILD_PRODUCT) .bin/$(EXECUTABLE)

test:
	swift test

release_local:
	swift build -c release
	rm -rf .release
	mkdir -p .release
	cp .build/release/$(BUILD_PRODUCT) .release/$(EXECUTABLE)

release:
	swift build --arch x86_64 -c release
	swift build --arch arm64 -c release
	rm -rf .release
	mkdir -p .release
	lipo -create \
	  .build/arm64-apple-macosx/release/$(BUILD_PRODUCT) \
	  .build/x86_64-apple-macosx/release/$(BUILD_PRODUCT) \
	  -output .release/$(EXECUTABLE)

sign_release: release
	codesign --force --sign "Developer ID Application: Wojciech Kulik ($$XCODE_DEVELOPMENT_TEAM)" --options runtime .release/xcp
	codesign -vvv --strict .release/$(EXECUTABLE)
	zip -j .release/$(EXECUTABLE).zip .release/$(EXECUTABLE)
	shasum -a 256 .release/$(EXECUTABLE).zip | pbcopy

install: release_local
	sudo cp .release/$(EXECUTABLE) /usr/local/bin/$(EXECUTABLE)

make uninstall:
	sudo rm /usr/local/bin/$(EXECUTABLE)

clean:
	rm -rf .bin .release .build
	swift package clean
	sudo rm /usr/local/bin/$(EXECUTABLE)
