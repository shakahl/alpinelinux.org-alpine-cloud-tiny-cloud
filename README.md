# Tiny Cloud

The Tiny Cloud bootstrapper performs critical initialization tasks for cloud
instances during their first boot.  Unlike the more popular and feature-rich
[cloud-init](https://cloudinit.readthedocs.io/en/latest), Tiny Cloud seeks to
do just what is necessary with a small footprint and minimal dependencies.

A direct descendant of [tiny-ec2-bootstrap](
https://gitlab.alpinelinux.org/alpine/cloud/tiny-ec2-bootstrap), Tiny Cloud
works with multiple cloud providers.  Currently, the following are supported:
* AWS (Amazon Web Services)
* Azure (Microsoft Azure)
* GCP (Google Cloud Platform)
* OCI (Oracle Cloud Infrastructure)

## Features

The following actions will occur ***only once***, during the initial boot of an
instance:
* expand the root filesystem to use all available root device space, during the
  **sysinit** runlevel
* set the instance's hostname from instance metadata
* install SSH keys from instance metadata to the cloud user account's
  `authorized_keys` file (the user must already exist)
* save the instance user-data to a file and if it's a script, execute it at the
  end of the **default** runlevel 

Optional features, which may not be universally necessary:
* manage symlinks from NVMe block devices to `/dev/xvd` and `/dev/sd` devices
  (i.e. AWS Nitro instances)
* manage secondary IPv4 and IPv6 addresses on network interfaces

## Requirements

As Tiny Cloud is meant to be tiny, it has very few dependencies:
* Busybox (`ash`, `wget`, etc.)
* `partx`
* `resize2fs`
* `sfdisk`

Tiny Cloud has been developed specifically for use with the
[Alpine Cloud Images](https://gitlab.alpinelinux.org/alpine/cloud/alpine-cloud-images)
project, and as such, it is currently tailored for use with [Alpine Linux](
https://alpinelinux.org), the [OpenRC](https://github.com/OpenRC/openrc) init
system, and the `ext4` root filesystem.  If you would like to see Tiny Cloud
supported on additional distributions, init systems, and/or filesystems, please
open an issue with your request -- or better yet, submit a merge request!

## Installation

Typically, Tiny Cloud is installed and configured when building a cloud image,
and is available on Alpine Linux as the [`tiny-cloud`](
https://pkgs.alpinelinux.org/packages?name=tiny-cloud) APK...
```
apk install tiny-cloud
```
This will install the necessary init scripts, libraries, etc. plus any missing
dependencies.

Alternately, you can download a release tarball, and use `make` to install it.

Next, enable the three primary init scripts...
```
rc-update add tiny-cloud-early sysinit
rc-update add tiny-cloud default
rc-update add tiny-cloud-final default
```

## Configuration

Tiny Cloud looks expects configuration to be found at
[`/etc/conf.d/tiny-cloud`](etc/conf.d/tiny-cloud), which documents all
tuneable parameters (and their defaults).

However, because Tiny Cloud does not do auto-detection, you ***must*** set a
value for `CLOUD` indicating which cloud provider which will be used when
instantiating the image.  Current valid values are `aws`, `azure`, `gcp`, and
`oci`.

## Operation

The first time an instance boots -- either freshly instantiated from an image,
or after installation on an existing instance -- Tiny Cloud sets up the
instance in three phases...

### Early Phase

The `tiny-cloud-early` init script does not depend on the cloud provider's
Instance MetaData Service (IMDS), and does therefore does not have a dependency
on networking.  During this "early" phase, the root filesystem is expanded, and
any necessary `mdev` rules for device hotplug are set up.

### Main Phase

The main `tiny-cloud` init script *does* depend on the cloud provider's IMDS
data, and sets up instance's hostname and the cloud user's SSH keys before
`sshd` starts.

### Final Phase

`tiny-cloud-final` should be the very last init script to run in the
**default** runlevel, and saves the instance's user data to
`/var/lib/cloud/user-data`.

If the user data is a script that starts with `#!` (aka "[shebang](
https://en.wikipedia.org/wiki/Shebang_(Unix))"), it will be executed; its
output (combined STDOUT and STDERR) is saved to `/var/log/cloud/user-data.log`
and the exit code can be found in `/var/log/cloud/user-data.exit`.

If all went well, the very last thing `tiny-cloud-final` does is touch
`/var/lib/cloud/.bootstrap-complete` into existence.

### Further Reboots

After the initial bootstrap of an instance, the init scripts are largely a
no-op.

To force the init scripts to re-run on the next boot...
```
rm -f /var/lib/cloud/.bootstrap-complete
```
If you're instantiating an instance in order to create a new cloud image
(using [Packer](https://packer.io), or some other means), you will need to
remove this file before creating the image to ensure that instances using the
new image will also run Tiny Cloud init scripts during their first boot.
