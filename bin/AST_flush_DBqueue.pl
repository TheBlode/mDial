#!/usr/bin/perl
#
# AST_flush_DBqueue.pl    version 2.14
#
# DESCRIPTION:
# - clears out mysql records for this server for the ACQS vicidial_manager table
# - OPTIMIZEs tables used frequently by VICIDIAL
#
# !!!!!!!! IMPORTANT !!!!!!!!!!!!!!!!!!
# THIS SCRIPT SHOULD ONLY BE RUN ON ONE SERVER ON YOUR CLUSTER
#
# Copyright (C) 2023  Matt Florell <vicidial@gmail.com>    LICENSE: AGPLv2
#
# CHANGES
# 60717-1214 - changed to DBI by Marin Blu
# 60717-1536 - changed to use /etc/astguiclient.conf for configs
# 60910-0238 - removed park_log query
# 90628-2358 - Added vicidial_drop_rate_groups optimization
# 91206-2149 - Added vicidial_campaigns and vicidial_lists optimization
# 120404-1315 - Changed to run only on DB server<you should remove from other servers' crontabs>
# 120411-1637 - Added --seconds option
# 150710-0907 - Added flush of vicidial_dtmf_log table
# 160101-1124 - Added flush of routing_initiated_recordings table
# 161214-1039 - Added flush of parked_channels_recent table
# 180112-0915 - Added flush for cid_channels_recent table
# 180511-1223 - Added flush for server-specific cid_channels_recent_ tables
# 180519-1431 - Added vicidial_inbound_groups optimization
# 181003-2115 - Added optimize of cid_channels_recent_ tables
# 190214-1758 - Fix for cid_recent_ table optimization issue
# 190222-1321 - Added optional flushing of vicidial_sessions_recent table
# 190503-1606 - Added flushing of vicidial_sip_event_recent table
# 191029-1555 - Added flushing of vicidial_agent_vmm_overrides table
# 220921-1148 - Added optimize of vicidial_users table
# 230414-1622 - Added --reset-stuck-leads option
#

$session_flush=0;
$SSsip_event_logging=0;
$reset_stuck_leads=0;
$stuck_lists='';
$stuck_listsSQL='';

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
		print "  [-q] = quiet\n";
		print "  [-t] = test\n";
		print "  [--debug] = debugging messages\n";
		print "  [--debugX] = extra debugging messages\n";
		print "  [--seconds=XXX] = optional, minimum number of seconds worth of records to keep(default 3600)\n";
		print "  [--session-flush] = flush the vicidial_sessions_recent table\n";
		print "  [--reset-stuck-leads] = reset status of ERI/INCALL leads to NEW if previewed but not called\n";
		print "  [--stuck-lists=X] = restrict stuck leads check to these lists: X-Y-Z multiple lists separated by a single dash\n";
		print "\n";

		exit;
		}
	else
		{
		if ($args =~ /-q/i)
			{
			$q=1;   $Q=1;
			}
		if ($args =~ /--debug/i)
			{
			$DB=1;
			print "\n-----DEBUGGING -----\n\n";
			}
		if ($args =~ /--debugX/i)
			{
			$DBX=1;
			print "\n----- EXTRA DEBUGGING -----\n\n";
			}
		if ($args =~ /-t|--test/i)
			{
			$T=1; $TEST=1;
			print "\n-----TESTING -----\n\n";
			}
		if ($args =~ /--session-flush/i)
			{
			$session_flush=1;
			if ($Q < 1)
				{print "\n----- SESSION FLUSH(vicidial_sessions_recent) ----- $session_flush \n\n";}
			}
		if ($args =~ /--reset-stuck-leads/i)
			{
			$reset_stuck_leads=1;
			if ($Q < 1)
				{print "\n----- RESET STUCK LEADS ----- $reset_stuck_leads \n\n";}
			}
		if ($args =~ /--stuck-lists=/i)
			{
			@data_in = split(/--stuck-lists=/,$args);
			$stuck_lists = $data_in[1];
			$stuck_lists =~ s/ .*$//gi;
			$stuck_listsSQL = $stuck_lists;
			$stuck_listsSQL =~ s/-/','/gi;
			if (length($stuck_listsSQL) > 0) {$stuck_listsSQL = "and list_id IN('$stuck_listsSQL')";}
			if ($Q < 1)
				{print "\n----- STUCK LISTS DEFINED: $stuck_lists [$stuck_listsSQL] -----\n\n";}
			}
		if ($args =~ /--seconds=/i)
			{
			@data_in = split(/--seconds=/,$args);
			$purge_seconds = $data_in[1];
			$purge_seconds =~ s/ .*$//gi;
			$purge_seconds =~ s/\D//gi;
			$purge_seconds_half = $purge_seconds;
			if ($Q < 1)
				{print "\n----- SECONDS OVERRIDE: $purge_seconds -----\n\n";}
			if (length($purge_seconds) < 3)
				{
				print "ERROR! Invalid Seconds: $purge_seconds     Exiting...\n";
				exit;
				}
			}
		else
			{
			$purge_seconds = '3600';
			$purge_seconds_half = '1800';
			}
		}
	}
