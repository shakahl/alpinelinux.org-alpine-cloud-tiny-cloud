PREFIX?=/

.PHONY: install
install:
	cp -r bin etc lib sbin usr $(PREFIX)
