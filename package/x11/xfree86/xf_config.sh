# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/x11/xfree86/xf_config.sh
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

# extract additional gl* stuff
	xf_extract_gl() {
	mkdir release ; ln -s ../.. release/xc
	tar xZf $archdir/mangl.tar.Z
	tar xZf $archdir/manglu.tar.Z
	tar xZf $archdir/manglx.tar.Z
	rm -rf release
}

# extract the Matrox HALlib (additional TV/DVI out support on x86)
xf_extract_hallib() {
	echo "Extracting mgaHALlib (For Matrox (>G400) cards) ..."
	tar $taropt $archdir/mgadrivers-$mga_version-src.tbz2
	cp mgadrivers-$mga_version-src/4.2.0/drivers/src/HALlib/mgaHALlib.a \
	  programs/Xserver/hw/xfree86/drivers/mga/HALlib/mgaHALlib.a
	rm -rf mgadrivers-$mga_version-src 

	if [ $arch == "x86" ] ; then
		echo "Enabling Matrox HALlib (since this is x86) ..."
		cat >> config/cf/host.def << EOT

/* Additinal TC/DVI support since this is x86 */
#define         HaveMatroxHal           YES
EOT
	fi
}

# apply the patches
xf_patch() {
	cp -v programs/twm/system.twmrc programs/twm/system.twmrc.orig
	for x in $patchfiles ; do
	  if [ -f $x ] ; then
		echo "Apply patch $x ..."
		patch -Nf -p1 < $x
	fi ; done
	find \( -name 'config.guess' -o -name 'config.sub' \) \
		-exec chmod +x '{}' ';'
}

# build the World
xf_build() {
	eval $MAKE World
	cd nls ; eval $MAKE ; cd ..
}

# install the World
xf_install() {
	echo "Create /etc/X11 (if it's not already there) ..."
	mkdir -p $root/etc/X11

	eval $MAKE install
	eval $MAKE install.man
	cd nls ; eval $MAKE install ; cd ..

	rm -fv $root/usr/X11
	rm -fv $root/usr/bin/X11
	rm -fv $root/usr/lib/X11
	rm -fv $root/usr/include/X11

	ln -sv X11R6 $root/usr/X11
	ln -sv ../X11/bin $root/usr/bin/X11
	ln -sv ../X11/lib/X11 $root/usr/lib/X11
	ln -sv ../X11/include/X11 $root/usr/include/X11

	mkdir -p $root/usr/X11R6/lib/X11/fonts/TrueType
	
	echo "Copy TWM config files ..."
	cp -v programs/twm/system.twmrc.orig \
	  programs/twm/sample-twmrc/original.twmrc
	cp -v programs/twm/sample-twmrc/*.twmrc $root/usr/X11R6/lib/X11/twm/
	register_wm twm TWM /usr/X11/bin/twm

	echo "Copy X11 Documentation and creating X11 symlink ..."
	rm -rf $root/usr/doc/X11
	cp -rv doc/* $docdir
	ln -s $docdir X11

	echo "Copying default example configs ..."
	cp -fv $base/package/x11/xfree86/XF86Config.data $root/etc/X11/XF86Config
	cp -fv $base/package/x11/xfree86/XF86Config.data $root/etc/X11/XF86Config.example
	cp -fv $base/package/x11/xfree86/local.conf.data $root/etc/fonts/local.conf

	echo "Fixing compiled keymaps directory ..."
	mkdir -p $root/var/lib/xkb $root/etc/X11/xkb
	cp -fu programs/xkbcomp/compiled/README $root/var/lib/xkb
	rm -rf $root/etc/X11/xkb/compiled
	ln -sf ../../../var/lib/xkb $root/etc/X11/xkb/compiled

	echo "Installing XDM SysV Init Script ..."
	install_init xdm $base/package/x11/xfree86/xdm.init

	echo "Installing XFree86 Setup Script ..."
	cp -fv $base/package/x11/xfree86/stone_mod_xfree86.sh $root/etc/stone.d/mod_xfree86.sh
	echo "export WINDOWMANAGER=gnome" > $root/etc/profile.d/windowmanager

	echo "Installing XFree86 Cron Script ..."
	cp -fv $base/package/x11/xfree86/xfree86.cron $root/etc/cron.d/80-xfree86
	chmod +x $root/etc/cron.d/80-xfree86
}

# configure the World
xf_config() {
	echo "Configuring XFree ..."
	cat >> config/cf/host.def << EOT
/* Disable the internal zlib to use the system installed one */
#define		HasZlib			YES

/* Less warnings with recent gccs ... */
#define		DefaultCCOptions	-ansi GccWarningOptions

/* Make sure config files are allways installed ... */
#define		InstallXinitConfig	YES
#define		InstallXdmConfig	YES
#define		InstallFSConfig		YES
EOT
	
	if [ $arch == "x86" ] ; then
	        echo "Enabling Matrox HALlib (since this is x86) ..."
		cat >> config/cf/host.def << EOT

/* Additinal TC/DVI support since this is x86 */
#define		HaveMatroxHal		YES
EOT
	fi
}

