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
ECHO=/bin/echo;
DATE=/bin/date;

#----------------file locations------------------------

INCOMING=/System/WindowsImageBackup/ORMA-DC;
ROTATION=/SystemImageRotations;
MOUNT_DEVICE=10.10.10.90:/mnt/backup/dedup;
SNAPSHOT_RW=/SystemImageRotations;

$MOUNT -o remount,rw $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
        $ECHO "Rotate Windows Image Daily: could not remount $SNAPSHOT_RW readwrite" >> /root/backup.log;
        exit;
}
fi;



#----delete the oldest daily snapshot, if it exists ----------

if [ -d $ROTATION/yesterday6 ] ; then  \
$RM -rf $ROTATION/yesterday6 ;     \
fi ;

if [ -d $ROTATION/yesterday5 ] ; then  \
$MV $ROTATION/yesterday5 $ROTATION/yesterday6 ;  \
fi;

if [ -d $ROTATION/yesterday4 ] ; then  \
$MV $ROTATION/yesterday4 $ROTATION/yesterday5 ;  \
fi;

if [ -d $ROTATION/yesterday3 ] ; then  \
$MV $ROTATION/yesterday3 $ROTATION/yesterday4 ;  \
fi;

if [ -d $ROTATION/yesterday2 ] ; then  \
$MV $ROTATION/yesterday2 $ROTATION/yesterday3 ;  \
fi;

if [ -d $ROTATION/yesterday ] ; then  \
$MV $ROTATION/yesterday $ROTATION/yesterday2 ;  \
fi;

if [ -d $ROTATION/current ] ; then  \
$MV $ROTATION/current $ROTATION/yesterday ;  \
fi;
 
$CP -ar $INCOMING $ROTATION/current ;

$ECHO System\ image\ rotated\: `$DATE` >> /root/backup.log;

$MOUNT -o remount,ro $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
        $ECHO "Rotate Windows Image Daily: could not remount $SNAPSHOT_RW readonly" >> /root/backup.log;
        exit;
} fi;