else
	{
	print "no command line options set\n";
	}
### end parsing run-time options ###

$secX = time();
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year = ($year + 1900);
$yy = $year; $yy =~ s/^..//gi;
$mon++;
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
if ($hour < 10) {$hour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
$SQLdate_NOW="$year-$mon-$mday $hour:$min:$sec";
$SQLdate_MIDNIGHT="$year-$mon-$mday 00:00:00";

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time() - 121);
$year = ($year + 1900);
$yy = $year; $yy =~ s/^..//gi;
$mon++;
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
if ($hour < 10) {$hour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
$SQLdate_NEG_2min="$year-$mon-$mday $hour:$min:$sec";

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time() - ($purge_seconds * 2));
$year = ($year + 1900);
$yy = $year; $yy =~ s/^..//gi;
$mon++;
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
if ($hour < 10) {$hour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
$SQLdate_NEG_2hour="$year-$mon-$mday $hour:$min:$sec";

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time() - $purge_seconds);
$year = ($year + 1900);
$yy = $year; $yy =~ s/^..//gi;
$mon++;
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
if ($hour < 10) {$hour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
$SQLdate_NEG_1hour="$year-$mon-$mday $hour:$min:$sec";

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time() - $purge_seconds_half);
$year = ($year + 1900);
$yy = $year; $yy =~ s/^..//gi;
$mon++;
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
if ($hour < 10) {$hour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
$SQLdate_NEG_halfhour="$year-$mon-$mday $hour:$min:$sec";

($Ssec,$Smin,$Shour,$Smday,$Smon,$Syear,$Swday,$Syday,$Sisdst) = localtime(time() - 21600);
$Syear = ($Syear + 1900);
$Syy = $Syear; $Syy =~ s/^..//gi;
$Smon++;
if ($Smon < 10) {$Smon = "0$Smon";}
if ($Smday < 10) {$Smday = "0$Smday";}
if ($Shour < 10) {$Shour = "0$Shour";}
if ($Smin < 10) {$Smin = "0$Smin";}
if ($Ssec < 10) {$Ssec = "0$Ssec";}
$SQLdate_NEG_sixhour="$Syear-$Smon-$Smday $Shour:$Smin:$Ssec";

($Tsec,$Tmin,$Thour,$Tmday,$Tmon,$Tyear,$Twday,$Tyday,$Tisdst) = localtime(time() - 600);
$Tyear = ($Tyear + 1900);
$Tyy = $Tyear; $Tyy =~ s/^..//gi;
$Tmon++;
if ($Tmon < 10) {$Tmon = "0$Tmon";}
if ($Tmday < 10) {$Tmday = "0$Tmday";}
if ($Thour < 10) {$Thour = "0$Thour";}
if ($Tmin < 10) {$Tmin = "0$Tmin";}
if ($Tsec < 10) {$Tsec = "0$Tsec";}
$SQLdate_NEG_tenminute="$Tyear-$Tmon-$Tmday $Thour:$Tmin:$Tsec";


if (!$Q) {print "TEST\n\n";}
if (!$Q) {print "NOW DATETIME:         $SQLdate_NOW\n";}
if (!$Q) {print "1 HOUR AGO DATETIME:  $SQLdate_NEG_1hour\n\n";}

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

# Customized Variables
$server_ip = $VARserver_ip;		# Asterisk server IP

if (!$VARDB_port) {$VARDB_port='3306';}

use DBI;	  

$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;

### Grab Server values from the database
$stmtA = "SELECT vd_server_logs FROM servers where server_ip = '$VARserver_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
if ($sthArows > 0)
	{
	@aryA = $sthA->fetchrow_array;
	$DBvd_server_logs =			$aryA[0];
	if ($DBvd_server_logs =~ /Y/)	{$SYSLOG = '1';}
	else {$SYSLOG = '0';}
	}
$sthA->finish();

### Grab system_settings values from the database
$stmtA = "SELECT sip_event_logging FROM system_settings limit 1;";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
if ($sthArows > 0)
	{
	@aryA = $sthA->fetchrow_array;
	$SSsip_event_logging =			$aryA[0];
	}
$sthA->finish();

if ($SYSLOG) 
	{$flush_time = $SQLdate_NEG_1hour;}
else
	{$flush_time = $SQLdate_NEG_halfhour;}

$stmtA = "DELETE from vicidial_manager where entry_date < '$flush_time';";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) {	$affected_rows = $dbhA->do($stmtA);}
if (!$Q) {print " - vicidial_manager flush: $affected_rows rows\n";}

