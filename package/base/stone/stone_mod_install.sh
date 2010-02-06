# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../stone/stone_mod_install.sh
# Copyright (C) 2004 - 2010 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

part_mounted_action() {
	if gui_yesno "Do you want to un-mount the filesystem on $1?"
	then umount /dev/$1; fi
}

part_swap_action() {
	if gui_yesno "Do you want to de-activate the swap space on $1?"
	then swapoff /dev/$1; fi
}

part_mount() {
	local dir
	gui_input "Mount device $1 on directory
(for example /, /home, /var, ...)" '/' dir
	if [ "$dir" ] ; then
		dir="$( echo $dir | sed 's,^/*,,; s,/*$,,' )"
		if [ -z "$dir" ] || grep -q " /mnt/target " /proc/mounts
		then
			mkdir -p /mnt/target/$dir
			mount /dev/$1 /mnt/target/$dir
		else
			gui_message "Please mount a root filesystem first."
		fi
	fi
}

part_mkfs() {
	dev=$1
	cmd="gui_menu part_mkfs 'Create filesystem on $dev'"

	maybe_add () {
	  if grep -q $1 /proc/filesystems && type -p $3 > /dev/null ; then
		cmd="$cmd '$1 ($2 filesystem)' '$3 $4 /dev/$dev'"
	  fi
	}

	maybe_add ext4  'journaling'            'mkfs.ext4'
	maybe_add ext3	'journaling'		'mkfs.ext3'
	maybe_add ext2	'non-journaling'	'mkfs.ext2'
	maybe_add reiserfs 'journaling'		'mkfs.reiserfs'
	maybe_add reiser4 'high-performance journaling' 'mkfs.reiser4'
	maybe_add jfs	'IBM journaling'	'mkfs.jfs'
	maybe_add xfs	'Sgi journaling'	'mkfs.xfs' '-f'

	eval "$cmd" && part_mount $dev
}

part_unmounted_action() {
	gui_menu part "$1" \
		"Mount an existing filesystem from the partition" \
				"part_mount $1" \
		"Create a filesystem on the partition" \
				"part_mkfs $1" \
		"Activate an existing swap space on the partition" \
				"swapon /dev/$1" \
		"Create a swap space on the partition" \
				"mkswap /dev/$1; swapon /dev/$1"
}

