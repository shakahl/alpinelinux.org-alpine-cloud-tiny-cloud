PREFIX?=/

SUBPACKAGES = core network openrc aws azure gcp oci

.PHONY: install $(SUBPACKAGES)

# installs all subpackages, then replaces cloud-specific config with example
install: $(SUBPACKAGES)
	mv "$(PREFIX)"/etc/conf.d/tiny-cloud.example "$(PREFIX)"/etc/conf.d/tiny-cloud

core:
	install -Dm755 -t "$(PREFIX)"/bin \
		bin/imds
	install -Dm644 -t "$(PREFIX)"/etc/conf.d \
		etc/conf.d/tiny-cloud.example
	install -Dm644 -t "$(PREFIX)"/lib/tiny-cloud \
		lib/tiny-cloud/common \
		lib/tiny-cloud/init-* \
		lib/tiny-cloud/mdev

network:
	install -Dm644 -t "$(PREFIX)"/etc/network/interfaces.d \
		etc/network/interfaces.d/*
	install -Dm755 -t "$(PREFIX)"/lib/mdev \
		lib/mdev/vnic-eth-hotplug
	install -Dm755 -t "$(PREFIX)"/sbin \
		sbin/*
	install -Dm755 -t "$(PREFIX)"/usr/libexec/ifupdown-ng \
		usr/libexec/ifupdown-ng/imds

openrc:
	install -Dm755 -t "$(PREFIX)"/etc/init.d \
		etc/init.d/*

aws:
	install -Dm755 -t "$(PREFIX)"/lib/mdev \
		lib/mdev/nvme-ebs-links
	install -Dm644 -t "$(PREFIX)"/lib/tiny-cloud/aws \
		lib/tiny-cloud/aws/*
	sed -e 's/^#?CLOUD=.*/CLOUD=aws/' \
		-e 's/^#?HOTPLUG_MODULES=.*/HOTPLUG_MODULES="vnic_eth_hotplug nvme_ebs_links"/' \
		etc/conf.d/tiny-cloud.example > "$(PREFIX)"/etc/conf.d/tiny-cloud

azure:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/azure \
		lib/tiny-cloud/azure/*
	sed -e 's/^#?CLOUD=.*/CLOUD=azure/' \
		etc/conf.d/tiny-cloud.example > "$(PREFIX)"/etc/conf.d/tiny-cloud

gcp:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/gcp \
		lib/tiny-cloud/gcp/*
	sed -e 's/^#?CLOUD=.*/CLOUD=gcp/' \
		etc/conf.d/tiny-cloud.example > "$(PREFIX)"/etc/conf.d/tiny-cloud

oci:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/oci \
		lib/tiny-cloud/oci/*
	sed -e 's/^#?CLOUD=.*/CLOUD=oci/' \
		etc/conf.d/tiny-cloud.example > "$(PREFIX)"/etc/conf.d/tiny-cloud