# Tiny Cloud

The Tiny Cloud bootstrapper performs critical initialization tasks for cloud
instances during their first boot.  Unlike the more popular and feature-rich
[cloud-init](https://cloudinit.readthedocs.io/en/latest), Tiny Cloud seeks to
do just what is necessary with a small footprint and minimal dependencies.

A direct descendant of [tiny-ec2-bootstrap](
https://gitlab.alpinelinux.org/alpine/cloud/tiny-ec2-bootstrap), Tiny Cloud
works with multiple cloud providers.  Currently, the following are supported:
* [AWS](https://aws.amazon.com) - Amazon Web Services
* [Azure](https://azure.microsoft.com) - Microsoft Azure
* [GCP](https://cloud.google.com) - Google Cloud Platform
* [OCI](https://cloud.oracle.com) - Oracle Cloud Infrastructure
* [NoCloud](
  https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html
  ) - cloud-init's NoCloud AWS-compatible user provided data source

Tiny Cloud is also used for Alpine Linux's experimental "auto-install" feature.

## Features

The following actions will occur ***only once***, during the initial boot of an
instance:
* expand the root filesystem to use all available root device space
* set up default network interfaces, if necessary
* enable `sshd`, if necessary
* save instance user-data to a file, decompress if necessary
* create default cloud user, if necessary
* set the instance's hostname from instance meta-data
* install SSH keys from instance meta-data to the cloud user account's
  `authorized_keys` file
* if instance user-data is a script, execute it at the end of the **default**
  runlevel
* mark the bootstrap of the instance as "complete"

Optional features, which may not be universally necessary:
* manage hotpluggable virtual network interfaces
* sync IMDS-provided secondary IPv4 and IPv6 network configuration

Other cloud- and user-data-specific actions may also occur.

Also included is a handy `imds` client script for easy access to an instance's
IMDS data.

## Requirements

As Tiny Cloud is meant to be tiny, it has few dependencies:
* Busybox (`ash`, `wget`, etc.)
* `e2fsprogs-extra` (for `resize2fs`)
* `openssh-server`
* `partx`
* `sfdisk`
* [`yx`](https://gitlab.com/tomalok/yx) (for extracting data from YAML files)

Optional dependencies:
* `ifupdown-ng` (for network management)
* `iproute2-minimal` (for syncing IPv4/IPv6 from IMDS)
* `nvme-cli` (for AWS nitro NVMe symlinks)

_Tiny Cloud has been developed specifically for use with the
[Alpine Cloud Images](
  https://gitlab.alpinelinux.org/alpine/cloud/alpine-cloud-images)
project, and as such, it is currently tailored for use with [Alpine Linux](
https://alpinelinux.org), the [OpenRC](https://github.com/OpenRC/openrc) init
system, and the `ext4` root filesystem.  If you would like to see Tiny Cloud
supported on additional distributions, init systems, and/or filesystems, please
open an issue with your request -- or better yet, submit a merge request!_

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

Next, enable the RC scripts...
```
tiny-cloud --enable
```

That's it!  On the next boot, Tiny Cloud will bootstrap the instance.

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
instance in four phases...

### Boot Phase

This phase does not depend on the cloud provider's Instance Meta-Data Service
(IMDS), and does not require networking to be up.  `mdev` hotplug modules are
installed (if any), default networking confinguration is set up, `sshd` is
enabled (but not started), and the root partition is expanded.

### Early Phase

After networking is up, and the cloud provider's IMDS is available, this phase
is primarily responsible for retrieving the instance's User-Data for use by
later phases.

User-Data is stored at `/var/lib/cloud/user-data`, and will be decompressed, if
necessary.  Currently supported compression algorithms are `gzip`, `bzip2`,
`unxz`, `lzma`, `lzop`, `lz4`, and `zstd`.  _(Note that `lz4` and `zstd` are
not installed in Alpine by default, and would need to be added to the image.)_

### Main Phase

When networking, IMDS, and User-Data are all availabile, this is the phase
takes care of the majority of bootstrapping actions that require them --
setting up the instance hostname, creating default cloud user, and installing
SSH keys for it.

Additional main phase actions may be taken if there is a User-Data handler
defined for its content type, and those actions are associated with the main
phase.

### Final Phase

The very last thing to be run in the **default** runlevel this phase will
execute the saved User-Data, if it is a script starting with `#!`; its output
(combined STDOUT and STDER) and exit code are saved to `/var/log/user-data.log`
and `/var/log/user-data.exit`.

Additional final phase actions may be taken if there is a User-Data handler
defined for its content type, and those actions are associated with the final
phase.

The very last action to be taken is to mark the instance's bootstrap as
"complete", so that future reboots do not re-boostrap the instance.

### Skipping Init Actions

If you need to skip any individual init script actions (for example, if you
have a different means to set the instance hostname), you can set the
`SKIP_INIT_ACTIONS` config to a whitespace-separated list of actions to skip.

### Further Reboots

After the initial bootstrap of an instance, the init scripts are largely a
no-op.

To force the init scripts to re-run on the next boot...
```
tiny-cloud --bootstrap incomplete
```
If you're instantiating an instance in order to create a new cloud image
(using [Packer](https://packer.io), or some other means), you will need to
do this before creating the image to ensure that instances using the new
image will also run Tiny Cloud init scripts during their first boot.

To check the status of the Tiny Cloud bootstrap, use...
```
tiny-cloud --bootstrap status
```
...which will either respond with `complete` or `incomplete`

## Cloud Hotplug Modules

### `vnic_eth_hotplug`

This hotplug module adds and removes ethernet interfaces as virtual NICs are
attached/detached from the instance.

An `ifupdown-ng` executor also syncs the interfaces' secondary IPv4 and IPV6
addresses associated with those VNICs, if the cloud's IMDS provides that
configuration data.
