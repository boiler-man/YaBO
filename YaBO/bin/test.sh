#!/bin/bash
# ---------------------------------------------------------------------
# Macks Mikes Handy Rotating Filesystem Snapshot Utility
# ---------------------------------------------------------------------
# A collection of scripts to snapshot and rotate backups to and from
# various locations. How secure and reliable the result is depends on 
# where you put them and how you push them. 
# This extends Mike Rubel's work, a continues to depend specifically on 
# stable features of the GNU toolkit, and could be easily modified to fit
# any other POSIX compliant system or compatibility layer.
# ---------------------------------------------------------------------
# This script sets environment variables to be sourced by the others.
# See the README for a brief overview of the system as a whole.
# ---------------------------------------------------------------------

unset PATH      # suggestion from H. Milz: avoid accidental use of $PATH

BASEDIR=/opt/backaroo

# ------------- system commands used by this script --------------------
ID=/usr/bin/id;
ECHO=/bin/echo;
MOUNT="/bin/mount -o loop";
RM=/bin/rm;
MV=/bin/mv;
CP=/bin/cp;
TOUCH=/bin/touch;
DATE=/bin/date;
RSYNC=/usr/bin/rsync;
MAIL=/usr/bin/mail;

# ------------- file locations -----------------------------------------
#this is the device where the backups will be stored
MOUNT_DEVICE=$BASEDIR/loop.img; 
#This is the filesystem location the backup device will be mounted to
SNAPSHOT_RW=/Backup; 
#if you don't need to exclude anything just create an empty file
EXCLUDES=$BASEDIR/etc/backup_exclude; 
#this is the folder that will be backed up
SOURCEDIR=/etc; 

# ------------- log locations ------------------------------------------

LOGFILE=$BASEDIR/log/backaroo.log

# ------------ mailer information --------------------------------------
FROMADDR=backup_operator@telegraph.dialunix.com;
TOADDR=kamaji@dialunix.com;

$MAIL -aFrom:$FROMADDR -s test1 $TOADDR < environment.sh ;
