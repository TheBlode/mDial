#!/usr/bin/perl
#/* ========================================
# * ███╗   ███╗██████╗ ██╗ █████╗ ██╗
# * ████╗ ████║██╔══██╗██║██╔══██╗██║
# * ██╔████╔██║██║  ██║██║███████║██║
# * ██║╚██╔╝██║██║  ██║██║██╔══██║██║
# * ██║ ╚═╝ ██║██████╔╝██║██║  ██║███████╗
# * ╚═╝     ╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝
# * ========================================
# * mDial - Omni-Channel Contact Centre Suite.
# * Initially Written by Martin McCarthy.
# * Contributions welcome.
# * Active: 2020 - 2023.
# *
# * This software is licensed under AGPLv2.
# * You can find more information here;
# * https://www.gnu.org/licenses/agpl-3.0.en.html
# * A copy of the license is also shipped with this build.
# *
# * Important note: this software is provided to you free of charge.
# * If you paid for this software, you were ripped off.
# *
# * This project is a fork of the awesome FOSS project, ViCiDial.
# * ViCiDial is copyrighted by Matt Florell and the ViCiDial Group
# * under the AGPLv2 license.
# *
# * You can find out more about ViCiDial;
# * Web: https://www.vicidial.com/
# * Email: Matt Florell <vicidial@gmail.com>
# * IRC: Libera.Chat - ##vicidial
# *
# * Bug reports, feature requests and patches welcome!
# * ======================================== */
$DB=0;  # Debug flag, set to 0 for no debug messages, On an active system this will generate thousands of lines of output per minute
$US='__';
$MT[0]='';
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
    print "allowed run time options:\n  [-t] = test\n  [-debug] = verbose debug messages\n[-debugX] = Extra-verbose debug messages\n\n";
    }
    else
    {
        if ($args =~ /-debug/i)
        {
        $DB=1; # Debug flag
        }
        if ($args =~ /--debugX/i)
        {
        $DBX=1;
        print "\n----- SUPER-DUPER DEBUGGING -----\n\n";
        }
        if ($args =~ /-t/i)
        {
        $TEST=1;
        $T=1;
        }
    }
}
else
{
}
$PATHconf =        '/etc/astguiclient.conf';
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
$server_ip = $VARserver_ip;        # Asterisk server IP
if (!$VARDB_port) {$VARDB_port='3306';}
    &get_time_now;
if (!$KHLOGfile) {$KHLOGfile = "$PATHlogs/congest.$year-$mon-$mday";}
use DBI;
$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;
    $stmtA = "SELECT vd_server_logs FROM servers where server_ip = '$VARserver_ip';";
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
    $sthArows=$sthA->rows;
    $rec_count=0;
    while ($sthArows > $rec_count)
        {
         @aryA = $sthA->fetchrow_array;
            $DBvd_server_logs =            "$aryA[0]";
            if ($DBvd_server_logs =~ /Y/)    {$SYSLOG = '1';}
                else {$SYSLOG = '0';}
         $rec_count++;
        }
    $sthA->finish();
$event_string = "SUBRT|killing_congest|KC|START|";
&event_logger;
$stmtA = "SELECT channel FROM live_sip_channels where server_ip = '$server_ip' and extension = 'CONGEST' and channel LIKE \"Local%\" limit 99";
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
    $sthArows=$sthA->rows;
    $rec_count=0; 
    while ($sthArows > $rec_count)
        {
         @aryA = $sthA->fetchrow_array;
        if($DB){print STDERR $aryA[0],"\n";}
        $congest_kill[$rec_count] = "$aryA[0]";
        $rec_count++;
        }
        $sthA->finish();
$i=0;
foreach(@congest_kill)
    {
    $i_count = $i;
    if ($i_count < 10) {$i_count = "0$i_count";}
    if (length($congest_kill[$i])>0)
        {
            $KCqueryCID = "KC$i_count$CIDdate";
        $stmtA = "INSERT INTO vicidial_manager values('','','$now_date','NEW','N','$server_ip','','Hangup','$KCqueryCID','Channel: $congest_kill[$i]','','','','','','','','','')";
            $event_string = "SUBRT|killing_congest|KC|$KCqueryCID|$congest_kill[$i]|$stmtA|";
         &event_logger;
        if ($DB) {print "KILLING $congest_kill[$i]\n";}
        $affected_rows = $dbhA->do($stmtA); 
        }
    $i++;
    }
sleep(14);
    &get_time_now;
