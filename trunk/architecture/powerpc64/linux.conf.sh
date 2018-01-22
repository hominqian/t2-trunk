# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: architecture/powerpc64/linux.conf.sh
# Copyright (C) 2013 - 2018 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

{
	linux_arch=GENERIC_CPU
	for x in "generic	GENERIC_CPU"	\
		 "power3	POWER3_CPU"	\
		 "power4	POWER4_CPU"	\
		 "G5		POWER4_CPU"	\
		 "power5	POWER5_CPU"	\
		 "power6	POWER6_CPU"	\
		 "power7	POWER7_CPU"
	do
		set $x
		[[ "$SDECFG_POWERPC64_OPT" = $1 ]] && linux_arch=$2
	done

	for x in GENERIC_CPU POWER3_CPU POWER4_CPU POWER5_CPU POWER6_CPU POWER7_CPU
	do
		if [ "$linux_arch" != "$x" ]
		then echo "# CONFIG_$x is not set"
		else echo "CONFIG_$x=y" ; fi
	done

	echo
	cat <<- 'EOT'
 		include(`linux.conf.m4')
	EOT
} | m4 -I $base/architecture/$arch -I $base/architecture/powerpc -I $base/architecture/share
