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
	local file="$(mktemp -p "$PWD")"
	cat > "$file"
	fake_bin mount <<-EOF
		#!/bin/sh
		# find last arg which is the mount dir
		while ! [ -d "\$1" ]; do
			shift
		done
		cp "$file" "\$1"/$datafile
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

fake_interfaces() {
	local n=1
	for i; do
		mkdir -p sys/class/net/$i
		echo $n > sys/class/net/$i/ifindex
		echo down >sys/class/net/$i/operstate
		n=$((n+1))
	done
}
