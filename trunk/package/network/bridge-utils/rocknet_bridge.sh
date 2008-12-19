# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../bridge-utils/rocknet_bridge.sh
# Copyright (C) 2008 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

public_bridge() {
	addcode up 2 5 "brctl addbr $if"
	addcode up 3 5 "ip link set $1 up"
	for i; do
		addcode up 3 6 "brctl addif $if $i"
	done

	# interfaces are implicitly removed form tbe bridge on delbr
	addcode down 1 1 "brctl delbr $if"
}
