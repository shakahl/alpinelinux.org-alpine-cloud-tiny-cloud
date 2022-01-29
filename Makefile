PREFIX?=/

SUBPACKAGES = core network openrc aws azure gcp oci

.PHONY: install $(SUBPACKAGES)

install: $(SUBPACKAGES)

core:
	install -Dm755 -t $(PREFIX)/bin \
		bin/imds
	install -Dm644 -t $(PREFIX)/etc/conf.d \
		etc/conf.d/tiny-cloud.example
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud \
		lib/tiny-cloud/common \
		lib/tiny-cloud/init-* \
		lib/tiny-cloud/mdev

network:
	install -Dm644 -t $(PREFIX)/etc/network/interfaces.d \
		etc/network/interfaces.d/*
	install -Dm755 -t $(PREFIX)/lib/mdev \
		lib/mdev/vnic-eth-hotplug
	install -Dm755 -t $(PREFIX)/sbin \
		sbin/*
	install -Dm755 -t $(PREFIX)/usr/libexec/ifupdown-ng \
		usr/libexec/ifupdown-ng/imds

openrc:
	install -Dm755 -t $(PREFIX)/etc/init.d \
		etc/init.d/*

aws:
	install -Dm644 -t $(PREFIX)/etc/conf.d \
		lib/tiny-cloud/aws/tiny-cloud
	install -Dm755 -t $(PREFIX)/lib/mdev \
		lib/mdev/nvme-ebs-links
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/aws \
		lib/tiny-cloud/aws/*

azure:
	install -Dm644 -t $(PREFIX)/etc/conf.d \
		lib/tiny-cloud/azure/tiny-cloud
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/azure \
		lib/tiny-cloud/azure/*

gcp:
	install -Dm644 -t $(PREFIX)/etc/conf.d \
		lib/tiny-cloud/gcp/tiny-cloud
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/gcp \
		lib/tiny-cloud/gcp/*

oci:
	install -Dm644 -t $(PREFIX)/etc/conf.d \
		lib/tiny-cloud/oci/tiny-cloud
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/oci \
		lib/tiny-cloud/oci/*