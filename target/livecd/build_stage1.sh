
echo_header "Creating initrd data:"
rm -rf $disksdir/initrd
mkdir -p $disksdir/initrd/{dev,proc,tmp,bin-static,mnt/cdrom,ramdisk,etc,ROCK}
cd $disksdir/initrd; ln -s bin-static sbin-static; ln -s . usr
#
echo_status "Create linuxrc binary."
diet $CC $base/target/$target/linuxrc.c -Wall \
	-DSTAGE_2_IMAGE="\"${ROCKCFG_SHORTID}/2nd_stage.img.z\"" \
	-o linuxrc 
#
echo_status "Copy various helper applications."
cp ../2nd_stage/bin/{tar,gzip} bin-static/
cp ../2nd_stage/sbin/hwscan bin-static/
cp ../2nd_stage/usr/bin/gawk bin-static/
for x in modprobe.static modprobe.static.old \
         insmod.static insmod.static.old
do
	if [ -f ../2nd_stage/sbin/${x/.static/} ]; then
		rm -f bin-static/${x/.static/}
		cp -a ../2nd_stage/sbin/${x/.static/} bin-static/
	fi
	if [ -f ../2nd_stage/sbin/$x ]; then
		rm -f bin-static/$x bin-static/${x/.static/}
		cp -a ../2nd_stage/sbin/$x bin-static/
		ln -sf $x bin-static/${x/.static/}
	fi
done
#
echo_status "Copy scsi and network kernel modules."
for x in ../2nd_stage/lib/modules/*/kernel/drivers/net/*.{ko,o} ../2nd_stage/lib/modules/*/misc/cloop.{ko,o} ; do
	# this test is needed in case there are only .o or only .ko files
	if [ -f $x ]; then
		xx=${x#../2nd_stage/}
		mkdir -p $( dirname $xx ) ; cp $x $xx
		strip --strip-debug $xx 
	fi
done
#
for x in ../2nd_stage/lib/modules/*/modules.{dep,pcimap,isapnpmap} ; do
	cp $x ${x#../2nd_stage/} || echo "not found: $x" ;
done
#
for x in lib/modules/*/kernel/drivers/net lib/modules/*/misc; do
	ln -s ${x#lib/modules/} lib/modules/
done
rm -f lib/modules/[0-9]*/kernel/drivers/net/{dummy,ppp*}.{o,ko}
#
echo_status "Adding kiss shell for expert use of the initrd image."
cp $build_root/bin/kiss bin-static/
cd ..

echo_header "Creating initrd filesystem image: "

ramdisk_size=4096

echo_status "Creating temporary files."
tmpdir=initrd_$$.dir; mkdir -p $disksdir/$tmpdir; cd $disksdir
dd if=/dev/zero of=initrd.img bs=1024 count=$ramdisk_size &> /dev/null
tmpdev=""
for x in /dev/loop/* ; do
        if losetup $x initrd.img 2> /dev/null ; then
                tmpdev=$x ; break
        fi
done
if [ -z "$tmpdev" ] ; then
        echo_error "No free loopback device found!"
        rm -f $tmpfile ; rmdir $tmpdir; exit 1
fi
echo_status "Using loopback device $tmpdev."
#
echo_status "Writing initrd image file."
mke2fs -m 0 -N 180 -q $tmpdev &> /dev/null
mount -t ext2 $tmpdev $tmpdir
rmdir $tmpdir/lost+found/
cp -a initrd/* $tmpdir
umount $tmpdir
#
echo_status "Compressing initrd image file."
gzip -9 initrd.img 
mv initrd{.img,}.gz
#
echo_status "Removing temporary files."
losetup -d $tmpdev
rm -rf $tmpdir