@congest_kill = @MT;
$stmtA = "SELECT channel FROM live_sip_channels where server_ip = '$server_ip' and extension = 'CONGEST' and channel LIKE \"Local%\" limit 99";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
$rec_count=0;
while ($sthArows > $rec_count)
    {
        @aryA = $sthA->fetchrow_array;
        if($DB){print STDERR $aryA[0],"\n";}
        $congest_kill[$rec_count] = "$aryA[0]";
        $rec_count++;
    }
    $sthA->finish();
$i=0;
foreach(@congest_kill)
    {
    $i_count = $i;
    if ($i_count < 10) {$i_count = "0$i_count";}
    if (length($congest_kill[$i])>0)
        {
            $KCqueryCID = "KC$i_count$CIDdate";
        $stmtA = "INSERT INTO vicidial_manager values('','','$now_date','NEW','N','$server_ip','','Hangup','$KCqueryCID','Channel: $congest_kill[$i]','','','','','','','','','')";
            $event_string = "SUBRT|killing_congest|KC|$KCqueryCID|$congest_kill[$i]|$stmtA|";
         &event_logger;
        if ($DB) {print "KILLING $congest_kill[$i]\n";}
        $affected_rows = $dbhA->do($stmtA);  # or die  "Couldn't execute query:\n";
        }
    $i++;
    }
sleep(15);
    &get_time_now;
@congest_kill = @MT;
$stmtA = "SELECT channel FROM live_sip_channels where server_ip = '$server_ip' and extension = 'CONGEST' and channel LIKE \"Local%\" limit 99";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
$rec_count=0;
while ($sthArows > $rec_count)
    {
        @aryA = $sthA->fetchrow_array;
        if($DB){print STDERR $aryA[0],"\n";}
        $congest_kill[$rec_count] = "$aryA[0]";
        $rec_count++;
    }
    $sthA->finish();
$i=0;
foreach(@congest_kill)
    {
    $i_count = $i;
    if ($i_count < 10) {$i_count = "0$i_count";}
    if (length($congest_kill[$i])>0)
        {
            $KCqueryCID = "KC$i_count$CIDdate";
        $stmtA = "INSERT INTO vicidial_manager values('','','$now_date','NEW','N','$server_ip','','Hangup','$KCqueryCID','Channel: $congest_kill[$i]','','','','','','','','','')";
            $event_string = "SUBRT|killing_congest|KC|$KCqueryCID|$congest_kill[$i]|$stmtA|";
         &event_logger;
        if ($DB) {print "KILLING $congest_kill[$i]\n";}
        $affected_rows = $dbhA->do($stmtA);  # or die  "Couldn't execute query:\n";
        }
    $i++;
    }
sleep(15);
    &get_time_now;
@congest_kill = @MT;
$stmtA = "SELECT channel FROM live_sip_channels where server_ip = '$server_ip' and extension = 'CONGEST' and channel LIKE \"Local%\" limit 99";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
$rec_count=0;
while ($sthArows > $rec_count)
    {
        @aryA = $sthA->fetchrow_array;
        if($DB){print STDERR $aryA[0],"\n";}
        $congest_kill[$rec_count] = "$aryA[0]";
        $rec_count++;
    }
    $sthA->finish();
$i=0;
foreach(@congest_kill)
    {
    $i_count = $i;
    if ($i_count < 10) {$i_count = "0$i_count";}
    if (length($congest_kill[$i])>0)
        {
            $KCqueryCID = "KC$i_count$CIDdate";
        $stmtA = "INSERT INTO vicidial_manager values('','','$now_date','NEW','N','$server_ip','','Hangup','$KCqueryCID','Channel: $congest_kill[$i]','','','','','','','','','')";
            $event_string = "SUBRT|killing_congest|KC|$KCqueryCID|$congest_kill[$i]|$stmtA|";
         &event_logger;
        if ($DB) {print "KILLING $congest_kill[$i]\n";}
            $affected_rows = $dbhA->do($stmtA);  # or die  "Couldn't execute query:\n";
        }
    $i++;
    }
$dbhA->disconnect();
    if($DB){print "DONE... Exiting... Goodbye... See you later... \n";}
exit;
sub get_time_now    #get the current date and time and epoch for logging call lengths and datetimes
{
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year = ($year + 1900);
$mon++;
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
if ($hour < 10) {$Fhour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
$now_date_epoch = time();
$now_date = "$year-$mon-$mday $hour:$min:$sec";
$action_log_date = "$year-$mon-$mday";
$CIDdate = "$year$mon$mday$hour$min$sec";
}
sub event_logger 
{
if ($SYSLOG)
    {
    open(Lout, ">>$KHLOGfile")
            || die "Can't open $KHLOGfile: $!\n";
    print Lout "$now_date|$event_string|\n";
    close(Lout);
    }
$event_string='';
}
