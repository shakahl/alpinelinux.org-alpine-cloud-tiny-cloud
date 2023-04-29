PREFIX?=/

SUBPACKAGES = core network openrc aws azure gcp oci nocloud

.PHONY: check install $(SUBPACKAGES)

install: $(SUBPACKAGES)

core:
	install -Dm755 -t "$(PREFIX)"/bin \
		bin/imds
	install -Dm644 -t "$(PREFIX)"/lib/tiny-cloud \
		lib/tiny-cloud/common \
		lib/tiny-cloud/init-* \
		lib/tiny-cloud/mdev \
		lib/tiny-cloud/tiny-cloud.conf
	install -Dm644 lib/tiny-cloud/tiny-cloud.conf \
		"$(PREFIX)"/etc/tiny-cloud.conf

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

azure:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/azure \
		lib/tiny-cloud/azure/*

gcp:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/gcp \
		lib/tiny-cloud/gcp/*

oci:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/oci \
		lib/tiny-cloud/oci/*

nocloud:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/nocloud \
		lib/tiny-cloud/nocloud/*

check: tests/Kyuafile Kyuafile
	kyua test || (kyua report --verbose && exit 1)

tests/Kyuafile: $(wildcard tests/*.test)
	echo "syntax(2)" > $@.tmp
	echo "test_suite('tiny-cloud')" >> $@.tmp
	for i in $(notdir $(wildcard tests/*.test)); do \
		echo "atf_test_program{name='$$i',timeout=5}" >> $@.tmp ; \
	done
	mv $@.tmp $@

Kyuafile:
	echo "syntax(2)" > $@.tmp
	echo "test_suite('tiny-cloud')" >> $@.tmp
	echo "include('tests/Kyuafile')" >> $@.tmp
	mv $@.tmp $@
