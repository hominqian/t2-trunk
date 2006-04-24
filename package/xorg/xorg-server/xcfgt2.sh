#!/bin/bash
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../xorg-server/xcfgt2.sh
# Copyright (C) 2005 The T2 SDE Project
# Copyright (C) 2005 Rene Rebe
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

# Quick T2 live X driver matching ...

tmp=`mktemp`

lspci | grep -i ' vga' | cut -d ' ' -f 2- | cut -d : -f 2- > $tmp

echo "Video card:`cat $tmp`"

case `cat $tmp | tr A-Z a-z` in
	*radeon*)       xdrv=radeon ;;
	*geforce*)	xdrv=nv ;;
	*cirrus*)	xdrv=cirrus ;;
	*savage*)	xdrv=savage ;;
	*unichrome*|*castlerock*)	xdrv=via ;;
	*virge*)	xdrv=s3virge ;;
	*s3*)		xdrv=s3 ;;

# this intel matches might not be accurate enough
	*intel*7*)		xdrv=i740 ;;
	*intel*8*|*intel*9*)	xdrv=i810 ;;

	*trident*)	xdrv=trident ;;
	*rendition*)	xdrv=rendition ;;
	*neo*)		xdrv=neomagic ;;
	*tseng*)	xdrv=tseng ;;

	*parhelia*)	xdrv=mtx ;;
	*matrox*)	xdrv=mga ;;

	*cyrix*)	xdrv=cyrix ;;
	*silicon\ motion*)	xdrv=siliconmotion ;;
	*chips*)	xdrv=chips ;;

	*3dfx*)		xdrv="tdfx" ;;
	*permedia*|*glint*)	xdrv="glint" ;;

	*vmware*)	xdrv="vmware" ;;

	*ark\ logic*)	xdrv="ark" ;;
	*dec*tga*)	xdrv="tga" ;;

	*national\ semi*|*amd*)	xdrv=nsc ;;

	*ati\ *)	xdrv=ati ;;
	*sis*|*xgi*)	xdrv=sis ;;

	# must be last so *nv* does not match one of the above
	*nv*)		xdrv=nv ;;
esac

# use the nvidia binary only driver - if available ...
if [ "$xdrv" = nv -a -f /usr/X11/lib/xorg/modules/drivers/nvidia_drv.o ]; then
	xdrv=nvidia

	echo "Installing nvidia GL libraries and headers ..."
	rm -rf /usr/X11/lib/libGL.*
	cp -arv /usr/src/nvidia/lib/* /usr/X11/lib/
	cp -arv /usr/src/nvidia/X11R6/lib/* /usr/X11/lib/
	cp -arv /usr/src/nvidia/include/* /usr/X11/lib/GL/
	ln -sf /usr/X11/lib/xorg/modules/extensions/{libglx.so.1.0.*,libglx.so}

	echo "Updating dynamic library database ..."
	ldconfig /usr/X11/lib
fi

# no driver? fallback to either vesa or fbdev ...
if [ -z "$xdrv" ]; then
	if [[ `uname -m` = i*86 ]]
	then xdrv=vesa
	else xdrv=fbdev ; fi 
fi

echo "X Driver:   $xdrv"

horiz_sync=""
vert_refresh=""
modes=""
depth=16

if [[ `uname -m` = i*86 ]]; then
	ddcprobe > $tmp

	if grep -q failed $tmp ; then
	  echo "DDC read failed"
	else
	  grep "Standard timing" $tmp
	  defx=`grep "Horizontal blank time" $tmp | cut -d : -f 2 |
	        sort -nu | tail -n 1`
	  defy=`grep "Vertical blank time" $tmp | cut -d : -f 2 |
	        sort -nu | tail -n 1`

	  defx=${defx:-0}
	  defy=${defy:-0}

	  while read m ; do
		x=${m/x*/}
		y=${m/*x/}
		if [ $defx -eq 0 -o $x -le $defx ] &&
		   [ $defy -eq 0 -o $y -le $defy ]; then
			echo "mode $x $y ok"
			modes="$modes \"${x}x${y}\""
		else
			echo "mode $x $y skipped"
		fi
	  done < <( grep -A 1000 '^Established' $tmp |
          grep -B 1000 '^Standard\|^Detailed' |
          sed -e 's/[\t ]*\([^ ]*\).*/\1/' -e '/^[A-Z]/d' |
          sort -rn | uniq )
	fi
fi

if [ -z "$modes" ]; then
	echo "No modes from DDC detection, using defaults!"
	modes='"1024x768" "800x600" "640x480"'
	horiz_sync="HorizSync   24.0 - 65.0"
	vert_refresh="VertRefresh 50 - 75"
fi

echo "Using modes: $modes"
echo "    @ depth: $depth"
[ "$hoiz_sync" -o "$vert_refresh" ] &&
echo "      horiz: $horiz_sync" &&
echo "       vert: $vert_refresh"

[ -f /etc/X11/xorg.conf ] && cp /etc/X11/xorg.conf /etc/X11/xorg.conf.bak

sed -e "s/\$xdrv/$xdrv/g" -e "s/\$modes/$modes/g" -e "s/\$depth/$depth/g" \
    -e "s/\$horiz_sync/$horiz_sync/g" \
    -e "s/\$vert_refresh/$vert_refresh/g" \
    /etc/X11/xorg.conf.template > /etc/X11/xorg.conf

rm $tmp
