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
$txt   = '.txt';
$US    = '_';
$MT[0] = '';
if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--help/i ) {
        print "allowed run time options:\n  [-q] = quiet\n  [-t] = test\n\n";
        exit;
    }
    else {
        if ( $args =~ /--debug/i ) {
            $DB = 1;
            print "\n-----DEBUG MODE-----\n\n";
        }
        if ( $args =~ /-q/i ) {
            $q = 1;
            $Q = 1;
        }
        if ( $args =~ /-t/i ) {
            $T    = 1;
            $TEST = 1;
            print "\n-----TESTING-----\n\n";
        }
    }
}
else {
    print "no command line options set\n";
}
$secX = time();
( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
  localtime(time);
$year = ( $year + 1900 );
$mon++;
if ( $mon < 10 )  { $mon  = "0$mon"; }
if ( $mday < 10 ) { $mday = "0$mday"; }
if ( $hour < 10 ) { $hour = "0$hour"; }
if ( $min < 10 )  { $min  = "0$min"; }
if ( $sec < 10 )  { $sec  = "0$sec"; }
$filedate    = "$year$mon$mday-$hour$min$sec";
$ABIfiledate = "$mon-$mday-$year$us$hour$min$sec";
$shipdate    = "$year-$mon-$mday";
$datestamp   = "$year/$mon/$mday $hour:$min";
if ( $wday == 0 ) { $day = 'Sunday   '; }
if ( $wday == 1 ) { $day = 'Monday   '; }
if ( $wday == 2 ) { $day = 'Tuesday  '; }
if ( $wday == 3 ) { $day = 'Wednesday'; }
if ( $wday == 4 ) { $day = 'Thursday '; }
if ( $wday == 5 ) { $day = 'Friday   '; }
if ( $wday == 6 ) { $day = 'Saturday '; }
$TDtarget = ( $secX - 600000 );    # 6 days 10 hours 30 minutes in the past
( $Tsec, $Tmin, $Thour, $Tmday, $Tmon, $Tyear, $Twday, $Tyday, $Tisdst ) =
  localtime($TDtarget);
$Tyear = ( $Tyear + 1900 );
$Tmon++;
if ( $Tmon < 10 )  { $Tmon  = "0$Tmon"; }
if ( $Tmday < 10 ) { $Tmday = "0$Tmday"; }
if ( $Thour < 10 ) { $Thour = "0$Thour"; }
if ( $Tmin < 10 )  { $Tmin  = "0$Tmin"; }
if ( $Tsec < 10 )  { $Tsec  = "0$Tsec"; }
$begindate = "$Tyear-$Tmon-$Tmday";
print "\n\n\n\n\n\n\n\n\n\n\n\n-- AST_agent_week_tally.pl --\n\n";
print
"This program is designed to print stats to a file for agents' activity for the previous week. \n\n";
$PATHconf = '/etc/astguiclient.conf';
open( conf, "$PATHconf" ) || die "can't open $PATHconf: $!\n";
@conf = <conf>;
close(conf);
$i = 0;

foreach (@conf) {
    $line = $conf[$i];
    $line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
    if ( ( $line =~ /^PATHhome/ ) && ( $CLIhome < 1 ) ) {
        $PATHhome = $line;
        $PATHhome =~ s/.*=//gi;
    }
    if ( ( $line =~ /^PATHlogs/ ) && ( $CLIlogs < 1 ) ) {
        $PATHlogs = $line;
        $PATHlogs =~ s/.*=//gi;
    }
    if ( ( $line =~ /^PATHagi/ ) && ( $CLIagi < 1 ) ) {
        $PATHagi = $line;
        $PATHagi =~ s/.*=//gi;
    }
    if ( ( $line =~ /^PATHweb/ ) && ( $CLIweb < 1 ) ) {
        $PATHweb = $line;
        $PATHweb =~ s/.*=//gi;
    }
    if ( ( $line =~ /^PATHsounds/ ) && ( $CLIsounds < 1 ) ) {
        $PATHsounds = $line;
        $PATHsounds =~ s/.*=//gi;
    }
    if ( ( $line =~ /^PATHmonitor/ ) && ( $CLImonitor < 1 ) ) {
        $PATHmonitor = $line;
        $PATHmonitor =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARserver_ip/ ) && ( $CLIserver_ip < 1 ) ) {
        $VARserver_ip = $line;
        $VARserver_ip =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARDB_server/ ) && ( $CLIDB_server < 1 ) ) {
        $VARDB_server = $line;
        $VARDB_server =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARDB_database/ ) && ( $CLIDB_database < 1 ) ) {
        $VARDB_database = $line;
        $VARDB_database =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARDB_user/ ) && ( $CLIDB_user < 1 ) ) {
        $VARDB_user = $line;
        $VARDB_user =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARDB_pass/ ) && ( $CLIDB_pass < 1 ) ) {
        $VARDB_pass = $line;
        $VARDB_pass =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARDB_port/ ) && ( $CLIDB_port < 1 ) ) {
        $VARDB_port = $line;
        $VARDB_port =~ s/.*=//gi;
    }
    $i++;
}
$server_ip = $VARserver_ip;                      # Asterisk server IP
$outfile   = "AGENT_TALLY_$shipdate$txt";
$Doutfile  = "AGENT_TALLY_PIPE_$shipdate$txt";
open( out, ">$PATHweb/vicidial/agent_reports/$outfile" )
  || die "Can't open $outfile: $!\n";
