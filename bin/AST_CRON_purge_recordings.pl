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
$save_statuses =
  '|SALE|UPSALE|UPSELL|XFER|DNC|DROP|A1|A2|A3|A4|A5|A6|A7|A8|A9|';
$suffix        = '-all.wav';
$local_DIR     = '/home2/cron/RECORDINGS';
$use_date_DIRs = 1;
$FTP_host      = '10.0.0.4';
$FTP_user      = 'cron';
$FTP_pass      = 'test';
$FTP_dir       = 'RECORDINGS';
$HTTP_path     = 'http://10.0.0.4';
$secX          = time();
$TDtarget      = ( $secX - 2592000 );        # thirty days
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
$FDtarget  = ( $secX - 3456000 );                        # forty-five days
( $Fsec, $Fmin, $Fhour, $Fmday, $Fmon, $Fyear, $Fwday, $Fyday, $Fisdst ) =
  localtime($FDtarget);
$Fyear = ( $Fyear + 1900 );
$Fmon++;
if ( $Fmon < 10 )  { $Fmon  = "0$Fmon"; }
if ( $Fmday < 10 ) { $Fmday = "0$Fmday"; }
if ( $Fhour < 10 ) { $Fhour = "0$Fhour"; }
if ( $Fmin < 10 )  { $Fmin  = "0$Fmin"; }
if ( $Fsec < 10 )  { $Fsec  = "0$Fsec"; }
$FDSQLdate = "$Fyear-$Fmon-$Fmday $Fhour:$Fmin:$Fsec";
$PATHconf  = '/etc/astguiclient.conf';
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
$dir1 = "$PATHmonitor";
$stmtA =
"SELECT lead_id,recording_id,start_time,filename,location FROM recording_log where start_time < '$TDSQLdate' and start_time > '$FDSQLdate' and location IS NOT NULL and location NOT IN('','NOT_FOUND','NOT_FOUND_2','DELETED') LIMIT 5000;";
print "$stmtA\n";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
$sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
$sthArows = $sthA->rows;
$i        = 0;

while ( $sthArows > $i ) {
    @aryA              = $sthA->fetchrow_array;
    $lead_ids[$i]      = "$aryA[0]";
    $recording_ids[$i] = "$aryA[1]";
    $start_times[$i]   = "$aryA[2]";
    $filenames[$i]     = "$aryA[3]";
    $locations[$i]     = "$aryA[4]";
    $i++;
}
$sthA->finish();
$i = 0;
foreach (@lead_ids) {
    $stmtA = "SELECT status FROM vicidial_list where lead_id='$lead_ids[$i]';";
    $sthA  = $dbhA->prepare($stmtA) or die "preparing: ", $dbhA->errstr;
    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
    $sthArows = $sthA->rows;
    $h        = 0;
    while ( $sthArows > $h ) {
        @aryA = $sthA->fetchrow_array;
        $statuses[$i] = "$aryA[0]";
        $h++;
    }
    $sthA->finish();
    $i++;
}
$i      = 0;
$KEEP   = 0;
$DELETE = 0;
foreach (@lead_ids) {
    if (   ( $save_statuses !~ /\|$statuses[$i]\|/ )
        && ( length( $statuses[$i] ) > 0 ) )
    {
        if ($use_date_DIRs) {
            $date_DIR = $start_times[$i];
            $date_DIR =~ s/ .*//gi;
            $date_DIR .= "/";
        }
        else { $date_DIR = '' }
        `rm -f $local_DIR/$date_DIR$filenames[$i]$suffix`;
        print
"rm -f $local_DIR/$date_DIR$filenames[$i]$suffix    |$statuses[$i]|$lead_ids[$i]|\n";
        $stmtA =
"UPDATE recording_log set location='DELETED' where recording_id='$recording_ids[$i]';";
        $affected_rows =
          $dbhA->do($stmtA);    #  or die  "Couldn't execute query:|$stmtA|\n";
        $DELETE++;
    }
    else {
        print "KEEP- $filenames[$i]$suffix     |$statuses[$i]|$lead_ids[$i]|\n";
        $KEEP++;
    }
    $i++;
}
print "KEEP:      $KEEP\n";
print "DELETED:   $DELETE\n";
print "--------------------\n";
print "TOTAL:     $i\n";
if ($v) { print "DONE... EXITING\n\n"; }
$dbhA->disconnect();
exit;
