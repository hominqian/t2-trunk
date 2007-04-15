# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: target/pkgdist/build.sh
# Copyright (C) 2006 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---
#
#Description: Distribute binary packages to (remote) location

if [ "$SDECFG_TARGET_PKGDIST_LOCATION" ]; then
	echo_header "Package distribution"

	case "$SDECFG_TARGET_PKGDIST_LOCATION" in
	http:*|ftp:*)
		echo_warning "Remote package distribution not supported yet"
		;;
	*)
		echo_status "Copying package files to $SDECFG_TARGET_PKGDIST_LOCATION..."
		mkdir -p $SDECFG_TARGET_PKGDIST_LOCATION
		cp -a $base/build/$SDECFG_ID/TOOLCHAIN/pkgs/* $SDECFG_TARGET_PKGDIST_LOCATION/
		;;
	esac
fi

exit