open( Dout, ">$PATHweb/vicidial/agent_reports/$Doutfile" )
  || die "Can't open $Doutfile: $!\n";
if ( !$VARDB_port ) { $VARDB_port = '3306'; }
use DBI;
$dbhA = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$dbhB = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$vicidial_agent_log = 'vicidial_agent_log';
print Dout
  "DATE|AGENT|USER|CALLS|TALK|PAUSE|WAIT|DISPO|ACTIVE|LOGTIME|FIRST|LAST\n";
print out "WEEK: $begindate through $shipdate\n\n";
print out
"AGENT                USER     CALLS  TALK     PAUSE    WAIT     DISPO    ACTIVE   LOGTIME  FIRST                LAST                    \n";
print "WEEK: $begindate through $shipdate\n\n";
print
"AGENT                USER     CALLS  TALK     PAUSE    WAIT     DISPO    ACTIVE   LOGTIME  FIRST                LAST                    \n";
$stmtA =
"select count(*) as calls, full_name,vicidial_users.user,sum(talk_sec),sum(pause_sec),sum(wait_sec),sum(dispo_sec) from vicidial_users,$vicidial_agent_log where event_time <= '$shipdate 23:59:59' and event_time >= '$begindate 00:00:00' and vicidial_users.user=$vicidial_agent_log.user and pause_sec<48800 and wait_sec<48800 and talk_sec<48800 and dispo_sec<48800 group by vicidial_users.user order by full_name limit 10000;";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
$sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
$sthArows  = $sthA->rows;
$rec_count = 0;

