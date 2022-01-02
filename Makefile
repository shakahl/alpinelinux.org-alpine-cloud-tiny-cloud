PREFIX?=/

.PHONY: install
install:
	cp -r etc $(PREFIX)
	cp -r lib $(PREFIX)
