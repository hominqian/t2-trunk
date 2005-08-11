#!/bin/bash

# this is a prelemninary hack just because the archivsta stuff is not
# available in nicer pieces so far
inject_archivista()
{
	pushd .
	# cvs code
	cd $imagelocation/home
	tar xvfz $base/target/$target/cvs.tar.gz

	# configuration
	cd cvs ; patch -p1 < $base/target/$target/config.patch ; cd ..

	# example db
	cd $imagelocation/home/data/archivista
	tar xvfz $base/target/$target/mysql.tar.gz

	# firefox junk
	cd $imagelocation/home/archivista
	tar xvfz $base/target/$target/firefox.tar.gz
	# wine config and archivista "rich-client" installation
	tar xvfz $base/target/$target/wine-archivista.tar.gz

	popd
}

inject_hook=inject_archivista

. $base/target/livecd/build_image.sh

