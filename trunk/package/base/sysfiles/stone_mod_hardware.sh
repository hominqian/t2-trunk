# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/base/sysfiles/stone_mod_hardware.sh
# ROCK Linux is Copyright (C) 1998 - 2003 Clifford Wolf
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version. A copy of the GNU General Public
# License can be found at Documentation/COPYING.
# 
# Many people helped and are helping developing ROCK Linux. Please
# have a look at http://www.rocklinux.org/ and the Documentation/TEAM
# file for details.
# 
# --- ROCK-COPYRIGHT-NOTE-END ---
#
# [MAIN] 20 hardware Kernel Drivers Configuration

set_hw_setup() {
    echo "export HARDWARE_SETUP=$1" > /etc/conf/hardware
}

flip_hw_config() {
	local tmp=`mktemp`
	awk "\$0 == \"### $1 ###\", \$0 == \"\" {"'
		if ( /^#[^# ]/ ) {
			sub("^#", "");
			system($0 " >&2");
		} else {
			if ( /^[^# ]/ ) $0 = "#" $0;
			if (/^#modprobe /) {
				cmd = $0;
				sub("^#modprobe", "modprobe -r", cmd);
				system(cmd " >&2");
			}
			if (/^#mount /) {
				cmd = $0;
				sub("^#mount .* ", "umount ", cmd);
				system(cmd " >&2");
			}
		}
	} { print; }' < /etc/conf/kernel > $tmp
	cat $tmp > /etc/conf/kernel; rm -f $tmp

	# this is needed to e.g. initialize /proc/bus/usb/devices
	sleep 1
}

add_hw_config() {
	case $state in
		1) cmd="$cmd '[ ] $name'" ;;
		2) cmd="$cmd '[*] $name'" ;;
		*) cmd="$cmd '[?] $name'" ;;
	esac
	case $state in
		1|2) cmd="$cmd 'flip_hw_config \"$id\"'" ;;
		*)   cmd="$cmd 'true'" ;;
	esac
	id=""
}

main() {
    while
        HARDWARE_SETUP=rockplug
	if [ -f /etc/conf/hardware ]; then
	    . /etc/conf/hardware
	fi
	for x in hwscan rockplug; do
	    if [ "$HARDWARE_SETUP" = $x ]; then
		eval "hw_$x='<*>'"
	    else
		eval "hw_$x='< >'"
	    fi
	done

	cmd="gui_menu hw 'Kernel Drivers Configuration'"
	if [ "$HARDWARE_SETUP" = rockplug ]; then
	    cmd="$cmd \"$hw_rockplug Use ROCKPLUG to configure hardware.\""
	    cmd="$cmd \"set_hw_setup rockplug\"";
	    cmd="$cmd \"$hw_hwscan Use hwscan to configure hardware.\""
	    cmd="$cmd \"set_hw_setup hwscan\"";
	    cmd="$cmd \"\" \"\"";
	    cmd="$cmd 'Edit/View PCI configuration'";
	    cmd="$cmd \"gui_edit PCI /etc/conf/pci\""
	    cmd="$cmd 'Edit/View USB configuration'";
	    cmd="$cmd \"gui_edit USB /etc/conf/usb\""
	    cmd="$cmd \"\" \"\"";
	    
	    #@FIXME single shot menu?

	    cmd="$cmd 'Re-create initrd image (mkinitrd, `uname -r`)'"
	    cmd="$cmd 'gui_cmd mkinitrd mkinitrd' '' ''"
	fi
	    
	if [ "$HARDWARE_SETUP" = hwscan ]; then
	    cmd="$cmd \"$hw_rockplug Use ROCKPLUG to configure hardware.\" \"set_hw_setup rockplug\"";
	    cmd="$cmd \"$hw_hwscan Use hwscan to configure hardware.\" \"set_hw_setup hwscan\"";
	    cmd="$cmd \"\" \"\"";
	    cmd="$cmd 'Edit /etc/conf/kernel (kernel drivers config file)'"
	    cmd="$cmd \"gui_edit 'Kernel Drivers Config File' /etc/conf/kernel\""
	    cmd="$cmd 'Re-create initrd image (mkinitrd, `uname -r`)'"
	    cmd="$cmd 'gui_cmd mkinitrd mkinitrd' '' ''"
	    hwscan -d -s /etc/conf/kernel

	    id=""
	    while read line; do
		if [ "${line#\#\#\# }" != "${line}" -a \
		    "${line% \#\#\#}" != "${line}" ]
		    then
		    id="${line#\#\#\# }"; id="${id% \#\#\#}"
		    state=0; name="Unamed Kernel Driver"
		elif [ -z "$id" ]; then
		    continue
		elif [ "${line#\# }" != "${line}" ]; then
		    name="${line#\# }"
		elif [ "${line#\#[!\# ]}" != "${line}" ]; then
		    [ $state -eq 0 ] && state=1
		    [ $state -eq 2 ] && state=3
		elif [ "${line#[!\# ]}" != "${line}" ]; then
		    [ $state -eq 0 ] && state=2
		    [ $state -eq 1 ] && state=3
		elif [ -z "$line" ]; then
		    add_hw_config
		fi
	    done < /etc/conf/kernel
	    [ -z "$id" ] || add_hw_config
	fi	   
 
	eval "$cmd"
    do : ; done

    return
}

