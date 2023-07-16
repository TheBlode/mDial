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
$VARFTP_dir  = 'RECORDINGS';
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
$dir1 = "$PATHmonitor";
$dir2 = "$PATHDONEmonitor";
$soxmixbin = '';
if ( -e ('/usr/bin/soxmix')) {$soxmixbin = '/usr/bin/soxmix';}
else 
    {
    if ( -e ('/usr/local/bin/soxmix')) {$soxmixbin = '/usr/local/bin/soxmix';}
    else
        {
        print "Can't find soxmix binary! Exiting...\n";
        exit;
        }
    }
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
        if ($v) {print "|$INfile|    |$OUTfile|     |$ALLfile|\n\n";}
            $p = Net::Ping->new();
            $ping_good = $p->ping("$VARFTP_host");
            if ($ping_good)
                {
                    `$soxmixbin "$dir1/$INfile" "$dir1/$OUTfile" "$dir2/$ALLfile"`;
                if ($v) {print "|$INfile|    |$OUTfile|     |$ALLfile|\n\n";}
                    if (!$T)
                        {
                        `mv -f "$dir1/$INfile" "$dir2/ORIG/$INfile"`;
                        `mv -f "$dir1/$OUTfile" "$dir2/ORIG/$OUTfile"`;
                        }
                $ftp = Net::FTP->new("$VARFTP_host", Port => 21);
                $ftp->login("$VARFTP_user","$VARFTP_pass");
                $ftp->cwd("$VARFTP_dir");
                $ftp->binary();
                $ftp->put("$dir2/$ALLfile", "$ALLfile");
                $ftp->quit;
                }
            }
        }
    $i++;
    }
if ($v) {print "DONE... EXITING\n\n";}
exit;