$stmtA = "DELETE from vicidial_dtmf_log where dtmf_time < '$flush_time';";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) {      $affected_rows = $dbhA->do($stmtA);}
if (!$Q) {print " - vicidial_dtmf_log flush: $affected_rows rows\n";}

$stmtA = "DELETE from routing_initiated_recordings where launch_time < '$flush_time';";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) {      $affected_rows = $dbhA->do($stmtA);}
if (!$Q) {print " - routing_initiated_recordings flush: $affected_rows rows\n";}

$stmtA = "DELETE from parked_channels_recent where park_end_time < '$flush_time';";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) {      $affected_rows = $dbhA->do($stmtA);}
if (!$Q) {print " - parked_channels_recent flush: $affected_rows rows\n";}

$stmtA = "DELETE from cid_channels_recent where call_date < '$SQLdate_NEG_2min';";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) {      $affected_rows = $dbhA->do($stmtA);}
if (!$Q) {print " - cid_channels_recent flush: $affected_rows rows\n";}

$stmtA = "DELETE from vicidial_agent_vmm_overrides where call_date < '$flush_time';";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) {      $affected_rows = $dbhA->do($stmtA);}
if (!$Q) {print " - vicidial_agent_vmm_overrides flush: $affected_rows rows\n";}


if ($SSsip_event_logging > 0)
	{
	$stmtA = "DELETE from vicidial_sip_event_recent where invite_date < '$SQLdate_NEG_2hour';";
	if($DB){print STDERR "\n|$stmtA|\n";}
	if (!$T) {      $affected_rows = $dbhA->do($stmtA);}
	if (!$Q) {print " - vicidial_sip_event_recent flush: $affected_rows rows\n";}
	}

$stmtA = "OPTIMIZE table vicidial_manager;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) 
	{
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	@aryA = $sthA->fetchrow_array;
	if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
	$sthA->finish();
	}
if (!$Q) {print " - OPTIMIZE vicidial_manager          \n";}


$stmtA = "OPTIMIZE table vicidial_dtmf_log;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T)
        {
        $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
        $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
        $sthArows=$sthA->rows;
        @aryA = $sthA->fetchrow_array;
        if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
        $sthA->finish();
        }
if (!$Q) {print " - OPTIMIZE vicidial_dtmf_log          \n";}


$stmtA = "OPTIMIZE table routing_initiated_recordings;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T)
        {
        $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
        $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
        $sthArows=$sthA->rows;
        @aryA = $sthA->fetchrow_array;
        if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
        $sthA->finish();
        }
if (!$Q) {print " - OPTIMIZE routing_initiated_recordings          \n";}


