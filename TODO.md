# TODO

## Tiny Cloud v3.0.0

* Support for Alpine Linux ISO auto-install via NoCloud `CIDATA` volumes, which
  have pre-network access to UserData and MetaData.  Adjust phase actions as
  appropriate.

* Detect UserData content type.  In addition to handling `#!` scripts and raw
  data, provide basic handling a subset of `#cloud-config` directives.

## FUTURE

* `imds-net-sync` improvements
  * Feature parity with current [amazon-ec2-net-utils](
    https://github.com/amazonlinux/amazon-ec2-net-utils)
  * Support for non-AWS clouds
  * daemonize to pick up IMDS network changes between reboots
