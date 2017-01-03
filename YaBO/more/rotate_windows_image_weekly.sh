#!/bin/bash
# ----------------------------------------------------------------------
# mikes handy rotating-filesystem-snapshot utility: daily snapshots
# ----------------------------------------------------------------------
# intended to be run daily as a cron job when hourly.3 contains the
# midnight (or whenever you want) snapshot; say, 13:00 for 4-hour snapshots.
# ----------------------------------------------------------------------

unset PATH

# ------------- system commands used by this script --------------------
ID=/usr/bin/id;
ECHO=/bin/echo;

MOUNT=/bin/mount;
RM=/bin/rm;
MV=/bin/mv;
CP=/bin/cp;
DATE=/bin/date;

#----------------file locations------------------------

INCOMING=/System/WindowsImageBackup/ORMA-DC;
ROTATION=/SystemImageRotations;

MOUNT_DEVICE=10.10.10.90:/mnt/backup/dedup; #this is the device where the backups will be stored
SNAPSHOT_RW=/SystemImageRotations; #This is the filesystem location the backup device will be mounted to

#----delete the oldest daily snapshot, if it exists ----------

# attempt to remount the RW mount point as RW; else abort
$MOUNT -o remount,rw $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
        $ECHO "snapshot: could not remount $SNAPSHOT_RW readwrite" >> /root/backup.log;
        exit;
}
fi;

#the rotation routine
if [ -d $ROTATION/lastweek3 ] ; then  \
$RM -rf $ROTATION/lastweek3 ;     \
fi ;


if [ -d $ROTATION/lastweek2 ] ; then  \
$MV $ROTATION/lastweek2 $ROTATION/lastweek3 ;  \
fi;

if [ -d $ROTATION/lastweek ] ; then  \
$MV $ROTATION/lastweek $ROTATION/lastweek2 ;  \
fi;

if [ -d $ROTATION/current ] ; then  \
$CP -ar $ROTATION/current $ROTATION/lastweek ;  \
fi;
 
$ECHO Weekly\ system\ rotation\: `$DATE`;

$MOUNT -o remount,ro $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
        $ECHO "snapshot: could not remount $SNAPSHOT_RW readonly" >> /root/backup.log;
        exit;
} fi;

