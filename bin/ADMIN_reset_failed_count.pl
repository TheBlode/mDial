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
$T=0;
$DB=1;
$DBX=0;
use DBI;
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
        print "Reset a given users failed count so they can attempt to log in.\n";
        print "\n";
        print "allowed run time options:\n";
        print "  [--user=XXX] = the user to reset failed count for\n";
        print "  [--test] = testing mode only, no database updates\n";
        print "  [--debug] = enable debugging output\n";
        print "  [--debugX] = enable extra debugging output\n";
        print "  [--help] = this help screen\n";
        print "\n";
        exit;
        }
    else
        {
        if ($args =~ /--debug/i)
            {
            $DB=1;
            if ($DB > 0) {print "\n----- DEBUGGING OUTPUT ENABLED: $DB -----\n";}
            }
        if ($args =~ /--debugX/i)
            {
            $DBX=1;
            $DB=1;
            if ($DB > 0) {print "\n----- EXTRA DEBUGGING OUTPUT ENABLED: $DBX -----\n";}
            }
        if ($args =~ /--test/i)
            {
            $T=1;
            if ($DB > 0) {print "\n----- TESTING MODE ENABLED: $T -----\n";}
            }
        if ($args =~ /--user=/i)
            {
            @data_in = split(/--user=/,$args);
            $CLIuser = $data_in[1];
            $CLIuser =~ s/ .*//gi;
            }
        }
    }
else
    {
    print "NO INPUT, NOTHING TO DO, EXITING...\n";
    exit;
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
if (!$VARDB_port) {$VARDB_port='3306';}
$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;
$affected_rows=0;
$stmtA = "UPDATE vicidial_users set failed_login_count=0 where user='$CLIuser';";
if ($T < 1)
    {
    $affected_rows = $dbhA->do($stmtA) or die  "Couldn't execute query:|$stmtA|\n";
    }
if ($DB > 0) {print "Failed Login Count for user $CLIuser has been reset: |$affected_rows|\n";}
if ($DBX > 0) {print "SQL:   |$stmtA|\n";}
$i++;
exit;
