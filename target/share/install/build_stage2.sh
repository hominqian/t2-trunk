# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by scripts/Create-CopyPatch.
# 
# T2 SDE: target/share/install/build_stage2.sh
# Copyright (C) 2004 - 2021 The T2 SDE Project
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

echo_header "Creating 2nd stage filesystem:"
rm -rf $disksdir/2nd_stage*
mkdir -p $disksdir/2nd_stage; cd $disksdir/2nd_stage

# package map to include
package_map="00-dirtree zlib          parted             cryptsetup
xfsprogs           dosfstools         jfsutils           btrfs-progs
e2fsprogs          reiserfsprogs      reiser4progs       genromfs
popt               raidtools          mdadm              pcre
lvm                lvm2               device-mapper      libaio
dump               eject              disktype           mac-fdisk
hdparm             memtest86          cpuburn            bonnie++
ncurses            readline           libgpg-error       libgcrypt
bash               attr               acl                findutils
mktemp             coreutils          pciutils           libcap
grep               sed                gzip               bzip2
tar                gawk               lzo                lzop
less               nvi                bc                 cpio
xz                 zstd               ed                 zile
curl               dialog             minicom            kmod
lrzsz              rsync              tcpdump            module-init-tools
sysvinit           shadow             util-linux         wireless-tools
runit              runit-logacct      runit-shutdown
net-tools          procps             psmisc
modutils           pciutils           portmap
sysklogd           setserial          iproute2
netkit-base        netkit-ftp         netkit-telnet      netkit-tftp
sysfiles           libpcap            iptables           tcp_wrappers
stone              rocknet
kbd		   ntfsprogs          libol              memtester
openssl            openssh            iproute2"

# TODO: a global multilib package multiplexer that allows distrinct control
#       and avoids such hacks ...
if [ "$SDECFG_POWERPC64_32" = 1 -o "$SDECFG_SPARC64_32BIT" = 1 ]; then
	package_map="$package_map ${SDECFG_LIBC}32"
else
	package_map="$package_map ${SDECFG_LIBC}"
fi

if pkginstalled mine; then
	packager=mine
else
	packager=bize
fi

package_map=" $( echo "$packager $package_map" | tr '\n' ' ' | tr '\t' ' ' | tr -s ' ' ) "

echo_status "Copying files."
for pkg in `grep '^X ' $base/config/$config/packages | cut -d ' ' -f 5`; do
	# include the package?
	#echo maybe $pkg >&2
	if [ "${package_map/ $pkg /}" != "$package_map" ]; then
		cut -d ' ' -f 2 $build_root/var/adm/flists/$pkg
	fi
done | (
	# quick and dirty filter
	grep  -v -e 'lib[^/]*/[^/]*\.\(a\|la\|o\)$' \
	         -e 'var/\(adm\|games\|mail\|opt\)' \
	         -e 'usr/\(local\|doc\|man\|info\|games\|share\|include\|src\)' \
	         -e 'usr/.*-linux-gnu' -e '/gconv/' -e '/locale/' -e '/pkgconfig/' \
	         -e 'bin/.*-config' \
	         -e 'bin/install' -e 'bin/openssl' -e 'bin/localedef' \
	         -e '/init.d/' -e '/rc.d/'
	# TODO: usr/lib/*/
) > ../files-wanted

# some more stuff
cut -d ' ' -f 2 $build_root/var/adm/flists/{kbd,pciutils,ncurses} |
grep -e 'usr/share/terminfo/.*/\(ansi\|linux\|.*xterm.*\|vt.*\|screen\|tmux\)' \
     -e 'usr/share/kbd/keymaps/i386/\(include\|azerty\|qwertz\|qwerty\)' \
     -e 'usr/share/kbd/keymaps/include' \
     -e 'usr/share/pci.ids' \
 >> ../files-wanted

copy_with_list_from_file $build_root $PWD $PWD/../files-wanted

copy_and_parse_from_source $base/target/share/install/rootfs $PWD

echo_status "Creating usability sym-links."
[ ! -e usr/bin/vi -a -e usr/bin/nvi ] && ln -s nvi usr/bin/vi
[ ! -e usr/bin/emacs -a -e usr/bin/zile ] && ln -s zile usr/bin/emacs
[ -e usr/sbin/stone ] && ln -s stone usr/sbin/install

[ "$SDECFG_CROSSBUILD" != 1 ] && (chroot . /sbin/ldconfig || true)

echo '$STONE install' > etc/stone.d/default.sh

cd $disksdir/

echo_header "Creating 2nd_stage_small filesystem:"
mkdir -p 2nd_stage_small; cd 2nd_stage_small