$stmtA = "OPTIMIZE table parked_channels_recent;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T)
        {
        $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
        $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
        $sthArows=$sthA->rows;
        @aryA = $sthA->fetchrow_array;
        if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
        $sthA->finish();
        }
if (!$Q) {print " - OPTIMIZE parked_channels_recent          \n";}


$stmtA = "OPTIMIZE table cid_channels_recent;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T)
        {
        $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
        $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
        $sthArows=$sthA->rows;
        @aryA = $sthA->fetchrow_array;
        if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
        $sthA->finish();
        }
if (!$Q) {print " - OPTIMIZE cid_channels_recent          \n";}


$stmtA = "OPTIMIZE table vicidial_agent_vmm_overrides;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T)
        {
        $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
        $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
        $sthArows=$sthA->rows;
        @aryA = $sthA->fetchrow_array;
        if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
        $sthA->finish();
        }
if (!$Q) {print " - OPTIMIZE vicidial_agent_vmm_overrides          \n";}


if ($SSsip_event_logging > 0)
	{
	$stmtA = "OPTIMIZE table vicidial_sip_event_recent;";
	if($DB){print STDERR "\n|$stmtA|\n";}
	if (!$T)
        {
        $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
        $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
        $sthArows=$sthA->rows;
        @aryA = $sthA->fetchrow_array;
        if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
        $sthA->finish();
        }
	if (!$Q) {print " - OPTIMIZE vicidial_sip_event_recent          \n";}
	}


$stmtA = "OPTIMIZE table vicidial_live_agents;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) 
	{
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	@aryA = $sthA->fetchrow_array;
	if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}             
	$sthA->finish();
	}
if (!$Q) {print " - OPTIMIZE vicidial_live_agents          \n";}


$stmtA = "OPTIMIZE table vicidial_drop_rate_groups;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) 
	{
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	@aryA = $sthA->fetchrow_array;
	if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
	$sthA->finish();
	}
if (!$Q) {print " - OPTIMIZE vicidial_drop_rate_groups          \n";}


$stmtA = "OPTIMIZE table vicidial_campaigns;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) 
	{
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	@aryA = $sthA->fetchrow_array;
	if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
	$sthA->finish();
	}
if (!$Q) {print " - OPTIMIZE vicidial_campaigns          \n";}


$stmtA = "OPTIMIZE table vicidial_lists;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) 
	{
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	@aryA = $sthA->fetchrow_array;
	if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
	$sthA->finish();
	}
if (!$Q) {print " - OPTIMIZE vicidial_lists          \n";}


$stmtA = "OPTIMIZE table vicidial_inbound_groups;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) 
	{
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	@aryA = $sthA->fetchrow_array;
	if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
	$sthA->finish();
	}
if (!$Q) {print " - OPTIMIZE vicidial_inbound_groups          \n";}


$stmtA = "OPTIMIZE table vicidial_users;";
if($DB){print STDERR "\n|$stmtA|\n";}
if (!$T) 
	{
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	@aryA = $sthA->fetchrow_array;
	if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
	$sthA->finish();
	}
if (!$Q) {print " - OPTIMIZE vicidial_users          \n";}


### Gather active servers from the database
$stmtA = "SELECT server_ip,server_id FROM servers where active='Y' and active_asterisk_server='Y';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArowsSERVERS=$sthA->rows;
$aas=0;
while ($sthArowsSERVERS > $aas)
	{
	@aryA = $sthA->fetchrow_array;
	$dialer_ip[$aas] =			$aryA[0];
	$dialer_id[$aas] =			$aryA[1];
	$PADserver_ip[$aas] =		$aryA[0];
	$PADserver_ip[$aas] =~ s/(\d+)(\.|$)/sprintf "%3.3d$2",$1/eg; 
	$PADserver_ip[$aas] =~ s/\.//eg; 
	$aas++;
	}
$sthA->finish();

