#!/bin/bash
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: target/livecd/build_image.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

. $base/misc/target/functions.in

set -e

mkdir -p $imagelocation ; cd $imagelocation

echo "Creating root file-system file lists ..."

pkg_skip=" ccache distcc "
for pkg in `grep '^X ' $base/config/$config/packages | cut -d ' ' -f 5`; do
	# include the package?
	if [ "${pkg_skip/ $pkg /}" == "$pkg_skip" ] ; then
		cut -d ' ' -f 2 $build_root/var/adm/flists/$pkg
	fi
done | sort -u > ../files-wanted

# for rsync with --delete we can not use file lists, since rsync does not
# delete in that mode - instead we need to generate a negative list

find $build_root -wholename $build_root/TOOLCHAIN -prune -o -printf '%P\n' |
	sort -u > ../files-all
# the difference
diff -u ../files-all ../files-wanted | grep '^-' | sed 's/^-//' > ../files-exclude

echo "Syncing root file-system (this may take some time) ..."
# we need to ignore the errors for now, since the some flists have a files
# that do not exist anymore - TODO: track why - post install moves?
rsync -artH --ignore-errors --delete --exclude-from ../files-exclude \
      --exclude TOOLCHAIN $build_root/ $imagelocation/ || true
rm ../files-{wanted,all,exclude}

echo "Overlaying root file-system with target defined files ..."
copy_and_parse_from_source $base/target/$target/rootfs $imagelocation

[ "$inject_hook" ] && "$inject_hook"

echo "Running ldconfig and other postinstall scripts ..."
mount /dev dev --bind
mount none proc -t proc
for x in sbin/ldconfig etc/postinstall.d/*; do
	case $x in
		*/scrollkeeper) echo "$x left out" ;;
		*) chroot . /$x && true
	esac
done
umount proc
umount dev

du -sh .
echo "Squashing root file-system (this may take some time) ..."
mksquashfs * $isofsdir/live.squash -noappend
du -sh $isofsdir/live.squash

