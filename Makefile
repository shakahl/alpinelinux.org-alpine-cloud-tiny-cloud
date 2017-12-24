PREFIX?=/

.PHONY: install
install:
	install -Dm 755 tiny-ec2-bootstrap $(PREFIX)/etc/init.d/tiny-ec2-bootstrap