$aas=0;
while ($sthArowsSERVERS > $aas)
	{
	$CCRrec=0;
	$stmtA = "SHOW TABLES LIKE \"cid_channels_recent_$PADserver_ip[$aas]\";";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$CCRrec=$sthA->rows;
	if($DB){print STDERR "\n|$CCRrec|$stmtA|\n";}

	if ($CCRrec > 0)
		{
		$stmtA = "DELETE from cid_channels_recent_$PADserver_ip[$aas] where call_date < '$SQLdate_NEG_2min';";
		if($DB){print STDERR "\n|$stmtA|\n";}
		if (!$T) {      $affected_rows = $dbhA->do($stmtA);}
		if (!$Q) {print " - cid_channels_recent_$PADserver_ip[$aas] flush: $affected_rows rows\n";}

		$stmtA = "OPTIMIZE table cid_channels_recent_$PADserver_ip[$aas];";
		if($DB){print STDERR "\n|$stmtA|\n";}
		if (!$T) 
			{
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthArows=$sthA->rows;
			@aryA = $sthA->fetchrow_array;
			if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
			$sthA->finish();
			}
		if (!$Q) {print " - OPTIMIZE cid_channels_recent_$PADserver_ip[$aas]          \n";}
		}
	$aas++;
	}
$sthA->finish();


if ($session_flush > 0) 
	{
	$stmtA = "DELETE from vicidial_sessions_recent where call_date < '$SQLdate_NEG_1hour';";
	if($DB){print STDERR "\n|$stmtA|\n";}
	if (!$T) {      $affected_rows = $dbhA->do($stmtA);}
	if (!$Q) {print " - vicidial_sessions_recent flush: $affected_rows rows\n";}

	$stmtA = "OPTIMIZE table vicidial_sessions_recent;";
	if($DB){print STDERR "\n|$stmtA|\n";}
	if (!$T) 
		{
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if (!$Q) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();
		}
	if (!$Q) {print " - OPTIMIZE vicidial_sessions_recent          \n";}
	}
$dbhA->disconnect();


