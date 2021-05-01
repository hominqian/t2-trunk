dnl --- T2-COPYRIGHT-NOTE-BEGIN ---
dnl This copyright note is auto-generated by scripts/Create-CopyPatch.
dnl 
dnl T2 SDE: architecture/microblaze/linux.conf.m4
dnl Copyright (C) 2004 - 2021 The T2 SDE Project
dnl 
dnl More information can be found in the files COPYING and README.
dnl 
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; version 2 of the License. A copy of the
dnl GNU General Public License can be found in the file COPYING.
dnl --- T2-COPYRIGHT-NOTE-END ---

define(`MICROBLAZE', 'Microblaze')dnl

dnl Microblaze
dnl

CONFIG_HZ_100=y
CONFIG_PCI=y
CONFIG_NET=y
CONFIG_UNIX=y
CONFIG_INET=y
CONFIG_VIRTIO_BLK=y
CONFIG_NETDEVICES=y
CONFIG_VIRTIO_NET=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_OF_PLATFORM=y
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO_MMIO=y
CONFIG_EXT4_FS=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')
