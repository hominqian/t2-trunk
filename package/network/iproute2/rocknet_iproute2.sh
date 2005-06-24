# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../iproute2/rocknet_iproute2.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

iproute2_init_if() {
	if isfirst "iproute2_$if"; then
		addcode up   5 4 "ip link set $if up"
		addcode down 5 4 "ip link set $if down"
		addcode down 5 5 "ip addr flush dev $if"
	fi
}

public_ip() {
	ip="${1%/*}"
	addcode up 5 5 "ip addr add $1 dev $if"
	iproute2_init_if
}

public_gw() {
	code="ip route append default via $1 dev $if" ; shift

	case "$1" in
	metric)
		code="$code metric $2" ; shift ;;
	esac
	shift

	addcode up 6 5 "$code"
	iproute2_init_if
}

public_mac() {
	addcode up 4 3 "ip link set $if address $1"
	iproute2_init_if
}

