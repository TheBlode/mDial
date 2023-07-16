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
$build = '131022-1659';
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
$secX = time();
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($secX);
$mon++;
$year = ($year + 1900);
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
if ($hour < 10) {$hour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
$launch_date = "$year$mon$mday$hour$min$sec";
$force_logging=0;
if (length($ARGV[0])>1)
    {
    $i=0;
    $allow_inactive_list_leads=0;
        while ($#ARGV >= $i)
        {
        $args = "$args $ARGV[$i]";
        $i++;
        }
    if ($args =~ /--help/i)
        {
        print "allowed run time options(must stay in this order):\n";
        print "  [--help] = this screen\n";
        print "  [--version] = print version of this script, then exit\n";
        print "  [--force-logging] = forces extra logging of asterisk even if disabled in settings\n";
        print "\n";
        exit;
        }
    else
        {
        if ($args =~ /--version/i)
            {
            print "version: $build\n";
            exit;
            }
        if ($args =~ /--force-logging/i)
            {
            $force_logging=1;
            print "extra logging forced: $force_logging\n";
            }
        }
    }
else
    {
    }
`PERL5LIB="$PATHhome/libs"; export PERL5LIB`;
use DBI;      
$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;
$stmtA = "SELECT vd_server_logs FROM servers where server_ip = '$VARserver_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
if ($sthArows > 0)
    {
    @aryA = $sthA->fetchrow_array;
    $DBvd_server_logs =            $aryA[0];
    if ($DBvd_server_logs =~ /Y/)    {$SYSLOG = '1';}
    else {$SYSLOG = '0';}
    }
$sthA->finish();
`ulimit -n 65536`;
if ( ($SYSLOG) || ($force_logging > 0) )
    {
    `/usr/bin/screen -d -m -S astershell$launch_date /usr/bin/screen -S astshell$launch_date`;
    print "started screen\n";
    sleep(1);
    `screen -XS astshell$launch_date eval 'stuff "cd /var/log/astguiclient\015"'`;
    print "changed directory\n";
    sleep(1);
    `screen -XS astshell$launch_date eval 'stuff "screen -L -S asterisk\015"'`;
    print "started new screen session\n";
    sleep(1);
    `screen -d astshell$launch_date`;
    `screen -d asterisk`;
    print "detached screens\n";
    sleep(1);
    `screen -XS asterisk eval 'stuff "ulimit -n 65536\015"'`;
    print "raised ulimit open files\n";
    sleep(1);
    `screen -XS asterisk eval 'stuff "/usr/sbin/asterisk -vvvvvvvvvvvvvvvvvvvvvgcT\015"'`;
    print "Asterisk started... screen logging on\n";
    }
else
    {
    `/usr/bin/screen -d -m -S astershell$launch_date /usr/bin/screen -S asterisk`;
    print "started screen\n";
    sleep(1);
    `screen -d asterisk`;
    print "detached screen\n";
    sleep(1);
    `screen -XS asterisk eval 'stuff "ulimit -n 65536\015"'`;
    print "raised ulimit open files\n";
    sleep(1);
    `screen -XS asterisk eval 'stuff "/usr/sbin/asterisk -vvvvgcT\015"'`;
    print "Asterisk started... screen logging off\n";
    }
$stmtA = "UPDATE servers SET rebuild_conf_files='Y' where server_ip = '$VARserver_ip';";
$affected_rows = $dbhA->do($stmtA);
exit;
