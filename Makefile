PREFIX?=/

SUBPACKAGES = core network openrc aws azure gcp oci nocloud

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

aws: conf_dir
	install -Dm755 -t "$(PREFIX)"/lib/mdev \
		lib/mdev/nvme-ebs-links
	install -Dm644 -t "$(PREFIX)"/lib/tiny-cloud/aws \
		lib/tiny-cloud/aws/*
	sed -Ee 's/^#?CLOUD=.*/CLOUD=aws/' \
		-Ee 's/^#?HOTPLUG_MODULES=.*/HOTPLUG_MODULES="vnic_eth_hotplug nvme_ebs_links"/' \
		etc/conf.d/tiny-cloud.example > "$(PREFIX)"/etc/conf.d/tiny-cloud

azure: conf_dir
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/azure \
		lib/tiny-cloud/azure/*
	sed -Ee 's/^#?CLOUD=.*/CLOUD=azure/' \
		etc/conf.d/tiny-cloud.example > "$(PREFIX)"/etc/conf.d/tiny-cloud

gcp: conf_dir
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/gcp \
		lib/tiny-cloud/gcp/*
	sed -Ee 's/^#?CLOUD=.*/CLOUD=gcp/' \
		etc/conf.d/tiny-cloud.example > "$(PREFIX)"/etc/conf.d/tiny-cloud

oci: conf_dir
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/oci \
		lib/tiny-cloud/oci/*
	sed -Ee 's/^#?CLOUD=.*/CLOUD=oci/' \
		etc/conf.d/tiny-cloud.example > "$(PREFIX)"/etc/conf.d/tiny-cloud

nocloud: conf_dir
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/nocloud \
		lib/tiny-cloud/nocloud/*
	sed -Ee 's/^#?CLOUD=.*/CLOUD=nocloud/' \
		etc/conf.d/tiny-cloud.example > "$(PREFIX)"/etc/conf.d/tiny-cloud

conf_dir:
	mkdir -p "$(PREFIX)"/etc/conf.d
