# NEXT

* `nvme-ebs-symlinks` hase been _deprecated_ and disabled by default.  The **mdev-conf** package, as of v4.4 is now responsible for maintaining NVMe device symlinks for AWS.

  ***WARNING:*** The behavior of **mdev-conf** is slightly different -- only **/dev/sd** or **/dev/xvd** symlinks are created, *not both*!

----
_CHANGELOG begins 2023-04-29_
