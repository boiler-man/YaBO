#!/bin/bash
# ----------------------------------------------------------------------
# mikes handy rotating-filesystem-snapshot utility: daily snapshots
# ----------------------------------------------------------------------
# intended to be run daily as a cron job when hourly.3 contains the
# midnight (or whenever you want) snapshot; say, 13:00 for 4-hour snapshots.
# ----------------------------------------------------------------------

# source site and system specific variables
. /opt/backaroo/bin/environment.sh

# mount backup destination read-write for the pass
$MOUNT -o remount,rw $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
        $ECHO "dialy_snapshot_rotate.sh could not remount $SNAPSHOT_RW readwrite" >> $LOGFILE;
        exit;
}
fi;


# step 1: delete the oldest snapshot, if it exists:
if [ -d $SNAPSHOT_RW/daily.2 ] ; then                      \
$RM -rf $SNAPSHOT_RW/daily.2 ;                             \
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/daily.1 ] ; then                      \
$MV $SNAPSHOT_RW/daily.1 $SNAPSHOT_RW/daily.2 ;       \
fi;
if [ -d $SNAPSHOT_RW/daily.0 ] ; then                      \
$MV $SNAPSHOT_RW/daily.0 $SNAPSHOT_RW/daily.1;        \
fi;

# step 3: make a hard-link-only (except for dirs) copy of
# hourly.3, assuming that exists, into daily.0
if [ -d $SNAPSHOT_RW/hourly.3 ] ; then                     \
$CP -al $SNAPSHOT_RW/hourly.3 $SNAPSHOT_RW/daily.0 ;  \
fi;

#Log our completion
$ECHO Daily\ rotation\ run\: `$DATE` >> $LOGFILE;

# remount the backup destination read-only
$MOUNT -o remount,ro $MOUNT_DEVICE $SNAPSHOT_RW ;
if (( $? )); then
{
        $ECHO "daily_snapshot_rotate.sh: could not remount $SNAPSHOT_RW readonly" >> $LOGFILE;
        exit;
} fi;
