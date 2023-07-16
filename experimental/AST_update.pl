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
$build = '80111-1850';
$SYSPERF=0;    # system performance logging to MySQL server_performance table every 5 seconds
$SYSPERF_rec=0;    # is dial-time recording turned on
$SYSLOG=0; # set to 1 to write log to a file
$DB=0;    # Debug flag, set to 1 for debug messages  WARNING LOTS OF OUTPUT!!!
$DBX=0;    # Debug flag, set to 1 for debug messages  WARNING LOTS OF OUTPUT!!!
$US='__';
$AMP='@';
$MT[0]='';
$cpuUSERprev=0;
$cpuSYSTprev=0;
$cpuIDLEprev=0;
$bincat = "/usr/bin/cat";
if (-e "/usr/local/bin/cat")
    {$bincat = "/usr/local/bin/cat";}
else
    {
    if (-e "/bin/cat")
        {$bincat = "/bin/cat";}
    }
$binfree = "/usr/bin/free";
if (-e "/usr/local/bin/free")
    {$binfree = "/usr/local/bin/free";}
else
    {
    if (-e "/bin/free")
        {$binfree = "/bin/free";}
    }
$binps = "/bin/ps";
if (-e "/usr/local/bin/ps")
    {$binps = "/usr/local/bin/ps";}
