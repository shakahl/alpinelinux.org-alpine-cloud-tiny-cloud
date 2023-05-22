# TODO

## FUTURE

* cloud auto-detection

* `#cloud-config` user-data handler (support a useful subset)

* `#tiny-config` user-data handler (should be simple-yet-flexible)

* `imds-net-sync` improvements
  * Feature parity with current [amazon-ec2-net-utils](
    https://github.com/amazonlinux/amazon-ec2-net-utils)
  * Support for non-AWS clouds
  * daemonize to pick up IMDS network changes between reboots

* Support LVM partitioning and non-`ext[234]` filesystems