part_add() {
	local action="unmounted" location="currently not mounted"
	if grep -q "^/dev/$1 " /proc/swaps; then
		action=swap ; location="swap  <no mount point>"
	elif grep -q "^/dev/$1 " /proc/mounts; then
		action=mounted
		location="`grep "^/dev/$1 " /proc/mounts | cut -d ' ' -f 2 |
			  sed "s,^/mnt/target,," `"
		[ "$location" ] || location="/"
	fi

	# save partition information
	disktype /dev/$1 > /tmp/stone-install
	type="`grep /tmp/stone-install -v -e '^  ' -e '^Block device' \
	       -e '^Partition' -e '^---' | \
	       sed -e 's/[,(].*//' -e '/^$/d' -e 's/ $//' | tail -n 1`"
	size="`grep 'Block device, size' /tmp/stone-install | \
	       sed 's/.* size \(.*\) (.*/\1/'`"

	[ "$type" ] || type="undetected"
	cmd="$cmd '`printf "%-6s %-24s %-10s" ${1#*/} "$location" "$size"` $type' 'part_${action}_action $1 $2'"
}

disk_action() {
	if grep -q "^/dev/$1 " /proc/swaps /proc/mounts; then
		gui_message "Partitions from $1 are currently in use, so you
can't modify this disks partition table."
		return
	fi

	cmd="gui_menu disk 'Edit partition table of $1'"
	for x in parted cfdisk fdisk pdisk mac-fdisk ; do
		type -p $x > /dev/null &&
		  cmd="$cmd \"Edit partition table using '$x'\" \"$x /dev/$1\""
	done

	eval $cmd
}

vg_action() {
	cmd="gui_menu vg 'Volume Group $1'"

	if [ -d /dev/$1 ]; then
		cmd="$cmd 'Display attributes of $1' 'gui_cmd \"display $1\" vgdisplay $1'"

		if grep -q "^/dev/$1/" /proc/swaps /proc/mounts; then
		  cmd="$cmd \"LVs of $1 are currently in use, so you can't
de-activate it.\" ''"
		else
		  cmd="$cmd \"De-activate VG '$1'\" 'vgchange -an $1'"
		fi
	else
		cmd="$cmd 'Display attributes of $1' 'gui_cmd \"display $1\" vgdisplay -D $1'"

		cmd="$cmd \"Activate VG '$1'\" 'vgchange -ay $1'"
	fi

	eval $cmd
}

disk_add() {
	local x y=0
	cmd="$cmd 'Edit partition table of $1:' 'disk_action $1'"
	for x in $( cd /dev/ ; ls $1[0-9]* 2> /dev/null )
	do
		part_add $x ; y=1
	done
	[ $y = 0 ] && cmd="$cmd 'Partition table is empty.' ''"
	cmd="$cmd '' ''"
}

vg_add() {
	local x= y=0
	cmd="$cmd 'Logical volumes of $1:' 'vg_action $1'"
	if [ -d /dev/$1 ] ; then
		for x in $( cd /dev/ ; ls -1 $1/* ); do
			part_add $x ; y=1
		done
		if [ $y = 0 ]; then
			cmd="$cmd 'No logical volumes.' ''"
		fi
	else
		cmd="$cmd 'Volume Group is not active.' ''"
	fi
	cmd="$cmd '' ''"
}

main() {
	$STONE general set_keymap

	local cmd install_now=0
	while
		cmd="gui_menu install 'Disc setup (partitions and mount-points)

This dialog allows you to modify your discs parition layout and to create filesystems and swap-space - as well as mouting / activating it. Everything you can do using this tool can also be done manually on the command line.'"

		# protect for the case no discs are present ...
		found=0
		for x in /sys/block/*/device; do
			x=${x%/device}; x=${x#/sys/block/}
			[ "$x" = "*" ] && continue
			grep -q cdrom /proc/ide/$x/media 2>/dev/null && continue
			disk_add $x
			found=1
		done
		for x in $( cat /etc/lvmtab 2> /dev/null ); do
			vg_add "$x"
			found=1
		done
		[ -x /sbin/vgs ] && for x in $( vgs --noheadings -o name 2> /dev/null ); do
			vg_add "$x"
			found=1
		done
		if [ $found = 0 ]; then
		  cmd="$cmd 'No hard-disc found!' ''"
		fi

		cmd="$cmd 'Install the system ...' 'install_now=1'"

		eval "$cmd" && [ "$install_now" -eq 0 ]
	do : ; done

	if [ "$install_now" -ne 0 ] ; then
		$STONE packages
		mount -v /dev /mnt/target/dev --bind
		cat > /mnt/target/tmp/stone_postinst.sh << EOT
#!/bin/sh
mount -v /proc
mount -v /sys
. /etc/profile
stone setup
umount -v /dev
umount -v /proc
umount -v /sys
EOT
		chmod +x /mnt/target/tmp/stone_postinst.sh
		grep ' /mnt/target[/ ]' /proc/mounts | \
			sed 's,/mnt/target/\?,/,' > /mnt/target/etc/mtab
		cd /mnt/target ; chroot . ./tmp/stone_postinst.sh
		rm -fv ./tmp/stone_postinst.sh
		if gui_yesno "Do you want to un-mount the filesystems and reboot now?"
		then
			shutdown -r now
		else
			echo
			echo "You might want to umount all filesystems now and reboot"
			echo "the system now using the commands:"
			echo
			echo "	umount -arv"
			echo "	reboot -f"
			echo
			echo "Or by executing 'shutdown -r now' which will run the above commands."
			echo
		fi
	fi
}

