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
$CIDlist[0]            = '9989998888';
$dialstring_800_prefix = '91';
$dialstring_number     = '6102350796';    # number being dialed (inbound queue)
$server_ips[0]         = '192.168.75.21';
$server_ips[1]         = '192.168.75.23';
$server_ips[2]         = '192.168.75.22';
$exten                 = '834562311';     # where the test audio file is located
$context               = 'default';
$US                    = '_';
$loop_delay            = '10000';
$it                    = '0';
$total_loops           = '3600';          # 3600 seconds = 1 hour
$dialstring            = "$dialstring_800_prefix$dialstring_number";
$MT[0]                 = '';

if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--help/i ) {
        print "allowed run time options:\n";
        print "  [-t] = test\n";
        print "  [-debug] = verbose debug messages\n";
        print
"  [--delay=XXX] = delay of XXX seconds per loop, default 2.5 seconds\n";
        print
"  [--concurrent-calls=XXX] = sets number of concurrent calls to maintain, overrides delay setting\n\n";
        exit;
    }
    else {
        if ( $args =~ /--delay=/i ) {
            @data_in    = split( /--delay=/, $args );
            $loop_delay = $data_in[1];
            print "     LOOP DELAY OVERRIDE!!!!! = $loop_delay seconds\n\n";
            $loop_delay = ( $loop_delay * 1000 );
        }
        else {
            $loop_delay = '1000';
        }
        if ( $args =~ /--concurrent-calls=/i ) {
            @data_in          = split( /--concurrent-calls=/, $args );
            $concurrent_calls = $data_in[1];
            $loop_delay       = ( 100000 / $concurrent_calls );
            print
"     CONCURRENT CALLS OVERRIDE!!!!! = $concurrent_calls - $loop_delay\n\n";
        }
        if ( $args =~ /-debug/i ) {
            $DB = 1
              ; # Debug flag, set to 0 for no debug messages, On an active system this will generate hundreds of lines of output per minute
        }
        if ( $args =~ /-t/i ) {
            $TEST = 1;
            $T    = 1;
        }
    }
}
else {
    print "no command line options set\n";
    $DB = 1;
}
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
&get_time_now;
$server_ip    = $VARserver_ip;                          # Asterisk server IP
$SWAMPLOGfile = "$PATHlogs/SWAMP_LOG_$file_date$txt";
$event_string =
'PROGRAM STARTED||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';
&event_logger;    # writes to the log and if debug flag is set prints to STDOUT
use lib './lib', '../lib';
use Time::HiRes ( 'gettimeofday', 'usleep', 'sleep' )
  ;               # necessary to have perl sleep command of less than one second
if ( !$VARDB_port ) { $VARDB_port = '3306'; }
use DBI;
$dbhA = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$event_string = 'LOGGED INTO MYSQL SERVER ON 1 CONNECTION|';
&event_logger;
$total     = 0;
$list_it   = 0;
$server_it = 0;
$list_inc  = 0;

while ( $it < $total_loops ) {
    &get_time_now;    # update time/date variables
    $CIDtemp    = ( $CIDlist[$list_it] + $list_inc );
    $SERVERtemp = $server_ips[$server_it];
    $k          = 0;
    while ( $k < 1 ) {
        $stmtA =
"INSERT INTO vicidial_manager values('','','$SQLdate','NEW','N','$SERVERtemp','','Originate','TESTCIDX$CIDdate$US$it','Channel: Local/$dialstring@$context','Context: $context','Exten: $exten','Priority: 1','Callerid: \"Inbound Test Call\" <$CIDtemp>','','','','','');";
        $affected_rows = $dbhA->do($stmtA);
        $k++;
        $total++;
        $event_string =
"CALL: $total TO: $dialstring   CID: $CIDtemp   it: $it   list_it: $list_it   list_inc: $list_inc  server: $SERVERtemp";
        print "$event_string\n";
        &event_logger;
    }
    usleep( 1 * $loop_delay * 1000 );
    $it++;
    $list_it++;
    if ( $list_it > $#CIDlist ) { $list_it = 0; $list_inc++; }
    $server_it++;
    if ( $server_it > $#server_ips ) { $server_it = 0; }
}
exit;

sub get_time_now #get the current date and time and epoch for logging call lengths and datetimes
{
    $secX = time();
    $secX = time();
    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    $year = ( $year + 1900 );
    $mon++;
    if ( $mon < 10 )  { $mon   = "0$mon"; }
    if ( $mday < 10 ) { $mday  = "0$mday"; }
    if ( $hour < 10 ) { $Fhour = "0$hour"; }
    if ( $min < 10 )  { $min   = "0$min"; }
    if ( $sec < 10 )  { $sec   = "0$sec"; }
    $now_date_epoch = time();
    $now_date       = "$year-$mon-$mday $hour:$min:$sec";
    $file_date      = "$year-$mon-$mday_$hour$min$sec";
    $CIDdate        = "$mon$mday$hour$min$sec";
    $tsSQLdate      = "$year$mon$mday$hour$min$sec";
    $SQLdate        = "$year-$mon-$mday $hour:$min:$sec";
}

sub event_logger {
    open( Lout, ">>$SWAMPLOGfile" )
      || die "Can't open $SWAMPLOGfile: $!\n";
    print Lout "$now_date|$event_string|\n";
    close(Lout);
    $event_string = '';
}
