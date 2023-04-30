# CHANGELOG

## 2023-05-XX - Tiny Cloud v3.0.0

* Tiny Cloud init functionality has been consolidated into **/sbin/tiny-cloud**
  and init scripts should use `tiny-cloud <phase>` to indicate whether `early`,
  `main`, or `final` actions should be taken.  Additionally, it is now possible
  for clouds to specify their own (or supercede the default) init functions
  and/or change which init phase they are executed in.

  The example OpenRC init scripts been updated and moved to **dist/openrc/**.

* Tiny Cloud configuration has moved to **/etc/tiny-cloud.conf**.

* `nvme-ebs-symlinks` has been _deprecated_ and disabled by default.  The
  **mdev-conf** package, as of v4.4 is now responsible for maintaining NVMe
  device symlinks for AWS.

  ***WARNING:*** The behavior of **mdev-conf** is slightly different -- either
  **/dev/sd** or **/dev/xvd** symlinks are created as indicated in NVMe device
  metadata, *but NOT both*!

* `imds` now supports `@local-hostname` alias.  For most clouds this is the
  same as `@hostname`.

* Fixed setting `local-hostname` metadata from **/proc/cmdline** for NoCloud.

----
_CHANGELOG begins 2023-04-29_
