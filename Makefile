EXECUTABLE=xcp
BUILD_PRODUCT=xcp

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

release:
	swift build -c release
	rm -rf .release
	mkdir -p .release
	cp .build/release/$(BUILD_PRODUCT) .release/$(EXECUTABLE)

install: release
	cp .release/$(EXECUTABLE) ~/.local/bin/$(EXECUTABLE)

make uninstall:
	rm ~/.local/bin/$(EXECUTABLE)

clean:
	rm -rf .bin .release .build
	swift package clean
	rm ~/.local/bin/$(EXECUTABLE) || true
