#!/usr/bin/perl
#
# AST_cleanup_agent_log.pl version 2.14
#
# DESCRIPTION:
# to be run frequently to clean up the vicidial_agent_log to fix erroneous time 
# calculations due to out-of-order vicidial_agent_log updates. This happens 0.5%
# of the time in our test setups, but that leads to inaccurate time logs so we
# wrote this script to fix the miscalculations
#
# This program only needs to be run by one server
#
# Copyright (C) 2022  Matt Florell <vicidial@gmail.com>    LICENSE: AGPLv2
#
# CHANGES
# 60711-0945 - Changed to DBI by Marin Blu
# 60715-2301 - Changed to use /etc/astguiclient.conf for configs
# 81029-0124 - Added portion to clean up queue_log entries if QM enabled
# 81114-0155 - Added portion to remove queue_log COMPLETE duplicates
# 81208-0133 - Added portion to check for more missing queue_log entries
# 90330-2128 - Minor code fixes and restricted queue_log actions to VICIDIAL-defined serverid records
# 91112-1100 - Added fixing for more QM issues, added CALLOUTBOUND checking with ENTERQUEUE
# 91209-0956 - Added PAUSEREASON-LAGGED queue_log correction during live call
# 91210-0609 - Added LOGOFF queue_log correction during live call
# 91214-0933 - Added queue_position to queue_log COMPLETE... and ABANDON records
# 100203-1110 - Added fix for vicidial_closer_log records with 0 length
# 100309-0555 - Added queuemetrics_loginout option
# 100327-0926 - Added validation of four agent "sec" fields
# 100331-0310 - Added one-day-ago and only-fix-old-lagged options, fixed validation process
# 110124-1134 - Small query fix for large queue_log tables
# 110224-1916 - Added compatibility with QM phone environment logging
# 110310-2259 - Added check for PAUSEREASON if no COMPLETE record
# 110414-0200 - Added queue_log CONNECT and PAUSEALL/UNPAUSEALL validation and fixing
# 110415-1442 - Added one minute run option
# 110425-1345 - Added check-complete-pauses option
# 110504-0737 - Small bug fix in agent log corrections
# 111208-0627 - Added concurrency check option
# 120123-0925 - Added vicidial_log duplicate check
# 120426-1622 - Added agent log park fix
# 121115-0624 - Added buffer time for agent log validation of LOGIN between record and next record
# 140426-2000 - Added pause_type
# 161102-1033 - Fixed QM partition problem
# 170609-2356 - Added option for fixing length_in_sec on vicidial_log and vicidial_closer_log records
# 180102-0111 - Added a check for vicidial_log entries with a user with no vicidial_agent_log entry
# 200422-1621 - Added optional check for duplicate vicidial_agent_log entries
# 200606-1802 - Added optional queue_log cleanup for multiple PAUSEREASON records in the same PAUSE session
# 201106-2146 - Added EXITEMPTY verb for queue_log cleanup section
# 210523-2321 - Added optional check for qa_data duplicates, -qm-qa-duplicate-check
# 220206-0714 - Added new -roll-back-preview-skips function to roll back the last_local_call_time and called_count for leads that were previewed and not dialed
#

# constants
$US='__';
$MT[0]='';

