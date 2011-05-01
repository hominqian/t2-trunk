dnl --- T2-COPYRIGHT-NOTE-BEGIN ---
dnl This copyright note is auto-generated by ./scripts/Create-CopyPatch.
dnl 
dnl T2 SDE: architecture/powerpc64/kernel.conf.m4
dnl Copyright (C) 2004 - 2011 The T2 SDE Project
dnl 
dnl More information can be found in the files COPYING and README.
dnl 
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; version 2 of the License. A copy of the
dnl GNU General Public License can be found in the file COPYING.
dnl --- T2-COPYRIGHT-NOTE-END ---
define(`PPC', 'PowerPC')dnl

dnl System type (default=Macintosh)
dnl
CONFIG_PPC=y
# CONFIG_PPC32 is not set
CONFIG_PPC64=y
CONFIG_64BIT=y
CONFIG_6xx=y
# CONFIG_4xx is not set
# CONFIG_82xx is not set
# CONFIG_8xx is not set
CONFIG_PMAC=y
CONFIG_PMAC64=y
# PPC_PMAC is not set
CONFIG_PPC_PMAC64=y
# CONFIG_PREP is not set
# CONFIG_CHRP is not set
# CONFIG_ALL_PPC is not set
# CONFIG_GEMINI is not set
# CONFIG_APUS is not set
CONFIG_MACH_SPECIFIC=y

dnl additional 2.6 kernel configs
# CONFIG_40x is not set
# CONFIG_POWER3 is not set

CONFIG_ALTIVEC=y

CONFIG_NR_CPUS=32

dnl Platform specific support
dnl

CONFIG_PROC_DEVICETREE=y

CONFIG_ADB=y
CONFIG_ADB_CUDA=y
CONFIG_ADB_PMU=y
CONFIG_PMAC_SMU=y

include(`kernel-common.conf.m4')
include(`kernel-block.conf.m4')
include(`kernel-net.conf.m4')
include(`kernel-fs.conf.m4')

dnl macs need a special RTC ... (this needs to be fixed in the kernel so we
dnl can have generic support for the rs6k and mac support at the same time)
dnl
CONFIG_GEN_RTC=y
CONFIG_PPC_RTC=y

dnl macs need an FB
dnl
CONFIG_FB_RADEON=y
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
CONFIG_FB_MATROX=m

dnl AGP
dnl
CONFIG_AGP_UNINORTH=y

dnl power management
dnl
CONFIG_PMAC_PBOOK=y
CONFIG_PMAC_BACKLIGHT=y
CONFIG_PMAC_APM_EMU=y
dnl the thermal control stuff needed for newer desktop macs and iBook G4
dnl
CONFIG_I2C=y
CONFIG_I2C_KEYWEST=y

CONFIG_THERM_PM72=y
CONFIG_WINDFARM=y
CONFIG_WINDFARM_PM81=y
CONFIG_WINDFARM_PM91=y
CONFIG_WINDFARM_PM112=y
CONFIG_WINDFARM_PM121=y

dnl for 2.6 kernels
dnl
CONFIG_TAU=y

CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_PMAC=y
CONFIG_CPU_FREQ_26_API=y
CONFIG_CPU_FREQ_PMAC64=y

CONFIG_BLK_DEV_IDE_PMAC=y
CONFIG_BLK_DEV_IDE_PMAC_ATA100FIRST=y
CONFIG_BLK_DEV_IDEDMA_PMAC=y
CONFIG_BLK_DEV_IDE_PMAC_BLINK=y
CONFIG_PMU_HD_BLINK=y
# CONFIG_MAC_ADBKEYCODES is not set

dnl some network teaks (the GMAC is obsoleted by SUNGEM)
dnl
# CONFIG_GMAC is not set
CONFIG_SUNGEM=m
