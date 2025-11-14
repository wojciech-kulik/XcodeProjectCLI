EXECUTABLE=xcp
BUILD_PRODUCT=XcodeProjectCLI

build:
	swift build
	rm -rf .bin
	mkdir -p .bin
	cp .build/debug/$(BUILD_PRODUCT) .bin/$(EXECUTABLE)

check:
	swiftlint --quiet
	swiftformat --lint --config .swiftformat Sources

test:
	swift test

release_local:
	swift build -c release
	rm -rf .release
	mkdir -p .release
	cp .build/release/$(BUILD_PRODUCT) .release/$(EXECUTABLE)

release_nosign:
	swift build --arch x86_64 -c release
	swift build --arch arm64 -c release
	rm -rf .release
	mkdir -p .release
	lipo -create \
	  .build/arm64-apple-macosx/release/$(BUILD_PRODUCT) \
	  .build/x86_64-apple-macosx/release/$(BUILD_PRODUCT) \
	  -output .release/$(EXECUTABLE)

release: release_nosign
	codesign --force --sign "Developer ID Application: Wojciech Kulik ($$XCODE_DEVELOPMENT_TEAM)" --options runtime .release/xcp
	codesign -vvv --strict .release/$(EXECUTABLE)
	zip -j .release/$(EXECUTABLE).zip .release/$(EXECUTABLE)
	shasum -a 256 .release/$(EXECUTABLE).zip | cut -d' ' -f1 | tr -d '\n' | pbcopy

install: release_local
	cp .release/$(EXECUTABLE) ~/.local/bin/$(EXECUTABLE)

make uninstall:
	rm ~/.local/bin/$(EXECUTABLE)

clean:
	rm -rf .bin .release .build
	swift package clean
	rm ~/.local/bin/$(EXECUTABLE)
