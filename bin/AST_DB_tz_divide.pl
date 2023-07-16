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
if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--help/i ) {
        print
"allowed run time options:\n  [-t] = test\n  [-debug] = verbose debug messages\n\n";
    }
    else {
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
    $loop_delay = '2500';
    $DB         = 1;
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
( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
  localtime(time);
if ($isdst) {
    $TZmove = "'-6.00','-7.00','-8.00','-9.00','-10.00'";
    $TZback = "'-4.00','-5.00'";
}
else {
    $TZmove = "'-7.00','-8.00','-9.00','-10.00','-11.00'";
    $TZback = "'-5.00','-6.00'";
}
$stmtA =
"UPDATE vicidial_list set list_id='222' where list_id='111' and gmt_offset_now IN($TZmove);";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
if ( !$T ) {
    $affected_rows = $dbhA->do($stmtA);
    if ($DB) { print STDERR "\n|$affected_rows records changed|\n"; }
}
$stmtA =
"UPDATE vicidial_list set list_id='12021' where list_id='11315' and gmt_offset_now IN($TZmove);";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
if ( !$T ) {
    $affected_rows = $dbhA->do($stmtA);
    if ($DB) { print STDERR "\n|$affected_rows records changed|\n"; }
}
$stmtA =
"UPDATE vicidial_list set list_id='4444' where list_id='3333' and gmt_offset_now IN($TZmove);";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
if ( !$T ) {
    $affected_rows = $dbhA->do($stmtA);
    if ($DB) { print STDERR "\n|$affected_rows records changed|\n"; }
}
$stmtA =
"UPDATE vicidial_list set list_id='111' where list_id='222' and gmt_offset_now IN($TZback);";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
if ( !$T ) {
    $affected_rows = $dbhA->do($stmtA);
    if ($DB) { print STDERR "\n|$affected_rows records changed|\n"; }
}
$stmtA =
"UPDATE vicidial_list set list_id='11315' where list_id='12021' and gmt_offset_now IN($TZback);";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
if ( !$T ) {
    $affected_rows = $dbhA->do($stmtA);
    if ($DB) { print STDERR "\n|$affected_rows records changed|\n"; }
}
$stmtA =
"UPDATE vicidial_list set list_id='3333' where list_id='4444' and gmt_offset_now IN($TZback);";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
if ( !$T ) {
    $affected_rows = $dbhA->do($stmtA);
    if ($DB) { print STDERR "\n|$affected_rows records changed|\n"; }
}
$secX     = time();
$XDtarget = ( $secX - 2678400 );
( $Xsec, $Xmin, $Xhour, $Xmday, $Xmon, $Xyear, $Xwday, $Xyday, $Xisdst ) =
  localtime($XDtarget);
$Xyear = ( $Xyear + 1900 );
$Xmon++;
if ( $Xmon < 10 )  { $Xmon  = "0$Xmon"; }
if ( $Xmday < 10 ) { $Xmday = "0$Xmday"; }
if ( $Xhour < 10 ) { $Xhour = "0$Xhour"; }
if ( $Xmin < 10 )  { $Xmin  = "0$Xmin"; }
if ( $Xsec < 10 )  { $Xsec  = "0$Xsec"; }
$XDSQLdate = "$Xyear-$Xmon-$Xmday $Xhour:$Xmin:$Xsec";
$TDtarget  = ( $secX - 5356800 );
( $Tsec, $Tmin, $Thour, $Tmday, $Tmon, $Tyear, $Twday, $Tyday, $Tisdst ) =
  localtime($TDtarget);
$Tyear = ( $Tyear + 1900 );
$Tmon++;
if ( $Tmon < 10 )  { $Tmon  = "0$Tmon"; }
if ( $Tmday < 10 ) { $Tmday = "0$Tmday"; }
if ( $Thour < 10 ) { $Thour = "0$Thour"; }
if ( $Tmin < 10 )  { $Tmin  = "0$Tmin"; }
if ( $Tsec < 10 )  { $Tsec  = "0$Tsec"; }
$TDSQLdate = "$Tyear-$Tmon-$Tmday $Thour:$Tmin:$Tsec";
$stmtA =
"UPDATE vicidial_list set list_id='999999' where list_id IN('11315','12021','111','222','3333','4444') and entry_date < \"$XDSQLdate\";";
if ($DB) { print STDERR "\n|$stmtA|\n"; }

if ( !$T ) {
    $affected_rows = $dbhA->do($stmtA);
    if ($DB) { print STDERR "\n|$affected_rows records changed|\n"; }
}
$stmtA =
"DELETE from vicidial_list WHERE list_id='999999' and entry_date < \"$TDSQLdate\" and status NOT IN('SALE','UPSELL','UPSALE','A1','A2','A3','A4');";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
if ( !$T ) {
    $affected_rows = $dbhA->do($stmtA);
    if ($DB) { print STDERR "\n|$affected_rows records changed|\n"; }
}
$dbhA->disconnect();
exit;
