# Tiny Cloud

The Tiny Cloud bootstrapper performs critical initialization tasks for cloud
instances during their first boot.  Unlike the more popular and feature-rich
[cloud-init](https://cloudinit.readthedocs.io/en/latest), Tiny Cloud seeks to
do just what is necessary with a small footprint and minimal dependencies.

A direct descendant of [tiny-ec2-bootstrap](
https://gitlab.alpinelinux.org/alpine/cloud/tiny-ec2-bootstrap), Tiny Cloud
works with multiple cloud providers.  Currently, the following are supported:
* [AWS](https://aws.amazon.com): Amazon Web Services
* [Azure](https://azure.microsoft.com): Microsoft Azure
* [GCP](https://cloud.google.com): Google Cloud Platform
* [OCI](https://cloud.oracle.com): Oracle Cloud Infrastructure
* [NoCloud](
    https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html
    ):
    cloud-init's NoCloud AWS-compatible user provided data source

## Features

The following actions will occur ***only once***, during the initial boot of an
instance:
* expand the root filesystem to use all available root device space, during the
  **sysinit** runlevel
* set the instance's hostname from instance metadata
* install SSH keys from instance metadata to the cloud user account's
  `authorized_keys` file (the user must already exist)
* save the instance user-data to a file, and if it's a script, execute it at
  the end of the **default** runlevel

Optional features, which may not be universally necessary:
* manage hotpluggable network interfaces
* sync IMDS-provided secondary IPv4 and IPv6 addresses network interfaces
* manage symlinks from NVMe block devices to `/dev/xvd` or `/dev/sd` devices
  (i.e. AWS Nitro instances)

Also included is a handy `imds` client script for easy access to an instance's
IMDS data.

## Requirements

As Tiny Cloud is meant to be tiny, it has very few dependencies:
* Busybox (`ash`, `wget`, etc.)
* `ifupdown-ng` (optional, for network management)
* `iproute2-minimal` (optional, for syncing IPv4/IPv6 from IMDS)
* `nvme-cli` (optional, for AWS nitro NVMe symlinks)
* `partx`
* `resize2fs`
* `sfdisk`
* [`yx`](https://gitlab.com/tomalok/yx)
  (optional, allows NoCloud to extract metadata from YAML files)

Tiny Cloud has been developed specifically for use with the
[Alpine Cloud Images](
  https://gitlab.alpinelinux.org/alpine/cloud/alpine-cloud-images)
project, and as such, it is currently tailored for use with [Alpine Linux](
https://alpinelinux.org), the [OpenRC](https://github.com/OpenRC/openrc) init
system, and the `ext4` root filesystem.  If you would like to see Tiny Cloud
supported on additional distributions, init systems, and/or filesystems, please
open an issue with your request -- or better yet, submit a merge request!

## Installation

Typically, Tiny Cloud is installed and configured when building a cloud image,
and is available on Alpine Linux as the [`tiny-cloud`](
  https://pkgs.alpinelinux.org/packages?name=tiny-cloud*) APKs...
```
apk add tiny-cloud-<cloud>
```
This will install the necessary init scripts, libraries, etc. plus any missing
dependencies for Tiny Cloud to support _`<cloud>`_.

Alternately, you can download a release tarball, and use `make` to install it.

Next, enable the three primary init scripts...
```
rc-update add tiny-cloud-early sysinit
rc-update add tiny-cloud default
rc-update add tiny-cloud-final default
```

## Configuration

By default, Tiny Cloud expects configuration at `/etc/tiny-cloud.conf`,
The stock [lib/tiny-cloud/tiny-cloud.conf`](lib/tiny-cloud/tiny-cloud.conf)
file contains details of all tuneable settings.

_Because Tiny Cloud does not currently do auto-detection, you **MUST** set a
configuration value for `CLOUD` indicating which cloud provider will be used.
Current valid values are `aws`, `azure`, `gcp`, `oci`, and `nocloud`._

## Operation

The first time an instance boots -- either freshly instantiated from an image,
or after installation on a pre-existing instance -- Tiny Cloud sets up the
instance in three phases...

### Early Phase

The `tiny-cloud-early` init script does not depend on the cloud provider's
Instance MetaData Service (IMDS), and therefore does not have a dependency on
networking.  During this "early" phase, the root filesystem is expanded, and
any necessary `mdev` rules for device hotplug are set up.

### Main Phase

The main `tiny-cloud` init script *does* depend on the cloud provider's IMDS
data; it saves the instance's user data to `/var/lib/cloud/user-data`, sets up
instance's hostname, and installs the cloud user's SSH keys before `sshd`
starts.

If the user data is compressed, Tiny Cloud will decompress it.  Currently
supported compression algorithms are `gzip`, `bzip2`, `unxz`, `lzma`, `lzop`,
`lz4`, and `zstd`.  _(Note that `lz4` and `zstd` are not installed in Alpine
by default, and would need to be added to the image.)_

### Final Phase

`tiny-cloud-final` should be the very last init script to run in the
**default** runlevel.

If the user data is a script starting with `#!/`, it will be executed; its
output (combined STDOUT and STDERR) and exit code are saved to
`/var/log/user-data.log` and `/var/log/user-data.exit`, respectively; the
directory is overrideable via the `TINY_CLOUD_LOGS` config setting.

If all went well, the very last thing `tiny-cloud-final` does is touch
a `.bootstrap-complete` file into existence in `/var/lib/cloud` or another
directory specified by the `TINY_CLOUD_VAR` config setting.

### Skipping Init Actions

If you need to skip any individual init script actions (for example, if you
have a different means to set the instance hostname), you can set the
`SKIP_INIT_ACTIONS` config to a whitespace-separated list of actions to skip.

### Further Reboots

After the initial bootstrap of an instance, the init scripts are largely a
no-op.

To force the init scripts to re-run on the next boot...
```
rm -f /var/lib/cloud/.bootstrap-complete
```
or
```
service tiny-cloud incomplete
```
If you're instantiating an instance in order to create a new cloud image
(using [Packer](https://packer.io), or some other means), you will need to
do this before creating the image to ensure that instances using the new
image will also run Tiny Cloud init scripts during their first boot.

## Cloud Hotplug Modules

### `vnic_eth_hotplug`

This hotplug module adds and removes ethernet interfaces as virtual NICs are
attached/detached from the instance.

An `ifupdown-ng` executor also syncs the interfaces' secondary IPv4 and IPV6
addresses associated with those VNICs, if the cloud's IMDS provides that
configuration data.

### `nvme_ebs_links`

EBS volumes are attached to AWS EC2 Nitro instances using the NVMe driver.
Unfortunately, the `/dev/nvme*` device names do not match the device name
assigned to the attached EBS volume.  This hotplug module figures out what the assigned device name is, and sets up `/dev/xvd*` and `/dev/sd*` symlinks to
the right NVMe devices for EBS volumes and their partitions.

_(deprecated, see [CHANGELOG.md](CHANGELOG.md))_
