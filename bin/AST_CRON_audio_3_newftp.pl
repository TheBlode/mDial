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
use 5.008;
use strict;
use warnings;
use DBI;
use Net::Ping;
use Net::FTP;
use Time::HiRes ('gettimeofday','usleep','sleep');  # necessary to have perl sleep command for less than one second
my $debug = 0;
my $debugX = 0;
my $test = 0;
my $run_check = 0;
my $pingtype    = "tcp";
my $pingtimeout = 5;
my $datedir        = 1;
my $camp_check    = 0;
my $campaigns    = "";
my @camp_array;
my $ingrp_check    = 0;
my $ingroups    = "";
my @ingrp_array;
my $list_limit    = 1000;
my $trans_limit    = 1000;
my $trans_type    = "wav";
my $PATHhome = '';
my $PATHlogs = '';
my $PATHagi = '';
my $PATHweb = '';
my $PATHsounds = '';
my $PATHmonitor = '';
my $PATHDONEmonitor = '';
my $VARserver_ip = '';
my $VARDB_server = '';
my $VARDB_database = '';
my $VARDB_user = '';
my $VARDB_pass = '';
my $VARDB_port = '';
my $ftp_host = '10.0.0.4';
my $ftp_user = 'cron';
my $ftp_pass = 'test';
my $ftp_port = '21';
my $ftp_dir  = 'RECORDINGS';
my $url_path = 'http://10.0.0.4';
my $PATHconf =        '/etc/astguiclient.conf';
open(CONF, "$PATHconf") || die "can't open $PATHconf: $!\n";
my @conf = <CONF>;
close(CONF);
my $i=0;
my $line='';
foreach(@conf) {
    $line = $conf[$i];
    $line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
    if ($line =~ /^PATHhome/)
        {$PATHhome = $line;   $PATHhome =~ s/.*=//gi;}
    if ($line =~ /^PATHlogs/)
        {$PATHlogs = $line;   $PATHlogs =~ s/.*=//gi;}
    if ($line =~ /^PATHagi/)
        {$PATHagi = $line;   $PATHagi =~ s/.*=//gi;}
    if ($line =~ /^PATHweb/)
        {$PATHweb = $line;   $PATHweb =~ s/.*=//gi;}
    if ($line =~ /^PATHsounds/)
        {$PATHsounds = $line;   $PATHsounds =~ s/.*=//gi;}
    if ($line =~ /^PATHmonitor/)
        {$PATHmonitor = $line;   $PATHmonitor =~ s/.*=//gi;}
    if ($line =~ /^PATHDONEmonitor/)
        {$PATHDONEmonitor = $line;   $PATHDONEmonitor =~ s/.*=//gi;}
    if ($line =~ /^VARserver_ip/)
        {$VARserver_ip = $line;   $VARserver_ip =~ s/.*=//gi;}
    if ($line =~ /^VARDB_server/)
        {$VARDB_server = $line;   $VARDB_server =~ s/.*=//gi;}
    if ($line =~ /^VARDB_database/)
        {$VARDB_database = $line;   $VARDB_database =~ s/.*=//gi;}
    if ($line =~ /^VARDB_user/)
        {$VARDB_user = $line;   $VARDB_user =~ s/.*=//gi;}
    if ($line =~ /^VARDB_pass/)
        {$VARDB_pass = $line;   $VARDB_pass =~ s/.*=//gi;}
    if ($line =~ /^VARDB_port/)
        {$VARDB_port = $line;   $VARDB_port =~ s/.*=//gi;}
    if ($line =~ /^VARFTP_host/)
        {$ftp_host = $line;   $ftp_host =~ s/.*=//gi;}
    if ($line =~ /^VARFTP_user/)
        {$ftp_user = $line;   $ftp_user =~ s/.*=//gi;}
    if ($line =~ /^VARFTP_pass/)
        {$ftp_pass = $line;   $ftp_pass =~ s/.*=//gi;}
    if ($line =~ /^VARFTP_port/)
        {$ftp_port = $line;   $ftp_port =~ s/.*=//gi;}
    if ($line =~ /^VARFTP_dir/)
        {$ftp_dir = $line;   $ftp_dir =~ s/.*=//gi;}
    if ($line =~ /^VARHTTP_path/)
        {$url_path = $line;   $url_path =~ s/.*=//gi;}
    $i++;
}
my $args = '';
if (length($ARGV[0])>1) {
    $i=0;
    while ($#ARGV >= $i) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ($args =~ /--help/i)    {
        print "allowed run time options:\n";
        print "  [--help]               = this screen\n";
        print "  [--test]               = don't move the file\n";
        print "  [--debug]              = debug\n";
        print "  [--debugX]             = super debug\n";
        print "  [--gsm or --GSM]       = copy GSM 6.10 files\n";
        print "  [--mp3 or --MP3]       = copy MPEG Layer3 files\n";
        print "  [--ogg or --OGG]       = copy OGG Vorbis files\n";
        print "  [--wav or --WAV]       = copy WAV files\n";
        print "  [--gsw or --GSW]       = copy GSM 6.10 codec with RIFF headers (.wav extension)\n";
        print "  [--gpg or --GPG]        = copy GPG encrypted files\n";
        print "  [--ping-type]          = The type of ping to send. Options are \"none\", \"tcp\", \"udp\", \"icmp\", \n";
        print "                         \"stream\", \"syn\", and \"external\". None disables pinging. Default is \"icmp\"\n";
        print "                         WARNING setting --ping-type=\"none\" can lead to files being \"transfer\"\n";
        print "                         to no where if your ftp server goes down.\n";
        print "  [--ping-timeout]       = How long to wait for the ping to timeout before giving up, default is 5 seconds.\n";
        print "  [--ftp-host]           = the host address to ftp into\n";
        print "  [--ftp-port]           = the port of the ftp server \n";
        print "  [--ftp-user]           = the user to log into the ftp server with\n";
        print "  [--ftp-pass]           = the password to log into the ftp server with\n";
        print "  [--ftp-dir]            = the directory to put the files into on the ftp server\n";
        print "  [--url-path]           = the url where the recordings can be accessed after the move\n";
        print "  [--transfer-limit=XXX] = the number of files to transfer before giving up. Default is 1000\n";
        print "  [--list-limit=XXX]     = number of files to list in the directory before moving on\n";
        print "  [--no-date-dir]        = does not put the files in a dated directory.\n";
        print "  [--run-check]          = concurrency check, die if another instance is running\n";
        print "  [--campaign_id]        = which OUTBOUND campaigns to transfer files for in a '-' delimited list \n";
        print "                         (this only works for outbound calls, not inbound or transfers)\n"; 
        print "  [--ingroup_id]         = which ingroups to transfer files for in a '-' delimited list\n";
        print "                         WARNING you can only set --campaign_id or --ingroup_id, not both.\n";
        print "\n";
        exit;
    } else {
        if ($args =~ /--debug/i) {
            $debug=1;
            print "\n----- DEBUG -----\n\n";
        }
        if ($args =~ /--debugX/i) {
            $debugX=1;
            $debug=1;
            print "\n----- SUPER DEBUG -----\n\n";
        }
        if ($args =~ /--test/i) {
            $test=1;
            print "\n----- TESTING -----\n\n";
        }
        if (($args =~ /--nodatedir/i) || ($args =~ /--no-date-dir/i)) {
            $datedir=0;
            if ($debug) {
                print "\n----- NO DATE DIRECTORIES -----\n\n";
            }
        }
        if ($args =~ /--run-check/i)
            {
            $run_check=1;
            if ($debug) {print "\n----- CONCURRENCY CHECK -----\n\n";}
            }
        if ($args =~ /--ping-type=/i) {
            my @data_in = split(/--ping-type=/,$args);
            $pingtype = $data_in[1];
            $pingtype =~ s/ .*//gi;
            if ($debug) {
                print "\n----- FILE TRANSFER LIMIT: $trans_limit -----\n\n";
            }
        }
        if ($args =~ /--ping-timeout=/i) {
            my @data_in = split(/--ping-timeout=/,$args);
            $pingtimeout = $data_in[1];
            $pingtimeout =~ s/ .*//gi;
            if ($debug) {
                print "\n----- PING TIMEOUT: $pingtimeout -----\n\n";
            }
        }
        if ($args =~ /--ftp-host=/i) {
            my @data_in = split(/--ftp-host=/,$args);
            $ftp_host = $data_in[1];
            $ftp_host =~ s/ .*//gi;
            if ($debug) {
                print "\n----- FTP HOST: $ftp_host -----\n\n";
            }
        }
        if ($args =~ /--ftp-port=/i) {
            my @data_in = split(/--ftp-port=/,$args);
            $ftp_port = $data_in[1];
            $ftp_port =~ s/ .*//gi;
            if ($debug) {
                print "\n----- FTP PORT: $ftp_port -----\n\n";
            }
        }
        if ($args =~ /--ftp-user=/i) {
            my @data_in = split(/--ftp-user=/,$args);
            $ftp_user = $data_in[1];
            $ftp_user =~ s/ .*//gi;
            if ($debug) {
                print "\n----- FTP USER: $ftp_user -----\n\n";
            }
        }
        if ($args =~ /--ftp-pass=/i) {
            my @data_in = split(/--ftp-pass=/,$args);
            $ftp_pass = $data_in[1];
            $ftp_pass =~ s/ .*//gi;
            if ($debug) {
                print "\n----- FTP PASSWORD: $ftp_pass -----\n\n";
            }
        }
        if ($args =~ /--ftp-dir=/i) {
            my @data_in = split(/--ftp-dir=/,$args);
            $ftp_dir = $data_in[1];
            $ftp_dir =~ s/ .*//gi;
            if ($debug) {
                print "\n----- FTP DIRECTORY: $ftp_dir -----\n\n";
            }
        }
        if ($args =~ /--url-path=/i) {
            my @data_in = split(/--url-path=/,$args);
            $url_path = $data_in[1];
            $url_path =~ s/ .*//gi;
            if ($debug) {
                print "\n----- URL PATH: $url_path -----\n\n";
            }
        }
        if ($args =~ /--campaign_id=/i) {
            my @data_in = split(/--campaign_id=/,$args);
            $campaigns = $data_in[1];
            $campaigns =~ s/ .*//gi;
            $campaigns = uc($campaigns);
            $camp_check=1;
            if ($debug) {
                print "\n----- CAMPAIGNS: $campaigns -----\n\n";
            }
        }
        if ($args =~ /--ingroup_id=/i) {
            my @data_in = split(/--ingroup_id=/,$args);
            $ingroups = $data_in[1];
            $ingroups =~ s/ .*//gi;
            $ingrp_check=1;
            if ($debug) {
                print "\n----- INGROUPS: $ingroups -----\n\n";
            }
        }
        if ($args =~ /--transfer-limit=/i) {
            my @data_in = split(/--transfer-limit=/,$args);
            $trans_limit = $data_in[1];
            $trans_limit =~ s/ .*//gi;
            if ($debug) {
                print "\n----- FILE TRANSFER LIMIT: $trans_limit -----\n\n";
            }
        }
        if ($args =~ /--list-limit=/i) {
            my @data_in = split(/--list-limit=/,$args);
            $list_limit = $data_in[1];
            $list_limit =~ s/ .*//gi;
            if ($debug) {
                print "\n----- FILE LIST LIMIT: $list_limit -----\n\n";
            }
        }
        if ( ( $args =~ /--GSM/i ) || ( $args =~ /--gsm/i ) ){
            $trans_type="gsm";
            if ($debug) {
                print "GSM audio files\n";
            }
        } else {
            if ( ($args =~ /--MP3/i) || ($args =~ /--mp3/i) ) {
                $trans_type="mp3";
                if ($debug) {
                    print "MP3 audio files\n";
                }
            } else {
                if ( ( $args =~ /--OGG/i) || ($args =~ /--ogg/i) ) {
                    $trans_type="ogg";
                    if ($debug) {
                        print "OGG audio files\n";
                    }
                } else {
                    if ( ( $args =~ /--WAV/i ) || ( $args =~ /--wav/i ) ) {
                        $trans_type="wav";
                        if ($debug) {
                            print "WAV audio files\n";
                        }
                    } else {
                        if ( ($args =~ /--GSW/i) || ($args =~ /--gsw/i) ) {
                            $trans_type="gsw";
                            if ($debug) {
                                print "GSW audio files\n";
                            }
                        } else {
                            if ( ($args =~ /--GPG/i) || ($args =~ /--gpg/i) ) {
                                $trans_type="gpg";
                                if ($debug) {
                                    print "GPG compressed files\n";
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
if (($camp_check) && ($ingrp_check)) {
    print "ERROR. You cannot specify ingroups and campaigns in the same instance of this script.\n";
    exit();
}
if ($camp_check) {
    @camp_array = split(/-/,$campaigns);
}
if ($ingrp_check) {
    @ingrp_array = split(/-/,$ingroups);
}
if ($run_check > 0)
    {
    my $grepout = `/bin/ps ax | grep $0 | grep -v grep | grep -v '/bin/sh'`;
    my $grepnum=0;
    $grepnum++ while ($grepout =~ m/\n/g);
    if ($grepnum > 1) 
        {
        if ($debug) {print "I am not alone! Another $0 is running! Exiting...\n";}
        exit;
        }
    }
my $dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;
my $rec_log_stmt = "SELECT recording_id, start_time, vicidial_id, lead_id FROM recording_log WHERE filename=? ORDER BY recording_id DESC LIMIT 1;";
my $rec_log_sth = $dbhA->prepare($rec_log_stmt) or die "preparing: ",$dbhA->errstr;
my $vici_log_stmt = "SELECT campaign_id FROM vicidial_log WHERE uniqueid=? AND lead_id=? ORDER BY campaign_id DESC LIMIT 1;";
my $vici_log_sth = $dbhA->prepare($vici_log_stmt) or die "preparing: ",$dbhA->errstr;
my $clsr_log_stmt = "SELECT campaign_id FROM vicidial_closer_log WHERE closecallid=? AND lead_id=? ORDER BY campaign_id DESC LIMIT 1;";
my $clsr_log_sth = $dbhA->prepare($clsr_log_stmt) or die "preparing: ",$dbhA->errstr;
my $update_log_stmt = "UPDATE recording_log SET location=? WHERE recording_id=?;";
my $update_log_sth = $dbhA->prepare($update_log_stmt) or die "preparing: ",$dbhA->errstr;
my $directory = '';
if ($trans_type eq "wav") {$directory = "$PATHDONEmonitor";}
if ($trans_type eq "gsw") {$directory = "$PATHDONEmonitor/GSW";}
if ($trans_type eq "gsm") {$directory = "$PATHDONEmonitor/GSM";}
if ($trans_type eq "ogg") {$directory = "$PATHDONEmonitor/OGG";}
if ($trans_type eq "mp3") {$directory = "$PATHDONEmonitor/MP3";}
if ($trans_type eq "gpg") {$directory = "$PATHDONEmonitor/GPG";}
opendir(FILE, "$directory/");
my @files = readdir(FILE);
my $file_loop_count=0;
my $files_that_count=0;
my @FILEsize1;
foreach(@files)    {
    $FILEsize1[$file_loop_count] = 0;
    if ( (length($files[$file_loop_count]) > 4) && (!-d "$directory/$files[$file_loop_count]") ) {
        $FILEsize1[$file_loop_count] = (-s "$directory/$files[$file_loop_count]");
        if ($debugX) {
            print "$directory/$files[$file_loop_count] $FILEsize1[$file_loop_count]\n";
        }
        $files_that_count++;
    }
    $file_loop_count++;
    if ($files_that_count >= $list_limit) {
        last();
    }        
}
sleep(5);
my $transfered_files = 0;
my @FILEsize2;
my $recording_id = '';
my $start_date = '';
my $ALLfile = '';
my $SQLFILE = '';
my $transfer_file=0;
my $ping = Net::Ping->new($pingtype, $pingtimeout);
if ($pingtype eq "none") {
    $ping = 0;
}
$file_loop_count=0;
$files_that_count=0;
foreach(@files)    {
    if ($debug) {print "\n\n\n--------NEW-FILE-------------------------------------------------------------------------------------------\n";}
    $transfer_file=0;    
    $FILEsize2[$file_loop_count] = 0;
    if ( (length($files[$file_loop_count]) > 4) && (!-d "$directory/$files[$file_loop_count]") ) {
        $FILEsize2[$file_loop_count] = (-s "$directory/$files[$file_loop_count]");
        if ($debug) {
            print "$directory/$files[$file_loop_count] $FILEsize2[$file_loop_count]\n";
        }
        if ($FILEsize1[$file_loop_count] ne $FILEsize2[$file_loop_count]) {
            if ($debugX) {print "not transfering $directory/$files[$file_loop_count]. File size mismatch $FILEsize2[$file_loop_count] != $FILEsize1[$file_loop_count]\n";}
        }
        if ( ($files[$file_loop_count] !~ /out\.|in\.|lost\+found/i) && ($FILEsize1[$file_loop_count] eq $FILEsize2[$file_loop_count]) && (length($files[$file_loop_count]) > 4)) {
            my $recording_id = '';
            my $start_date = '';
            my $lead_id = '';
            my $vicidial_id = '';
            my $ALLfile = $files[$file_loop_count];
            my $SQLFILE = $files[$file_loop_count];
            $SQLFILE =~ s/\.gpg//gi;
            $SQLFILE =~ s/-all\.wav|-all\.gsm|-all\.ogg|-all\.mp3//gi;
            $SQLFILE =~ s/\.wav|\.gsm|\.ogg|\.mp3//gi;
            my $rec_log_db_stmt = "select recording_id, start_time, vicidial_id, lead_id from recording_log where filename=$SQLFILE order by recording_id desc LIMIT 1;";
            $rec_log_sth->execute($SQLFILE) or die "executing: $rec_log_db_stmt ", $dbhA->errstr;
            my $sthArows=$rec_log_sth->rows;
            if ($sthArows > 0) {
                my @aryA = $rec_log_sth->fetchrow_array;
                $recording_id =    "$aryA[0]";
                $start_date   = "$aryA[1]";
                $vicidial_id  = "$aryA[2]";
                $lead_id      = "$aryA[3]";
                $start_date =~ s/ .*//gi;
            }
            $rec_log_sth->finish();
            if ($debug) {
                print "|$camp_check|$recording_id|$start_date|$ALLfile|$SQLFILE|\n";
            }
            if ($camp_check) {
                my $vici_log_db_stmt = "select campaign_id from vicidial_log where uniqueid=$vicidial_id and lead_id=$lead_id;";
                $vici_log_sth->execute($vicidial_id, $lead_id) or die "executing: $rec_log_db_stmt ", $dbhA->errstr;
                my $sthArows=$vici_log_sth->rows;
                if ($sthArows > 0) {
                    my @aryA = $vici_log_sth->fetchrow_array;
                    my $campaign_id = "$aryA[0]";
                    if($debug){print STDERR "\n|$ALLfile is in the $campaign_id campaign.|\n";}
                    foreach( @camp_array ) {
                        if ( $_ eq $campaign_id ) {
                            $transfer_file = 1;
                            if($debug){print STDERR "\n|$_ is in the list of campaigns.|\n";}
                        }
                    }
                    if(($debug) && ($transfer_file == 0)) {print STDERR "\n|$campaign_id is not in the list of campaigns.|\n";}            
                }
                $vici_log_sth->finish();                
            } else {
                if ($ingrp_check) {
                    my $clsr_log_db_stmt = "select campaign_id from vicidial_closer_log where closecallid=$vicidial_id and lead_id=$lead_id;";
                    $clsr_log_sth->execute($vicidial_id, $lead_id) or die "executing: $rec_log_db_stmt ", $dbhA->errstr;
                    my $sthArows=$clsr_log_sth->rows;
                    if ($sthArows > 0) {
                        my @aryA = $clsr_log_sth->fetchrow_array;
                        my $ingroup_id = "$aryA[0]";    
                        if($debug){print STDERR "\n|$ALLfile is in the $ingroup_id ingroup.|\n";}
                        foreach( @ingrp_array ) {
                            if ( $_ eq $ingroup_id ) {
                                $transfer_file = 1;
                                if($debug){print STDERR "\n|$_ is in the list of ingroups.|\n";}
                            }
                        }
                        if(($debug) && ($transfer_file == 0)) {print STDERR "\n|$ingroup_id is not in the list of ingroups.|\n";}
                    }
                    $clsr_log_sth->finish();
                } else {
                    $transfer_file = 1;
                }
            }
            if ($transfer_file) {
                my $ping_good = 0;
                if ($pingtype ne "none") {
                    $ping_good = $ping->ping("$ftp_host");
                    if($debug){print "Ping result: $ping_good\n";}
                }
                if (($ping_good) || ($pingtype eq "none")) {    
                    if($debug) {
                        print STDERR "Transfering the file\n";
                    }
                    $transfered_files++;
                    my $start_date_PATH='';
                    my $ftp = Net::FTP->new("$ftp_host", Port => $ftp_port, Debug => $debugX);
                    $ftp->login("$ftp_user","$ftp_pass");
                    $ftp->mkdir("$ftp_dir");
                    $ftp->cwd("$ftp_dir");
                    if ($datedir) {
                        $ftp->mkdir("$start_date");
                        $ftp->cwd("$start_date");
                        $start_date_PATH = "$start_date/";
                    }
                    $ftp->binary();
                    $ftp->put("$directory/$ALLfile", "$ALLfile");
                    $ftp->quit;
                    my $update_log_db_stmt = "UPDATE recording_log set location='$url_path/$start_date_PATH$ALLfile' where recording_id='$recording_id';";
                    if($debug){print STDERR "\n|$update_log_db_stmt|\n";}
                    my $affected_rows = $update_log_sth->execute("$url_path/$start_date_PATH$ALLfile",$recording_id) 
                        or die "executing: $rec_log_db_stmt ", $dbhA->errstr;
                    if (!$test)    {
                        if($debugX) {
                            print STDERR "Moving file from $directory/$ALLfile to $PATHDONEmonitor/FTP/$ALLfile\n";
                        }
                        `mv -f "$directory/$ALLfile" "$PATHDONEmonitor/FTP/$ALLfile"`;
                    }
                    if($debugX){
                        print STDERR "Transfered $transfered_files files\n";
                    }
                    if ( $transfered_files == $trans_limit) {
                        if($debug) {
                            print STDERR "Transfer limit of $trans_limit reached breaking out of the loop\n";
                        }
                        last();
                    }    
                } else {
                    if($debug){
                        print "ERROR: Could not ping server $ftp_host\n";
                    }
                }
            }
            usleep(200*1000);
        }
        $files_that_count++;
    } else {
        if($debug) {
            print STDERR "$files[$file_loop_count]'s file name is to short or it is a directory.\n";
        }
    }
    $file_loop_count++;
    if ($files_that_count >= $list_limit) {
        last();
    }
}
if ($debug) {print "DONE... EXITING\n\n";}
$dbhA->disconnect();
exit;
