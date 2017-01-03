#!/bin/bash
# ----------------------------------------------------------------------
# macks mikes handy rotating-filesystem-snapshot utility
# ----------------------------------------------------------------------
# this needs to be a lot more general, but the basic idea is it makes
# rotating backup-snapshots of /home whenever called
# ----------------------------------------------------------------------
#additions and modifications made by Mack Allison (mallison AT Brooks Network Services =.COM)
#proper attribution for original work belongs to http://www.mikerubel.org/computers/rsync_snapshots/

unset PATH      # suggestion from H. Milz: avoid accidental use of $PATH

# ------------- system commands used by this script --------------------
ID=/usr/bin/id;
ECHO=/bin/echo;

MOUNT=/bin/mount;
RM=/bin/rm;
MV=/bin/mv;
CP=/bin/cp;
TOUCH=/bin/touch;
DATE=/bin/date

RSYNC=/usr/bin/rsync;


# ------------- file locations -----------------------------------------

MOUNT_DEVICE=10.10.10.90:/mnt/backup/backup; #this is the device where the backups will be stored
SNAPSHOT_RW=/Backup2 #This is the filesystem location the backup device will be mounted to
EXCLUDES=/usr/local/etc/backup_exclude; #if you don't need to exclude anything just create an empty file
SOURCEDIR=/Storage/daily.0/ #this is the folder that will be backed up



# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit; } fi

# attempt to remount the RW mount point as RW; else abort
$MOUNT -o remount,rw $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
        $ECHO "snapshot: could not remount $SNAPSHOT_RW readwrite" >> /root/backup.log;
        exit;
}
fi;





# rotating snapshots of /home

if [ -d $SNAPSHOT_RW/daily.3 ] ; then                     \
$RM -rf $SNAPSHOT_RW/daily.3 ;                            \
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/daily.2 ] ; then                     \
$MV $SNAPSHOT_RW/daily.2 $SNAPSHOT_RW/daily.3 ;     \
fi;

if [ -d $SNAPSHOT_RW/daily.1 ] ; then                     \
$MV $SNAPSHOT_RW/daily.1 $SNAPSHOT_RW/daily.2 ;     \
fi;



# step 3: make a hard-link-only (except for dirs) copy of the latest snapshot,
# if that exists

if [ -d $SNAPSHOT_RW/daily.0 ] ; then                     \
$CP -al $SNAPSHOT_RW/daily.0 $SNAPSHOT_RW/daily.1 ; \
#$CP $SNAPSHOT_RW/timestamp $SNAPSHOT_RW/daily.1/timestamp;
fi;

$RSYNC                                                          \
        -va --delete --delete-excluded                          \
        --exclude-from="$EXCLUDES"                              \
        $SOURCEDIR $SNAPSHOT_RW/daily.0 ;


$DATE > $SNAPSHOT_RW/timestamp
#$CP $SNAPSHOT_RW/timestamp $SNAPSHOT_RW/daily.0/timestamp;

$ECHO NAS\ snapshot\ run\: `$DATE` >> /root/backup.log


# now remount the RW snapshot mountpoint as readonly

$MOUNT -o remount,ro $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
        $ECHO "snapshot: could not remount $SNAPSHOT_RW readonly" >> /root/backup.log;
        exit;
} fi;

