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
$stmtA = "UPDATE conferences set extension='' where server_ip='$server_ip';";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
$affected_rows =
  $dbhA->do($stmtA);           #  or die  "Couldn't execute query: |$stmtA|\n";
print " - conferences reset\n";
$stmtA =
  "UPDATE vicidial_conferences set extension='' where server_ip='$server_ip';";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
$affected_rows =
  $dbhA->do($stmtA);           #  or die  "Couldn't execute query: |$stmtA|\n";
print " - vicidial_conferences reset\n";
$stmtA = "DELETE from vicidial_manager where server_ip='$server_ip';";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
$affected_rows =
  $dbhA->do($stmtA);           #  or die  "Couldn't execute query: |$stmtA|\n";
print " - vicidial_manager delete\n";
$stmtA = "DELETE from vicidial_auto_calls where server_ip='$server_ip';";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
$affected_rows =
  $dbhA->do($stmtA);           #  or die  "Couldn't execute query: |$stmtA|\n";
print " - vicidial_auto_calls delete\n";
$stmtA = "DELETE from vicidial_live_agents where server_ip='$server_ip';";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
$affected_rows =
  $dbhA->do($stmtA);           #  or die  "Couldn't execute query: |$stmtA|\n";
print " - vicidial_live_agents delete\n";
$stmtA = "DELETE from vicidial_users where full_name='5555';";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
$affected_rows =
  $dbhA->do($stmtA);           #  or die  "Couldn't execute query: |$stmtA|\n";
print " - vicidial__users delete\n";
$stmtA =
  "DELETE from vicidial_campaign_server_stats where server_ip='$server_ip';";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
$affected_rows =
  $dbhA->do($stmtA);           #  or die  "Couldn't execute query: |$stmtA|\n";
print " - vicidial_campaign_server_stats delete\n";
$stmtA = "DELETE from vicidial_hopper where user LIKE \"%_$server_ip\";";
if ($DB) { print STDERR "\n|$stmtA|\n"; }
$affected_rows =
  $dbhA->do($stmtA);           #  or die  "Couldn't execute query: |$stmtA|\n";
print " - vicidial_hopper delete\n";
$dbhA->disconnect();
exit;
