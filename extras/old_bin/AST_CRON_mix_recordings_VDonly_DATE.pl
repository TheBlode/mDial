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
$VARFTP_host = '10.0.0.4';
$VARFTP_user = 'cron';
$VARFTP_pass = 'test';
$VARFTP_port = '21';
$VARFTP_dir  = 'RECORDINGS';
$VARHTTP_path = 'http://10.0.0.4';
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
    if ( ($line =~ /PATHDONEmonitor/) && ($CLIDONEmonitor < 1) )
        {$PATHDONEmonitor = $line;   $PATHDONEmonitor =~ s/.*=//gi;}
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
    if ( ($line =~ /^VARFTP_host/) && ($CLIFTP_host < 1) )
        {$VARFTP_host = $line;   $VARFTP_host =~ s/.*=//gi;}
    if ( ($line =~ /^VARFTP_user/) && ($CLIFTP_user < 1) )
        {$VARFTP_user = $line;   $VARFTP_user =~ s/.*=//gi;}
    if ( ($line =~ /^VARFTP_pass/) && ($CLIFTP_pass < 1) )
        {$VARFTP_pass = $line;   $VARFTP_pass =~ s/.*=//gi;}
    if ( ($line =~ /^VARFTP_port/) && ($CLIFTP_port < 1) )
        {$VARFTP_port = $line;   $VARFTP_port =~ s/.*=//gi;}
    if ( ($line =~ /^VARFTP_dir/) && ($CLIFTP_dir < 1) )
        {$VARFTP_dir = $line;   $VARFTP_dir =~ s/.*=//gi;}
    if ( ($line =~ /^VARHTTP_path/) && ($CLIHTTP_path < 1) )
        {$VARHTTP_path = $line;   $VARHTTP_path =~ s/.*=//gi;}
    $i++;
    }
$server_ip = $VARserver_ip;        # Asterisk server IP
if (!$VARDB_port) {$VARDB_port='3306';}
use DBI;      
$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;
$dir1 = "$PATHmonitor";
$dir2 = "$PATHDONEmonitor";
use Net::Ping;
use Net::FTP;
 opendir(FILE, "$dir1/");
 @FILES = readdir(FILE);
$i=0;
foreach(@FILES)
   {
    $size1 = 0;
    $size2 = 0;
    if ( (length($FILES[$i]) > 4) && (!-d $FILES[$i]) )
        {
        $size1 = (-s "$dir1/$FILES[$i]");
        if ($v) {print "$FILES[$i] $size1\n";}
        sleep(1);
        $size2 = (-s "$dir1/$FILES[$i]");
        if ($v) {print "$FILES[$i] $size2\n\n";}
        if ( ($FILES[$i] !~ /out\.wav|out\.gsm/i) && ($size1 eq $size2) && (length($FILES[$i]) > 4))
            {
            $INfile = $FILES[$i];
            $OUTfile = $FILES[$i];
            $OUTfile =~ s/-in\.wav/-out.wav/gi;
            $OUTfile =~ s/-in\.gsm/-out.gsm/gi;
            $ALLfile = $FILES[$i];
            $ALLfile =~ s/-in\.wav/-all.wav/gi;
            $ALLfile =~ s/-in\.gsm/-all.gsm/gi;
            $SQLFILE = $FILES[$i];
            $SQLFILE =~ s/-in\.wav|-in\.gsm//gi;
            $stmtA = "select recording_id,start_time from recording_log where filename='$SQLFILE' order by recording_id desc LIMIT 1;";
            if($DBX){print STDERR "\n|$stmtA|\n";}
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
            $sthArows=$sthA->rows;
            $rec_count=0;
            while ($sthArows > $rec_count)
                {
                @aryA = $sthA->fetchrow_array;
                $recording_id =    "$aryA[0]";
                $start_date =    "$aryA[1]";
                $start_date =~ s/ .*//gi;
                $rec_count++;
                }
            $sthA->finish();
        if ($v) {print "|$INfile|     |$ALLfile|     |$recording_id|$start_date|\n";}
            $p = Net::Ping->new();
            $ping_good = $p->ping("$VARFTP_host");
            if ($ping_good)
                {
                $ftp = Net::FTP->new("$VARFTP_host", Port => $VARFTP_port);
                $ftp->login("$VARFTP_user","$VARFTP_pass");
                $ftp->cwd("$VARFTP_dir");
                $ftp->mkdir("$start_date");
                $ftp->cwd("$start_date");
                $ftp->binary();
                $ftp->put("$dir1/$INfile", "$ALLfile");
                $ftp->quit;
                $stmtA = "UPDATE recording_log set location='$VARHTTP_path/$start_date/$ALLfile' where recording_id='$recording_id';";
                    if($DB){print STDERR "\n|$stmtA|\n";}
                $affected_rows = $dbhA->do($stmtA); #  or die  "Couldn't execute query:|$stmtA|\n";
                if (!$T)
                    {
                    `mv -f "$dir1/$INfile" "$dir2/ORIG/$INfile"`;
                    `mv -f "$dir1/$OUTfile" "$dir2/ORIG/$OUTfile"`;
                    }
                }
            }
        }
    $i++;
    }
if ($v) {print "DONE... EXITING\n\n";}
$dbhA->disconnect();
exit;
