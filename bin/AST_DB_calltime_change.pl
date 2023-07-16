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
$calltime = '';
$DB       = 0;
$Q        = 0;
$startSQL = '';
$stopSQL  = '';
$secX     = time();
$time     = $secX;
( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
  localtime(time);
$year = ( $year + 1900 );
$mon++;
if ( $mon < 10 )  { $mon  = "0$mon"; }
if ( $mday < 10 ) { $mday = "0$mday"; }
if ( $hour < 10 ) { $hour = "0$hour"; }
if ( $min < 10 )  { $min  = "0$min"; }
if ( $sec < 10 )  { $sec  = "0$sec"; }
$timestamp = "$year-$mon-$mday $hour:$min:$sec";

if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--help/i ) {
        print "allowed run time options:\n";
        print "  [--calltime=XXX] = define the calltime entry to change\n";
        print
"  [--default-start=XXXX] = the default start time to change, 4 digits\n";
        print
"  [--default-stop=XXXX] = the default stop time to change, 4 digits\n";
        print "  [-t] = test\n";
        print "  [-q] = quiet\n";
        print "  [-debug] = verbose debug messages\n\n";
    }
    else {
        if ( $args =~ /-debug/i ) {
            $DB = 1;    # Debug flag, set to 0 for no debug messages
        }
        if ( $args =~ /-t/i ) {
            $TEST = 1;
            $T    = 1;
        }
        if ( $args =~ /-q/i ) {
            $Q = 1;
        }
        if ( $args =~ /--calltime=/i ) {
            @data_in  = split( /--calltime=/, $args );
            $calltime = $data_in[1];
            $calltime =~ s/ .*//gi;
            if ( $Q < 1 ) { print "\n----- CALLTIME: $calltime -----\n\n"; }
        }
        if ( $args =~ /--default-start=/i ) {
            @data_in = split( /--default-start=/, $args );
            $start   = $data_in[1];
            $start =~ s/ .*//gi;
            $start =~ s/\D//gi;
            $startSQL = ",ct_default_start='$start'";
            if ( $Q < 1 ) { print "\n----- START: $start -----\n\n"; }
        }
        if ( $args =~ /--default-stop=/i ) {
            @data_in = split( /--default-stop=/, $args );
            $stop    = $data_in[1];
            $stop =~ s/ .*//gi;
            $stop =~ s/\D//gi;
            $stopSQL = ",ct_default_stop='$stop'";
            if ( $Q < 1 ) { print "\n----- STOP: $stop -----\n\n"; }
        }
    }
}
else {
    print "no command line options set\n";
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
$server_ip = $VARserver_ip;    # Asterisk server IP
if ( !$VARDB_port ) { $VARDB_port = '3306'; }
use DBI;
$dbhA = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$stmtA =
"UPDATE vicidial_call_times set call_time_comments='auto-modified $timestamp' $startSQL $stopSQL where call_time_id='$calltime';";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
if ( ( !$T ) && ( length($calltime) > 0 ) ) {
    $affected_rows = $dbhA->do($stmtA);
    if ($DB) { print STDERR "\n|$affected_rows records changed|\n"; }
    $SQL_log = "$stmtA|";
    $SQL_log =~ s/;|\\|\'|\"//gi;
    $stmtA =
"INSERT INTO vicidial_admin_log set event_date='$timestamp', user='VDAD', ip_address='1.1.1.1', event_section='CALLTIMES', event_type='MODIFY', record_id='$calltime', event_code='ADMIN AUTO MODIFY CALL TIME', event_sql=\"$SQL_log\", event_notes='$affected_rows updated records';";
    $Iaffected_rows = $dbhA->do($stmtA);
}
$dbhA->disconnect();
exit;
