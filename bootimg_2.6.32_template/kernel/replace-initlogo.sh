#!/sbin/sh

# Set a sane umask
#
umask 022

# Get a list of the files in the RAM disk archive for later use.
#
zcat "$1" | cpio -t | fgrep -v boot.img-ramdisk.gz > /tmp/ramdisk.filelist

# Insert initlogo.rle back into the file list for ROMs (GB-, HC-based)
# which remove this file from their fully booted system for some reason.
#
fgrep -q initlogo.rle /tmp/ramdisk.filelist  			||
echo initlogo.rle >> /tmp/ramdisk.filelist

# Uncompress and unpack the RAM disk archive
#

# Start with a clean slate for multiple consecutive installs.
#
rm -rf /tmp/ramdisk.extracted

mkdir /tmp/ramdisk.extracted					&&
cd /tmp/ramdisk.extracted					&&
zcat "$1" | cpio -i						&&

cp -f /tmp/initlogo.rle .					&&
chown 1000.1000 initlogo.rle					&&
chmod 640 initlogo.rle						&&

# Create and compress a new RAM disk archive.
#
cpio -o -H newc < /tmp/ramdisk.filelist | gzip -9c > "$1.new"	&&
mv -f "$1" "$1.orig"						&&
mv -f "$1.new" "$1"						|| rc=$?

cd -
rm -f "$1.orig"
rm -f /tmp/ramdisk.filelist
rm -rf /tmp/ramdisk.extracted

return $rc