mkdir -p share {,usr/}{,s}bin

# we re-use some of the initrd files, too!
progs="agetty sh bash cat cp date dd df dmesg ifconfig ln ls $packager mkdir \
       mkswap mount mv rm reboot route sleep swapoff swapon sync umount cut \
       setsid eject chmod chroot grep halt rmdir init shutdown uname killall5 \
       install stone tar mktemp sort fold sed mkreiserfs head tail disktype \
       login-shell stat gzip mkfs.ext3 mkfs.fat mkfs.xfs gasgui dialog stty  \
       wc fmt"

progs="$progs parted fdisk sfdisk"

if [[ $arch = powerpc* ]]; then
	progs="$progs mac-fdisk pdisk"
fi

if [ $packager = bize ]; then
	progs="$progs md5sum"
fi

for x in $progs; do
	fn=""
	for f in ../2nd_stage/{,usr/}{s,}bin/$x; do
		[ -e $f ] && fn=${f#../2nd_stage/} && break
	done

	if [ "$fn" ]; then
		mv ../2nd_stage/$fn $fn
	else
		echo_error "\`- Program not found: $x"
	fi
done

echo_status "Moving the required libraries ..."
found=1
while [ $found = 1 ]; do
	found=0
	for x in ../2nd_stage/{,usr/}lib{64,}; do
		for y in $( cd $x 2>/dev/null && ls *.so.* 2>/dev/null ); do
			dir=${x#../2nd_stage/}
			# TODO: maybe use readelf, too?
			if [ ! -f $dir/$y ] &&
			   grep -q $y {s,}bin/* usr/{s,}bin/* lib{64,}/* 2> /dev/null
			then
				echo_status "\`- Found $dir/$y."
				mkdir -p $dir
				xx=$x # save for update in symlink loop
				while z=`readlink $x/$y`; [ "$z" ]; do
					echo "	$dir/$y SYMLINKS to $z"
					mv $x/$y $dir/
					[[ $z = /* ]] && x=../2nd_stage/
					y=$z
				done
				mv $x/$y $dir/
				x=$xx
				found=1
			fi
		done
	done
done

#
echo_status "Move SDE-CONFIG."
mkdir -p etc/SDE-CONFIG
mv ../2nd_stage/etc/SDE-CONFIG/config etc/SDE-CONFIG/
echo_status "Move stone.d."
mkdir -p etc/stone.d
for i in gui_text gui_dialog mod_install mod_packages mod_gas default; do
	mv ../2nd_stage/etc/stone.d/$i.sh etc/stone.d
done
echo_status "Moving additional files."
mkdir -p usr/share/terminfo/{v,l}/
mv ../2nd_stage/usr/share/terminfo/l/linux usr/share/terminfo/l/
mv ../2nd_stage/usr/share/terminfo/v/vt102 usr/share/terminfo/v/
mv ../2nd_stage/root root

echo_status "Removing shared libraries already in initrd."

# remove libs already in the regular initrd, for each available kernel:
for x in `egrep 'X .* KERNEL .*' $base/config/$config/packages |
          cut -d ' ' -f 5`; do
  kernel=${x/_*/}
  for moduledir in `grep lib/modules $build_root/var/adm/flists/$kernel |
                   cut -d ' ' -f 2 | cut -d / -f 1-3 | uniq`; do
    kernelver=${moduledir/*\/}
    initrd="initrd-$kernelver"
    kernelimg=`ls $build_root/boot/vmlinu?-$kernelver`
    kernelimg=${kernelimg##*/}

    zstd -d < $isofsdir/boot/$initrd | cpio -tv | grep -e "lib.*\.so" -e bin/ |
    while read _ _ _ _ size _ _ _ exe _; do
      for fn in ../2nd_stage{,_small}/$exe; do
        if [ -e $fn -o -L $fn ]; then
          if [[ $fn = *bin* ]]; then
	    size2=$(stat -c "%s" $fn)	# or du
	    # only delete bin/* if diff. size, e.g. embutils replacement
	    [ -L $fn -o $size = $size2 ] && rm -vf $fn
	  else
	    rm -vf $fn
	  fi
	fi
      done
    done
  done
done


echo_status "Creating links for identical files."
link_identical_files

cd $disksdir/

echo_status "Creating stage2 archive."
(cd 2nd_stage_small; find ! -type d |
	tar -cf- --no-recursion --files-from=-) | zstd -14 -T0 > $isofsdir/stage2.tar.zst

echo_status "Creating stage2ext archive."
(cd 2nd_stage; find ! -type d |
	tar -cf- --no-recursion --files-from=-) | zstd -18 -T0 > $isofsdir/stage2ext.tar.zst