if ($reset_stuck_leads > 0) 
	{
	$found_stuck_ct=0;
	# Gather possible stuck leads
	$stmtA = "SELECT lead_id,list_id,status,user,last_local_call_time,called_count,modify_date FROM vicidial_list where status IN('ERI','INCALL') and modify_date >= \"$SQLdate_NEG_sixhour\" and modify_date <= \"$SQLdate_NEG_2min\" $stuck_listsSQL order by modify_date limit 10000;";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArowsSTUCK=$sthA->rows;
	if ($DBX) {print "DEBUG: $sthArowsSTUCK|$stmtA|\n";}
	$a=0;
	while ($sthArowsSTUCK > $a)
		{
		@aryA = $sthA->fetchrow_array;
		$ST_lead_id[$a] =				$aryA[0];
		$ST_list_id[$a] =				$aryA[1];
		$ST_status[$a] =				$aryA[2];
		$ST_user[$a] =					$aryA[3];
		$ST_last_local_call_time[$a] =	$aryA[4];
		$ST_called_count[$a] =			$aryA[5];
		$ST_modify_date[$a] =			$aryA[6];
		$a++;
		}
	$sthA->finish();

	$a=0;
	while ($sthArowsSTUCK > $a)
		{
		$active_count=0;
		$log_count=0;
		$inbound_count=0;
		$dial_count=0;
		$preview_count=0;

		$stmtA = "SELECT count(*) FROM vicidial_auto_calls where lead_id='$ST_lead_id[$a]';";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArowsACTIVE=$sthA->rows;
		if ($DBX) {print "DEBUG: $sthArowsACTIVE|$stmtA|\n";}
		if ($sthArowsACTIVE > 0)
			{
			@aryA = $sthA->fetchrow_array;
			$active_count =		$aryA[0];
			}
		$sthA->finish();

		if ($active_count > 0) 
			{if($DB){print STDERR "Call active: $active_count|$ST_lead_id[$a]|\n";}}
		else
			{
			$stmtA = "SELECT count(*) FROM vicidial_log where lead_id='$ST_lead_id[$a]' and call_date >= \"$SQLdate_MIDNIGHT\";";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthArowsACTIVE=$sthA->rows;
			if ($DBX) {print "DEBUG: $sthArowsACTIVE|$stmtA|\n";}
			if ($sthArowsACTIVE > 0)
				{
				@aryA = $sthA->fetchrow_array;
				$log_count =	$aryA[0];
				}
			$sthA->finish();

			if ($log_count > 0) 
				{if($DB){print STDERR "Lead has outbound log today: $log_count|$ST_lead_id[$a]|\n";}}
			else
				{
				$stmtA = "SELECT count(*) FROM vicidial_closer_log where lead_id='$ST_lead_id[$a]' and call_date >= \"$SQLdate_MIDNIGHT\";";
				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
				$sthArowsACTIVE=$sthA->rows;
				if ($DBX) {print "DEBUG: $sthArowsACTIVE|$stmtA|\n";}
				if ($sthArowsACTIVE > 0)
					{
					@aryA = $sthA->fetchrow_array;
					$inbound_count = 	$aryA[0];
					}
				$sthA->finish();

				if ($inbound_count > 0) 
					{if($DB){print STDERR "Lead has inbound log today: $inbound_count|$ST_lead_id[$a]|\n";}}
				else
					{
					$stmtA = "SELECT count(*) FROM vicidial_dial_log where lead_id='$ST_lead_id[$a]' and call_date >= \"$SQLdate_MIDNIGHT\";";
					$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
					$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
					$sthArowsACTIVE=$sthA->rows;
					if ($DBX) {print "DEBUG: $sthArowsACTIVE|$stmtA|\n";}
					if ($sthArowsACTIVE > 0)
						{
						@aryA = $sthA->fetchrow_array;
						$dial_count = 	$aryA[0];
						}
					$sthA->finish();

					if ($dial_count > 0) 
						{if($DB){print STDERR "Lead has dial log today: $dial_count|$ST_lead_id[$a]|\n";}}
					else
						{
						$stmtA = "SELECT count(*) FROM vicidial_live_agents where preview_lead_id='$ST_lead_id[$a]' and last_state_change >= \"$SQLdate_MIDNIGHT\";";
						$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
						$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
						$sthArowsACTIVE=$sthA->rows;
						if ($DBX) {print "DEBUG: $sthArowsACTIVE|$stmtA|\n";}
						if ($sthArowsACTIVE > 0)
							{
							@aryA = $sthA->fetchrow_array;
							$preview_count = 	$aryA[0];
							}
						$sthA->finish();

						if ($preview_count > 0) 
							{if($DB){print STDERR "Lead is being previewed right now: $preview_count|$ST_lead_id[$a]|\n";}}
						else
							{
							if (!$Q) {print " - stuck lead found: |$ST_modify_date[$a]|$ST_lead_id[$a]|$ST_list_id[$a]|$ST_status[$a]|$ST_user[$a]|$ST_last_local_call_time[$a]|$ST_called_count[$a]|\n";}

							$new_status='NEW';
							$affected_rows=0;
		
							# lead should be reset to allowed to be called again
							$stmtA = "UPDATE vicidial_list SET status='$new_status',called_since_last_reset='N' where lead_id='$ST_lead_id[$a]';";
							if($DB){print STDERR "\n|$stmtA|\n";}
							if (!$T) {$affected_rows = $dbhA->do($stmtA);}
							if ($DBX) {print "DEBUG: $affected_rows|$stmtA|\n";}
							$found_stuck_ct++;
							if (!$Q) {print " - stuck call has been reset: $ST_lead_id[$a]|$found_stuck_ct|\n";}

							if (!$STUCKLOGfile)	{$STUCKLOGfile = "$PATHlogs/stuck_leads.$year-$mon-$mday";}
							open(Lout, ">>$STUCKLOGfile")
									|| die "Can't open $STUCKLOGfile: $!\n";
							print Lout "$SQLdate_NOW|$affected_rows|$ST_modify_date[$a]|$ST_lead_id[$a]|$ST_list_id[$a]|$ST_user[$a]|$ST_last_local_call_time[$a]|$ST_called_count[$a]|$ST_status[$a]|\n";
							close(Lout);
							}
						}
					}
				}
			}
		$a++;
		}

	if (!$Q) {print " - STUCK leads check finished, stuck calls checked: $a  reset: $found_stuck_ct, exiting...\n";}
	}
$dbhA->disconnect();

exit;