while ( $sthArows > $rec_count ) {
    @aryA   = $sthA->fetchrow_array;
    $Dcalls = $aryA[0];
    $Dname  = $aryA[1];
    $Duser  = $aryA[2];
    $calls  = sprintf( "%7s",   $aryA[0] );
    $name   = sprintf( "%-20s", $aryA[1] );
    while ( length($name) > 20 ) { chop($name); }
    $user   = sprintf( "%-8s", $aryA[2] );
    $active = ( $aryA[3] + $aryA[4] + $aryA[5] + $aryA[6] );
    $TIME_S = $active;
    $TIME_H = int( $TIME_S / 3600 );
    $TIME_S = ( $TIME_S - ( $TIME_H * 3600 ) );
    $TIME_M = int( $TIME_S / 60 );
    $TIME_S = ( $TIME_S - ( $TIME_M * 60 ) );
    if ( $TIME_S < 10 ) { $TIME_S = "0$TIME_S"; }
    if ( $TIME_M < 10 ) { $TIME_M = "0$TIME_M"; }
    $TIME_HMS = "$TIME_H:$TIME_M:$TIME_S";
    $Dactive  = $TIME_HMS;
    $active   = sprintf( "%9s", $TIME_HMS );
    $TIME_S   = $aryA[3];
    $TIME_H   = int( $TIME_S / 3600 );
    $TIME_S   = ( $TIME_S - ( $TIME_H * 3600 ) );
    $TIME_M   = int( $TIME_S / 60 );
    $TIME_S   = ( $TIME_S - ( $TIME_M * 60 ) );
    if ( $TIME_S < 10 ) { $TIME_S = "0$TIME_S"; }
    if ( $TIME_M < 10 ) { $TIME_M = "0$TIME_M"; }
    $TIME_HMS = "$TIME_H:$TIME_M:$TIME_S";
    $Dtalk    = $TIME_HMS;
    $talk     = sprintf( "%9s", $TIME_HMS );
    $TIME_S   = $aryA[4];
    $TIME_H   = int( $TIME_S / 3600 );
    $TIME_S   = ( $TIME_S - ( $TIME_H * 3600 ) );
    $TIME_M   = int( $TIME_S / 60 );
    $TIME_S   = ( $TIME_S - ( $TIME_M * 60 ) );
    if ( $TIME_S < 10 ) { $TIME_S = "0$TIME_S"; }
    if ( $TIME_M < 10 ) { $TIME_M = "0$TIME_M"; }
    $TIME_HMS = "$TIME_H:$TIME_M:$TIME_S";
    $Dpause   = $TIME_HMS;
    $pause    = sprintf( "%9s", $TIME_HMS );
    $TIME_S   = $aryA[5];
    $TIME_H   = int( $TIME_S / 3600 );
    $TIME_S   = ( $TIME_S - ( $TIME_H * 3600 ) );
    $TIME_M   = int( $TIME_S / 60 );
    $TIME_S   = ( $TIME_S - ( $TIME_M * 60 ) );
    if ( $TIME_S < 10 ) { $TIME_S = "0$TIME_S"; }
    if ( $TIME_M < 10 ) { $TIME_M = "0$TIME_M"; }
    $TIME_HMS = "$TIME_H:$TIME_M:$TIME_S";
    $Dwait    = $TIME_HMS;
    $wait     = sprintf( "%9s", $TIME_HMS );
    $TIME_S   = $aryA[6];
    $TIME_H   = int( $TIME_S / 3600 );
    $TIME_S   = ( $TIME_S - ( $TIME_H * 3600 ) );
    $TIME_M   = int( $TIME_S / 60 );
    $TIME_S   = ( $TIME_S - ( $TIME_M * 60 ) );
    if ( $TIME_S < 10 ) { $TIME_S = "0$TIME_S"; }
    if ( $TIME_M < 10 ) { $TIME_M = "0$TIME_M"; }
    $TIME_HMS = "$TIME_H:$TIME_M:$TIME_S";
    $Ddispo   = $TIME_HMS;
    $dispo    = sprintf( "%9s", $TIME_HMS );
    $stmtB =
"select event_time,UNIX_TIMESTAMP(event_time) from $vicidial_agent_log where event_time <= '$shipdate 23:59:59' and event_time >= '$begindate 00:00:00' and user='$aryA[2]' order by event_time limit 1;";
    $sthB = $dbhB->prepare($stmtB) or die "preparing: ",        $dbhB->errstr;
    $sthB->execute                 or die "executing: $stmtA ", $dbhB->errstr;
    @aryB        = $sthB->fetchrow_array;
    $Dfirst_time = $aryB[0];
    $first_time  = sprintf( "%21s", $aryB[0] );
    $Dfirst_log  = $aryB[1];
    $first_log   = $aryB[1];
    $stmtB =
"select event_time,UNIX_TIMESTAMP(event_time) from $vicidial_agent_log where event_time <= '$shipdate 23:59:59' and event_time >= '$begindate 00:00:00' and user='$aryA[2]' order by event_time desc limit 1;";
    $sthB = $dbhB->prepare($stmtB) or die "preparing: ",        $dbhB->errstr;
    $sthB->execute                 or die "executing: $stmtA ", $dbhB->errstr;
    @aryB       = $sthB->fetchrow_array;
    $Dlast_time = $aryB[0];
    $last_time  = sprintf( "%21s", $aryB[0] );
    $Dlast_log  = $aryB[1];
    $last_log   = $aryB[1];
    $TIME_S     = ( $last_log - $first_log );
    $TIME_H     = int( $TIME_S / 3600 );
    $TIME_S     = ( $TIME_S - ( $TIME_H * 3600 ) );
    $TIME_M     = int( $TIME_S / 60 );
    $TIME_S     = ( $TIME_S - ( $TIME_M * 60 ) );
    if ( $TIME_S < 10 ) { $TIME_S = "0$TIME_S"; }
    if ( $TIME_M < 10 ) { $TIME_M = "0$TIME_M"; }
    $TIME_HMS    = "$TIME_H:$TIME_M:$TIME_S";
    $TIME_HMS    = "N/A";
    $Dlogin_time = $TIME_HMS;
    $login_time  = sprintf( "%9s", $TIME_HMS );
    print Dout
"$shipdate|$Dname|$Duser|$Dcalls|$Dtalk|$Dpause|$Dwait|$Ddispo|$Dactive|$Dlogin_time|$Dfirst_time|$Dlast_time\n";
    print out
"$name$user$calls$talk$pause$wait$dispo$active$login_time$first_time$last_time\n";
    print
"$name$user$calls$talk$pause$wait$dispo$active$login_time$first_time$last_time\n";
    $rec_count++;
}
$sthA->finish();
close(Dout);
close(out);
$secY  = time();
$secZ  = ( $secY - $secX );
$secZm = ( $secZ / 60 );
print "script execution time in seconds: $secZ     minutes: $secZm\n";
exit;
