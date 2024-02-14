# shellcheck shell=sh

atf_srcdir="$(atf_get_srcdir)"
srcdir="$atf_srcdir/.."
PATH="$atf_srcdir/bin:$srcdir/bin:$srcdir/sbin:$PATH"

export TINY_CLOUD_BASEDIR="$srcdir"
export ROOT="$PWD"


init_tests() {
	TESTS=
	for t; do
		TESTS="$TESTS $t"
		atf_test_case "$t"
	done
	export TESTS
}

atf_init_test_cases() {
	for t in $TESTS; do
		atf_add_test_case "$t"
	done
}

fake_bin() {
	mkdir -p bin
	cat > bin/"$1"
	chmod +x bin/"$1"
	PATH="$PWD/bin:$PATH"
}

fake_umount() {
	fake_bin umount <<-EOF
		#!/bin/sh
		while ! [ -d "\$1" ]; do
			shift
		done
		rm -f "\$1"/meta-data "\$1"/user-data
	EOF
}

fake_data_nocloud() {
	local datafile="$1"
	mkdir -p tmp/fake-data
	cat > tmp/fake-data/"$datafile"
	fake_bin mount <<-EOF
		#!/bin/sh
		# find last arg which is the mount dir
		while ! [ -d "\$1" ]; do
			shift
		done
		cp tmp/fake-data/* "\$1"/
	EOF
	mkdir -p mnt
	fake_umount
}

fake_metadata_nocloud() {
	fake_data_nocloud meta-data
}

fake_userdata_nocloud() {
	fake_data_nocloud user-data
}

fake_metadata_aws() {
	cat > "169.254.169.254.yaml"
	export WGET_STRIP_PREFIX="/latest/meta-data"
}

fake_metadata_azure() {
	cat > "169.254.169.254.yaml"
	export WGET_STRIP_PREFIX="/metadata/instance"
}

fake_metadata_gcp() {
	cat > "169.254.169.254.yaml"
	export WGET_STRIP_PREFIX="/computeMetadata/v1"
}

fake_metadata_oci() {
	cat > "169.254.169.254.yaml"
	export WGET_STRIP_PREFIX="/opc/v2"
}

fake_metadata_scaleway() {
	cat > "169.254.42.42.txt"
	export WGET_STRIP_PREFIX="/conf"
}

fake_userdata_scaleway() {
	cat > "169.254.42.42.txt"
}

fake_metadata() {
	case "${1:-$CLOUD}" in
		alpine|nocloud) fake_metadata_nocloud;;
		aws) fake_metadata_aws;;
		azure) fake_metadata_azure;;
		gcp) fake_metadata_gcp;;
		oci) fake_metadata_oci;;
		scaleway) fake_metadata_scaleway;;
		*) echo "TODO: fake_metadata_$CLOUD" >&2;;
	esac
}

fake_interfaces() {
	local n=1
	for i; do
		mkdir -p sys/class/net/$i
		echo $n > sys/class/net/$i/ifindex
		echo down >sys/class/net/$i/operstate
		n=$((n+1))
	done
}
