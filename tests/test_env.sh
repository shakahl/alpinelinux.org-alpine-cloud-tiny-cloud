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

fake_userdata_nocloud() {
	local file="$(mktemp -p "$PWD")"
	cat > "$file"
	fake_bin mount <<-EOF
		#!/bin/sh
		# find last arg which is the mount dir
		while ! [ -d "\$1" ]; do
			shift
		done
		cp "$file" "\$1"/user-data
	EOF
	mkdir -p mnt
}

