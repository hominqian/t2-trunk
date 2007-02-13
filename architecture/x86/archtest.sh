# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: architecture/x86/archtest.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

case "$SDECFG_X86_OPT" in
    i?86)
	arch_machine="$SDECFG_X86_OPT" ;;

    pentium|pentium-mmx|k6*|c3*)
	arch_machine="i586" ;;

    *)	# all the rest, incuding athlon*, prescot, nocona, etc.
	arch_machine="i686" ;;
esac

arch_target="${arch_machine}-t2-linux-gnu"

