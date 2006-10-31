#!/bin/bash
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: example.sh
# Copyright (C) 2006 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

#
# This is a simple lua bash example.

# init lua bash and load code chunk from file internal.lua.
enable -f ../luabash.so luabash
luabash load ./internal.lua

# perform some arithmetic using a lua function called "plus".
total=0
for ((i=1;i<3;i++)) ; do
   for ((j=1;j<3;j++)) ; do
	plus $i $j
   done
done
echo "total sum is: " $total


# bash function to be called from within lua context
some_bashy_function ()
{
    if [ -n "$2" ] ; then
	shift
	some_bashy_function $@
	echo "$1"
    fi
}

# call the lua function that calls bash function above
callbash

# test if io redirection works
cat <<EOF | redirections | sed 's,xx,yy,g'
line one
line two
line three
EOF

# print ten shell variables
printenv | head -n 10

one
echo $?

zero
echo $?

str
echo $?

boolean
echo $?
