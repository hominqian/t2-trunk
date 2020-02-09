# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: target/reference/build.sh
# Copyright (C) 2004 - 2020 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

build_result="$build_toolchain/result"

pkgloop_action() {

	# Rebuild command line without '$cmd_maketar'
	#
	cmd_buildpkg="./scripts/Build-Pkg -$stagelevel -cfg $config"
	cmd_buildpkg="$cmd_buildpkg $cmd_root $cmd_prefix $pkg_name"

	# Build package
	#
	$cmd_buildpkg ; rc=$?

	# Copy *.cache file
	#
	if [ -f "$build_root/var/adm/cache/$pkg_name" ] ; then
		dir="$build_result/package/$pkg_tree/$pkg_name" ; mkdir -p $dir
		cp $build_root/var/adm/cache/$pkg_name $dir/$pkg_name.cache
	fi

	return $rc
}

pkgloop

echo_header "Finishing build."

mkdir -p "$build_result/scripts"

echo_status "Copying error logs and t2-debug data."
mkdir -p $build_result/{errors,t2-debug,dep-debug}
cp $build_root/var/adm/t2-debug/* $build_result/t2-debug/
cp $build_root/var/adm/dep-debug/* $build_result/dep-debug/
cp $build_root/var/adm/logs/*.err $build_result/errors/

echo_status "Creating package database ..."
admdir="build/${SDECFG_ID}/var/adm"
create_package_db $admdir build/${SDECFG_ID}/TOOLCHAIN/pkgs \
	build/${SDECFG_ID}/TOOLCHAIN/pkgs/packages.db

echo_status "Creating isofs.txt file .."
cat << EOT > build/${SDECFG_ID}/TOOLCHAIN/isofs.txt
DISK1	$admdir/cache/					${SDECFG_SHORTID}/info/cache/
DISK1	$admdir/cksums/					${SDECFG_SHORTID}/info/cksums/
DISK1	$admdir/dependencies/				${SDECFG_SHORTID}/info/dependencies/
DISK1	$admdir/descs/					${SDECFG_SHORTID}/info/descs/
DISK1	$admdir/flists/					${SDECFG_SHORTID}/info/flists/
DISK1	$admdir/md5sums/				${SDECFG_SHORTID}/info/md5sums/
DISK1	$admdir/packages/				${SDECFG_SHORTID}/info/packages/
EVERY	build/${SDECFG_ID}/TOOLCHAIN/pkgs/packages.db	${SDECFG_SHORTID}/pkgs/packages.db
SPLIT	build/${SDECFG_ID}/TOOLCHAIN/pkgs/			${SDECFG_SHORTID}/pkgs/
EOT

echo_header "Reference build finished."

cat <<- EOT > build/${SDECFG_ID}/TOOLCHAIN/result/copy-cache.sh
	#!/bin/sh
	cd $base/build/${SDECFG_ID}/TOOLCHAIN/result
	find package -type f | while read fn
	do [ -f ../../../\${fn%.cache}.desc ] && cp -v \$fn ../../../\$fn; done
	cd ../../..
EOT
chmod +x build/${SDECFG_ID}/TOOLCHAIN/result/copy-cache.sh

echo_status "Results are stored in the directory"
echo_status "build/$SDECFG_ID/TOOLCHAIN/result/."