else
    {
    if (-e "/usr/bin/ps")
        {$binps = "/usr/bin/ps";}
    }
    $parked_channels =        'parked_channels';
    $live_channels =        'live_channels';
    $live_sip_channels =    'live_sip_channels';
    $server_updater =        'server_updater';
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
    print "allowed run time options:\n  [-t] = test\n  [-sysperf] = system performance logging\n  [-sysperfdebug] = system performance debug output\n  [-debug] = verbose debug messages\n  [-debugX] = Extra-verbose debug messages\n\n";
    exit;
    }
    else
    {
        if ($args =~ /-sysperf/i)
        {
        $SYSPERF=1; # System performance logging flag
        }
        if ($args =~ /-sysperfdebug/i)
        {
        $SYSPERFDB=1; # prints system performance data out to STDOUT
        }
        if ($args =~ /-debug/i)
        {
        $DB=1; # Debug flag
        }
        if ($args =~ /--debugX/i)
        {
        $DB=1;
        $DBX=1;
        print "\n----- SUPER-DUPER DEBUGGING -----\nBUILD: $build\n";
        }
        if ($args =~ /-t/i)
        {
        $TEST=1;
        $T=1;
        }
    }
}
else
{
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
$server_ip = $VARserver_ip;        # Asterisk server IP
    &get_time_now;
if (!$UPLOGfile) {$UPLOGfile = "$PATHlogs/update.$year-$mon-$mday";}
if (!$VARDB_port) {$VARDB_port='3306';}
    $event_string='PROGRAM STARTED||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';
    &event_logger;
use Time::HiRes ('gettimeofday','usleep','sleep');  # necessary to have perl sleep command of less than one second
use Net::Telnet ();
use DBI;      
$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;
    $event_string='LOGGED INTO MYSQL SERVER ON 1 CONNECTION|';
    &event_logger;
$stmtA = "SELECT telnet_host,telnet_port,ASTmgrUSERNAME,ASTmgrSECRET,ASTmgrUSERNAMEupdate,ASTmgrUSERNAMElisten,ASTmgrUSERNAMEsend,max_vicidial_trunks,answer_transfer_agent,local_gmt,ext_context,asterisk_version,sys_perf_log,vd_server_logs FROM servers where server_ip = '$server_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
while ( my @aryA = $sthA->fetchrow_array )
    {
        $DBtelnet_host    =            "$aryA[0]";
        $DBtelnet_port    =            "$aryA[1]";
        $DBASTmgrUSERNAME    =        "$aryA[2]";
        $DBASTmgrSECRET    =            "$aryA[3]";
        $DBASTmgrUSERNAMEupdate    =    "$aryA[4]";
        $DBASTmgrUSERNAMElisten    =    "$aryA[5]";
        $DBASTmgrUSERNAMEsend    =    "$aryA[6]";
        $DBmax_vicidial_trunks    =    "$aryA[7]";
        $DBanswer_transfer_agent=    "$aryA[8]";
        $DBSERVER_GMT        =        "$aryA[9]";
        $DBext_context    =            "$aryA[10]";
        $DBasterisk_version    =        "$aryA[11]";
        $DBsys_perf_log    =            "$aryA[12]";
        $DBvd_server_logs =            "$aryA[13]";
        if ($DBtelnet_host)                {$telnet_host = $DBtelnet_host;}
        if ($DBtelnet_port)                {$telnet_port = $DBtelnet_port;}
        if ($DBASTmgrUSERNAME)            {$ASTmgrUSERNAME = $DBASTmgrUSERNAME;}
        if ($DBASTmgrSECRET)            {$ASTmgrSECRET = $DBASTmgrSECRET;}
        if ($DBASTmgrUSERNAMEupdate)    {$ASTmgrUSERNAMEupdate = $DBASTmgrUSERNAMEupdate;}
        if ($DBASTmgrUSERNAMElisten)    {$ASTmgrUSERNAMElisten = $DBASTmgrUSERNAMElisten;}
        if ($DBASTmgrUSERNAMEsend)        {$ASTmgrUSERNAMEsend = $DBASTmgrUSERNAMEsend;}
        if ($DBmax_vicidial_trunks)        {$max_vicidial_trunks = $DBmax_vicidial_trunks;}
        if ($DBanswer_transfer_agent)    {$answer_transfer_agent = $DBanswer_transfer_agent;}
        if ($DBSERVER_GMT)                {$SERVER_GMT = $DBSERVER_GMT;}
        if ($DBext_context)                {$ext_context = $DBext_context;}
        if ($DBasterisk_version)        {$AST_ver = $DBasterisk_version;}
        if ($DBsys_perf_log =~ /Y/)        {$SYSPERF = '1';}
        if ($DBvd_server_logs =~ /Y/)    {$SYSLOG = '1';}
     $rec_count++;
    }
$sthA->finish();
    $show_channels_format = 1;
    if ($AST_ver =~ /^1\.0/i) {$show_channels_format = 0;}
    if ($AST_ver =~ /^1\.4/i) {$show_channels_format = 2;}
    print STDERR "SHOW CHANNELS format: $show_channels_format\n";
$SUrec=0;
$stmtA = "SELECT count(*) FROM $server_updater where server_ip = '$server_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
@aryA = $sthA->fetchrow_array;
$SUrec = $aryA[0];
$sthA->finish();
    if($DB){print STDERR "\n|$SUrec|$stmtA|\n";}
if ($SUrec < 1)
    {
    &get_time_now;
    $stmtU = "INSERT INTO $server_updater set  server_ip='$server_ip', last_update='$now_date';";
        if($DB){print STDERR "\n|$stmtU|\n";}
    $affected_rows = $dbhA->do($stmtU);
    }
    print STDERR "LOOKING FOR Zap clients assigned to this server:\n";
    $Zap_client_count=0;
    $Zap_client_list='|';
    $stmtA = "SELECT extension FROM phones where protocol = 'Zap' and server_ip='$server_ip'";
    if($DB){print STDERR "|$stmtA|\n";}
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
    while ( my @aryA = $sthA->fetchrow_array() )
        {
            print STDERR $aryA[0],"\n";
            $Zap_client_list .= "$aryA[0]|";
            $Zap_client_count++;
        }
    $sthA->finish();
    print STDERR "LOOKING FOR IAX2 clients assigned to this server:\n";
    $IAX2_client_count=0;
    $IAX2_client_list='|';
    $stmtA = "SELECT extension FROM phones where protocol = 'IAX2' and server_ip='$server_ip'";
    if($DB){print STDERR "|$stmtA|\n";}
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
    while (my @aryA = $sthA->fetchrow_array() )
        {
            print STDERR $aryA[0],"\n";
            $IAX2_client_list .= "$aryA[0]|";
            if ($aryA[0] !~ /\@/)
                {$IAX2_client_list .= "$aryA[0]$AMP$aryA[0]|";}
            else
                {
                $IAX_user = $aryA[0];
                $IAX_user =~ s/\@.*$//gi;
                $IAX2_client_list .= "$IAX_user|";
                }
            $IAX2_client_count++;
        }
    $sthA->finish();
    print STDERR "LOOKING FOR SIP clients assigned to this server:\n";
    $SIP_client_count=0;
    $SIP_client_list='|';
    $stmtA = "SELECT extension FROM phones where protocol = 'SIP' and server_ip='$server_ip'";
    if($DB){print STDERR "|$stmtA|\n";}
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
    while (@aryA = $sthA->fetchrow_array)
        {
            print STDERR $aryA[0],"\n";
            $SIP_client_list .= "$aryA[0]|";
            if ($aryA[0] !~ /\@/)
                {$SIP_client_list .= "$aryA[0]$AMP$aryA[0]|";}
            else
                {
                $SIP_user = $aryA[0];
                $SIP_user =~ s/\@.*$//gi;
                $SIP_client_list .= "$SIP_user|";
                }
            $SIP_client_count++;
        }
    $sthA->finish();
    print STDERR "Zap Clients:  $Zap_client_list\n";
    print STDERR "IAX2 Clients: $IAX2_client_list\n";
    print STDERR "SIP Clients:  $SIP_client_list\n";
$one_day_interval = 12;        # 2 hour loops for one day
while($one_day_interval > 0)
{
        $event_string="STARTING NEW MANAGER TELNET CONNECTION||ATTEMPT|ONE DAY INTERVAL:$one_day_interval|";
    &event_logger;
if (!$telnet_port) {$telnet_port = '5038';}
    $t = new Net::Telnet (Port => $telnet_port,
                          Prompt => '/.*[\$%#>] $/',
                          Output_record_separator => '',);
    if (length($ASTmgrUSERNAMEupdate) > 3) {$telnet_login = $ASTmgrUSERNAMEupdate;}
    else {$telnet_login = $ASTmgrUSERNAME;}
    $t->open("$telnet_host"); 
    $t->waitfor('/[01]\n$/');            # print login
    $t->print("Action: Login\nUsername: $telnet_login\nSecret: $ASTmgrSECRET\n\n");
    $t->waitfor('/Authentication accepted/');        # waitfor auth accepted
        $event_string="STARTING NEW MANAGER TELNET CONNECTION|$telnet_login|CONFIRMED CONNECTION|ONE DAY INTERVAL:$one_day_interval|";
    &event_logger;
    $endless_loop=5769999;        # 30 days minutes at .45 seconds per loop
    while($endless_loop > 0)
    {
        @DBchannels=@MT;
        @DBsips=@MT;
        @list_channels=@MT;
        @test_channels=@MT;
            &get_current_channels;
            &validate_parked_channels;
    $t->buffer_empty;
    if ($show_channels_format < 1)
        {
        @list_channels = $t->cmd(String => "Action: Command\nCommand: show channels\n\n", Prompt => '/--END COMMAND-.*/'); 
        }
    if ($show_channels_format == 1)
        {
        @list_channels = $t->cmd(String => "Action: Command\nCommand: show channels concise\n\n", Prompt => '/--END COMMAND-.*/'); 
        }
    if ($show_channels_format > 1)
        {
        @list_channels = $t->cmd(String => "Action: Command\nCommand: core show channels concise\n\n", Prompt => '/--END COMMAND-.*/'); 
        }
    @test_channels=@list_channels;
    $test_zap_count=0;
    $test_iax_count=0;
    $test_local_count=0;
    $test_sip_count=0;
    $s=0;
    foreach(@test_channels)
        {
        chomp($test_channels[$s]);
        if($DBX){print "$s|$test_channels[$s]\n";}
        $test_channels[$s] =~ s/Congestion\s+\(Empty\)/ SIP\/CONGEST/gi;
        $test_channels[$s] =~ s/\(Outgoing Line\)|\(None\)/SIP\/ring/gi;
        $test_channels[$s] =~ s/\(Empty\)/SIP\/internal/gi;
        if (!$show_channels_format)
            {
            $test_channels[$s] =~ s/^\s*|\s*$//gi;
            $test_channels[$s] =~ s/\(.*\)//gi;
            }
        else
            {
            $EXcount = 0;
            $EXcount = @{[$test_channels[$s] =~ /\!/g]};
            if ($EXcount > 10)
                {
                @test_chan_12 = split(/\!/, $test_channels[$s]);
                }
            else
                {
                @test_chan_12 = split(/:/, $test_channels[$s]);
                }
            if (length($test_chan_12[6])<2) {$test_chan_12[6] = 'SIP/ring';}
            $test_channels[$s] = "$test_chan_12[0]     $test_chan_12[6]";
            }
        if ($test_channels[$s] =~ /^Zap|^IAX2|^SIP|^Local/)
            {
            if ($test_channels[$s] =~ /^(\S+)\s+.+\s+(\S+)$/)
                {
                $channel = $1;
                $extension = $2;
                if ($show_channels_format)
                    {$extension =~ s/^.*\(|\).*$//gi;}
                $extension =~ s/^SIP\/|-\S+$//gi;
                $extension =~ s/\|.*//gi;
                if ($channel =~ /^SIP/) {$test_sip_count++;}
                if ($channel =~ /^Local/) {$test_local_count++;}
                if ($IAX2_client_count) 
                    {
                    $channel_match=$channel;
                    $channel_match =~ s/\/\d+$|-\d+$//gi;
                    $channel_match =~ s/^IAX2\///gi;
                    $channel_match =~ s/\*/\\\*/gi;
                    if ($IAX2_client_list =~ /\|$channel_match\|/i) {$test_iax_count++;}
                    }
                if ($Zap_client_count) 
                    {
                    $channel_match=$channel;
                    $channel_match =~ s/^Zap\///gi;
                    $channel_match =~ s/\*/\\\*/gi;
                    if ($Zap_client_list =~ /\|$channel_match\|/i) {$test_zap_count++;}
                    }
                }
            }
        $s++;
        }
        $DB_live_lines = ($channel_counter + $sip_counter);
        if ( (!$DB_live_lines) or ($#list_channels < 2) )
            {$PERCENT_static = 0;}
        else
            {
            $PERCENT_static = ( ($#list_channels / $DB_live_lines) * 100);
            $PERCENT_static = sprintf("%6.2f", $PERCENT_static);
            }
        if ( (!$test_zap_count) or ($zap_client_counter < 2) )
            {$PERCENT_ZC_static = 0;}
        else
            {
            $PERCENT_ZC_static = ( ($test_zap_count / $zap_client_counter) * 100);
            $PERCENT_ZC_static = sprintf("%6.2f", $PERCENT_ZC_static);
            }
        if ( (!$test_iax_count) or ($iax_client_counter < 2) )
            {$PERCENT_IC_static = 0;}
        else
            {
            $PERCENT_IC_static = ( ($test_iax_count / $iax_client_counter) * 100);
            $PERCENT_IC_static = sprintf("%6.2f", $PERCENT_IC_static);
            }
        if ( (!$test_local_count) or ($local_client_counter < 2) )
            {$PERCENT_LC_static = 0;}
        else
            {
            $PERCENT_LC_static = ( ($test_local_count / $local_client_counter) * 100);
            $PERCENT_LC_static = sprintf("%6.2f", $PERCENT_LC_static);
            }
        if ( (!$test_sip_count) or ($sip_client_counter < 2) )
            {$PERCENT_SC_static = 0;}
        else
            {
            $PERCENT_SC_static = ( ($test_sip_count / $sip_client_counter) * 100);
            $PERCENT_SC_static = sprintf("%6.2f", $PERCENT_SC_static);
            }
        if ($endless_loop =~ /0$/)
            {print "-$now_date   $PERCENT_static    $#list_channels    $#DBchannels:$channel_counter      $#DBsips:$sip_counter    $PERCENT_ZC_static|$test_zap_count:$zap_client_counter    $PERCENT_IC_static|$test_iax_count:$iax_client_counter    $PERCENT_LC_static|$test_local_count:$local_client_counter    $PERCENT_SC_static|$test_sip_count:$sip_client_counter\n";}
        if ( ( ($PERCENT_static < 10) && ( ($channel_counter > 3) or ($sip_counter > 4) ) ) or
            ( ($PERCENT_static < 20) && ( ($channel_counter > 10) or ($sip_counter > 10) ) ) or
            ( ($PERCENT_static < 30) && ( ($channel_counter > 20) or ($sip_counter > 20) ) ) or
            ( ($PERCENT_static < 40) && ( ($channel_counter > 30) or ($sip_counter > 30) ) ) or
            ( ($PERCENT_static < 50) && ( ($channel_counter > 40) or ($sip_counter > 40) ) ) or
            ( ($PERCENT_ZC_static < 20) && ( $zap_client_counter > 3 ) )  or
            ( ($PERCENT_ZC_static < 40) && ( $zap_client_counter > 9 ) )  or
            ( ($PERCENT_IC_static < 20) && ( $iax_client_counter > 3 ) )  or
            ( ($PERCENT_IC_static < 40) && ( $iax_client_counter > 9 ) )  or
            ( ($PERCENT_SC_static < 20) && ( $sip_client_counter > 3 ) )  or
            ( ($PERCENT_SC_static < 40) && ( $sip_client_counter > 9 ) )    )
            {
            $UD_bad_grab++;
            $event_string="------ UPDATER BAD GRAB!!!    UBGcount: $UD_bad_grab\n          $PERCENT_static    $#list_channels    $#DBchannels:$channel_counter      $#DBsips:$sip_counter    $PERCENT_ZC_static|$test_zap_count:$zap_client_counter    $PERCENT_IC_static|$test_iax_count:$iax_client_counter    $PERCENT_LC_static|$test_local_count:$local_client_counter    $PERCENT_SC_static|$test_sip_count:$sip_client_counter\n";
            print "$event_string\n";
                &event_logger;
            if ($UD_bad_grab > 20) {$UD_bad_grab=0;}
            }
        else
            {
            $UD_bad_grab=0;
            if ( ($endless_loop =~ /0$/) && ($SYSPERF) )
                {
                $cpuUSERcent=0; $cpuSYSTcent=0; $cpuIDLEcent=0;
                @cpuUSE = `$bincat /proc/stat`;
                    if ($cpuUSE[0] =~ /cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
                    {
                    $cpuUSER  = ($1 + $2);
                    $cpuSYST  = $3;
                    $cpuIDLE  = $4;
                    $cpuUSERdiff  = ($cpuUSER - $cpuUSERprev);
                    $cpuSYSTdiff  = ($cpuSYST - $cpuSYSTprev);
                    $cpuIDLEdiff  = ($cpuIDLE - $cpuIDLEprev);
                    $cpuIDLEdiffTOTAL = (($cpuUSERdiff + $cpuSYSTdiff) + $cpuIDLEdiff);
                    if ($cpuIDLEdiffTOTAL > 0) 
                        {
                        $cpuUSERcent  = sprintf("%.0f", (($cpuUSERdiff / $cpuIDLEdiffTOTAL) * 100));
                        $cpuSYSTcent  = sprintf("%.0f", (($cpuSYSTdiff / $cpuIDLEdiffTOTAL) * 100));
                        $cpuIDLEcent  = sprintf("%.0f", (($cpuIDLEdiff / $cpuIDLEdiffTOTAL) * 100));
                        }
                    $cpuUSERprev=$cpuUSER;
                    $cpuSYSTprev=$cpuSYST;
                    $cpuIDLEprev=$cpuIDLE;
                    }
                $serverLOAD = `$bincat /proc/loadavg`;
                $serverLOAD =~ s/ .*//gi;
                $serverLOAD =~ s/\D//gi;
                @GRABserverMEMORY = `$binfree -m -t`;
                    if ($GRABserverMEMORY[1] =~ /Mem:\s+(\d+)\s+(\d+)\s+(\d+)\s+/)
                    {
                    $MEMused  = $2;
                    $MEMfree  = $3;
                    }
                @GRABserverPROCESSES = `$binps -A --no-heading`;
                $serverPROCESSES = $#GRABserverPROCESSES;
                if ($SYSPERF_rec) {$recording_count = ($test_local_count / 2)}
                 else {$recording_count=0;}
                if ($SYSPERFDB)
                    {print "$serverLOAD  $MEMfree  $MEMused  $serverPROCESSES  $#list_channels  $cpuUSERcent  $cpuSYSTcent  $cpuIDLEcent\n";}
                $stmtA = "INSERT INTO server_performance (start_time,server_ip,sysload,freeram,usedram,processes,channels_total,trunks_total,clients_total,clients_zap,clients_iax,clients_local,clients_sip,live_recordings,cpu_user_percent,cpu_system_percent,cpu_idle_percent) values('$now_date','$server_ip','$serverLOAD','$MEMfree','$MEMused','$serverPROCESSES','$#list_channels','$channel_counter','$sip_counter','$test_zap_count','$test_iax_count','$test_local_count','$test_sip_count','$recording_count','$cpuUSERcent','$cpuSYSTcent','$cpuIDLEcent')";
                    if( ($DB) or ($UD_bad_grab) ){print STDERR "\n|$stmtA|\n";}
                $affected_rows = $dbhA->do($stmtA) or die  "Couldn't execute query: |$stmtA|\n";
                }
            }
        if ($endless_loop =~ /00$/)
            {
                print STDERR "LOOKING FOR Zap clients assigned to this server:\n";
                $Zap_client_count=0;
                $Zap_client_list='|';
                $stmtA = "SELECT extension FROM phones where protocol = 'Zap' and server_ip='$server_ip'";
                if($DB){print STDERR "|$stmtA|\n";}
                $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                while ( my @aryA = $sthA->fetchrow_array() )
                    {
                        print STDERR $aryA[0],"\n";
                        $Zap_client_list .= "$aryA[0]|";
                        $Zap_client_count++;
                    }
                $sthA->finish();
                print STDERR "LOOKING FOR IAX2 clients assigned to this server:\n";
                $IAX2_client_count=0;
                $IAX2_client_list='|';
                $stmtA = "SELECT extension FROM phones where protocol = 'IAX2' and server_ip='$server_ip'";
                if($DB){print STDERR "|$stmtA|\n";}
                $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                while (my @aryA = $sthA->fetchrow_array() )
                    {
                        print STDERR $aryA[0],"\n";
                        $IAX2_client_list .= "$aryA[0]|";
                        if ($aryA[0] !~ /\@/)
                            {$IAX2_client_list .= "$aryA[0]$AMP$aryA[0]|";}
                        else
                            {
                            $IAX_user = $aryA[0];
                            $IAX_user =~ s/\@.*$//gi;
                            $IAX2_client_list .= "$IAX_user|";
                            }
                        $IAX2_client_count++;
                    }
                $sthA->finish();
                print STDERR "LOOKING FOR SIP clients assigned to this server:\n";
                $SIP_client_count=0;
                $SIP_client_list='|';
                $stmtA = "SELECT extension FROM phones where protocol = 'SIP' and server_ip='$server_ip'";
                if($DB){print STDERR "|$stmtA|\n";}
                $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                while ( my @aryA = $sthA->fetchrow_array() )
                    {
                    ;
                        print STDERR $aryA[0],"\n";
                        $SIP_client_list .= "$aryA[0]|";
                        if ($aryA[0] !~ /\@/)
                            {$SIP_client_list .= "$aryA[0]$AMP$aryA[0]|";}
                        else
                            {
                            $SIP_user = $aryA[0];
                            $SIP_user =~ s/\@.*$//gi;
                            $SIP_client_list .= "$SIP_user|";
                            }
                        $SIP_client_count++;
                    }
                $sthA->finish();
                print STDERR "Zap Clients:  $Zap_client_list\n";
                print STDERR "IAX2 Clients: $IAX2_client_list\n";
                print STDERR "SIP Clients:  $SIP_client_list\n";
                $stmtA = "SELECT sys_perf_log,vd_server_logs FROM servers where server_ip = '$server_ip';";
                $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                while ( my @aryA = $sthA->fetchrow_array() )
                    {
                        $DBsys_perf_log    =            "$aryA[0]";
                        $DBvd_server_logs =            "$aryA[1]";
                        if ($DBsys_perf_log =~ /Y/)        {$SYSPERF = '1';}
                            else {$SYSPERF = '0';}
                        if ($DBvd_server_logs =~ /Y/)    {$SYSLOG = '1';}
                            else {$SYSLOG = '0';}
                    }
                $sthA->finish();
            if ($SYSPERFDB)
                {print "SYSPERF RELOAD: $DBsys_perf_log:$SYSPERF|$DBvd_server_logs:$SYSLOG\n";}
            }
    @list_chan_12=@MT;
    $EXcount = 0;
    $EXcount = @{[$list_channels[2] =~ /\!/g]};
    if ($EXcount > 10)
        {
        @list_chan_12 = split(/\!/, $list_channels[2]);
        }
    else
        {
        @list_chan_12 = split(/:/, $list_channels[2]);
        }
    if( ($DB) && ($show_channels_format) ) {print "concise: $#list_chan_12\n";}
    if ( ( ( ($list_channels[1] =~ /State Appl\./) or ($list_channels[2] =~ /State Appl\.|Application\(Data\)/) or ($list_channels[3] =~ /State Appl\.|Application\(Data\)/) ) || ($#list_chan_12 > 8) ) && (!$UD_bad_grab) )
        {
        $c=0;
            if($DB){print "lines: $#list_channels\n";}
            if($DB){print "DBchn: $#DBchannels\n";}
            if($DB){print "DBsip: $#DBsips\n";}
        foreach(@list_channels)
            {
                chomp($list_channels[$c]);
                    if( ($DB) or ($UD_bad_grab) ){print "-|$c|$list_channels[$c]|\n";}
                $list_channels[$c] =~ s/Congestion\s+\(Empty\)/ SIP\/CONGEST/gi;
                $list_channels[$c] =~ s/\(Outgoing Line\)|\(None\)/SIP\/ring/gi;
                $list_channels[$c] =~ s/\(Empty\)/SIP\/internal/gi;
                if (!$show_channels_format)
                    {
                    $list_channels[$c] =~ s/^\s*|\s*$//gi;
                    $list_channels[$c] =~ s/\(.*\)//gi;
                    }
                else
                    {
                    @list_chan_12=@MT;
                    if ($EXcount > 10)
                        {
                        @list_chan_12 = split(/\!/, $list_channels[$c]);
                        }
                    else
                        {
                        @list_chan_12 = split(/:/, $list_channels[$c]);
                        }
                    if ($DBX) {print "EXcount: $EXcount\n";}
                    if (length($list_chan_12[6])<2) {$list_chan_12[6] = 'SIP/ring';}
                    $list_channels[$c] = "$list_chan_12[0]     $list_chan_12[6]";
                    }
                $list_SIP[$c] = $list_channels[$c];
                    if( ($DB) or ($UD_bad_grab) ){print "+|$c|$list_channels[$c]|\n\n";}
            if ($list_channels[$c] =~ /^Zap|^IAX2|^SIP|^Local/)
                {
                if ($list_channels[$c] =~ /^(\S+)\s+.+\s+(\S+)$/)
                    {
                    $line_type = '';
                    $channel = $1;
                    $extension = $2;
                    $channel_data = $extension;
                    if ($show_channels_format)
                        {
                        $extension =~ s/^.*\(|\).*$//gi;
                        }
                    $extension =~ s/^SIP\/|-\S+$//gi;
                    $extension =~ s/\|.*//gi;
                    $QRYchannel = "$channel$US$extension";
                    if( ($DB) or ($UD_bad_grab) ){print "channel:   |$channel|\n";}
                    if( ($DB) or ($UD_bad_grab) ){print "extension: |$extension|\n";}
                    if( ($DB) or ($UD_bad_grab) ){print "QRYchannel:|$QRYchannel|\n";}
                    if ($channel =~ /^SIP|^Zap|^IAX2/) {$line_type = 'TRUNK';}
                    if ($channel =~ /^Local/) {$line_type = 'CLIENT';}
                    if ($IAX2_client_count) 
                        {
                        $channel_match=$channel;
                        $channel_match =~ s/\/\d+$|-\d+$//gi;
                        $channel_match =~ s/^IAX2\///gi;
                        $channel_match =~ s/\*/\\\*/gi;
                        if ($IAX2_client_list =~ /\|$channel_match\|/i) {$line_type = 'CLIENT';}
                        }
                    if ($Zap_client_count) 
                        {
                        $channel_match=$channel;
                        $channel_match =~ s/^Zap\///gi;
                        $channel_match =~ s/\*/\\\*/gi;
                        if ($Zap_client_list =~ /\|$channel_match\|/i) {$line_type = 'CLIENT';}
                        }
                    if ($SIP_client_count) 
                        {
                        $channel_match=$channel;
                        $channel_match =~ s/-\S+$//gi;
                        $channel_match =~ s/^SIP\///gi;
                        $channel_match =~ s/\*/\\\*/gi;
                        if ($SIP_client_list =~ /\|$channel_match\|/i) {$line_type = 'CLIENT';}
                        }
                    if ($line_type eq 'TRUNK')
                        {
                        if( ($DB) or ($UD_bad_grab) ){print "current channels: $#DBchannels\n";}
                            $k=0;
                            $channel_in_DB=0;
                        foreach(@DBchannels)
                            {
                            if ( ($DBchannels[$k] eq "$QRYchannel") && (!$channel_in_DB) )
                                {
                                $DBchannels[$k] = '';
                                $channel_in_DB++;
                                }
                            if( ($DB) or ($UD_bad_grab) ){print "DB $k|$DBchannels[$k]|     |";}
                            $k++;
                            }
                        if ( (!$channel_in_DB) && (length($QRYchannel)>3) )
                            {
                            $stmtA = "INSERT INTO $live_channels (channel,server_ip,extension,channel_data) values('$channel','$server_ip','$extension','$channel_data')";
                                if( ($DB) or ($UD_bad_grab) ){print STDERR "\n|$stmtA|\n";}
                            $affected_rows = $dbhA->do($stmtA) or die  "Couldn't execute query: |$stmtA|\n";
                            }
                        }
                    if ($line_type eq 'CLIENT')
                        {
                        if( ($DB) or ($UD_bad_grab) ){print "current sips: $#DBsips\n";}
                            $k=0;
                            $sipchan_in_DB=0;
                        foreach(@DBsips)
                            {
                            if ( ($DBsips[$k] eq "$QRYchannel") && (!$sipchan_in_DB) )
                                {
                                $DBsips[$k] = '';
                                $sipchan_in_DB++;
                                }
                            if( ($DB) or ($UD_bad_grab) ){print "DB $k|$DBsips[$k]|     |";}
                            $k++;
                            }
                        if ( (!$sipchan_in_DB) && (length($QRYchannel)>3) )
                            {
                            $stmtA = "INSERT INTO $live_sip_channels (channel,server_ip,extension,channel_data) values('$channel','$server_ip','$extension','$channel_data')";
                                if( ($DB) or ($UD_bad_grab) ){print STDERR "\n|$stmtA|\n";}
                            $affected_rows = $dbhA->do($stmtA) or die  "Couldn't execute query: |$stmtA|\n";
                            }
                        }
                    }
                }
            $c++;
            }
        if($DB){print "COUNT: $c|$#list_channels|$endless_loop\n";}
            if ($#DBchannels >= 0)
                {
                    $d=0;
                foreach(@DBchannels)
                    {
                    if (length($DBchannels[$d])>4)
                        {
                            ($DELchannel, $DELextension) = split(/\_\_/, $DBchannels[$d]);
                            $stmtB = "DELETE FROM $live_channels where server_ip='$server_ip' and channel='$DELchannel' and extension='$DELextension' limit 1";
                                if( ($DB) or ($UD_bad_grab) ){print STDERR "\n|$stmtB|\n";}
                            $affected_rows = $dbhA->do($stmtB);
                        }
                    $d++;
                    }
                }
            if ($#DBsips >= 0)
                {
                    $d=0;
                foreach(@DBsips)
                    {
                    if (length($DBsips[$d])>4)
                        {
                            ($DELchannel, $DELextension) = split(/\_\_/, $DBsips[$d]);
                            $stmtB = "DELETE FROM $live_sip_channels where server_ip='$server_ip' and channel='$DELchannel' and extension='$DELextension' limit 1";
                                if( ($DB) or ($UD_bad_grab) ){print STDERR "\n|$stmtB|\n";}
                            $affected_rows = $dbhA->do($stmtB);
                        }
                    $d++;
                    }
                }
        usleep(1*450*1000);
    $endless_loop--;
        if($DB){print STDERR "\nloop counter: |$endless_loop|\n";}
        if (-e "$PATHhome/update.kill")
            {
            unlink("$PATHhome/update.kill");
            $endless_loop=0;
            $one_day_interval=0;
            print "\nPROCESS KILLED MANUALLY... EXITING\n\n"
            }
        $bad_grabber_counter=0;
        $no_channels_12_counter=0;
        }
    else
        {
        if ( ($list_channels[1] !~ /Privilege: Command/) && ($show_channels_format) )
            {
            $bad_grabber_counter++;
            if($DB){print STDERR "\nbad grab, trying again\n";}
            usleep(1*200*1000);
                $event_string="BAD GRAB TRYING AGAIN|BAD_GRABS: $bad_grabber_counter|$endless_loop|ONE DAY INTERVAL:$one_day_interval|";
            &event_logger;
            if ($bad_grabber_counter > 100)
                {
                $endless_loop=0;
                    $event_string="TOO MANY BAD GRABS, STARTING NEW CONNECTION|BAD_GRABS: $bad_grabber_counter|$endless_loop|ONE DAY INTERVAL:$one_day_interval|";
                &event_logger;
                $bad_grabber_counter=0;
                }
            }
        else
            {
            $no_channels_12_counter++;
                $event_string="NO CHANNELS HERE|COUNTER: $no_channels_12_counter|$endless_loop|ONE DAY INTERVAL:$one_day_interval|$list_channels[1]";
            &event_logger;
            if($DBX) {print "*|EMPTY CHANNELS: $no_channels_12_counter|$#list_channels|$list_channels[1]";}
            usleep(1*400*1000);
            if ($no_channels_12_counter == 3)
                {
                    $event_string="NO CHANNELS HERE|COUNTER: $no_channels_12_counter|$endless_loop|ONE DAY INTERVAL:$one_day_interval|$list_channels[1]";
                &event_logger;
                $stmtB = "DELETE FROM $live_sip_channels where server_ip='$server_ip'";
                    if( ($DB) or ($UD_bad_grab) ){print STDERR "\n|$stmtB|\n";}
                $affected_rows = $dbhA->do($stmtB);
                $stmtB = "DELETE FROM $live_channels where server_ip='$server_ip'";
                    if( ($DB) or ($UD_bad_grab) ){print STDERR "\n|$stmtB|\n";}
                $affected_rows = $dbhA->do($stmtB);
                }
            }
        }
    }
        if($DB){print "DONE... Exiting... Goodbye... See you later... Not really, initiating next loop...\n";}
        $event_string='HANGING UP|';
        &event_logger;
        @hangup = $t->cmd(String => "Action: Logoff\n\n", Prompt => "/.*/"); 
        $ok = $t->close;
    $one_day_interval--;
}
        $event_string='CLOSING DB CONNECTION|';
        &event_logger;
$dbhA->disconnect();
if($DB){print "DONE... Exiting... Goodbye... See you later... Really I mean it this time\n";}
exit;
sub get_current_channels
{
$sip_counter=0;
$zap_client_counter=0;
$iax_client_counter=0;
$local_client_counter=0;
$sip_client_counter=0;
    if($DB){print STDERR "\n|SELECT channel,extension FROM $live_channels where server_ip = '$server_ip'|\n";}
$stmtA = "SELECT channel,extension FROM $live_channels where server_ip = '$server_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$channel_counter=0;
while ( my @aryA = $sthA->fetchrow_array() )
    {
    if($DB){print STDERR $aryA[0],"|", $aryA[1],"\n";}
        $DBchannels[$channel_counter] = "$aryA[0]$US$aryA[1]";
    $channel_counter++;
    }
$sthA->finish();
$stmtA = "SELECT channel,extension FROM $live_sip_channels where server_ip = '$server_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
$rec_count_sip=0;
while ( my @aryA = $sthA->fetchrow_array() )
    {
    if($DB){print STDERR $aryA[0],"|", $aryA[1],"\n";}
        $DBsips[$sip_counter] = "$aryA[0]$US$aryA[1]";
    if ($aryA[0] =~ /^Zap/) {$zap_client_counter++;}
    if ($aryA[0] =~ /^IAX/) {$iax_client_counter++;}
    if ($aryA[0] =~ /^Local/) {$local_client_counter++;}
    if ($aryA[0] =~ /^SIP/) {$sip_client_counter++;}
    $sip_counter++;
    $rec_count_sip++;
    }
$sthA->finish();
    &get_time_now;
$stmtU = "UPDATE $server_updater set last_update='$now_date' where server_ip='$server_ip'";
    if($DB){print STDERR "\n|$stmtU|\n";}
$affected_rows = $dbhA->do($stmtU);
}
sub validate_parked_channels
{
if (!$run_validate_parked_channels_now) 
    {
    $parked_counter=0;
    @ARchannel=@MT;   @ARextension=@MT;   @ARparked_time=@MT;   @ARparked_time_UNIX=@MT;   
    $stmtA = "SELECT channel,extension,parked_time,UNIX_TIMESTAMP(parked_time) FROM $parked_channels where server_ip = '$server_ip' order by channel desc, parked_time desc;";
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
    $rec_count=0;
    while ( my @aryA = $sthA->fetchrow_array() )
        {
        $PQchannel =            $aryA[0];
        $PQextension =            $aryA[1];
        $PQparked_time =        $aryA[2];
        $PQparked_time_UNIX =    $aryA[3];
            if($DB){print STDERR "\n|$PQchannel|$PQextension|$PQparked_time|$PQparked_time_UNIX|\n";}
        $dbhC = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;
        $AR=0;
        $record_deleted=0;
        foreach(@ARchannel)
           {
            if (@ARchannel[$AR] eq "$PQchannel")
                {
                if (@ARparked_time_UNIX[$AR] > $PQparked_time_UNIX)
                    {
                        if($DBX){print "Duplicate parked channel delete: |$PQchannel|$PQparked_time|\n";}
                    $stmtPQ = "DELETE FROM $parked_channels where server_ip='$server_ip' and channel='$PQchannel' and extension='$PQextension' and parked_time='$PQparked_time' limit 1";
                            if($DB){print STDERR "\n|$stmtPQ|$$DEL_chan_park_counter|$DEL_chan_park_counter|\n\n";}
                        $affected_rows = $dbhC->do($stmtPQ);
                        $DEL_chan_park_counter = "DEL$PQchannel$PQextension";
                        $$DEL_chan_park_counter=0;
                    $record_deleted++;
                    }
                }
            $AR++;
           }
        if (!$record_deleted)
            {
            $ARchannel[$rec_count] =            $aryA[0];
            $ARextension[$rec_count] =            $aryA[1];
            $ARparked_time[$rec_count] =        $aryA[2];
            $ARparked_time_UNIX[$rec_count] =    $aryA[3];
        $dbhB = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;
            $event_string='LOGGED INTO MYSQL SERVER ON 2 CONNECTIONS TO VALIDATE PARKED CALLS|';
            &event_logger;
            $stmtB = "SELECT count(*) FROM $live_channels where server_ip='$server_ip' and channel='$PQchannel' and extension='$PQextension';";
            $sthB = $dbhB->prepare($stmtB) or die "preparing: ",$dbhB->errstr;
            $sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
            $rec_countB = 0;
            while ( my @aryB = $sthB->fetchrow_array() )
                {
                $PQcount = $aryB[0];
                    if($DB){print STDERR "\n|$PQcount|\n";}
                $rec_countB++;
                }
            $sthB->finish();
            if ($PQcount < 1)
                {
                $DEL_chan_park_counter = "DEL$PQchannel$PQextension";
                $$DEL_chan_park_counter++;
                    if($DBX){print STDERR "Parked counter down|$$DEL_chan_park_counter|$DEL_chan_park_counter|\n";}
                if ($$DEL_chan_park_counter > 5)
                    {
                if($DBX){print "          parked channel delete: |$PQchannel|$PQparked_time|\n";}
                    $stmtPQ = "DELETE FROM $parked_channels where server_ip='$server_ip' and channel='$PQchannel' and extension='$PQextension' limit 1";
                        if($DB){print STDERR "\n|$stmtPQ|$$DEL_chan_park_counter|$DEL_chan_park_counter|\n\n";}
                    $affected_rows = $dbhC->do($stmtPQ);
                        $ARchannel[$rec_count] = '';
                        $ARextension[$rec_count] = '';
                        $ARparked_time[$rec_count] = '';
                        $ARparked_time_UNIX[$rec_count] = '';
                    $$DEL_chan_park_counter=0;
                    }
                }
            else
               {
                $DEL_chan_park_counter = "DEL$PQchannel$PQextension";
                $$DEL_chan_park_counter=0;
               }
            $event_string='CLOSING MYSQL CONNECTIONS OPENED TO VALIDATE PARKED CALLS|';
            &event_logger;
            $dbhB->disconnect();
            }
        $dbhC->disconnect();
        $parked_counter++;
        $rec_count++;
        }
    $sthA->finish();
    $run_validate_parked_channels_now=5;    # set to run every five times the subroutine runs
    }
$run_validate_parked_channels_now--;
}
sub get_time_now
{
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year = ($year + 1900);
$mon++;
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
if ($hour < 10) {$Fhour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
$now_date_epoch = time();
$now_date = "$year-$mon-$mday $hour:$min:$sec";
}
sub event_logger 
{
if ($SYSLOG)
    {
    open(Lout, ">>$UPLOGfile")
            || die "Can't open $UPLOGfile: $!\n";
    print Lout "$now_date|$event_string|\n";
    close(Lout);
    }
$event_string='';
}
