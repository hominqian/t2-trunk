#!/bin/bash
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: misc/archive/Find.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

matched=0

echo "Searching for matching package names ..."

x="`cd package/ ; ls -d */*$1* 2>/dev/null`"

if [ -n "$x" ] ; then
	echo -e "$x\n"
	matched=1
fi

echo "Searching in package descriptions (may take some time) ..."
grep "[(\I\|T\)].* $1" package/*/*/*.desc | grep $1 --color
[ $? -eq 0 ] && matched=1

[ $matched = 0 ] && echo "No match found ..."

