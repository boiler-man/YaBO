#!/bin/bash
# ----------------------------------------------------------------------
# macks mikes handy rotating-filesystem-snapshot utility
# ----------------------------------------------------------------------
# makes rotating backup-snapshots of a directory sourced in a variable whenever called
# ----------------------------------------------------------------------
# Mack Allison (mallison AT Brooks Network Services =.COM)
# based on original work by Mike Rubel http://www.mikerubel.org/computers/rsync_snapshots/

# source environment variables from top level
. /opt/backaroo/bin/environment.sh

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit; } fi

# attempt to remount the RW mount point as RW; else abort
$MOUNT -o remount,rw $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
        $ECHO "make_snapshot.sh: could not remount $SNAPSHOT_RW readwrite" >> $LOGFILE;
        exit;
}
fi;

# rotating snapshots of Target Data

if [ -d $SNAPSHOT_RW/hourly.3 ] ; then                     \
$RM -rf $SNAPSHOT_RW/hourly.3 ;                            \
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/hourly.2 ] ; then             \
$MV $SNAPSHOT_RW/hourly.2 $SNAPSHOT_RW/hourly.3 ;   \
fi;

if [ -d $SNAPSHOT_RW/hourly.1 ] ; then                     \
$MV $SNAPSHOT_RW/hourly.1 $SNAPSHOT_RW/hourly.2 ;     \
fi;


# step 3: make a hard-link-only (except for dirs) copy of the latest snapshot,
# if that exists

if [ -d $SNAPSHOT_RW/hourly.0 ] ; then                     \
$CP -al $SNAPSHOT_RW/hourly.0 $SNAPSHOT_RW/hourly.1 ; \
fi;

$RSYNC                                                          \
        -va --delete --delete-excluded                          \
        --exclude-from="$EXCLUDES"                              \
        $SOURCEDIR $SNAPSHOT_RW/hourly.0 ;

# print the date into a timestamp file
$DATE > $SNAPSHOT_RW/timestamp

# copy the timestamp file into the backup. This is the date of the sanpshot 
# that will follow the backups.
$CP $SNAPSHOT_RW/timestamp $SNAPSHOT_RW/hourly.0/timestamp;

#log our completion
$ECHO Hourly\ snapshot\ run\: `$DATE` | \
$MAIL -aFrom:$FROMADDR -s Backup $TOADDR ;


# now remount the RW snapshot mountpoint as readonly

$MOUNT -o remount,ro $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
        $ECHO "make_snapshot.sh: could not remount $SNAPSHOT_RW readonly" >> $LOGFILE;
        exit;
} fi;