### begin parsing run-time options ###
if (length($ARGV[0])>1)
	{
	$i=0;
	while ($#ARGV >= $i)
		{
		$args = "$args $ARGV[$i]";
		$i++;
		}

	if ($args =~ /--help/i)
		{
		print "allowed run time options:\n";
		print "  [-no-time-restriction] = will clean up all logs, without flag will only do last hour\n";
		print "   (without time flag will do logs from 150-10 minutes ago)\n";
		print "  [-last-24hours] = will clean up logs for the last 24 hours only\n";
		print "  [-more-than-24hours] = will clean up logs older than 24 hours only\n";
		print "  [-last-30days] = will clean up logs for the last 30 days only\n";
		print "  [-one-day-ago] = will clean up logs for the last 24-48 hours ago only\n";
		print "  [-one-minute-run] = short settings for running every minute\n";
		print "  [-check-complete-pauses] = make sure every complete with a pause has a pausereason\n";
		print "  [-check-agent-dups] = check for and fix agent log duplicates, ONLY RUN AFTER HOURS!\n";
		print "  [-check-call-lengths] = will check for too-long call lengths\n";
		print "  [-skip-queue-log-inserts] = will skip only the queue_log missing record checks\n";
		print "  [-skip-agent-log-validation] = will skip only the vicidial_agent_log validation\n";
		print "  [-only-check-agent-login-lags] = will only fix queue_log missing PAUSEREASON records\n";
		print "  [-only-qm-live-call-check] = will only check the queue_log calls that report as live, in ViciDial\n";
		print "  [-qm-pausereason-check] = will check/fix the queue_log for multiple PAUSEREASON entries in same pause session\n";
		print "  [-qm-qa-duplicate-check] = will check/fix the qa_data table for duplicates\n";
		print "  [-only-fix-old-lagged] = will go through old lagged entries and add a new entry after\n";
		print "  [-only-dedupe-vicidial-log] = will look for duplicate vicidial_log and extended entries\n";
		print "  [-only-check-vicidial-log-agent] = will check for missing agent log entries\n";
		print "  [-only-hold-cleanup] = will look for hold entries and correct agent log wait/talk times\n";
		print "  [-roll-back-preview-skips] = roll back the last_local_call_time and called_count for leads that were previewed and not dialed\n";
		print "  [-run-check] = concurrency check, die if another instance is running\n";
		print "  [-quiet] = quiet, no output\n";
		print "  [-test] = test\n";
		print "  [-debug] = verbose debug messages\n";
		print "  [--debugX] = Extra-verbose debug messages\n\n";
		exit;
		}
	else
		{
		if ($args =~ /-quiet/i)
			{
			$Q=1; # quiet
			}
		if ($args =~ /-debug/i)
			{
			$DB=1; # Debug flag
			if ($Q < 1) {print "\n----- DEBUGGING -----\n\n";}
			}
		if ($args =~ /--debugX/i)
			{
			$DBX=1;
			if ($Q < 1) {print "\n----- SUPER-DUPER DEBUGGING -----\n\n";}
			}
		if ($args =~ /-test/i)
			{
			$TEST=1;
			$T=1;
			if ($Q < 1) {print "\n----- TEST RUN, NO UPDATES -----\n\n";}
			}
		if ($args =~ /-no-time-restriction/i)
			{
			$VAL_validate=1;
			$ALL_TIME=1;
			if ($Q < 1) {print "\n----- NO TIME RESTRICTIONS -----\n\n";}
			}
		if ($args =~ /-only-check-agent-login-lags/i)
			{
			$login_lagged_check=1;
			if ($Q < 1) {print "\n----- ONLY LOGIN LAGGED CHECK -----\n\n";}
			}
		if ($args =~ /-only-qm-live-call-check/i)
			{
			$qm_live_call_check=1;
			if ($Q < 1) {print "\n----- QM LIVE CALL CHECK -----\n\n";}
			}
		if ($args =~ /-qm-pausereason-check/i)
			{
			$qm_pausereason_check=1;
			if ($Q < 1) {print "\n----- QM PAUSEREASON CHECK -----\n\n";}
			}
		if ($args =~ /-qm-qa-duplicate-check/i)
			{
			$qm_qa_duplicate_check=1;
			if ($Q < 1) {print "\n----- QM QA DUPLICATE CHECK -----\n\n";}
			}
		if ($args =~ /-only-dedupe-vicidial-log/i)
			{
			$vl_dup_check=1;
			if ($Q < 1) {print "\n----- VICIDIAL LOG DUPLICATE CHECK -----\n\n";}
			}
		if ($args =~ /-only-check-vicidial-log-agent/i)
			{
			$vl_val_check=1;
			if ($Q < 1) {print "\n----- VICIDIAL LOG AGENT LOG CHECK -----\n\n";}
			}
		if ($args =~ /-last-24hours/i)
			{
			$VAL_validate=1;
			$TWENTYFOUR_HOURS=1;
			if ($Q < 1) {print "\n----- LAST 24 HOURS ONLY -----\n\n";}
			}
		if ($args =~ /-one-day-ago/i)
			{
			$VAL_validate=1;
			$ONEDAYAGO=1;
			if ($Q < 1) {print "\n----- ONE DAY AGO ONLY -----\n\n";}
			}
		if ($args =~ /-last-30days/i)
			{
			$VAL_validate=1;
			$THIRTY_DAYS=1;
			if ($Q < 1) {print "\n----- LAST 30 DAYS ONLY -----\n\n";}
			}
		if ($args =~ /-one-minute-run/i)
			{
			$VAL_validate=1;
			$ONE_MINUTE=1;
			if ($Q < 1) {print "\n----- ONE MINUTE RUN -----\n\n";}
			}
		if ($args =~ /-check-complete-pauses/i)
			{
			$check_complete_pauses=1;
			if ($Q < 1) {print "\n----- CHECK COMPLETE PAUSES -----\n\n";}
			}
		if ($args =~ /-check-agent-dups/i)
			{
			$check_agent_dups=1;
			if ($Q < 1) {print "\n----- CHECK FOR AGENT LOG DUPLICATES -----\n\n";}
			}
		if ($args =~ /-check-call-lengths/i)
			{
			$check_call_lengths=1;
			if ($Q < 1) {print "\n----- CHECK CALL LENGTHS -----\n\n";}
			}			
		if ($args =~ /-more-than-24hours/i)
			{
			$VAL_validate=1;
			$TWENTYFOUR_OLDER=1;
			if ($Q < 1) {print "\n----- MORE THAN 24 HOURS OLD ONLY -----\n\n";}
			}
		if ($args =~ /-skip-queue-log-inserts/i)
			{
			$skip_queue_log_inserts=1;
			if ($Q < 1) {print "\n----- SKIPPING QUEUE_LOG INSERTS -----\n\n";}
			}
		if ($args =~ /-skip-agent-log-validation/i)
			{
			$skip_agent_log_validation=1;
			if ($Q < 1) {print "\n----- SKIPPING VICIDIAL_AGENT_LOG VALIDATION -----\n\n";}
			}
		if ($args =~ /-only-fix-old-lagged/i)
			{
			$fix_old_lagged_entries=1;
			if ($Q < 1) {print "\n----- FIX OLD LAGGED ENTRIES ONLY -----\n\n";}
			}
		if ($args =~ /-only-hold-cleanup/i)
			{
			$hold_cleanup=1;
			if ($Q < 1) {print "\n----- FIX HOLD ENTRIES ONLY -----\n\n";}
			}
		if ($args =~ /-roll-back-preview-skips/i)
			{
			$roll_back_preview_skips=1;
			if ($Q < 1) {print "\n----- ROLL BACK PREVIEW SKIPS: $roll_back_preview_skips -----\n\n";}
			}
		if ($args =~ /-run-check/i)
			{
			$run_check=1;
			if ($DB) {print "\n----- CONCURRENCY CHECK -----\n\n";}
			}
		}
	}
else
	{
	#	print "no command line options set\n";
	}
### end parsing run-time options ###

# define time restrictions for queries in script
$secX = time();
$HDtarget = ($secX - 150); # 2.5 minutes in the past
($Hsec,$Hmin,$Hhour,$Hmday,$Hmon,$Hyear,$Hwday,$Hyday,$Hisdst) = localtime($HDtarget);
$Hyear = ($Hyear + 1900);
$Hmon++;
if ($Hmon < 10) {$Hmon = "0$Hmon";}
if ($Hmday < 10) {$Hmday = "0$Hmday";}
if ($Hhour < 10) {$Hhour = "0$Hhour";}
if ($Hmin < 10) {$Hmin = "0$Hmin";}
if ($Hsec < 10) {$Hsec = "0$Hsec";}
	$HDSQLdate = "$Hyear-$Hmon-$Hmday $Hhour:$Hmin:$Hsec";

$FDtarget = ($secX - 600); # 10 minutes in the past
($Fsec,$Fmin,$Fhour,$Fmday,$Fmon,$Fyear,$Fwday,$Fyday,$Fisdst) = localtime($FDtarget);
$Fyear = ($Fyear + 1900);
$Fmon++;
if ($Fmon < 10) {$Fmon = "0$Fmon";}
if ($Fmday < 10) {$Fmday = "0$Fmday";}
if ($Fhour < 10) {$Fhour = "0$Fhour";}
if ($Fmin < 10) {$Fmin = "0$Fmin";}
if ($Fsec < 10) {$Fsec = "0$Fsec";}
	$FDSQLdate = "$Fyear-$Fmon-$Fmday $Fhour:$Fmin:$Fsec";

$TDtarget = ($secX - 9000); # 150 minutes in the past
($Tsec,$Tmin,$Thour,$Tmday,$Tmon,$Tyear,$Twday,$Tyday,$Tisdst) = localtime($TDtarget);
$Tyear = ($Tyear + 1900);
$Tmon++;
if ($Tmon < 10) {$Tmon = "0$Tmon";}
if ($Tmday < 10) {$Tmday = "0$Tmday";}
if ($Thour < 10) {$Thour = "0$Thour";}
if ($Tmin < 10) {$Tmin = "0$Tmin";}
if ($Tsec < 10) {$Tsec = "0$Tsec";}
	$TDSQLdate = "$Tyear-$Tmon-$Tmday $Thour:$Tmin:$Tsec";

$VDAD_SQL_time = "and event_time > \"$TDSQLdate\" and event_time < \"$FDSQLdate\"";
$VDAD_SQL_time_where = "where event_time > \"$TDSQLdate\" and event_time < \"$FDSQLdate\"";
$VDCL_SQL_time = "and call_date > \"$TDSQLdate\" and call_date < \"$FDSQLdate\"";
$VDCL_SQL_time_where = "where call_date > \"$TDSQLdate\" and call_date < \"$FDSQLdate\"";
$VDP_SQL_time = "and parked_time > \"$TDSQLdate\" and parked_time < \"$FDSQLdate\"";
$QM_SQL_time = "and time_id > $TDtarget and time_id < $FDtarget";
$QM_SQL_time_H = "and time_id > $TDtarget and time_id < $HDtarget";

if ($ALL_TIME > 0)
	{
	$VDAD_SQL_time = "";
	$VDCL_SQL_time = "";
	$VDCL_SQL_time_where = "where call_date > \"2000-01-01 00:00:00\"";
	$QM_SQL_time = "";
	}
if ($ONE_MINUTE > 0)
	{
	$MDtarget = ($secX - 60); # 1 minute in the past
	($Msec,$Mmin,$Mhour,$Mmday,$Mmon,$Myear,$Mwday,$Myday,$Misdst) = localtime($MDtarget);
	$Myear = ($Myear + 1900);
	$Mmon++;
	if ($Mmon < 10) {$Mmon = "0$Mmon";}
	if ($Mmday < 10) {$Mmday = "0$Mmday";}
	if ($Mhour < 10) {$Mhour = "0$Mhour";}
	if ($Mmin < 10) {$Mmin = "0$Mmin";}
	if ($Msec < 10) {$Msec = "0$Msec";}
		$MDSQLdate = "$Myear-$Mmon-$Mmday $Mhour:$Mmin:$Msec";

	$VDAD_SQL_time = "and event_time < \"$MDSQLdate\" and event_time > \"$TDSQLdate\"";
	$VDAD_SQL_time_where = "where event_time > \"$MDSQLdate\" and event_time < \"$TDSQLdate\"";
	$VDCL_SQL_time = "and call_date < \"$MDSQLdate\" and call_date > \"$TDSQLdate\"";
	$VDCL_SQL_time_where = "where call_date < \"$MDSQLdate\" and call_date > \"$TDSQLdate\"";
	$VDP_SQL_time = "and parked_time > \"$TDSQLdate\" and parked_time < \"$MDSQLdate\"";
	$QM_SQL_time = "and time_id < $MDtarget and time_id > $TDtarget";
	$QM_SQL_time_H = "and time_id < $MDtarget and time_id > $TDtarget";
	}
if ($TWENTYFOUR_HOURS > 0)
	{
	$TDtarget = ($secX - 86400); # 24 hours in the past
	($Tsec,$Tmin,$Thour,$Tmday,$Tmon,$Tyear,$Twday,$Tyday,$Tisdst) = localtime($TDtarget);
	$Tyear = ($Tyear + 1900);
	$Tmon++;
	if ($Tmon < 10) {$Tmon = "0$Tmon";}
	if ($Tmday < 10) {$Tmday = "0$Tmday";}
	if ($Thour < 10) {$Thour = "0$Thour";}
	if ($Tmin < 10) {$Tmin = "0$Tmin";}
	if ($Tsec < 10) {$Tsec = "0$Tsec";}
		$TDSQLdate = "$Tyear-$Tmon-$Tmday $Thour:$Tmin:$Tsec";

	$VDAD_SQL_time = "and event_time > \"$TDSQLdate\" and event_time < \"$FDSQLdate\"";
	$VDAD_SQL_time_where = "where event_time > \"$TDSQLdate\" and event_time < \"$FDSQLdate\"";
	$VDCL_SQL_time = "and call_date > \"$TDSQLdate\" and call_date < \"$FDSQLdate\"";
	$VDCL_SQL_time_where = "where call_date > \"$TDSQLdate\" and call_date < \"$FDSQLdate\"";
	$VDP_SQL_time = "and parked_time > \"$TDSQLdate\" and parked_time < \"$FDSQLdate\"";
	$QM_SQL_time = "and time_id > $TDtarget and time_id < $FDtarget";
	$QM_SQL_time_H = "and time_id > $TDtarget and time_id < $HDtarget";
	}
if ($ONEDAYAGO > 0)
	{
	$TDtarget = ($secX - 86400); # 24 hours in the past
	($Tsec,$Tmin,$Thour,$Tmday,$Tmon,$Tyear,$Twday,$Tyday,$Tisdst) = localtime($TDtarget);
	$Tyear = ($Tyear + 1900);
	$Tmon++;
	if ($Tmon < 10) {$Tmon = "0$Tmon";}
	if ($Tmday < 10) {$Tmday = "0$Tmday";}
	if ($Thour < 10) {$Thour = "0$Thour";}
	if ($Tmin < 10) {$Tmin = "0$Tmin";}
	if ($Tsec < 10) {$Tsec = "0$Tsec";}
		$TDSQLdate = "$Tyear-$Tmon-$Tmday $Thour:$Tmin:$Tsec";

	$KDtarget = ($secX - 172800); # 48 hours in the past
	($Ksec,$Kmin,$Khour,$Kmday,$Kmon,$Kyear,$Kwday,$Kyday,$Kisdst) = localtime($KDtarget);
	$Kyear = ($Kyear + 1900);
	$Kmon++;
	if ($Kmon < 10) {$Kmon = "0$Kmon";}
	if ($Kmday < 10) {$Kmday = "0$Kmday";}
	if ($Khour < 10) {$Khour = "0$Khour";}
	if ($Kmin < 10) {$Kmin = "0$Kmin";}
	if ($Ksec < 10) {$Ksec = "0$Ksec";}
		$KDSQLdate = "$Kyear-$Kmon-$Kmday $Khour:$Kmin:$Ksec";

	$VDAD_SQL_time = "and event_time > \"$KDSQLdate\" and event_time < \"$TDSQLdate\"";
	$VDAD_SQL_time_where = "where event_time > \"$KDSQLdate\" and event_time < \"$TDSQLdate\"";
	$VDCL_SQL_time = "and call_date > \"$KDSQLdate\" and call_date < \"$TDSQLdate\"";
	$VDCL_SQL_time_where = "where call_date > \"$KDSQLdate\" and call_date < \"$TDSQLdate\"";
	$VDP_SQL_time = "and parked_time > \"$KDSQLdate\" and parked_time < \"$TDSQLdate\"";
	$QM_SQL_time = "and time_id > $KDtarget and time_id < $TDtarget";
	$QM_SQL_time_H = "and time_id > $KDtarget and time_id < $TDtarget";
	}
if ($TWENTYFOUR_OLDER > 0)
	{
	$TDtarget = ($secX - 86400); # 24 hours in the past
	($Tsec,$Tmin,$Thour,$Tmday,$Tmon,$Tyear,$Twday,$Tyday,$Tisdst) = localtime($TDtarget);
	$Tyear = ($Tyear + 1900);
	$Tmon++;
	if ($Tmon < 10) {$Tmon = "0$Tmon";}
	if ($Tmday < 10) {$Tmday = "0$Tmday";}
	if ($Thour < 10) {$Thour = "0$Thour";}
	if ($Tmin < 10) {$Tmin = "0$Tmin";}
	if ($Tsec < 10) {$Tsec = "0$Tsec";}
		$TDSQLdate = "$Tyear-$Tmon-$Tmday $Thour:$Tmin:$Tsec";

	$VDAD_SQL_time = "and event_time < \"$TDSQLdate\"";
	$VDAD_SQL_time_where = "where event_time < \"$TDSQLdate\"";
	$VDCL_SQL_time = "and call_date < \"$TDSQLdate\"";
	$VDCL_SQL_time_where = "where call_date < \"$TDSQLdate\"";
	$VDP_SQL_time = "and parked_time < \"$TDSQLdate\"";
	$QM_SQL_time = "and time_id < $TDtarget";
	$QM_SQL_time_H = "and time_id < $TDtarget";
	}
if ($THIRTY_DAYS > 0)
	{
	$TDtarget = ($secX - 2592000); # 30 days in the past
	($Tsec,$Tmin,$Thour,$Tmday,$Tmon,$Tyear,$Twday,$Tyday,$Tisdst) = localtime($TDtarget);
	$Tyear = ($Tyear + 1900);
	$Tmon++;
	if ($Tmon < 10) {$Tmon = "0$Tmon";}
	if ($Tmday < 10) {$Tmday = "0$Tmday";}
	if ($Thour < 10) {$Thour = "0$Thour";}
	if ($Tmin < 10) {$Tmin = "0$Tmin";}
	if ($Tsec < 10) {$Tsec = "0$Tsec";}
		$TDSQLdate = "$Tyear-$Tmon-$Tmday $Thour:$Tmin:$Tsec";

	$VDAD_SQL_time = "and event_time > \"$TDSQLdate\" and event_time < \"$FDSQLdate\"";
	$VDAD_SQL_time_where = "where event_time > \"$TDSQLdate\" and event_time < \"$FDSQLdate\"";
	$VDCL_SQL_time = "and call_date > \"$TDSQLdate\" and call_date < \"$FDSQLdate\"";
	$VDCL_SQL_time_where = "where call_date > \"$TDSQLdate\" and call_date < \"$FDSQLdate\"";
	$VDP_SQL_time = "and parked_time > \"$TDSQLdate\" and parked_time < \"$FDSQLdate\"";
	$QM_SQL_time = "and time_id > $TDtarget and time_id < $FDtarget";
	$QM_SQL_time_H = "and time_id > $TDtarget and time_id < $HDtarget";
	}

# default path to astguiclient configuration file:
$PATHconf =		'/etc/astguiclient.conf';

open(conf, "$PATHconf") || die "can't open $PATHconf: $!\n";
@conf = <conf>;
close(conf);
$i=0;
foreach(@conf)
	{
	$line = $conf[$i];
	$line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
	if ( ($line =~ /^PATHhome/) && ($CLIhome < 1) )
		{$PATHhome = $line;   $PATHhome =~ s/.*=//gi;}
	if ( ($line =~ /^PATHlogs/) && ($CLIlogs < 1) )
		{$PATHlogs = $line;   $PATHlogs =~ s/.*=//gi;}
	if ( ($line =~ /^PATHagi/) && ($CLIagi < 1) )
		{$PATHagi = $line;   $PATHagi =~ s/.*=//gi;}
	if ( ($line =~ /^PATHweb/) && ($CLIweb < 1) )
		{$PATHweb = $line;   $PATHweb =~ s/.*=//gi;}
	if ( ($line =~ /^PATHsounds/) && ($CLIsounds < 1) )
		{$PATHsounds = $line;   $PATHsounds =~ s/.*=//gi;}
	if ( ($line =~ /^PATHmonitor/) && ($CLImonitor < 1) )
		{$PATHmonitor = $line;   $PATHmonitor =~ s/.*=//gi;}
	if ( ($line =~ /^VARserver_ip/) && ($CLIserver_ip < 1) )
		{$VARserver_ip = $line;   $VARserver_ip =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_server/) && ($CLIDB_server < 1) )
		{$VARDB_server = $line;   $VARDB_server =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_database/) && ($CLIDB_database < 1) )
		{$VARDB_database = $line;   $VARDB_database =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_user/) && ($CLIDB_user < 1) )
		{$VARDB_user = $line;   $VARDB_user =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_pass/) && ($CLIDB_pass < 1) )
		{$VARDB_pass = $line;   $VARDB_pass =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_port/) && ($CLIDB_port < 1) )
		{$VARDB_port = $line;   $VARDB_port =~ s/.*=//gi;}
	$i++;
	}

### concurrency check
if ($run_check > 0)
	{
	my $grepout = `/bin/ps ax | grep $0 | grep -v grep | grep -v '/bin/sh'`;
	my $grepnum=0;
	$grepnum++ while ($grepout =~ m/\n/g);
	if ($grepnum > 1) 
		{
		if ($DB) {print "I am not alone! Another $0 is running! Exiting...\n";}
		exit;
		}
	}

# Customized Variables
$server_ip = $VARserver_ip;		# Asterisk server IP

if (!$CLEANLOGfile) {$CLEANLOGfile = "$PATHlogs/clean.$Hyear-$Hmon-$Hmday";}

if (!$VARDB_port) {$VARDB_port='3306';}

use DBI;	  

$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
or die "Couldn't connect to database: " . DBI->errstr;

#############################################
##### START QUEUEMETRICS LOGGING LOOKUP #####
$stmtA = "SELECT enable_queuemetrics_logging,queuemetrics_server_ip,queuemetrics_dbname,queuemetrics_login,queuemetrics_pass,queuemetrics_log_id,queuemetrics_eq_prepend,queuemetrics_loginout,queuemetrics_dispo_pause,queuemetrics_pause_type FROM system_settings;";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
if ($sthArows > 0)
	{
	@aryA = $sthA->fetchrow_array;
	$enable_queuemetrics_logging =	$aryA[0];
	$queuemetrics_server_ip	=	$aryA[1];
	$queuemetrics_dbname =		$aryA[2];
	$queuemetrics_login=		$aryA[3];
	$queuemetrics_pass =		$aryA[4];
	$queuemetrics_log_id =		$aryA[5];
	$queuemetrics_eq_prepend =	$aryA[6];
	$queuemetrics_loginout =	$aryA[7];
	$queuemetrics_dispo_pause = $aryA[8];
	$queuemetrics_pause_type =	$aryA[9];
	}
$sthA->finish();
##### END QUEUEMETRICS LOGGING LOOKUP #####
###########################################





### BEGIN roll back the last_local_call_time and called_count for leads that were previewed and not dialed
# this function will basically gather every MANUAL DIAL lead_id that any agent handled during the current day and check if it has a dispo, or has a log entry in the vicidial_dial_log or vicidial_log, and if not, then roll back the lead called data
#  and lead_id=31095499
if ($roll_back_preview_skips > 0) 
	{
	$processed_lead_ids=' ';
	if ($DB) {print " - check for leads that were handled by an agent that had no status\n";}
	$stmtA = "SELECT agent_log_id,lead_id,comments,user,status,event_time,wait_epoch,DATE(event_time) from vicidial_agent_log $VDAD_SQL_time_where and ( (status IS NULL) or (status IN('','ERI')) ) and comments='MANUAL' order by event_time desc;";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	if($DBX){print STDERR "\n$sthArows|$stmtA|\n";}
	$i=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$RB_agent_log_id[$i] =	$aryA[0];
		$RB_lead_id[$i] =		$aryA[1];
		$RB_comments[$i] =		$aryA[2];
		$RB_user[$i] =			$aryA[3];
		$RB_status[$i] =		$aryA[4];
		$RB_event_time[$i] =	$aryA[5];
		$RB_wait_epoch[$i] =	$aryA[6];
		$RB_wait_epoch60min[$i] = ($RB_wait_epoch[$i] - 3600);
		$RB_event_timeDATE[$i] =$aryA[7];
		$i++;
		}
	$sthA->finish();

	if ($DB > 0) 
		{
		print "$sthArows vicidial_agent_log no-status records found, starting analysis...\n";
		}

	$i=0;
	$newer_agent_record=0;
	$newer_outbound_record=0;
	$newer_dial_record=0;
	$newer_closer_record=0;
	$bad_agent_log=0;
	$within_hour_agent_record=0;
	$lead_gone=0;
	$lead_not_updated=0;
	$lead_already_processed=0;
	$live_callback_found=0;
	$update_called_count=0;
	$update_last_call=0;
	$lead_updates=0;
	$lead_updates_affected=0;

	while ($sthArows > $i)
		{
		# check for newer agent record with a status for this lead
		$stmtA = "SELECT count(*) from vicidial_agent_log $VDAD_SQL_time_where and lead_id='$RB_lead_id[$i]' and agent_log_id!='$RB_agent_log_id[$i]' and ( (wait_epoch >= \"$RB_wait_epoch[$i]\") or (event_time >= \"$RB_event_time[$i]\") ) and ( (status IS NOT NULL) and (status NOT IN('','ERI')) );";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArowsVAL=$sthA->rows;
		if($DBX){print STDERR "\n$sthArowsVAL|$stmtA|\n";}
		if ($sthArowsVAL > 0)
			{
			@aryA = $sthA->fetchrow_array;
			$sthA->finish();
			$newer_agent_count[$i] =	$aryA[0];
			if ($newer_agent_count[$i] > 0) 
				{$newer_agent_record++;}
			else
				{
				# check for vicidial_log entry for this lead
				$stmtA = "SELECT count(*) from vicidial_log $VDCL_SQL_time_where and lead_id='$RB_lead_id[$i]' and (call_date >= \"$RB_event_time[$i]\") and ( (status IS NOT NULL) and (status NOT IN('','ERI')) );";
				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
				$sthArowsVAL=$sthA->rows;
				if($DBX){print STDERR "\n$sthArowsVAL|$stmtA|\n";}
				if ($sthArowsVAL > 0)
					{
					@aryA = $sthA->fetchrow_array;
					$sthA->finish();
					$newer_outbound_count[$i] =	$aryA[0];
					if ($newer_outbound_count[$i] > 0) 
						{$newer_outbound_record++;}
					else
						{
						# check for vicidial_dial_log entry for this lead
						$stmtA = "SELECT count(*) from vicidial_dial_log $VDCL_SQL_time_where and lead_id='$RB_lead_id[$i]' and (call_date >= \"$RB_event_time[$i]\") and caller_code NOT LIKE \"%Alert%\";";
						$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
						$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
						$sthArowsVAL=$sthA->rows;
						if($DBX){print STDERR "\n$sthArowsVAL|$stmtA|\n";}
						if ($sthArowsVAL > 0)
							{
							@aryA = $sthA->fetchrow_array;
							$sthA->finish();
							$newer_dial_count[$i] =	$aryA[0];
							if ($newer_dial_count[$i] > 0) 
								{$newer_dial_record++;}
							else
								{
								# check for vicidial_closer_log entry for this lead
								$stmtA = "SELECT count(*) from vicidial_closer_log $VDCL_SQL_time_where and lead_id='$RB_lead_id[$i]' and (call_date >= \"$RB_event_time[$i]\");";
								$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
								$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
								$sthArowsVAL=$sthA->rows;
								if($DBX){print STDERR "\n$sthArowsVAL|$stmtA|\n";}
								if ($sthArowsVAL > 0)
									{
									@aryA = $sthA->fetchrow_array;
									$sthA->finish();
									$newer_closer_count[$i] =	$aryA[0];
									if ($newer_closer_count[$i] > 0) 
										{$newer_closer_record++;}
									else
										{
										# check for slightly older agent record with a status for this lead
										$stmtA = "SELECT count(*) from vicidial_agent_log $VDAD_SQL_time_where and lead_id='$RB_lead_id[$i]' and agent_log_id!='$RB_agent_log_id[$i]' and (wait_epoch >= \"$RB_wait_epoch60min[$i]\") and (wait_epoch > 0) and ( (status IS NOT NULL) and (status NOT IN('','ERI')) );";
										$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
										$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
										$sthArowsVAL=$sthA->rows;
										if($DBX){print STDERR "\n$sthArowsVAL|$stmtA|\n";}
										if ($sthArowsVAL > 0)
											{
											@aryA = $sthA->fetchrow_array;
											$sthA->finish();
											$within_hour_agent_count[$i] =	$aryA[0];
											if ($within_hour_agent_count[$i] > 0) 
												{$within_hour_agent_record++;}
											else
												{
												# check for lead existing
												$stmtA = "SELECT count(*) from vicidial_list where lead_id='$RB_lead_id[$i]';";
												$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
												$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
												$sthArowsVL=$sthA->rows;
												if($DBX){print STDERR "\n$sthArowsVL|$stmtA|\n";}
												if ($sthArowsVL > 0)
													{
													@aryA = $sthA->fetchrow_array;
													$sthA->finish();
													$lead_gone_count[$i] =	$aryA[0];
													if ($lead_gone_count[$i] < 1) 
														{$lead_gone++;}
													else
														{
														# check for lead modification date being in the past
														$stmtA = "SELECT count(*) from vicidial_list where lead_id='$RB_lead_id[$i]' and last_local_call_time < \"$RB_event_timeDATE[$i] 00:00:00\";";
														$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
														$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
														$sthArowsVL=$sthA->rows;
														if($DBX){print STDERR "\n$sthArowsVL|$stmtA|\n";}
														if ($sthArowsVL > 0)
															{
															@aryA = $sthA->fetchrow_array;
															$sthA->finish();
															$lead_not_updated_count[$i] =	$aryA[0];
															if ($lead_not_updated_count[$i] > 0) 
																{$lead_not_updated++;}
															else
																{
																# check for live/active callback record
																$stmtA = "SELECT count(*) from vicidial_callbacks where lead_id='$RB_lead_id[$i]' and status IN('ACTIVE','LIVE');";
																$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
																$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
																$sthArowsVL=$sthA->rows;
																if($DBX){print STDERR "\n$sthArowsVL|$stmtA|\n";}
																if ($sthArowsVL > 0)
																	{
																	@aryA = $sthA->fetchrow_array;
																	$sthA->finish();
																	$live_callback_count[$i] =	$aryA[0];
																	if ($live_callback_count[$i] > 0) 
																		{$live_callback_found++;}
																	else
																		{
																		# check for already processed lead
																		if ($processed_lead_ids =~ / $RB_lead_id[$i] /) 
																			{$lead_already_processed++;}
																		else
																			{
																			$something_changed=0;
																			$use_vd_log=0;
																			$processed_lead_ids .= "$RB_lead_id[$i] ";
																			$bad_agent_log++;
																			if ($DB > 0) {print "FOUND!     $i|$bad_agent_log|User: $RB_user[$i]|Lead ID: $RB_lead_id[$i]|Time: $RB_event_time[$i]|Agent Log ID: $RB_agent_log_id[$i]| \n";}

																			# gather lead info before fix
																			$last_call_EPOCH=0;
																			$stmtA = "SELECT entry_date,called_count,last_local_call_time,UNIX_TIMESTAMP(last_local_call_time) from vicidial_list where lead_id='$RB_lead_id[$i]';";
																			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
																			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
																			$sthArowsVL=$sthA->rows;
																			if($DBX){print STDERR "\n$sthArowsVL|$stmtA|\n";}
																			if ($sthArowsVL > 0)
																				{
																				@aryA = $sthA->fetchrow_array;
																				$sthA->finish();
																				$entry_date =			$aryA[0];
																				$called_count =			$aryA[1];
																				$last_local_call_time =	$aryA[2];
																				$last_call_day =		$aryA[2];
																					$last_call_day =~ s/ .*//gi;
																				$last_call_EPOCH =		$aryA[3];
																				}

																			# gather lead info before fix
																			$dial_log_count=0;
																			$stmtA = "SELECT count(*) from vicidial_dial_log where lead_id='$RB_lead_id[$i]' and call_date >= \"$entry_date\" and caller_code NOT LIKE \"%Alert%\";";
																			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
																			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
																			$sthArowsVDL=$sthA->rows;
																			if($DBX){print STDERR "\n$sthArowsVDL|$stmtA|\n";}
																			if ($sthArowsVDL > 0)
																				{
																				@aryA = $sthA->fetchrow_array;
																				$sthA->finish();
																				$dial_log_count =	$aryA[0];
																				}
																			$vd_log_count=0;
																			$stmtA = "SELECT count(*) from vicidial_log where lead_id='$RB_lead_id[$i]' and call_date >= \"$entry_date\";";
																			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
																			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
																			$sthArowsVDL=$sthA->rows;
																			if($DBX){print STDERR "\n$sthArowsVDL|$stmtA|\n";}
																			if ($sthArowsVDL > 0)
																				{
																				@aryA = $sthA->fetchrow_array;
																				$sthA->finish();
																				$vd_log_count =	$aryA[0];
																				}
																			if ($vd_log_count > $dial_log_count) 
																				{
																				$use_vd_log++;
																				if($DB){print STDERR "     DEBUG 0: use vicidial_log count: |$vd_log_count|$dial_log_count|$RB_lead_id[$i]|\n";}
																				$dial_log_count = $vd_log_count;
																				}
																			if ($called_count ne $dial_log_count) 
																				{
																				if($DB){print STDERR "     DEBUG 1: lead called_count change: |$called_count|$dial_log_count|$RB_lead_id[$i]|\n";}
																				$update_called_count++;
																				$something_changed++;
																				$called_count = $dial_log_count;
																				}
																			if ($dial_log_count > 0)
																				{
																				$stmtA = "SELECT call_date,UNIX_TIMESTAMP(call_date) from vicidial_dial_log where lead_id='$RB_lead_id[$i]' and call_date >= \"$entry_date\" and caller_code NOT LIKE \"%Alert%\" order by call_date desc limit 1;";
																				if ($use_vd_log > 0) 
																					{$stmtA = "SELECT call_date,UNIX_TIMESTAMP(call_date) from vicidial_log where lead_id='$RB_lead_id[$i]' and call_date >= \"$entry_date\" order by call_date desc limit 1;";}
																				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
																				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
																				$sthArowsVDL=$sthA->rows;
																				if($DBX){print STDERR "\n$sthArowsVDL|$stmtA|\n";}
																				if ($sthArowsVDL > 0)
																					{
																					@aryA = $sthA->fetchrow_array;
																					$sthA->finish();
																					$last_local_call_time_DIAL =	$aryA[0];
																					$last_call_day_DIAL =			$aryA[0];
																						$last_call_day_DIAL =~ s/ .*//gi;
																					$last_local_call_time_EPOCH =	$aryA[1];
																					if ( ($last_local_call_time_EPOCH > 0) && ($last_call_day ne $last_call_day_DIAL) )
																						{
																						if($DB){print STDERR "     DEBUG 2: lead last_local_call_time change: |$last_local_call_time|$last_local_call_time_DIAL|$last_call_day|$last_call_day_DIAL|$RB_lead_id[$i]|\n";}
																						$update_last_call++;
																						$something_changed++;
																						$last_local_call_time = $last_local_call_time_DIAL;
																						}
																					}
																				}
																			if ($called_count < 1) 
																				{$last_local_call_time = $entry_date;}
																			if ($something_changed > 0) 
																				{
																				$VLaffected_rows=0;
																				$stmtAX = "UPDATE vicidial_list SET last_local_call_time='$last_local_call_time',called_count='$called_count' where lead_id='$RB_lead_id[$i]';";
																				if ($TEST < 1) {$VLaffected_rows = $dbhA->do($stmtAX);}
																				if ($DB) {print "VL record updated: $VLaffected_rows|$stmtAX|\n";}
																				$lead_updates_affected = ($lead_updates_affected + $VLaffected_rows);
																				$lead_updates++;
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				else
					{
					if ($DB > 0) 
						{print "ERROR VL query: $i|$stmtA|\n";}
					}
				}
			}
		
		$i++;

		if ( ($i =~ /0$/) && ($DB > 0) )
			{
			if ($i =~ /00$/) {$k='+';}
			if ($i =~ /10$/) {$k='|';}
			if ($i =~ /20$/) {$k='/';}
			if ($i =~ /30$/) {$k='-';}
			if ($i =~ /40$/) {$k="\\";}
			if ($i =~ /50$/) {$k='|';}
			if ($i =~ /60$/) {$k='/';}
			if ($i =~ /70$/) {$k='-';}
			if ($i =~ /80$/) {$k="\\";}
			if ($i =~ /90$/) {$k='0';}
			print STDERR "$k    $i / $sthArows     BAD: $bad_agent_log \r";
			}
		}

	if ($DB > 0) 
		{
		print "Processiong complete... $i records scanned\n";
		print "Newer agent log record:                   $newer_agent_record \n";
		print "Newer outbound log record:                $newer_outbound_record \n";
		print "Newer dial log record:                    $newer_dial_record \n";
		print "Newer closer log record:                  $newer_closer_record \n";
		print "Within hour agent log record:             $within_hour_agent_record \n";
		print "Lead record gone:                         $lead_gone \n";
		print "Lead call time not updated:               $lead_not_updated \n";
		print "Live callback found:                      $live_callback_found \n";
		print "Lead already processed:                   $lead_already_processed \n";
		print "     Bad agent log record:                $bad_agent_log \n";
		print "        Update lead called_count:            $update_called_count \n";
		print "        Update lead last_call:               $update_last_call \n";
		print "        Total leads updated:                 $lead_updates ($lead_updates_affected) \n";
		}

	exit;
	}
### END roll back the last_local_call_time and called_count for leads that were previewed and not dialed





### BEGIN check for vicidial_log entries with a user with no vicidial_agent_log entry
if ($vl_val_check > 0) 
	{
	if ($DB) {print " - check for vicidial_log entries with a user with no vicidial_agent_log entry\n";}
	$stmtA = "SELECT call_date,lead_id,uniqueid,user,status from vicidial_log $VDCL_SQL_time_where and user NOT IN('','VDAC','VDAD') order by call_date;";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	if($DBX){print STDERR "\n$sthArows|$stmtA|\n";}
	$i=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$dup_call_date[$i] =	$aryA[0];
			$dup_date[$i] = $aryA[0];
			$dup_date[$i] =~ s/ .*//;

		$dup_lead[$i] =			$aryA[1];
		$dup_uniqueid[$i] =		$aryA[2];
		$dup_user[$i] =			$aryA[3];
		$dup_status[$i] =		$aryA[4];
		$i++;
		}
	$sthA->finish();

	if ($DB > 0) 
		{
		print "$sthArows vicidial_log records found, starting lookups...\n";
		}

	$i=0;
	$missing=0;
	$missing_uid=0;
	while ($sthArows > $i)
		{
		$stmtA = "SELECT count(*) from vicidial_agent_log where user='$dup_user[$i]' and lead_id='$dup_lead[$i]' and uniqueid='$dup_uniqueid[$i]' and event_time >= \"$dup_date[$i] 00:00:00\" and event_time <= \"$dup_date[$i] 23:59:59\";";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArowsVAL=$sthA->rows;
		if($DBX){print STDERR "\n$sthArowsVAL|$stmtA|\n";}
		if ($sthArowsVAL > 0)
			{
			@aryA = $sthA->fetchrow_array;
			$sthA->finish();
			$dup_agent_count[$i] =	$aryA[0];
			if ($dup_agent_count[$i] < 1) 
				{
				$stmtA = "SELECT uniqueid from vicidial_agent_log where user='$dup_user[$i]' and lead_id='$dup_lead[$i]' and event_time >= \"$dup_date[$i] 00:00:00\" and event_time <= \"$dup_date[$i] 23:59:59\";";
				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
				$sthArowsVAL=$sthA->rows;
				if($DBX){print STDERR "\n$sthArowsVAL|$stmtA|\n";}
				if ($sthArowsVAL > 0)
					{
					@aryA = $sthA->fetchrow_array;
					$dup_agent_uniqueid[$i] =	$aryA[0];
					if ($dup_agent_uniqueid[$i] != $dup_uniqueid[$i]) 
						{
						$missing_uid++;
						if ($DBX > 0) 
							{print "VAL record UID MISMATCH: $i|$missing_uid|     |$dup_call_date[$i]|$dup_user[$i]|$dup_lead[$i]|$dup_uniqueid[$i]|$dup_agent_uniqueid[$i]|$dup_status[$i]|\n";}
						}
					}
				else
					{
					$missing++;
					if ($DB > 0) 
						{print "Missing VAL record: $i|$missing|     |$dup_call_date[$i]|$dup_user[$i]|$dup_lead[$i]|$dup_uniqueid[$i]|$dup_status[$i]|\n";}
					}
				}
			}
		
		$i++;

		if ( ($i =~ /0$/) && ($DB > 0) )
			{
			if ($i =~ /00$/) {$k='+';}
			if ($i =~ /10$/) {$k='|';}
			if ($i =~ /20$/) {$k='/';}
			if ($i =~ /30$/) {$k='-';}
			if ($i =~ /40$/) {$k="\\";}
			if ($i =~ /50$/) {$k='|';}
			if ($i =~ /60$/) {$k='/';}
			if ($i =~ /70$/) {$k='-';}
			if ($i =~ /80$/) {$k="\\";}
			if ($i =~ /90$/) {$k='0';}
			print STDERR "$k    $i / $sthArows     MISSING: $missing ($missing_uid)\r";
			}
		}

	if ($DB > 0) 
		{
		print "DONE:     TOTAL: $i     MISSING: $missing ($missing_uid)\n";
		}

	exit;
	}
### END check for vicidial_log entries with a user with no vicidial_agent_log entry





##### BEGIN hold entries process (not recurring process, only run once) #####
### NOTE: after running with this flag, you need to run without this flag to recalculate wait_sec and talk_sec of affected records
if ($hold_cleanup > 0)
	{
	if ($DBX) {print "\n\n";}
	if ($DB) {print " - starting validation of on-hold entries\n";}
	$total_corrected_records=0;
	$total_scanned_records=0;
	$total_bad_records=0;
	$total_good=0;
	$total_pause=0;
	$total_wait=0;
	$total_talk=0;
	$total_dispo=0;
	$total_dead=0;

	### Gather distinct users in vicidial_agent_log during time period
	$stmtA = "SELECT user,parked_time,UNIX_TIMESTAMP(parked_time),parked_sec,lead_id,uniqueid from park_log where parked_sec > 0 $VDP_SQL_time;";
	if ($DBX) {print "$stmtA\n";}
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArowsU=$sthA->rows;

	$i=0;
	while ($sthArowsU > $i)
		{
		@aryA = $sthA->fetchrow_array;	
		$Vuser[$i] =		$aryA[0];
		$Vpark_time[$i] =	$aryA[1];
		$Vpark_epoch[$i] =	$aryA[2];
		$Vpark_sec[$i] =	$aryA[3];
		$Vlead_id[$i] =		$aryA[4];
		$Vuniqueid[$i] = 	$aryA[5];
		$i++;
		}
	$sthA->finish();

	$i=0;
	while ($sthArowsU > $i)
		{
		### Gather distinct users in vicidial_agent_log during time period
		$stmtA = "SELECT talk_epoch,agent_log_id from vicidial_agent_log where lead_id='$Vlead_id[$i]' and uniqueid='$Vuniqueid[$i]' and user='$Vuser[$i]' and talk_epoch >= '$Vpark_epoch[$i]' $VDAD_SQL_time;";
		if ($DBX) {print "$stmtA\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$VCL_bad_records=$sthA->rows;
		if ($VCL_bad_records < 1)
			{
			if ($DBX) {print "   VAL record good: $Vlead_id[$i]|$Vuser[$i]|$Vpark_epoch[$i]|$Vpark_time[$i]|$Vuniqueid[$i]\n";}
			$val_good++;
			}
		else
			{
			@aryAbad = $sthA->fetchrow_array;
			$Vold_talk_epoch[$i] =	$aryAbad[0];
			$Vagent_log_id[$i] =	$aryAbad[1];
			if ($DB) {print "      VAL record BAD: $Vlead_id[$i]|$Vuser[$i]|$Vpark_epoch[$i]|$Vpark_time[$i]|$Vuniqueid[$i]|$Vold_talk_epoch[$i]\n";}

			### check inbound log ###
			$stmtA = "SELECT start_epoch,length_in_sec,queue_seconds from vicidial_closer_log where lead_id='$Vlead_id[$i]' and uniqueid='$Vuniqueid[$i]' and user='$Vuser[$i]' $VDCL_SQL_time;";
			if ($DBX) {print "$stmtA\n";}
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$VCL_records=$sthA->rows;
			if ($DBX) {print "vicidial_closer_log record: $VCL_records|$stmtA|\n\n";}
			$h=0;
			while ($VCL_records > $h)
				{
				@aryA = $sthA->fetchrow_array;
				$Vagent_talk_epoch[$i] =	($aryA[0] + $aryA[2]);
				
				$h++;
				}
			if ($h < 1)
				{
				### check outbound log ###
				$stmtA = "SELECT start_epoch,length_in_sec from vicidial_log where lead_id='$Vlead_id[$i]' and uniqueid='$Vuniqueid[$i]' and user='$Vuser[$i]' $VDCL_SQL_time;";
				if ($DBX) {print "$stmtA\n";}
				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
				$VCL_records=$sthA->rows;
				if ($DBX) {print "vicidial_closer_log record: $VCL_records|$stmtA|\n\n";}
				$h=0;
				while ($VCL_records > $h)
					{
					@aryA = $sthA->fetchrow_array;
					$Vagent_talk_epoch[$i] =	$aryA[0];

					$h++;
					}
				if ($h < 1)
					{
					if ($DBX) {print "ERROR: No call record found!\n\n";}
					$total_dead++;
					}
				}
			if ($h > 0)
				{
				$Vagent_talk_epochROUND[$i] = int($Vagent_talk_epoch[$i] + 0.5);
				if ($DBX) {print "UPDATE $Vagent_log_id[$i]  ---  $Vold_talk_epoch[$i]($Vpark_epoch[$i]) with $Vagent_talk_epoch[$i]($Vagent_talk_epochROUND[$i])\n";}

				##### insert vicidial_agent_log record
				$stmtAX = "UPDATE vicidial_agent_log SET talk_epoch='$Vagent_talk_epochROUND[$i]' where agent_log_id='$Vagent_log_id[$i]';";
				if ($TEST < 1)
					{$VALaffected_rows = $dbhA->do($stmtAX);}
				if ($DB) {print "          BAD VAL record updated: $VALaffected_rows|$stmtAX|\n";}

				$total_corrected_records++;
				}

			$total_bad_records++;
			}

		$i++;
		}

	if ($DB) {print " - finished hold scan:\n";}
	if ($DB) {print "     records scanned:         $i\n";}
	if ($DB) {print "     records good:       $total_good\n";}
	if ($DB) {print "     records bad:        $total_bad_records\n";}
	if ($DB) {print "     records not found:    $total_dead\n";}
	if ($DB) {print "     records corrected:    $total_corrected_records\n";}

	if ($DB) {print "process completed, exiting...\n";}

	exit;
	}
##### END hold entries process (not recurring process, only run once) #####


##### BEGIN fix_old_lagged_entries process (not recurring process, only run once) #####
if ($fix_old_lagged_entries > 0)
	{
	if ($DBX) {print "\n\n";}
	if ($DB) {print " - starting validation of vicidial_agent_log sec fields\n";}
	$total_corrected_records=0;
	$total_scanned_records=0;
	$total_pause=0;
	$total_wait=0;
	$total_talk=0;
	$total_dispo=0;
	$total_dead=0;

	### Gather distinct users in vicidial_agent_log during time period
	$stmtA = "SELECT user,agent_log_id,pause_epoch,wait_epoch,talk_epoch,dispo_epoch,UNIX_TIMESTAMP(event_time),server_ip,campaign_id,user_group from vicidial_agent_log where sub_status='LAGGED' $VDAD_SQL_time;";
	if ($DBX) {print "$stmtA\n";}
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArowsU=$sthA->rows;

	$i=0;
	while ($sthArowsU > $i)
		{
		@aryA = $sthA->fetchrow_array;	
		$Vuser[$i]	=			$aryA[0];
		$Vagent_log_id[$i]	=	$aryA[1];
		$Vpause_epoch[$i]	=	$aryA[2];
		$Vwait_epoch[$i]	=	$aryA[3];
		$Vtalk_epoch[$i]	=	$aryA[4];
		$Vdispo_epoch[$i]	=	$aryA[5];
		$Vevent_epoch[$i]	=	$aryA[6];
		$Vserver_ip[$i]	=		$aryA[7];
		$Vcampaign_id[$i]	=	$aryA[8];
		$Vuser_group[$i]	=	$aryA[9];
		if ($Vpause_epoch[$i] > 1000) {$Vlast_epoch[$i] = $Vpause_epoch[$i];}
		if ($Vwait_epoch[$i] > 1000) {$Vlast_epoch[$i] = $Vwait_epoch[$i];}
		if ($Vtalk_epoch[$i] > 1000) {$Vlast_epoch[$i] = $Vtalk_epoch[$i];}
		if ($Vdispo_epoch[$i] > 1000) {$Vlast_epoch[$i] = $Vdispo_epoch[$i];}
		
		($Ksec,$Kmin,$Khour,$Kmday,$Kmon,$Kyear,$Kwday,$Kyday,$Kisdst) = localtime($Vlast_epoch[$i]);
		$Kyear = ($Kyear + 1900);
		$Kmon++;
		if ($Kmon < 10) {$Kmon = "0$Kmon";}
		if ($Kmday < 10) {$Kmday = "0$Kmday";}
		if ($Khour < 10) {$Khour = "0$Khour";}
		if ($Kmin < 10) {$Kmin = "0$Kmin";}
		if ($Ksec < 10) {$Ksec = "0$Ksec";}
		$Vlast_date[$i] = "$Kyear-$Kmon-$Kmday $Khour:$Kmin:$Ksec";

		$i++;
		}
	$sthA->finish();

	$i=0;
	while ($sthArowsU > $i)
		{
		### Gather distinct users in vicidial_agent_log during time period
		$stmtA = "SELECT count(*) from vicidial_agent_log where user='$Vuser[$i]' and pause_epoch='$Vlast_epoch[$i]' $VDAD_SQL_time;";
		if ($DBX) {print "$stmtA\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		@aryA = $sthA->fetchrow_array;	
		if ($aryA[0] < 1)
			{
			##### insert vicidial_agent_log record
			$stmtAX = "INSERT INTO vicidial_agent_log SET user='$Vuser[$i]',event_time='$Vlast_date[$i]',pause_epoch='$Vlast_epoch[$i]',wait_epoch='$Vlast_epoch[$i]',pause_sec='0',user_group='$Vuser_group[$i]',campaign_id='$Vcampaign_id[$i]',server_ip='$Vserver_ip[$i]',sub_status='LOGOUT',pause_type='SYSTEM';";
			if ($TEST < 1)
				{$VALaffected_rows = $dbhA->do($stmtAX);}
			if ($DB) {print "     VAL record inserted: $VALaffected_rows|$stmtAX|\n";}
			$val_fixed++;
			}
		else
			{
			if ($DB) {print "   VAL record exists: $aryA[0]|$stmtA|\n";}
			$val_good++;
			}

		$i++;
		}

	if ($DB) {print " - finished lagged fixing:\n";}
	if ($DB) {print "     records scanned:       $i\n";}
	if ($DB) {print "     records fixed:      $val_fixed\n";}
	if ($DB) {print "     records good:       $val_good\n";}

	if ($DB) {print "process completed, exiting...\n";}

	exit;
	}
##### END fix_old_lagged_entries process #####



### BEGIN CHECKING ENTERQUEUE/CALLOUTBOUND ENTRIES FOR LIVE CALLS
if ($enable_queuemetrics_logging > 0)
	{
	$dbhB = DBI->connect("DBI:mysql:$queuemetrics_dbname:$queuemetrics_server_ip:3306", "$queuemetrics_login", "$queuemetrics_pass")
	 or die "Couldn't connect to database: " . DBI->errstr;

	if ($DBX) {print "CONNECTED TO DATABASE:  $queuemetrics_server_ip|$queuemetrics_dbname\n";}
	
	if ($qm_pausereason_check > 0) 
		{
		$PRdeleted=0;
		$PRsecondchoice=0;
		##############################################################
		##### grab all queue_log entries with a PAUSEREASON to validate  ,'LOGIN'
		$stmtB = "SELECT time_id,agent FROM queue_log where verb='PAUSEREASON' and data1 NOT IN('LAGGED') $QM_SQL_time_H order by time_id;";
		$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
		$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
		$P_pr_records=$sthB->rows;
		if ($DB) {print "TOTAL PAUSEREASON Records: $P_pr_records|$stmtB|\n";}
		$h=0;
		while ($P_pr_records > $h)
			{
			@aryB = $sthB->fetchrow_array;
			$time_id[$h] =	$aryB[0];
			$agent[$h] =	$aryB[1];
			$h++;
			}
		$sthB->finish();

		$h=0;
		while ($P_pr_records > $h)
			{
			$temp_8hours_prev_time = ($time_id[$h] - 28800);
			$PAUSEtime=$temp_8hours_prev_time;
			$temp_8hours_next_time = ($time_id[$h] + 28800);
			$UNPAUSEtime=$temp_8hours_next_time;
			$PAUSEfound=0;
			$UNPAUSEfound=0;
			##### find the most recent PAUSEALL queue_log record before the PAUSEREASON record
			$stmtB = "SELECT time_id FROM queue_log where agent='$agent[$h]' and time_id <= '$time_id[$h]' and time_id > '$temp_8hours_prev_time' and verb='PAUSEALL' and agent='$agent[$h]' order by time_id desc limit 1;";
			$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
			$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
			$PL_records=$sthB->rows;
			if ($PL_records > 0)
				{
				@aryB = $sthB->fetchrow_array;
				$PAUSEtime =		$aryB[0];
				$PAUSEfound++;
				}
			$sthB->finish();
			##### find the most recent UNPAUSEALL queue_log record after the PAUSEREASON record
			$stmtB = "SELECT time_id FROM queue_log where agent='$agent[$h]' and time_id >= '$time_id[$h]' and time_id < '$temp_8hours_next_time' and verb IN('UNPAUSEALL') and agent='$agent[$h]' order by time_id limit 1;";
			$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
			$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
			$PL_recordsUNPAUSEALL=$sthB->rows;
			if ($PL_recordsUNPAUSEALL > 0)
				{
				@aryB = $sthB->fetchrow_array;
				$UNPAUSEtime =		$aryB[0];
				$UNPAUSEfound++;
				}
			$sthB->finish();
			##### find the most recent AGENTLOGOFF queue_log record after the PAUSEREASON record
			$stmtB = "SELECT time_id FROM queue_log where agent='$agent[$h]' and time_id >= '$time_id[$h]' and time_id < '$temp_8hours_next_time' and verb IN('AGENTLOGOFF') and agent='$agent[$h]' order by time_id limit 1;";
			$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
			$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
			$PL_recordsAGENTLOGOFF=$sthB->rows;
			if ($PL_recordsAGENTLOGOFF > 0)
				{
				@aryB = $sthB->fetchrow_array;
				if ($aryB[0] < $UNPAUSEtime) 
					{
					$UNPAUSEtime =		$aryB[0];
					$UNPAUSEfound++;
					}
				}
			$sthB->finish();
			##### find the most recent AGENTLOGIN queue_log record after the PAUSEREASON record
			$stmtB = "SELECT time_id FROM queue_log where agent='$agent[$h]' and time_id >= '$time_id[$h]' and time_id < '$temp_8hours_next_time' and verb IN('AGENTLOGIN') and agent='$agent[$h]' order by time_id limit 1;";
			$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
			$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
			$PL_recordsAGENTLOGIN=$sthB->rows;
			if ($PL_recordsAGENTLOGIN > 0)
				{
				@aryB = $sthB->fetchrow_array;
				if ($aryB[0] < $UNPAUSEtime) 
					{
					$UNPAUSEtime =		$aryB[0];
					$UNPAUSEfound++;
					}
				}
			$sthB->finish();
 			##### find the most recent PAUSEALL queue_log record after the PAUSEREASON record
			$stmtB = "SELECT time_id FROM queue_log where agent='$agent[$h]' and time_id >= '$time_id[$h]' and time_id < '$temp_8hours_next_time' and verb IN('PAUSEALL') and agent='$agent[$h]' order by time_id limit 1;";
			$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
			$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
			$PL_recordsPAUSEALL=$sthB->rows;
			if ($PL_recordsPAUSEALL > 0)
				{
				@aryB = $sthB->fetchrow_array;
				if ($aryB[0] < $UNPAUSEtime) 
					{
					$UNPAUSEtime =		$aryB[0];
					$UNPAUSEfound++;
					}
				}
			$sthB->finish();

			if ( ($PAUSEfound > 0) && ($UNPAUSEfound > 0) )
				{
			#	if ($DBX) {print "PAUSES FOUND: $h|$time_id[$h]|$agent[$h]|$NEXTtime|$NEXTverb|$NEXTqueue|$NEXTcall_id\n";}

				$firstPAUSEREASONtime=0;
				$firstPAUSEREASONdata1='';
				##### find the PAUSEREASON records during the pause session
				$stmtB = "SELECT time_id,data1 FROM queue_log where agent='$agent[$h]' and time_id >= '$PAUSEtime' and time_id <= '$UNPAUSEtime' and verb='PAUSEREASON' and agent='$agent[$h]' and data1 NOT IN('LAGGED') order by time_id limit 100;";
				$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
				$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
				$PR_records=$sthB->rows;
				if ( ($DBX) && ($PR_records > 1) ) {print "PAUSEREASON Records: $PR_records     ($h / $P_pr_records)   $PRdeleted    |$stmtB|\n";}
				$pr=0;
				while ($PR_records > $pr)
					{
					@aryB = $sthB->fetchrow_array;
					$PAUSEREASONtime[$pr] =		$aryB[0];
					$PAUSEREASONdata1[$pr] =	$aryB[1];
					if ($pr < 1) 
						{
						$firstPAUSEREASONtime=$aryB[0];
						$firstPAUSEREASONdata1=$aryB[1];
						}
					else 
						{
						if ( ( ($firstPAUSEREASONdata1 == 'ANDIAL') || ($firstPAUSEREASONdata1 == 'PNCALL') ) && ( ($aryB[1] != 'ANDIAL') && ($aryB[1] != 'PNCALL') ) )
							{
							$firstPAUSEREASONtime=$aryB[0];
							$firstPAUSEREASONdata1=$aryB[1];
							$PRsecondchoice++;
							}
						}
					$pr++;
					}
				$sthB->finish();
			#	if ($DBX) {print "PAUSEREASON records found: $pr|$firstPAUSEREASONtime|$firstPAUSEREASONdata1|\n";}

				if ($pr > 1) 
					{
					$pr=0;
					while ($PR_records > $pr)
						{
						if ($PAUSEREASONtime[$pr] != $firstPAUSEREASONtime)
							{
							##### delete the extra PAUSEREASON records in the queue_log
							$stmtB = "DELETE from queue_log where agent='$agent[$h]' and time_id='$PAUSEREASONtime[$pr]' and data1='$PAUSEREASONdata1[$pr]' and verb='PAUSEREASON' limit 1;";
							if ($TEST < 1)
								{$Baffected_rows = $dbhB->do($stmtB);}
							if ($DB) {print "     extra PAUSEREASON record deleted: $Baffected_rows|$stmtB|\n";}
							$PRdeleted++;

							$event_string = "extra PAUSEREASON record deleted: $h|$PR_records|$pr|$time_id[$h]|$agent[$h]|$PAUSEREASONtime[$pr]|$PAUSEREASONdata1[$pr]|";
							&event_logger;
							}
						$pr++;
						}
					}
				}
			else
				{
				if ($DBX) {print "Missing PAUSEALL or UNPAUSEALL for PAUSEREASON record: $time_id[$h]|$agent[$h]|$PAUSEfound|$UNPAUSEfound|\n";}
				}

		#	if ($PRdeleted > 100) {exit;}

			$h++;
			}
		@time_id=@MT;
		@agent=@MT;

		if ($DB) {print "PAUSEREASON cleanup done, records deleted: $PRdeleted ($PRsecondchoice) \n";}
		}

	if ($qm_qa_duplicate_check > 0) 
		{
		$QAdeleted=0;
		##############################################################
		##### grab top 1000 qa_data records ordered by duplicates first
		$stmtB = "SELECT count(*) as tally,call_id,sys_dt_creazione,sys_user_creazione FROM qa_data group by call_id,sys_dt_creazione,sys_dt_creazione order by tally desc limit 1000;";
		$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
		$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
		$P_qa_records=$sthB->rows;
		if ($DB) {print "TOTAL QA duplicate check Records: $P_qa_records|$stmtB|\n";}
		$h=0;   $qa_dup_ct=0;
		while ($P_qa_records > $h)
			{
			@aryB = $sthB->fetchrow_array;
			if ($aryB[0] > 1) 
				{
				$call_id[$qa_dup_ct] =	$aryB[1];
				$qa_date[$qa_dup_ct] =	$aryB[2];
				$agent[$qa_dup_ct] =	$aryB[3];
				$qa_dup_ct++;
				}
			$h++;
			}
		$sthB->finish();

		$h=0;
		while ($qa_dup_ct > $h)
			{
			##### find the most recent qa_data duplicate record and delete it
			$stmtB = "DELETE FROM qa_data where call_id='$call_id[$h]' and sys_dt_creazione='$qa_date[$h]' and sys_user_creazione='$agent[$h]' order by qadata_id desc limit 1;";

			if ($TEST < 1)
				{$Baffected_rows = $dbhB->do($stmtB);}
			if ($DB) {print "     extra qa_data record deleted: $Baffected_rows|$stmtB|\n";}
			$QAdeleted++;

			$event_string = "extra qa_data record deleted: $Baffected_rows|$h|$call_id[$h]|$qa_date[$h]|$agent[$h]|";
			&event_logger;

			$h++;
			}

		@call_id=@MT;
		@qa_date=@MT;
		@agent=@MT;

		if ($DB) {print "QA DUPLICATE check done, records deleted: $QAdeleted \n";}
		}

	if ($DB) {print " - Checking queue_log in-queue calls in ViciDial\n";}

	##############################################################
	##### grab all queue_log entries for ENTERQUEUE verb to validate
	$stmtB = "SELECT time_id,call_id,queue,verb,serverid FROM queue_log where verb IN('ENTERQUEUE','CALLOUTBOUND') and serverid='$queuemetrics_log_id' $QM_SQL_time_H order by time_id;";
	$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
	$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
	$EQenter_records=$sthB->rows;
	if ($DB) {print "ENTERQUEUE Records: $EQenter_records|$stmtB|\n\n";}
	$h=0;
	while ($EQenter_records > $h)
		{
		@aryB = $sthB->fetchrow_array;
		$time_id[$h] =	$aryB[0];
		$call_id[$h] =	$aryB[1];
		$queue[$h] =	$aryB[2];
		$verb[$h] =		$aryB[3];
		$serverid[$h] =	$aryB[4];
		$lead_id[$h] = substr($call_id[$h], 11, 9);
		$lead_id[$h] = ($lead_id[$h] + 0);
		$h++;
		}
	$sthB->finish();

	$h=0;
	while ($EQenter_records > $h)
		{
		$EQend_count=0;
		##### find the CONNECT/ABANDON/COMPLETEAGENT/COMPLETECALLER/CALLSTATUS/EXITWITHKEY/EXITWITHTIMEOUT/EXITEMPTY count for each record
		$stmtB = "SELECT count(*) FROM queue_log where verb IN('CONNECT','ABANDON','COMPLETEAGENT','COMPLETECALLER','CALLSTATUS','EXITWITHKEY','EXITWITHTIMEOUT','EXITEMPTY') and call_id='$call_id[$h]';";
		$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
		$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
		$CQ_records=$sthB->rows;
		if ($CQ_records > 0)
			{
			@aryB = $sthB->fetchrow_array;
			$EQend_count =		$aryB[0];
			}
		$sthB->finish();

		if ($EQend_count < 1)
			{
			if ($DB) {print "IN-QUEUE CALL: $h|$time_id[$h]|$call_id[$h]|$verb[$h]|$serverid[$h]\n";}

			$VAClive_count=0;
			$VLAlive_count=0;

			$stmtA = "SELECT count(*) FROM vicidial_auto_calls where callerid='$call_id[$h]';";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthArows=$sthA->rows;
			if ($sthArows > 0)
				{
				@aryA = $sthA->fetchrow_array;
				$VAClive_count =	$aryA[0];
				}
			$sthA->finish();

			$stmtA = "SELECT count(*) FROM vicidial_live_agents where callerid='$call_id[$h]';";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthArows=$sthA->rows;
			if ($sthArows > 0)
				{
				@aryA = $sthA->fetchrow_array;
				$VLAlive_count =	$aryA[0];
				}
			$sthA->finish();

			if ( ($VLAlive_count < 1) && ($VAClive_count < 1) )
				{
				$EQdead++;
				if ($DB) {print "     DEAD IN-QUEUE queue_log CALL: $EQdead|$call_id[$h]|$VLAlive_count|$VAClive_count\n";}

				$secX = time();
				$Rtarget = ($secX - 21600);	# look for VDCL entry within last 6 hours
				($Rsec,$Rmin,$Rhour,$Rmday,$Rmon,$Ryear,$Rwday,$Ryday,$Risdst) = localtime($Rtarget);
				$Ryear = ($Ryear + 1900);
				$Rmon++;
				if ($Rmon < 10) {$Rmon = "0$Rmon";}
				if ($Rmday < 10) {$Rmday = "0$Rmday";}
				if ($Rhour < 10) {$Rhour = "0$Rhour";}
				if ($Rmin < 10) {$Rmin = "0$Rmin";}
				if ($Rsec < 10) {$Rsec = "0$Rsec";}
					$RSQLdate = "$Ryear-$Rmon-$Rmday $Rhour:$Rmin:$Rsec";

				### find original queue position of the call
				$queue_position=1;
				$queue_seconds=0;
				$stmtA = "SELECT queue_position,queue_seconds FROM vicidial_closer_log where lead_id='$lead_id[$h]' and campaign_id='$queue[$h]' and call_date > \"$RSQLdate\" order by closecallid desc limit 1;";
				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
				$sthArows=$sthA->rows;
				if ($sthArows > 0)
					{
					@aryA = $sthA->fetchrow_array;
					$queue_position =	$aryA[0];
					$queue_seconds =	int($aryA[1] + .5);
					}
				$sthA->finish();

				$newtimeABANDON = ($time_id[$h] + 1);
				##### insert an ABANDON record for this call into the queue_log
				$stmtB = "INSERT INTO queue_log SET `partition`='P01',time_id='$newtimeABANDON',call_id='$call_id[$h]',queue='$queue[$h]',agent='NONE',verb='ABANDON',data1='1',data2='$queue_position',data3='$queue_seconds',serverid='$serverid[$h]';";
				if ($TEST < 1)
					{
					$Baffected_rows = $dbhB->do($stmtB);
					}
				if ($DB) {print "     ABANDON record inserted: $Baffected_rows|$stmtB|\n";}

				$event_string = "DEAD IN-QUEUE CALL: $h|$EQdead|$time_id[$h]|$call_id[$h]|$queue[$h]|$verb[$h]|$serverid[$h]|$VLAlive_count|$VAClive_count|$Baffected_rows|$stmtB";
				&event_logger;
				}
			}

		$h++;
		}

	@time_id=@MT;
	@agent=@MT;

	##############################################################
	##### grab all queue_log entries with a PAUSEREASON of LAGGED to validate
	$stmtB = "SELECT time_id,agent FROM queue_log where verb='PAUSEREASON' and data1='LAGGED' $QM_SQL_time_H order by time_id;";
	$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
	$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
	$P_lagged_records=$sthB->rows;
	if ($DB) {print "LAGGED Records: $P_lagged_records|$stmtB|\n\n";}
	$h=0;
	while ($P_lagged_records > $h)
		{
		@aryB = $sthB->fetchrow_array;
		$time_id[$h] =	$aryB[0];
		$agent[$h] =	$aryB[1];
		$h++;
		}
	$sthB->finish();

	$h=0;
	while ($P_lagged_records > $h)
		{
		$NEXTtime=0;
		$NEXTverb='';
		$NEXTqueue='';
		$NEXTcall_id='';
		##### find the next queue_log record after the PAUSEREASON record
		$stmtB = "SELECT time_id,verb,queue,call_id FROM queue_log where agent='$agent[$h]' and time_id > '$time_id[$h]' order by time_id limit 1;";
		$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
		$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
		$PL_records=$sthB->rows;
		if ($PL_records > 0)
			{
			@aryB = $sthB->fetchrow_array;
			$NEXTtime =		$aryB[0];
			$NEXTverb =		$aryB[1];
			$NEXTqueue =	$aryB[2];
			$NEXTcall_id =	$aryB[3];
			}
		$sthB->finish();

		if ( ($PL_records > 0) && ($NEXTverb =~ /CALLSTATUS|COMPLETECALLER|COMPLETEAGENT/) )
			{
			$NEXTtimePAUSE = ($NEXTtime + 1);
			if ($DB) {print "LAGGED PAUSE DURING CALL: $h|$time_id[$h]|$agent[$h]|$NEXTtime|$NEXTverb|$NEXTqueue|$NEXTcall_id\n";}

			##### update the PAUSEREASON LAGGED record in the queue_log to one second after the end of the call
			$stmtB = "UPDATE queue_log SET time_id='$NEXTtimePAUSE' where agent='$agent[$h]' and time_id='$time_id[$h]' and verb='PAUSEREASON' and data1='LAGGED' limit 1;";
			if ($TEST < 1)
				{
				$Baffected_rows = $dbhB->do($stmtB);
				}
			if ($DB) {print "     PAUSEREASON record updated: $Baffected_rows|$stmtB|\n";}

			$event_string = "LAGGED DURING CALL: $h|$PL_records|$time_id[$h]|$agent[$h]|$NEXTtimePAUSE|$NEXTverb|$NEXTqueue|$NEXTcall_id|$Baffected_rows|$stmtB";
			&event_logger;
			}

		$h++;
		}


	@time_id=@MT;
	@agent=@MT;

	##############################################################
	##### grab all queue_log entries with a verb of AGENTLOGOFF to validate
	$stmtB = "SELECT time_id,agent FROM queue_log where verb IN('AGENTLOGOFF','AGENTCALLBACKLOGOFF') $QM_SQL_time_H order by time_id;";
	$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
	$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
	$A_logoff_records=$sthB->rows;
	if ($DB) {print "AGENTLOGOFF Records: $A_logoff_records|$stmtB|\n\n";}
	$h=0;
	while ($A_logoff_records > $h)
		{
		@aryB = $sthB->fetchrow_array;
		$time_id[$h] =	$aryB[0];
		$agent[$h] =	$aryB[1];
		$h++;
		}
	$sthB->finish();

	$h=0;
	while ($A_logoff_records > $h)
		{
		$NEXTtime=0;
		$NEXTverb='';
		$NEXTqueue='';
		$NEXTcall_id='';
		##### find the next queue_log record after the PAUSEREASON record
		$stmtB = "SELECT time_id,verb,queue,call_id FROM queue_log where agent='$agent[$h]' and time_id > '$time_id[$h]' order by time_id limit 1;";
		$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
		$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
		$AL_records=$sthB->rows;
		if ($AL_records > 0)
			{
			@aryB = $sthB->fetchrow_array;
			$NEXTtime =		$aryB[0];
			$NEXTverb =		$aryB[1];
			$NEXTqueue =	$aryB[2];
			$NEXTcall_id =	$aryB[3];
			}
		$sthB->finish();

		if ( ($AL_records > 0) && ($NEXTverb =~ /CALLSTATUS|COMPLETECALLER|COMPLETEAGENT/) )
			{
			$NEXTtimeLOGOFF = ($NEXTtime + 1);
			if ($DB) {print "LOGOFF DURING CALL: $h|$time_id[$h]|$agent[$h]|$NEXTtime|$NEXTverb|$NEXTqueue|$NEXTcall_id\n";}

			##### update the AGENTLOGOFF record in the queue_log to one second after the end of the call
			$stmtB = "UPDATE queue_log SET time_id='$NEXTtimeLOGOFF' where agent='$agent[$h]' and time_id='$time_id[$h]' and verb IN('AGENTLOGOFF','AGENTCALLBACKLOGOFF') limit 1;";
			if ($TEST < 1)
				{
				$Baffected_rows = $dbhB->do($stmtB);
				}
			if ($DB) {print "     AGENTLOGOFF record updated: $Baffected_rows|$stmtB|\n";}

			$event_string = "AGENTLOGOFF DURING CALL: $h|$AL_records|$time_id[$h]|$agent[$h]|$NEXTtimeLOGOFF|$NEXTverb|$NEXTqueue|$NEXTcall_id|$Baffected_rows|$stmtB";
			&event_logger;
			}

		$h++;
		}


	@time_id=@MT;
	@agent=@MT;

	##############################################################
	##### grab all queue_log entries with a verb of CONNECT to validate
	$stmtB = "SELECT time_id,agent FROM queue_log where verb IN('CONNECT') $QM_SQL_time_H order by time_id;";
	$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
	$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
	$A_connect_records=$sthB->rows;
	if ($DB) {print "CONNECT Records: $A_connect_records|$stmtB|\n\n";}
	$h=0;
	while ($A_connect_records > $h)
		{
		@aryB = $sthB->fetchrow_array;
		$time_id[$h] =	$aryB[0];
		$agent[$h] =	$aryB[1];
		$h++;
		}
	$sthB->finish();

	$h=0;
	while ($A_connect_records > $h)
		{
		$samecount=0;
		##### find the next queue_log record after the PAUSEREASON record
		$stmtB = "SELECT count(*) FROM queue_log where agent='$agent[$h]' and time_id='$time_id[$h]' and verb IN('PAUSEALL','UNPAUSEALL');";
		$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
		$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
		$PAU_records=$sthB->rows;
		if ($PAU_records > 0)
			{
			@aryB = $sthB->fetchrow_array;
			$samecount =	$aryB[0];
			}
		$sthB->finish();

		if ($samecount >= 2)
			{
			$NEXTtime = ($time_id[$h] + 1);
			if ($DB) {print "CONNECT-PAUSE SAME TIME: $h|$time_id[$h]|$agent[$h]|$NEXTtime|$samecount|\n";}

			##### update the CONNECT and UNPAUSEALL records in the queue_log to one second after the PAUSEALL
			$stmtB = "UPDATE queue_log SET time_id='$NEXTtime' where agent='$agent[$h]' and time_id='$time_id[$h]' and verb IN('CONNECT','UNPAUSEALL') limit 2;";
			if ($TEST < 1)
				{
				$Baffected_rows = $dbhB->do($stmtB);
				}
			if ($DB) {print "     CONNECT-PAUSE records updated: $Baffected_rows|$stmtB|\n";}

			$event_string = "CONNECT-PAUSE SAME TIME: $h|$time_id[$h]|$agent[$h]|$NEXTtime|$samecount|$Baffected_rows|$stmtB";
			&event_logger;
			}

		$h++;
		}


	if ($qm_live_call_check > 0)
		{
		exit;
		}
	}
### END CHECKING ENTERQUEUE/CALLOUTBOUND ENTRIES FOR LIVE CALLS AND PAUSEREASON-LAGGED/LOGOFF ENTRIES FOR LIVE AGENTS



### BEGIN FIX LOGIN/LAGGED PAUSEREASON ENTRIES (not a recurring process that needs to be run)
if ( ($enable_queuemetrics_logging > 0) && ($login_lagged_check > 0) )
	{
	@time_id=@MT;
	@agent=@MT;
	@verb=@MT;
	@serverid=@MT;
	@lead_id=@MT;

	if ($DB) {print " - Checking for LOGIN and LAGGED pausereason records in queue_log\n";}

	$PAUSEREASONinsert=0;
	##############################################################
	##### grab all queue_log entries for AGENTLOGIN verb to validate
	$stmtB = "SELECT time_id,agent,verb,serverid FROM queue_log where verb IN('AGENTLOGIN','AGENTCALLBACKLOGIN') and serverid='$queuemetrics_log_id' $QM_SQL_time order by time_id;";
	$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
	$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
	$EQ_records=$sthB->rows;
	if ($DB) {print "AGENTLOGIN Records: $EQ_records|$stmtB|\n\n";}
	$h=0;
	while ($EQ_records > $h)
		{
		@aryB = $sthB->fetchrow_array;
		$time_id[$h] =	$aryB[0];
		$agent[$h] =	$aryB[1];
		$verb[$h] =		$aryB[2];
		$serverid[$h] =	$aryB[3];
		$h++;
		}
	$sthB->finish();

	$h=0;
	while ($EQ_records > $h)
		{
		$PRtimecheck = ($time_id[$h] + 1);
		$PRtimecheckCOUNT=0;
		##### find the CONNECT details for calls that were sent to agents
		$stmtB = "SELECT count(*) FROM queue_log where verb='PAUSEREASON' and time_id='$PRtimecheck' and agent='$agent[$h]';";
		$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
		$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
		$CQ_records=$sthB->rows;
		if ($CQ_records > 0)
			{
			@aryB = $sthB->fetchrow_array;
			$PRtimecheckCOUNT =		"$aryB[0]";
			}
		$sthB->finish();

		if ($PRtimecheckCOUNT < 1)
			{
			##### insert a PAUSEREASON record for this call into the queue_log
			$pause_typeSQL='';
			if ($queuemetrics_pause_type > 0)
				{$pause_typeSQL=",data5='SYSTEM'";}
			$stmtB = "INSERT INTO queue_log SET `partition`='P01',time_id='$PRtimecheck',call_id='NONE',queue='NONE',agent='$agent[$h]',verb='PAUSEREASON',data1='LOGIN',serverid='$serverid[$h]'$pause_typeSQL;";
			if ($TEST < 1)
				{
				$Baffected_rows = $dbhB->do($stmtB);
				}
			if ($DB) {print "PRI: $Baffected_rows|$stmtB|\n";}
			$PAUSEREASONinsert++;
			}
		$h++;
		}

	if ($DB) {print " - DONE Checking for LOGIN and LAGGED pausereason records in queue_log\n";}

	exit;
	}
### END FIX LOGIN/LAGGED PAUSEREASON ENTRIES





### BEGIN check for duplicate vicidial_log entries
if ($DB) {print " - vicidial_log duplication check\n";}
$stmtA = "SELECT count(*) as tally,lead_id,end_epoch from vicidial_log $VDCL_SQL_time_where group by lead_id,end_epoch order by tally desc;";
if($DBX){print STDERR "\n|$stmtA|\n";}
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
$i=0;
$j=0;
$nonDUP=0;
while ( ($sthArows > $i) && ($nonDUP < 1) )
	{
	@aryA = $sthA->fetchrow_array;
	if ($aryA[0] > 1)
		{
		$dup_count[$i] =	$aryA[0];
		$dup_lead[$i] =		$aryA[1];
		$dup_end[$i] =		$aryA[2];
		$j++;
		}
	else
		{
		$nonDUP++;
		}
	$i++;
	}
$sthA->finish();

$h=0;
while ($h < $j)
	{
	$stmtA = "SELECT uniqueid,start_epoch,user,status,length_in_sec from vicidial_log $VDCL_SQL_time_where and lead_id='$dup_lead[$h]' and end_epoch='$dup_end[$h]' order by start_epoch;";
		if ($DBX) {print "$stmtA\n";}
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$i=0;
	$first_uniqueid='';
	$del_uniqueid='';
	$del_start_epoch='';
	while ( $sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;		
		if ($i < 1)
			{
			$first_uniqueid = $aryA[0];
			$first_uniqueid =~ s/\..*//gi;
			}
		else
			{
			if ( (length($first_uniqueid)>7) && ($aryA[0] =~ /^$first_uniqueid/) ) 
				{
				$del_uniqueid =		$aryA[0];
				$del_start_epoch =	$aryA[1];
				}
			}

		if ($DBX) {print "$h - $i - $dup_lead[$h]|$dup_end[$h]     |$aryA[0]|$aryA[1]|$aryA[2]|$aryA[3]|$aryA[4]|$first_uniqueid\n";}
		$i++;
		}
	$sthA->finish();

	if ( (length($del_uniqueid)>7) && (length($del_start_epoch)>6) ) 
		{
		$stmtA = "DELETE FROM vicidial_log where lead_id='$dup_lead[$h]' and end_epoch='$dup_end[$h]' and uniqueid='$del_uniqueid' and start_epoch='$del_start_epoch';";
			if($DBX){print STDERR "\n|$stmtA|\n";}
		if ($TEST < 1)	{$affected_rows = $dbhA->do($stmtA); }
		$event_string = "VL DELETE: $h|$i|$dup_lead[$h]|$dup_end[$h]|$affected_rows|$stmtA|";
		&event_logger;
		}

	$h++;
	}
if ($DB) {print STDERR "     vicidial_log duplicates scanned: $h\n";}

if ($vl_dup_check > 0)
	{
	exit;
	}
### END check for duplicate vicidial_log entries




### BEGIN optional check for vicidial_agent_log duplicate entries ###
if ($check_agent_dups > 0)
	{
	if ($DB) {print " - vicidial_agent_log duplicate check starting\n";}
	$stmtA = "SELECT * from ((SELECT user, pause_epoch, count(*) as ct from vicidial_agent_log where ( (pause_sec > 0) or (wait_sec > 0) or (talk_sec > 0) or (dispo_sec > 0) ) $VDAD_SQL_time group by user, pause_epoch) as dupes) where ct>1;";
	if($DBX){print STDERR "\n|$stmtA|\n";}
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$i=0;
	$j=0;
	$nonDUP=0;
	while ( ($sthArows > $i) && ($nonDUP < 1) )
		{
		@aryA = $sthA->fetchrow_array;
		if ($aryA[2] > 1)
			{
			$dup_user[$j] =			$aryA[0];
			$dup_pause_epoch[$j] =	$aryA[1];
			$dup_count[$j] =		$aryA[2];
			if($DBX){print "     DEBUG: |$dup_user[$j]|$dup_pause_epoch[$j]|$dup_count[$j]|\n";}
			$j++;
			}
		else
			{
			$nonDUP++;
			}
		$i++;
		}
	$sthA->finish();

	# loop through results to look for log entries to delete #
	$h=0;
	$VAL_deleted_ct=0;
	while ($h < $j)
		{
		$stmtA = "SELECT agent_log_id,lead_id,pause_sec,wait_epoch,wait_sec,talk_epoch,talk_sec,dispo_epoch,dispo_sec,status,uniqueid,comments from vicidial_agent_log where user='$dup_user[$h]' and pause_epoch='$dup_pause_epoch[$h]';";
			if ($DBX) {print "$stmtA\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		$i=0;
		$VAL_agent_log_id='';
		$VAL_agent_log_output='';
		while ($sthArows > $i)
			{
			@aryA = $sthA->fetchrow_array;
			if ( ( ($aryA[1] eq 'NULL') || (length($aryA[1]) < 1) ) && ( ($aryA[7] eq 'NULL') || (length($aryA[7]) < 1) ) && ($dup_pause_epoch[$h] eq $aryA[3]) )
				{
				if ($DBX) {print "$h $i - BAD:    |$aryA[0]|$aryA[1]|$aryA[2]|$aryA[3]|$aryA[4]|$aryA[5]|$aryA[6]|$aryA[7]|$aryA[8]|$aryA[9]|$aryA[10]|$aryA[11]|\n";}
				if (length($VAL_agent_log_id)>0) {$VAL_agent_log_id .= ",";}
				$VAL_agent_log_id .= "'$aryA[0]'";
				$VAL_agent_log_output .= "|$aryA[0]|$aryA[1]|$aryA[2]|$aryA[3]|$aryA[4]|$aryA[5]|$aryA[6]|$aryA[7]|$aryA[8]|$aryA[9]|$aryA[10]|$aryA[11]|\n";
				}
			else
				{
				if ($DBX) {print "$h $i - GOOD:   |$aryA[0]|$aryA[1]|$aryA[2]|$aryA[3]|$aryA[4]|$aryA[5]|$aryA[6]|$aryA[7]|$aryA[8]|$aryA[9]|$aryA[10]|$aryA[11]|\n";}
				}
			$i++;
			}
		$sthA->finish();

		if (length($VAL_agent_log_id)>2)
			{
			$stmtA = "DELETE FROM vicidial_agent_log where agent_log_id IN($VAL_agent_log_id);";
				if($DBX){print STDERR "\n|$stmtA|\n";}
			if ($TEST < 1)	
				{
				$affected_rows = $dbhA->do($stmtA);
				$VAL_deleted_ct = ($VAL_deleted_ct + $affected_rows);
				}
			$event_string = "VAL DELETE: $h|$affected_rows|$stmtA|     $VAL_agent_log_output";
			&event_logger;
			}

		$h++;
		}

	if ($DB) {print STDERR "     vicidial_agent_log records scanned: $h ($j|$nonDUP)   Deleted: $VAL_deleted_ct \n";}
	}
### END optional check for vicidial_agent_log duplicate entries ###


### BEGIN check for call lengths longer than 1 day(84600 seconds) and correct them
if ($check_call_lengths > 0) 
	{
	if ($DB) {print " - vicidial_log call length check\n";}
	$stmtA = "SELECT uniqueid,lead_id,start_epoch,end_epoch,length_in_sec from vicidial_log $VDCL_SQL_time_where and ( (length_in_sec > 86400) or (length_in_sec < -86400) ) order by call_date;";
	if($DBX){print STDERR "\n|$stmtA|\n";}
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$i=0;
	$j=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$LONG_uniqueid[$i] =		$aryA[0];
		$LONG_lead_id[$i] =			$aryA[1];
		$LONG_start_epoch[$i] =		$aryA[2];
		$LONG_end_epoch[$i] =		$aryA[3];
		$LONG_length_in_sec[$i] =	$aryA[4];
		$i++;
		}
	$sthA->finish();

	$h=0;
	while ($h < $i)
		{
		if ( ($LONG_start_epoch[$h] > 86400) && ($LONG_end_epoch[$h] > 86400) ) 
			{
			$new_length = ($LONG_end_epoch[$h] - $LONG_start_epoch[$h]);
			if ($new_length < 1) 
				{$new_length=1;}
			$stmtA = "UPDATE vicidial_log SET length_in_sec='$new_length' where uniqueid='$LONG_uniqueid[$h]' and lead_id='$LONG_lead_id[$h]';";
				if($DBX){print STDERR "\n|$stmtA|\n";}
			if ($TEST < 1)	{$affected_rows = $dbhA->do($stmtA); }
			$event_string = "VL UPDATE: $h|$i|$LONG_uniqueid[$h]|$new_length|$LONG_length_in_sec[$i]|$affected_rows|$stmtA|";
			&event_logger;
			$j++;
			}

		$h++;
		}
	if ($DB) {print "     Finished:   longs: $h   updated: $j\n";}


	if ($DB) {print " - vicidial_closer_log call length check\n";}
	$stmtA = "SELECT closecallid,lead_id,start_epoch,end_epoch,length_in_sec from vicidial_closer_log $VDCL_SQL_time_where and ( (length_in_sec > 86400) or (length_in_sec < -86400) ) order by call_date;";
	if($DBX){print STDERR "\n|$stmtA|\n";}
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$i=0;
	$j=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$LONG_closecallid[$i] =		$aryA[0];
		$LONG_lead_id[$i] =			$aryA[1];
		$LONG_start_epoch[$i] =		$aryA[2];
		$LONG_end_epoch[$i] =		$aryA[3];
		$LONG_length_in_sec[$i] =	$aryA[4];
		$i++;
		}
	$sthA->finish();

	$h=0;
	while ($h < $i)
		{
		if ( ($LONG_start_epoch[$h] > 86400) && ($LONG_end_epoch[$h] > 86400) ) 
			{
			$new_length = ($LONG_end_epoch[$h] - $LONG_start_epoch[$h]);
			if ($new_length < 1) 
				{$new_length=1;}
			$stmtA = "UPDATE vicidial_closer_log SET length_in_sec='$new_length' where closecallid='$LONG_closecallid[$h]' and lead_id='$LONG_lead_id[$h]';";
				if($DBX){print STDERR "\n|$stmtA|\n";}
			if ($TEST < 1)	{$affected_rows = $dbhA->do($stmtA); }
			$event_string = "VCL UPDATE: $h|$i|$LONG_closecallid[$h]|$new_length|$LONG_length_in_sec[$i]|$affected_rows|$stmtA|";
			&event_logger;
			$j++;
			}

		$h++;
		}
	if ($DB) {print "     Finished:   longs: $h   updated: $j\n";}
	}
if ($check_call_lengths > 0)
	{
	exit;
	}
### END check for call lengths longer than 1 day(84600 seconds) and correct them





if ($DB) {print " - cleaning up pause time\n";}
### Grab any pause time record greater than 43999
$stmtA = "SELECT agent_log_id,pause_epoch,wait_epoch from vicidial_agent_log where pause_sec>43999 $VDAD_SQL_time;";
if ($DBX) {print "$stmtA\n";}
#$dbhA->query("$stmtA");
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;

$i=0;
while ($sthArows > $i)
	{
	@aryA = $sthA->fetchrow_array;	
	$DBout = '';
	$agent_log_id[$i]	=		"$aryA[0]";
	$pause_epoch[$i]	=		"$aryA[1]";
	$wait_epoch[$i]	=			"$aryA[2]";
	$pause_sec[$i] = int($wait_epoch[$i] - $pause_epoch[$i]);
	if ( ($pause_sec[$i] < 0) || ($pause_sec[$i] > 43999) ) 
		{
		$DBout = "Override output: $pause_sec[$i]"; 
		$pause_sec[$i] = 0;
		}
	if ($DBX) {print "$i - $agent_log_id[$i]     |$wait_epoch[$i]|$pause_epoch[$i]|$pause_sec[$i]|$DBout|\n";}
	$i++;
	} 

$sthA->finish();
		   
$h=0;
while ($h < $i)
	{
	$stmtA = "UPDATE vicidial_agent_log set pause_sec='$pause_sec[$h]' where agent_log_id='$agent_log_id[$h]';";
		if($DBX){print STDERR "\n|$stmtA|\n";}
	if ($TEST < 1)	{$affected_rows = $dbhA->do($stmtA); }
	$h++;
	$event_string = "VAL UPDATE PAUSESEC: $h|$pause_epoch[$h]|$wait_epoch[$h]|$affected_rows|$stmtA|";
	&event_logger;
	}
if ($DB) {print STDERR "     Pause times fixed: $h\n";}


@agent_log_id=@MT;
@wait_epoch=@MT;

if ($DBX) {print "\n\n";}
if ($DB) {print " - cleaning up wait time\n";}
### Grab any pause time record greater than 43999
$stmtA = "SELECT agent_log_id,wait_epoch,talk_epoch from vicidial_agent_log where wait_sec>43999 $VDAD_SQL_time;";
	if ($DBX) {print "$stmtA\n";}

$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
		
$i=0;
while ( $sthArows > $i)
	{
	@aryA = $sthA->fetchrow_array;		
	$DBout = '';
	$agent_log_id[$i]	=		"$aryA[0]";
	$wait_epoch[$i]	=		    "$aryA[1]";
	$talk_epoch[$i]	=			"$aryA[2]";
	$wait_sec[$i] = int($talk_epoch[$i] - $wait_epoch[$i]);
	if ( ($wait_sec[$i] < 0) || ($wait_sec[$i] > 43999) ) 
		{
		$DBout = "Override output: $wait_sec[$i]"; 
		$wait_sec[$i] = 0;
		}
	if ($DBX) {print "$i - $agent_log_id[$i]     |$talk_epoch[$i]|$wait_epoch[$i]|$wait_sec[$i]|$DBout|\n";}
	$i++;
	} 
$sthA->finish();

$h=0;
while ($h < $i)
	{
	$stmtA = "UPDATE vicidial_agent_log set wait_sec='$wait_sec[$h]' where agent_log_id='$agent_log_id[$h]';";
		if($DBX){print STDERR "\n|$stmtA|\n";}
	if ($TEST < 1)	{$affected_rows = $dbhA->do($stmtA); }
	$h++;
	$event_string = "VAL UPDATE WAITSEC: $h|$wait_epoch[$h]|$wait_epoch[$h]|$affected_rows|$stmtA|";
	&event_logger;
	}
if ($DB) {print STDERR "     Wait times fixed: $h\n";}


@agent_log_id=@MT;
@talk_epoch=@MT;

if ($DBX) {print "\n\n";}
if ($DB) {print " - cleaning up talk time\n";}
### Grab any pause time record greater than 43999
$stmtA = "SELECT agent_log_id,talk_epoch,dispo_epoch from vicidial_agent_log where talk_sec>43999 $VDAD_SQL_time;";
	if ($DBX) {print "$stmtA\n";}

$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
	
$i=0;
while ( $sthArows > $i)
	{
	@aryA = $sthA->fetchrow_array;		
	$DBout = '';
	$agent_log_id[$i]	=	"$aryA[0]";
	$talk_epoch[$i]	=		"$aryA[1]";
	$dispo_epoch[$i]	=	"$aryA[2]";
	$talk_sec[$i] = int($dispo_epoch[$i] - $talk_epoch[$i]);
	if ( ($talk_sec[$i] < 0) || ($talk_sec[$i] > 43999) ) 
		{
		$DBout = "Override output: $talk_sec[$i]"; 
		$talk_sec[$i] = 0;
		}
	if ($DBX) {print "$i - $agent_log_id[$i]     |$dispo_epoch[$i]|$talk_epoch[$i]|$talk_sec[$i]|$DBout|\n";}
	$i++;
	} 
$sthA->finish();
 
$h=0;
while ($h < $i)
	{
	$stmtA = "UPDATE vicidial_agent_log set talk_sec='$talk_sec[$h]' where agent_log_id='$agent_log_id[$h]';";
		if($DBX){print STDERR "|$stmtA|\n";}
	if ($TEST < 1)	{$affected_rows = $dbhA->do($stmtA);  }
	$h++;
	$event_string = "VAL UPDATE TALKSEC: $h|$talk_epoch[$h]|$dispo_epoch[$h]|$affected_rows|$stmtA|";
	&event_logger;
	}
if ($DB) {print STDERR "     Talk times fixed: $h\n";}



@agent_log_id=@MT;
@dispo_epoch=@MT;

if ($DBX) {print "\n\n";}
if ($DB) {print " - cleaning up dispo time\n";}
	$stmtA = "UPDATE vicidial_agent_log set dispo_sec='0' where dispo_sec>43999 $VDAD_SQL_time;";
		if($DBX){print STDERR "|$stmtA|\n";}
if ($TEST < 1)
	{
	$affected_rows = $dbhA->do($stmtA); 	
	}
if ($DB) {print STDERR "     Bad Dispo times zeroed out: $affected_rows\n";}


if ($DBX) {print "\n\n";}
if ($DB) {print " - cleaning up closer records\n";}
	$stmtA = "UPDATE vicidial_closer_log set length_in_sec=(end_epoch - start_epoch) where length_in_sec < 1 and end_epoch > 1000 $VDCL_SQL_time;";
		if($DBX){print STDERR "|$stmtA|\n";}
if ($TEST < 1)
	{
	$affected_rows = $dbhA->do($stmtA); 	
	}
if ($DB) {print STDERR "     Bad Closer times recalculated: $affected_rows\n\n";}







##### BEGIN vicidial_agent_log sec validation #####
if ( ($skip_agent_log_validation < 1) && ($VAL_validate > 0) )
	{
	if ($DBX) {print "\n\n";}
	if ($DB) {print " - starting validation of vicidial_agent_log sec fields\n";}
	$total_corrected_records=0;
	$total_scanned_records=0;
	$total_pause=0;
	$total_wait=0;
	$total_talk=0;
	$total_dispo=0;
	$total_dead=0;
	$epoch_changes=0;

	### Gather distinct users in vicidial_agent_log during time period
	$stmtA = "SELECT distinct user from vicidial_agent_log where user != '' $VDAD_SQL_time order by user;";
	if ($DBX) {print "$stmtA\n";}
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArowsU=$sthA->rows;

	$i=0;
	while ($sthArowsU > $i)
		{
		@aryA = $sthA->fetchrow_array;	
		$Vuser[$i]	=		$aryA[0];
		$i++;
		}
	$sthA->finish();

	$i=0;
	while ($sthArowsU > $i)
		{
		### Gather distinct users in vicidial_agent_log during time period
		$stmtA = "SELECT agent_log_id,pause_epoch,pause_sec,wait_epoch,wait_sec,talk_epoch,talk_sec,dispo_epoch,dispo_sec,dead_epoch,dead_sec,event_time from vicidial_agent_log where user='$Vuser[$i]' $VDAD_SQL_time order by event_time, agent_log_id;";
		if ($DBX) {print "$stmtA\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArowsR=$sthA->rows;
		$r=0;
		$total_Vrecords=0;
		@Vagent_log_id =	@MT;
		@Vpause_epoch =		@MT;
		@Vpause_sec =		@MT;
		@Vwait_epoch =		@MT;
		@Vwait_sec =		@MT;
		@Vtalk_epoch =		@MT;
		@Vtalk_sec =		@MT;
		@Vdispo_epoch =		@MT;
		@Vdispo_sec =		@MT;
		@Vdead_epoch =		@MT;
		@Vdead_sec =		@MT;
		@Vevent_time =		@MT;

		# gather records
		while ($sthArowsR > $r)
			{
			@aryA = $sthA->fetchrow_array;	
			$Vagent_log_id[$r] =	$aryA[0];
			$Vpause_epoch[$r] =		$aryA[1];
			$Vpause_sec[$r] =		$aryA[2];
			$Vwait_epoch[$r] =		$aryA[3];
			$Vwait_sec[$r] =		$aryA[4];
			$Vtalk_epoch[$r] =		$aryA[5];
			$Vtalk_sec[$r] =		$aryA[6];
			$Vdispo_epoch[$r] =		$aryA[7];
			$Vdispo_sec[$r] =		$aryA[8];
			$Vdead_epoch[$r] =		$aryA[9];
			$Vdead_sec[$r] =		$aryA[10];
			$Vevent_time[$r] =		$aryA[11];
			$r++;
			} 
		$sthA->finish();

		$total_Vrecords = $r;
		$r=0;
		while ($sthArowsR > $r)
			{
			$corrections=0;
			$corrections_LOG='';
			$corrections_SQL='';
			$NVpause_sec=0;
			$NVwait_sec=0;
			$NVtalk_sec=0;
			$NVdispo_sec=0;
			$NVdead_sec=0;
			$next_r = ($r + 1);
			if ($next_r < $total_Vrecords)
				{$next_begin_epoch = $Vpause_epoch[$next_r];}
			else
				{$next_begin_epoch = 0;}
			$Vpause_date="1970-01-01 00:00:00";
			if ($Vpause_epoch[$next_r] > 1000)
				{
				$Vpause_epoch_min5 = ($Vpause_epoch[$next_r] - 5);
				($Ksec,$Kmin,$Khour,$Kmday,$Kmon,$Kyear,$Kwday,$Kyday,$Kisdst) = localtime($Vpause_epoch[$next_r]);
				$Kyear = ($Kyear + 1900);
				$Kmon++;
				if ($Kmon < 10) {$Kmon = "0$Kmon";}
				if ($Kmday < 10) {$Kmday = "0$Kmday";}
				if ($Khour < 10) {$Khour = "0$Khour";}
				if ($Kmin < 10) {$Kmin = "0$Kmin";}
				if ($Ksec < 10) {$Ksec = "0$Ksec";}
				$Vpause_date = "$Kyear-$Kmon-$Kmday $Khour:$Kmin:$Ksec";
				$Vpause_dayB = "$Kyear-$Kmon-$Kmday 00:00:00";

				($KFsec,$KFmin,$KFhour,$KFmday,$KFmon,$KFyear,$KFwday,$KFyday,$KFisdst) = localtime($Vpause_epoch_min5);
				$KFyear = ($KFyear + 1900);
				$KFmon++;
				if ($KFmon < 10) {$KFmon = "0$KFmon";}
				if ($KFmday < 10) {$KFmday = "0$KFmday";}
				if ($KFhour < 10) {$KFhour = "0$KFhour";}
				if ($KFmin < 10) {$KFmin = "0$KFmin";}
				if ($KFsec < 10) {$KFsec = "0$KFsec";}
				$VFpause_date = "$KFyear-$KFmon-$KFmday $KFhour:$KFmin:$KFsec";
				}

			### find if next record is a LOGIN
			$LOGOUT_update=0;
			$stmtA = "SELECT count(*) from vicidial_user_log where user='$Vuser[$i]' and event_date<='$Vpause_date' and event_date > '$VFpause_date' and event='LOGIN';";
		#	if ($DBX) {print "$stmtA\n";}
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			@aryA = $sthA->fetchrow_array;	
			if ($aryA[0] > 0)
				{
				$stmtA = "SELECT UNIX_TIMESTAMP(event_date),event_date from vicidial_user_log where user='$Vuser[$i]' and event_date < '$Vpause_date' and event_date > \"$Vpause_dayB\" and event='LOGOUT' order by event_date desc limit 1;";
				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
				@aryA = $sthA->fetchrow_array;	
				$next_begin_epoch = $aryA[0];
				$LOGOUT_update++;
			#	if ($DBX) {print "LOGOUT UPDATE: $next_begin_epoch|$aryA[1]|$Vpause_date|$VFpause_date|$LOGOUT_update|$stmtA\n";}
				}

			if ( ($Vwait_epoch[$r] < 1000) || ( ($Vwait_epoch[$r] <= $Vpause_epoch[$r]) && ($Vtalk_epoch[$r] < 1000) && ($Vpause_sec[$r] > 0) ) )
				{
				if ($LOGOUT_update > 0) 
					{
					$corrections_LOG .= "WAITEPOCH:$next_begin_epoch!$Vwait_epoch[$r]|";
					$corrections_SQL .= "wait_epoch='$next_begin_epoch',";
					$epoch_changes++;
					}
				$Vwait_epoch[$r] = $next_begin_epoch;
				$NVpause_sec = ($Vwait_epoch[$r] - $Vpause_epoch[$r]);
				}
			else
				{
				$NVpause_sec = ($Vwait_epoch[$r] - $Vpause_epoch[$r]);
				if ($Vtalk_epoch[$r] < 1000)
					{
					if ($LOGOUT_update > 0) 
						{
						$corrections_LOG .= "TALKEPOCH:$next_begin_epoch!$Vtalk_epoch[$r]|";
						$corrections_SQL .= "talk_epoch='$next_begin_epoch',";
						$epoch_changes++;
						}
					$Vtalk_epoch[$r] = $next_begin_epoch;
					$NVwait_sec = ($Vtalk_epoch[$r] - $Vwait_epoch[$r]);
					}
				else
					{
					$NVwait_sec = ($Vtalk_epoch[$r] - $Vwait_epoch[$r]);
					if ($Vdispo_epoch[$r] < 1000)
						{
						if ($LOGOUT_update > 0) 
							{
							$corrections_LOG .= "DISPOEPOCH:$next_begin_epoch!$Vdispo_epoch[$r]|";
							$corrections_SQL .= "dispo_epoch='$next_begin_epoch',";
							$epoch_changes++;
							}
						$Vdispo_epoch[$r] = $next_begin_epoch;
						$NVtalk_sec = ($Vdispo_epoch[$r] - $Vtalk_epoch[$r]);
						}
					else
						{
						$NVtalk_sec = ($Vdispo_epoch[$r] - $Vtalk_epoch[$r]);
						if ($next_begin_epoch < 1000)
							{
							$NVdispo_sec = $Vdispo_sec[$r];
							}
						else
							{
							$NVdispo_sec = ($next_begin_epoch - $Vdispo_epoch[$r]);
							}
						}
					}
				}

			if ( ($NVpause_sec > 43999) || ($NVpause_sec < 0) )		{$NVpause_sec = 0;}
			if ( ($NVwait_sec > 43999) || ($NVwait_sec < 0) )		{$NVwait_sec = 0;}
			if ( ($NVtalk_sec > 43999) || ($NVtalk_sec < 0) )		{$NVtalk_sec = 0;}
			if ( ($NVdispo_sec > 43999) || ($NVdispo_sec < 0) )		{$NVdispo_sec = 0;}

			if ( ($NVpause_sec > $Vpause_sec[$r]) || ($NVpause_sec < $Vpause_sec[$r]) )
				{
				$corrections++;
				$total_pause++;
				$corrections_LOG .= "PAUSE:$NVpause_sec!$Vpause_sec[$r]|";
				$corrections_SQL .= "pause_sec='$NVpause_sec',";
				}
			if ( ($NVwait_sec > $Vwait_sec[$r]) || ($NVwait_sec < $Vwait_sec[$r]) )
				{
				$corrections++;
				$total_wait++;
				$corrections_LOG .= "WAIT:$NVwait_sec!$Vwait_sec[$r]|";
				$corrections_SQL .= "wait_sec='$NVwait_sec',";
				}
			if ( ($NVtalk_sec > $Vtalk_sec[$r]) || ($NVtalk_sec < $Vtalk_sec[$r]) )
				{
				$corrections++;
				$total_talk++;
				$corrections_LOG .= "TALK:$NVtalk_sec!$Vtalk_sec[$r]|";
				$corrections_SQL .= "talk_sec='$NVtalk_sec',";
				}
			if ( ($NVdispo_sec > $Vdispo_sec[$r]) || ($NVdispo_sec < $Vdispo_sec[$r]) )
				{
				$corrections++;
				$total_dispo++;
				$corrections_LOG .= "DISPO:$NVdispo_sec!$Vdispo_sec[$r]|";
				$corrections_SQL .= "dispo_sec='$NVdispo_sec',";
				}
			if ($NVtalk_sec < $Vdead_sec[$r])
				{
				$corrections++;
				$total_dead++;
				$corrections_LOG .= "DEAD:$NVtalk_sec!$Vdead_sec[$r]|";
				$corrections_SQL .= "dead_sec='$NVtalk_sec',";
				}

			if ($corrections > 0)
				{
				$total_corrected_records++;
				chop($corrections_SQL);
				if ($DB > 0) {print "$Vevent_time[$r] $Vuser[$i] $corrections  $Vagent_log_id[$r]   $corrections_LOG   $corrections_SQL\n";}
				$stmtA = "UPDATE vicidial_agent_log set $corrections_SQL where agent_log_id='$Vagent_log_id[$r]';";
					if($DBX){print STDERR "|$stmtA|\n";}
				if ($TEST < 1)
					{
					$affected_rows = $dbhA->do($stmtA); 	
					}
				$event_string = "VAL UPDATE: $r|$i|$Vuser[$i]|$Vevent_time[$r]|$affected_rows|$corrections_LOG|$stmtA|";
				&event_logger;
				}

			$total_scanned_records++;
			$r++;
			} 

		$i++;
		} 

	if ($DB) {print " - finished validation of vicidial_agent_log sec fields:\n";}
	if ($DB) {print "     records scanned/corrected:  $total_scanned_records / $total_corrected_records\n";}
	if ($DB) {print "        PAUSE updates: $total_pause\n";}
	if ($DB) {print "        WAIT updates:  $total_wait\n";}
	if ($DB) {print "        TALK updates:  $total_talk\n";}
	if ($DB) {print "        DISPO updates: $total_dispo\n";}
	if ($DB) {print "        DEAD updates:  $total_dead\n";}
	if ($DB) {print "        EPOCH updates: $epoch_changes\n";}
	if ($DB) {print "     distinct users: $i\n";}
	}
##### END vicidial_agent_log sec validation #####



if ($enable_queuemetrics_logging > 0)
	{
	if ($skip_queue_log_inserts < 1)
		{
		$COMPLETEinsert=0;
		$COMPLETEupdate=0;
		$COMPLETEqueue=0;
		$CONNECTinsert=0;
		$noCONNECT=0;
		$noCALLSTATUS=0;
		$noCOMPLETEinsert=0;

		##############################################################
		##### grab all queue_log entries for ENTERQUEUE verb to validate
		$stmtB = "SELECT time_id,call_id,queue,agent,verb,serverid FROM queue_log where verb IN('ENTERQUEUE','CALLOUTBOUND') and serverid='$queuemetrics_log_id' $QM_SQL_time order by time_id;";
		$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
		$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
		$EQ_records=$sthB->rows;
		if ($DB) {print "ENTERQUEUE Records: $EQ_records|$stmtB|\n\n";}
		$h=0;
		while ($EQ_records > $h)
			{
			@aryB = $sthB->fetchrow_array;
			$time_id[$h] =	"$aryB[0]";
			$call_id[$h] =	"$aryB[1]";
			$queue[$h] =	"$aryB[2]";
			$agent[$h] =	"$aryB[3]";
			$verb[$h] =		"$aryB[4]";
			$serverid[$h] =	"$aryB[5]";
			$h++;
			}
		$sthB->finish();

		$h=0;
		while ($EQ_records > $h)
			{
			##### find the CONNECT details for calls that were sent to agents
			$stmtB = "SELECT time_id,call_id,queue,agent,verb,serverid,data1 FROM queue_log where verb='CONNECT' and call_id='$call_id[$h]' $QM_SQL_time;";
			$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
			$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
			$CQ_records=$sthB->rows;
			if ($CQ_records > 0)
				{
				@aryB = $sthB->fetchrow_array;
				$Ctime_id[$h] =		"$aryB[0]";
				$Ccall_id[$h] =		"$aryB[1]";
				$Cqueue[$h] =		"$aryB[2]";
				$Cagent[$h] =		"$aryB[3]";
				$Cverb[$h] =		"$aryB[4]";
				$Cserverid[$h] =	"$aryB[5]";
				$Cdata1[$h] =		"$aryB[6]";
				}
			$sthB->finish();

			if ( ($CQ_records > 0) && ($Ctime_id[$h] > 1000) )
				{
				##### find the CALLSTATUS details for calls that were dispositioned by an agent
				$stmtB = "SELECT time_id,call_id,queue,agent,verb,serverid,data4 FROM queue_log where verb='CALLSTATUS' and call_id='$call_id[$h]' and agent='$Cagent[$h]';";
				$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
				$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
				$SQ_records=$sthB->rows;
				if ($SQ_records > 0)
					{
					@aryB = $sthB->fetchrow_array;
					$Stime_id[$h] =		$aryB[0];
					$Scall_id[$h] =		$aryB[1];
					$Squeue[$h] =		$aryB[2];
					$Sagent[$h] =		$aryB[3];
					$Sverb[$h] =		$aryB[4];
					$Sserverid[$h] =	$aryB[5];
					$Sdata4[$h] =		$aryB[6];
					$Slead_id[$h] = substr($Scall_id[$h], 11, 9);
					$Slead_id[$h] = ($Slead_id[$h] + 0);
					}
				$sthB->finish();

				if ( ($SQ_records > 0) && ($Stime_id[$h] > 1000) )
					{
					##### check if there is a COMPLETEAGENT or COMPLETECALLER record for this call_id
					$stmtB = "SELECT count(*) FROM queue_log where verb IN('COMPLETEAGENT','COMPLETECALLER') and call_id='$call_id[$h]' and agent='$Cagent[$h]';";
					$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
					$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
					$MQ_records=$sthB->rows;
					if ($MQ_records > 0)
						{
						@aryB = $sthB->fetchrow_array;
						$COMPLETEcount[$h] =		"$aryB[0]";
						}
					$sthB->finish();
					if ($COMPLETEcount[$h] > 0)
						{
						##### check that the queue is set properly
						$stmtB = "SELECT count(*) FROM queue_log where verb IN('COMPLETEAGENT','COMPLETECALLER') and call_id='$call_id[$h]' and agent='$Cagent[$h]' and queue='$queue[$h]';";
						$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
						$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
						$QQ_records=$sthB->rows;
						if ($QQ_records > 0)
							{
							@aryB = $sthB->fetchrow_array;
							$COMPLETEqueue[$h] =		"$aryB[0]";
							}
						$sthB->finish();
						if ($COMPLETEqueue[$h] < 1)
							{
							$stmtB = "UPDATE queue_log SET queue='$queue[$h]' where verb IN('COMPLETEAGENT','COMPLETECALLER') and call_id='$call_id[$h]' and agent='$Cagent[$h]';";
							if ($TEST < 1)
								{
								$Baffected_rows = $dbhB->do($stmtB);
								}
							if ($DB) {print "MCRI: $Baffected_rows|$stmtB|\n";}
							$COMPLETEupdate++;
							}
						}
					else
						{
						$DPRdebug='';
						##### find a DISPO PAUSEREASON for this call if there is one
						$stmtB = "SELECT time_id FROM queue_log where call_id='$call_id[$h]' and verb='PAUSEREASON' and data1='$queuemetrics_dispo_pause' and agent='$Cagent[$h]';";
						$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
						$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
						$DPR_records=$sthB->rows;
						if ($DPR_records > 0)
							{
							@aryB = $sthB->fetchrow_array;
							$Stime_id[$h] =		$aryB[0];
							$DPRdebug = "DISPO TIME";
							}
						$sthB->finish();

						$secX = time();
						$Rtarget = ($secX - 21600);	# look for VDCL entry within last 6 hours
						($Rsec,$Rmin,$Rhour,$Rmday,$Rmon,$Ryear,$Rwday,$Ryday,$Risdst) = localtime($Rtarget);
						$Ryear = ($Ryear + 1900);
						$Rmon++;
						if ($Rmon < 10) {$Rmon = "0$Rmon";}
						if ($Rmday < 10) {$Rmday = "0$Rmday";}
						if ($Rhour < 10) {$Rhour = "0$Rhour";}
						if ($Rmin < 10) {$Rmin = "0$Rmin";}
						if ($Rsec < 10) {$Rsec = "0$Rsec";}
							$RSQLdate = "$Ryear-$Rmon-$Rmday $Rhour:$Rmin:$Rsec";

						### find original queue position of the call
						$queue_position=1;
						$queue_seconds=0;
						$stmtA = "SELECT queue_position,queue_seconds FROM vicidial_closer_log where lead_id='$Slead_id[$h]' and campaign_id='$Squeue[$h]' and call_date > \"$RSQLdate\" order by closecallid desc limit 1;";
						$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
						$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
						$sthArows=$sthA->rows;
						if ($sthArows > 0)
							{
							@aryA = $sthA->fetchrow_array;
							$queue_position =	$aryA[0];
							$queue_seconds =	int($aryA[1] + .5);
							}
						$sthA->finish();

						##### insert a COMPLETEAGENT record for this call into the queue_log
						$CALLtime[$h] = ($Stime_id[$h] - $time_id[$h]);
						$stmtB = "INSERT INTO queue_log SET `partition`='P01',time_id='$Stime_id[$h]',call_id='$Scall_id[$h]',queue='$Squeue[$h]',agent='$Sagent[$h]',verb='COMPLETEAGENT',data1='$Cdata1[$h]',data2='$CALLtime[$h]',data3='$queue_position',serverid='$Sserverid[$h]',data4='$Sdata4[$h]';";
						if ($TEST < 1)
							{
							$Baffected_rows = $dbhB->do($stmtB);
							}
						if ($DB) {print "MCRI: $Baffected_rows|$DPRdebug|$stmtB|\n";}
						$COMPLETEinsert++;
						}
					}
				else
					{
					if ($DB) {print "NO CALLSTATUS: $Ctime_id[$h]|$Ccall_id[$h]|$Cagent[$h]   \n";}
					$noCALLSTATUS++;
					##### find the COMPLETE details for calls that were connected to an agent
					$stmtB = "SELECT time_id,call_id,queue,agent,verb,serverid,data4 FROM queue_log where verb IN('COMPLETEAGENT','COMPLETECALLER') and call_id='$call_id[$h]' and agent='$Cagent[$h]';";
					$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
					$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
					$SQ_records=$sthB->rows;
					if ($SQ_records > 0)
						{
						@aryB = $sthB->fetchrow_array;
						$Stime_id[$h] =		$aryB[0];
						$Scall_id[$h] =		$aryB[1];
						$Squeue[$h] =		$aryB[2];
						$Sagent[$h] =		$aryB[3];
						$Sverb[$h] =		$aryB[4];
						$Sserverid[$h] =	$aryB[5];
						$Sdata4[$h] =		$aryB[6];
						}
					$sthB->finish();

					if ( ($SQ_records > 0) && ($Stime_id[$h] > 1000) )
						{
						##### insert a CALLSTATUS record for this call into the queue_log
						$CALLtime[$h] = ($Stime_id[$h] - $time_id[$h]);
						$stmtB = "INSERT INTO queue_log SET `partition`='P01',time_id='$Stime_id[$h]',call_id='$Scall_id[$h]',queue='$Cqueue[$h]',agent='$Sagent[$h]',verb='CALLSTATUS',data1='PU',serverid='$Sserverid[$h]';";
						if ($TEST < 1)
							{
							$Baffected_rows = $dbhB->do($stmtB);
							}
						if ($DB) {print "MCSI: $Baffected_rows|$stmtB|\n";}
						$CONNECTinsert++;
						}
					else
						{
						$old_call_sec = ($secX - 10800);
						if ($Ctime_id[$h] < $old_call_sec) 
							{
							$search_sec_BEGIN = ($Ctime_id[$h] - 3600);
							$search_sec_END = ($Ctime_id[$h] + 3600);
							$search_lead_id = substr($call_id[$h], 11, 9);
							$search_lead_id = ($search_lead_id + 0);
							$VALuser = $Cagent[$h];
							$VALuser =~ s/Agent\///gi;

							##### insert a COMPLETEAGENT record for this call into the queue_log
							$stmtA = "SELECT pause_epoch,wait_epoch,talk_epoch,dispo_epoch,status FROM vicidial_agent_log where lead_id='$search_lead_id' and user='$VALuser' and pause_epoch > \"$search_sec_BEGIN\" and pause_epoch < \"$search_sec_END\" order by pause_epoch desc;";
							$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
							$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
							$sthArows=$sthA->rows;
							$rec_count=0;
							while ($sthArows > $rec_count)
								{
								 @aryA = $sthA->fetchrow_array;
									$VALpause =	"$aryA[0]";
									$VALwait =	"$aryA[1]";
									$VALtalk =	"$aryA[2]";
									$VALdispo =	"$aryA[3]";
									$VALstatus ="$aryA[4]";
								 $rec_count++;
								}
							$sthA->finish();
							
							if ($rec_count > 0)
								{
								$Stime_id[$h]=0;
								if ($VALwait >= $Ctime_id[$h]) {$Stime_id[$h] = $VALwait;}
								if ($VALtalk >= $Ctime_id[$h]) {$Stime_id[$h] = $VALtalk;}
								if ($VALdispo >= $Ctime_id[$h]) {$Stime_id[$h] = $VALdispo;}
								if ($Stime_id[$h] < 1) {$Stime_id[$h] = ($time_id[$h] + 1);}
								$VALstatus =~ s/ //gi;
								if ( ($VALstatus =~ /NULL/i) || (length($VALstatus<1)) ) {$VALstatus='ERI';}

								$Clead_id[$h] = substr($Ccall_id[$h], 11, 9);
								$Clead_id[$h] = ($Clead_id[$h] + 0);

								$secX = time();
								$Rtarget = ($secX - 21600);	# look for VDCL entry within last 6 hours
								($Rsec,$Rmin,$Rhour,$Rmday,$Rmon,$Ryear,$Rwday,$Ryday,$Risdst) = localtime($Rtarget);
								$Ryear = ($Ryear + 1900);
								$Rmon++;
								if ($Rmon < 10) {$Rmon = "0$Rmon";}
								if ($Rmday < 10) {$Rmday = "0$Rmday";}
								if ($Rhour < 10) {$Rhour = "0$Rhour";}
								if ($Rmin < 10) {$Rmin = "0$Rmin";}
								if ($Rsec < 10) {$Rsec = "0$Rsec";}
									$RSQLdate = "$Ryear-$Rmon-$Rmday $Rhour:$Rmin:$Rsec";

								### find original queue position of the call
								$queue_position=1;
								$queue_seconds=0;
								$stmtA = "SELECT queue_position,queue_seconds FROM vicidial_closer_log where lead_id='$Clead_id[$h]' and campaign_id='$Cqueue[$h]' and call_date > \"$RSQLdate\" order by closecallid desc limit 1;";
								$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
								$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
								$sthArows=$sthA->rows;
								if ($sthArows > 0)
									{
									@aryA = $sthA->fetchrow_array;
									$queue_position =	$aryA[0];
									$queue_seconds =	int($aryA[1] + .5);
									}
								$sthA->finish();

								##### insert a COMPLETEAGENT record for this call into the queue_log
								$CALLtime[$h] = ($Stime_id[$h] - $time_id[$h]);
								$stmtB = "INSERT INTO queue_log SET `partition`='P01',time_id='$Stime_id[$h]',call_id='$Ccall_id[$h]',queue='$Cqueue[$h]',agent='$Cagent[$h]',verb='COMPLETEAGENT',data1='$Cdata1[$h]',data2='$CALLtime[$h]',data3='$queue_position',serverid='$Cserverid[$h]',data4='$Sdata4[$h]';";
								if ($TEST < 1)
									{
									$Baffected_rows = $dbhB->do($stmtB) or die "ERROR: $stmtB" . DBI->errstr;
									}
								if ($DB) {print "MNCI: $Baffected_rows|$stmtB|$TEST\n";}

								##### insert a CALLSTATUS record for this call into the queue_log
								$CALLtime[$h] = ($Stime_id[$h] - $time_id[$h]);
								$stmtB = "INSERT INTO queue_log SET `partition`='P01',time_id='$Stime_id[$h]',call_id='$Ccall_id[$h]',queue='$Cqueue[$h]',agent='$Cagent[$h]',verb='CALLSTATUS',data1='$VALstatus',serverid='$Cserverid[$h]';";
								if ($TEST < 1)
									{
									$Baffected_rows = $dbhB->do($stmtB) or die "ERROR: $stmtB" . DBI->errstr;
									}
								if ($DB) {print "MNCI: $Baffected_rows|$stmtB|$TEST\n";}
								$noCOMPLETEinsert++;

								}
							}
						}
					}
				}
			else
				{
				if ($DBX) {print "NO CONNECT: $time_id[$h]|$call_id[$h]|$queue[$h]   \n";}
				$noCONNECT++;
				}
			if ($DB) 
				{
				($Dsec,$Dmin,$Dhour,$Dmday,$Dmon,$Dyear,$Dwday,$Dyday,$Disdst) = localtime($time_id[$h]);
				$Dyear = ($Dyear + 1900);
				$Dmon++;
				if ($Dmon < 10) {$Dmon = "0$Dmon";}
				if ($Dmday < 10) {$Dmday = "0$Dmday";}
				if ($Dhour < 10) {$Dhour = "0$Dhour";}
				if ($Dmin < 10) {$Dmin = "0$Dmin";}
				if ($Dsec < 10) {$Dsec = "0$Dsec";}
					$DBSQLdate = "$Dyear-$Dmon-$Dmday $Dhour:$Dmin:$Dsec";

				if ($h =~ /0$/) {$k='+';}
				if ($h =~ /1$/) {$k='|';}
				if ($h =~ /2$/) {$k='/';}
				if ($h =~ /3$/) {$k='-';}
				if ($h =~ /4$/) {$k="\\";}
				if ($h =~ /5$/) {$k='|';}
				if ($h =~ /6$/) {$k='/';}
				if ($h =~ /7$/) {$k='-';}
				if ($h =~ /8$/) {$k="\\";}
				if ($h =~ /9$/) {$k='0';}
				print STDERR "$k  $noCONNECT $noCALLSTATUS $COMPLETEinsert|$COMPLETEupdate $CONNECTinsert $noCOMPLETEinsert $h/$EQ_records  $DBSQLdate|$time_id[$h]   $Ctime_id[$h]|$CQ_records   $Stime_id[$h]|$SQ_records   $call_id[$h]|$COMPLETEcount[$h]\r";
				}
			$h++;
			}
		}
	


	##############################################################
	##### grab all queue_log entries for COMPLETEAGENT verb to validate queue
	$stmtB = "SELECT time_id,call_id,queue,agent,serverid,data4 FROM queue_log where verb='COMPLETEAGENT' and serverid='$queuemetrics_log_id' $QM_SQL_time order by time_id;";
	$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
	$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
	$EQ_records=$sthB->rows;
	if ($DB) {print "COMPLETEAGENT Records: $EQ_records|$stmtB|\n\n";}
	$h=0;
	while ($EQ_records > $h)
		{
		@aryB = $sthB->fetchrow_array;
		$time_id[$h] =	$aryB[0];
		$call_id[$h] =	$aryB[1];
		$queue[$h] =	$aryB[2];
		$agent[$h] =	$aryB[3];
		$serverid[$h] =	$aryB[4];
		$data4[$h] =	$aryB[5];
		$h++;
		}
	$sthB->finish();

	$h=0;
	while ($EQ_records > $h)
		{
		if (length($queue[$h])<1)
			{
			$CAQqueue[$h]='';
			##### find queue ID for this call
			$stmtB = "SELECT queue FROM queue_log WHERE verb='CONNECT' and serverid='$queuemetrics_log_id' and call_id='$call_id[$h]' and agent='$agent[$h]';";
			$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
			$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
			$MXC_records=$sthB->rows;
			if ($MXC_records > 0)
				{
				@aryB = $sthB->fetchrow_array;
				$CAQqueue[$h] =	$aryB[0];
				}
			$sthB->finish();

			##### update queue ID in this COMPLETEAGENT record
			$stmtB = "UPDATE queue_log SET queue='$CAQqueue[$h]' WHERE verb='COMPLETEAGENT' and serverid='$queuemetrics_log_id' and time_id='$time_id[$h]' and call_id='$call_id[$h]';";
			if ($TEST < 1)	
				{
				$Baffected_rows = $dbhB->do($stmtB);
				$COMPLETEqueue = ($COMPLETEqueue + $Baffected_rows);
				}
			if ($DB) {print "COMPLETEAGENT Record Updated: $Baffected_rows|$stmtB|\n\n";}
			}
		$h++;
		}



	#######################################################################
	##### grab all queue_log entries with more than one COMPLETE verb to clean up
	$stmtB = "SELECT call_id, count(*) FROM queue_log WHERE verb IN('COMPLETEAGENT','COMPLETECALLER','TRANSFER') and serverid='$queuemetrics_log_id' $QM_SQL_time_H GROUP BY call_id HAVING count(*)>1 ORDER BY count(*) DESC;";
	$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
	$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
	$XC_records=$sthB->rows;
	if ($DB) {print "Extra COMPLETE Records: $XC_records|$stmtB|\n\n";}
	$h=0;
	while ($XC_records > $h)
		{
		@aryB = $sthB->fetchrow_array;
		$CDcall_id[$h] =	"$aryB[0]";
		$h++;
		}
	$sthB->finish();

	$h=0;
	while ($XC_records > $h)
		{
		##### grab oldest COMPLETE record to delete
		$stmtB = "DELETE FROM queue_log WHERE call_id='$CDcall_id[$h]' and verb IN('COMPLETEAGENT','COMPLETECALLER','TRANSFER') ORDER BY unique_row_count DESC LIMIT 1;";
		if ($TEST < 1)	{$Baffected_rows = $dbhB->do($stmtB);  }
		if ($DB) {print "Extra COMPLETE Record Deleted: $Baffected_rows|$stmtB|\n\n";}

		$h++;
		}


	##########################################################################
	##### grab all queue_log COMPLETEAGENT entries with negative call time to clean up
	$stmtB = "SELECT call_id, time_id FROM queue_log WHERE verb IN('COMPLETEAGENT') and data2 < '0' and serverid='$queuemetrics_log_id' $QM_SQL_time_H;";
	$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
	$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
	$XN_records=$sthB->rows;
	if ($DB) {print "Negative COMPLETEAGENT Records: $XN_records|$stmtB|\n\n";}
	$h=0;
	while ($XN_records > $h)
		{
		@aryB = $sthB->fetchrow_array;
		$CNcall_id[$h] =	"$aryB[0]";
		$CNtime_id[$h] =	"$aryB[1]";
		$h++;
		}
	$sthB->finish();

	$h=0;
	while ($XN_records > $h)
		{
		### Get time of CONNECT
		$stmtB = "SELECT time_id FROM queue_log WHERE verb IN('CONNECT') and call_id='$CNcall_id[$h]';";
		$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
		$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
		$XNC_records=$sthB->rows;
		if ($XNC_records < 1)
			{print "ERROR! No CONNECT record for $CNcall_id[$h] $CNtime_id[$h]";}
		else
			{
			@aryB = $sthB->fetchrow_array;
			$CCNtime_id[$h] =	"$aryB[0]";
			$sthB->finish();

			### Get time of CALLSTATUS
			$stmtB = "SELECT time_id FROM queue_log WHERE verb IN('CALLSTATUS') and call_id='$CNcall_id[$h]';";
			$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
			$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
			$XNS_records=$sthB->rows;
			if ($XNS_records < 1)
				{print "ERROR! No CALLSTATUS record for $CNcall_id[$h] $CNtime_id[$h]";}
			else
				{
				@aryB = $sthB->fetchrow_array;
				$CSNtime_id[$h] =	"$aryB[0]";
				$sthB->finish();

				if ($CSNtime_id[$h] < $CCNtime_id[$h])
					{
					##### update CALLSTATUS record to CONNECT time_id
					$stmtB = "UPDATE queue_log SET time_id='$CCNtime_id[$h]' WHERE call_id='$CNcall_id[$h]' and verb IN('CALLSTAUTS') LIMIT 1;";
					if ($TEST < 1)	{$Baffected_rows = $dbhB->do($stmtB);  }
					if ($DB) {print "CALLSTATUS time_id Record Updated: $Baffected_rows|$stmtB|\n\n";}
					}
				}
			if ($CNtime_id[$h] < $CCNtime_id[$h])
				{
				##### update COMPLETEAGENT record to CONNECT time_id and 0 data2
				$stmtB = "UPDATE queue_log SET time_id='$CCNtime_id[$h]',data2='0' WHERE call_id='$CNcall_id[$h]' and verb IN('COMPLETEAGENT') LIMIT 1;";
				if ($TEST < 1)	{$Baffected_rows = $dbhB->do($stmtB);  }
				if ($DB) {print "COMPLETEAGENT time_id Record Updated: $Baffected_rows|$stmtB|\n";}
				if ($DB) {print "Debug: $CCNtime_id[$h]|$CSNtime_id[$h]|$CNtime_id[$h]|$CNcall_id[$h]|\n\n";}
				}
			}
		$h++;
		}


	$PRadded=0;
	if ($check_complete_pauses > 0)
		{
		##############################################################
		##### grab all queue_log entries for COMPLETECALLER verb to validate a pausereason is present
		$stmtB = "SELECT time_id,call_id,queue,agent,serverid,data4 FROM queue_log where verb='COMPLETECALLER' and serverid='$queuemetrics_log_id' $QM_SQL_time order by time_id;";
		$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
		$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
		$CCP_records=$sthB->rows;
		if ($DB) {print "COMPLETECALLER Records: $EQ_records|$stmtB|\n\n";}
		$h=0;
		while ($CCP_records > $h)
			{
			@aryB = $sthB->fetchrow_array;
			$time_id[$h] =	$aryB[0];
			$call_id[$h] =	$aryB[1];
			$queue[$h] =	$aryB[2];
			$agent[$h] =	$aryB[3];
			$serverid[$h] =	$aryB[4];
			$data4[$h] =	$aryB[5];
			$h++;
			}
		$sthB->finish();

		$h=0;
		while ($CCP_records > $h)
			{
			$unpause_time_id[$h] = ($time_id[$h] + 1);
			$pausereason_count[$h] = 0;

			##### find time_id of the next unpauseall event
			$stmtB = "SELECT time_id FROM queue_log WHERE verb='UNPAUSEALL' and serverid='$queuemetrics_log_id' and agent='$agent[$h]' and time_id >= $time_id[$h] order by time_id limit 1;";
			$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
			$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
			$MXC_records=$sthB->rows;
			if ($MXC_records > 0)
				{
				@aryB = $sthB->fetchrow_array;
				$unpause_time_id[$h] =	$aryB[0];
				}
			$sthB->finish();

			##### find if there is a pausereason record during the pause time
			$stmtB = "SELECT count(*) FROM queue_log WHERE verb='PAUSEREASON' and serverid='$queuemetrics_log_id' and agent='$agent[$h]' and time_id >= $time_id[$h] and  time_id <= $unpause_time_id[$h];";
			$sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
			$sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
			$MXD_records=$sthB->rows;
			if ($MXD_records > 0)
				{
				@aryB = $sthB->fetchrow_array;
				$pausereason_count[$h] =	$aryB[0];
				}
			$sthB->finish();

			if ($pausereason_count[$h] < 1)
				{
				$pause_typeSQL='';
				if ($queuemetrics_pause_type > 0)
					{$pause_typeSQL=",data5='SYSTEM'";}
				##### add new PAUSEREASON record
				$stmtB = "INSERT INTO queue_log SET `partition`='P01',time_id='$time_id[$h]',call_id='$call_id[$h]',queue='NONE',agent='$agent[$h]',verb='PAUSEREASON',data1='$queuemetrics_dispo_pause',serverid='$Cserverid[$h]'$pause_typeSQL;";
				if ($TEST < 1)	
					{
					$Baffected_rows = $dbhB->do($stmtB);
					$PRadded = ($PRadded + $Baffected_rows);
					}
				if ($DB) {print "PAUSEREASON Record Added: $Baffected_rows|$PRadded|$stmtB|\n\n";}
				}

			$h++;
			}

		if ($DB) {print "COMPLETECALLER pause reason validation records: $PRadded\n";}
		}

	$dbhB->disconnect();
	}







	if ($DB) {print STDERR "\nDONE\n";}



#	$dbhA->close;


exit;






sub event_logger
	{
	### open the log file for writing ###
	open(Lout, ">>$CLEANLOGfile")
			|| die "Can't open $CLEANLOGfile: $!\n";
	print Lout "$HDSQLdate|$event_string|\n";
	close(Lout);
	$event_string='';
	}
