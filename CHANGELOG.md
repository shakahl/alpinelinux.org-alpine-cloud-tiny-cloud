# CHANGELOG

## UNRELEASED - Tiny Cloud v3.0.x

* Replace non-functioning `tiny-cloud --setup` with working `--enable` and
  `--disable` to enable/disable the set of Tiny Cloud init scripts.

## 2023-06-12 - Tiny Cloud v3.0.1

* Adds support for additional `ssh-authorized-keys` via userdata for
  experimental Alpine auto installer.

## 2023-05-31 - Tiny Cloud v3.0.0

### INIT SCRIPTS / PHASES

* Tiny Cloud has been reorganized into **four** init script phases...
  * `boot` - "boot" runlevel, after `syslogd` is started, and before
    networking is up.
  * `early` - "default" runlevel, after networking is up, but *before*
    user-data is made available.  This phase is responsible for pulling in
    user-data for *later* phases.
  * `main` - "default" runlevel, after user-data is available.  Most things
    get done here.
  * `final` - "default" runlevel, after all other init scripts have finished.
    Typically user-data scripts are run here, and bootstrap status is marked
    as complete.

* Tiny Cloud init functionality has been consolidated into **/sbin/tiny-cloud**
  and init scripts should use `tiny-cloud <phase>` to indicate whether `boot`,
  `early`, `main`, or `final` actions should be taken.

* Use `tiny-cloud --setup` to add/update Tiny Cloud's init scripts into the
  right runlevels.  Currently only OpenRC is supported.

* The example OpenRC init scripts been updated and moved to **dist/openrc/**.

### NEW STUFF

* Tiny Cloud now supports the concept of user-data handlers, to support acting
  on different payload content-types.

* Clouds and user-data handlers can specify their own (or supercede the default)
  init functions and/or change the init phase in which they are executed. The
  order of declaration is default --> cloud --> user-data (last one wins).

* We now have an experimental `alpine` installer "cloud", based on NoCloud,
  and an associated `#alpine-config` user-data handler, which supports a subset
  of `#cloud-config` features, plus some extensions.  As this is new, we expect
  it to experience some continued evolution.

* Also thanks to Nataniel Copa (@ncopa), Tiny Cloud now has unit tests.

### DEPRECATION

* `nvme-ebs-symlinks` has been _deprecated_ and disabled by default.  The
  **mdev-conf** package, as of v4.4 is now responsible for maintaining NVMe
  device symlinks for AWS.

  ***WARNING:*** The behavior of **mdev-conf** is slightly different -- either
  **/dev/sd** or **/dev/xvd** symlinks are created as indicated in NVMe device
  metadata, *but NOT both*!

### MISCELLANEOUS

* Tiny Cloud configuration has moved to **/etc/tiny-cloud.conf**.

* `imds` now supports `@local-hostname` alias.  For most clouds this is the
  same as `@hostname`.

* Fixed setting `local-hostname` metadata from **/proc/cmdline** for NoCloud.

----
_CHANGELOG begins 2023-04-29_
