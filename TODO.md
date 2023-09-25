# TODO

## SOON-ish

* Should the extra stuff that the `alpine` installer cloud does also apply to
  the `nocloud` cloud?  If so, move it there, and the installer is entirely
  handled by the user-data handler.

* Package user-data handlers separately?

* `#cloud-config` user-data handler (support a useful subset)


## FUTURE

* cloud auto-detection?

* `#tiny-config` user-data handler (should be simple-yet-flexible)

* `imds-net-sync` improvements
  * Feature parity with current [amazon-ec2-net-utils](
    https://github.com/amazonlinux/amazon-ec2-net-utils)
  * Support for non-AWS clouds
  * Daemonize to pick up IMDS network changes between reboots
  * ***OR DEPRECATE AND NOT INSTALL FOR AWS BY DEFAULT***
    * `dhcpcd` seems to work just fine with multiple IPv6 delivered via DHCPv6
    * secondary IPv4 on an interface may be an edge case
    * probably want to keep the `vnic-eth-hotplug` portion around for adding
      and removing VNICs

* Support LVM partitioning and non-`ext[234]` filesystems
