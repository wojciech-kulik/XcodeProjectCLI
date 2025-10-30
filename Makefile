build:
	swift build
	rm -rf .release
	mkdir -p .bin
	cp .build/debug/XcodeProjectCLI .bin/xcodeproj

test:
	swift test

release:
	swift build -c release
	swift build --arch x86_64 -c release
	swift build --arch arm64 -c release
	rm -rf .release
	mkdir -p .release
	lipo -create \
	  .build/arm64-apple-macosx/release/XcodeProjectCLI \
	  .build/x86_64-apple-macosx/release/XcodeProjectCLI \
	  -output .release/xcodeproj
	zip -j .release/xcodeproj.zip .release/xcodeproj

