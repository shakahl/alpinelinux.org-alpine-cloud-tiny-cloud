PREFIX?=/

SUBPACKAGES = core network openrc aws azure gcp oci nocloud alpine

.PHONY: check install $(SUBPACKAGES)

install: $(SUBPACKAGES)

core:
	install -Dm755 -t "$(PREFIX)"/bin \
		bin/imds
	install -Dm644 -t "$(PREFIX)"/lib/tiny-cloud \
		lib/tiny-cloud/common \
		lib/tiny-cloud/init \
		lib/tiny-cloud/mdev \
		lib/tiny-cloud/tiny-cloud.conf
	install -Dm644 -t "$(PREFIX)"/lib/tiny-cloud/user-data \
		lib/tiny-cloud/user-data/missing \
		lib/tiny-cloud/user-data/script \
		lib/tiny-cloud/user-data/unknown
	install -Dm644 lib/tiny-cloud/tiny-cloud.conf \
		"$(PREFIX)"/etc/tiny-cloud.conf
	install -Dm755 -t "$(PREFIX)"/sbin \
		sbin/tiny-cloud

network:
	install -Dm644 -t "$(PREFIX)"/etc/network/interfaces.d \
		etc/network/interfaces.d/*
	install -Dm755 -t "$(PREFIX)"/lib/mdev \
		lib/mdev/vnic-eth-hotplug
	install -Dm755 -t "$(PREFIX)"/sbin \
		sbin/assemble-interfaces \
		sbin/imds-net-sync
	install -Dm755 -t "$(PREFIX)"/usr/libexec/ifupdown-ng \
		usr/libexec/ifupdown-ng/imds

openrc:
	install -Dm755 -t "$(PREFIX)"/etc/init.d \
		dist/openrc/*

aws:
	install -Dm755 -t "$(PREFIX)"/lib/mdev \
		lib/mdev/nvme-ebs-links
	install -Dm644 -t "$(PREFIX)"/lib/tiny-cloud/cloud/aws \
		lib/tiny-cloud/cloud/aws/*

azure:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/cloud/azure \
		lib/tiny-cloud/cloud/azure/*

gcp:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/cloud/gcp \
		lib/tiny-cloud/cloud/gcp/*

oci:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/cloud/oci \
		lib/tiny-cloud/cloud/oci/*

nocloud:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/cloud/nocloud \
		lib/tiny-cloud/cloud/nocloud/*

alpine:
	install -Dm644 -t $(PREFIX)/lib/tiny-cloud/cloud/alpine \
		lib/tiny-cloud/cloud/alpine/init
	ln -s ../nocloud/imds $(PREFIX)/lib/tiny-cloud/cloud/alpine/imds
	install -Dm644 -t "$(PREFIX)"/lib/tiny-cloud/user-data \
		lib/tiny-cloud/user-data/alpine-config

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
