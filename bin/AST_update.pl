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
$build   = '171208-1543';
$SYSPERF = 0
  ; # system performance logging to MySQL server_performance table every 5 seconds
$SYSPERF_rec = 0;                # is dial-time recording turned on
$SYSLOG      = 0;                # set to 1 to write log to a file
$DB  = 0; # Debug flag, set to 1 for debug messages  WARNING LOTS OF OUTPUT!!!
$DBX = 0; # Debug flag, set to 1 for debug messages  WARNING EVEN MORE OUTPUT!!!
$US          = '__';
$AMP         = '@';
$MT[0]       = '';
$cpuUSERprev = 0;
$cpuSYSTprev = 0;
$cpuIDLEprev = 0;
$run_check   = 1;                # concurrency check
$bincat      = "/usr/bin/cat";
if ( -e "/usr/local/bin/cat" ) { $bincat = "/usr/local/bin/cat"; }
else {
    if ( -e "/bin/cat" ) { $bincat = "/bin/cat"; }
}
$binfree = "/usr/bin/free";
if ( -e "/usr/local/bin/free" ) { $binfree = "/usr/local/bin/free"; }
else {
    if ( -e "/bin/free" ) { $binfree = "/bin/free"; }
}
$binps = "/bin/ps";
if ( -e "/usr/local/bin/ps" ) { $binps = "/usr/local/bin/ps"; }
else {
    if ( -e "/usr/bin/ps" ) { $binps = "/usr/bin/ps"; }
}
$dfbin = '';
if ( -e ('/bin/df') ) { $dfbin = '/bin/df'; }
else {
    if ( -e ('/usr/bin/df') ) { $dfbin = '/usr/bin/df'; }
    else {
        if ( -e ('/usr/local/bin/df') ) { $dfbin = '/usr/local/bin/df'; }
        else {
            print "Can't find df binary! Exiting...\n";
            exit;
        }
    }
}
$parked_channels   = 'parked_channels';
$live_channels     = 'live_channels';
$live_sip_channels = 'live_sip_channels';
$server_updater    = 'server_updater';
if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--help/i ) {
        print "allowed run time options:\n";
        print "  [--help] = this screen\n";
        print "  [--test] = test\n";
        print "  [--sysperf] = system performance logging\n";
        print "  [--sysperfdebug] = system performance debug output\n";
        print "  [--debug] = verbose debug messages\n";
        print "  [--debugX] = Extra-verbose debug messages\n";
        print "  [--quiet] = no output unless error\n";
        print "\n";
        exit;
    }
    else {
        if ( $args =~ /-sysperf/i ) {
            $SYSPERF = 1;    # System performance logging flag
        }
        if ( $args =~ /-sysperfdebug/i ) {
            $SYSPERFDB = 1;    # prints system performance data out to STDOUT
        }
        if ( $args =~ /-debug/i ) {
            $DB = 1;           # Debug flag
        }
        if ( $args =~ /--debugX/i ) {
            $DB  = 1;
            $DBX = 1;
            print "\n----- SUPER-DUPER DEBUGGING -----\nBUILD: $build\n";
        }
        if ( $args =~ /-test/i ) {
            $TEST = 1;
            $T    = 1;
        }
        if ( $args =~ /--quiet/i ) {
            $Q = 1;
        }
    }
}
else {
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
&get_time_now;
if ( !$UPLOGfile )  { $UPLOGfile  = "$PATHlogs/update.$year-$mon-$mday"; }
if ( !$UPERRfile )  { $UPERRfile  = "$PATHlogs/updateERROR.$year-$mon-$mday"; }
if ( !$VARDB_port ) { $VARDB_port = '3306'; }
$event_string =
'PROGRAM STARTED||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';
&event_logger;
use Time::HiRes ( 'gettimeofday', 'usleep', 'sleep' )
  ;    # necessary to have perl sleep command of less than one second
use Net::Telnet ();
use DBI;
use POSIX;
use Scalar::Util qw(looks_like_number);
$dbhA = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$event_string = 'LOGGED INTO MYSQL SERVER ON 1 CONNECTION|';
&event_logger;
$stmtA =
"SELECT telnet_host,telnet_port,ASTmgrUSERNAME,ASTmgrSECRET,ASTmgrUSERNAMEupdate,ASTmgrUSERNAMElisten,ASTmgrUSERNAMEsend,max_vicidial_trunks,answer_transfer_agent,local_gmt,ext_context,asterisk_version,sys_perf_log,vd_server_logs FROM servers where server_ip='$server_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
$sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
$sthArows = $sthA->rows;

if ( $sthArows > 0 ) {
    @aryA                    = $sthA->fetchrow_array;
    $DBtelnet_host           = $aryA[0];
    $DBtelnet_port           = $aryA[1];
    $DBASTmgrUSERNAME        = $aryA[2];
    $DBASTmgrSECRET          = $aryA[3];
    $DBASTmgrUSERNAMEupdate  = $aryA[4];
    $DBASTmgrUSERNAMElisten  = $aryA[5];
    $DBASTmgrUSERNAMEsend    = $aryA[6];
    $DBmax_vicidial_trunks   = $aryA[7];
    $DBanswer_transfer_agent = $aryA[8];
    $DBSERVER_GMT            = $aryA[9];
    $DBext_context           = $aryA[10];
    $DBasterisk_version      = $aryA[11];
    $DBsys_perf_log          = $aryA[12];
    $DBvd_server_logs        = $aryA[13];
    if ($DBtelnet_host)    { $telnet_host    = $DBtelnet_host; }
    if ($DBtelnet_port)    { $telnet_port    = $DBtelnet_port; }
    if ($DBASTmgrUSERNAME) { $ASTmgrUSERNAME = $DBASTmgrUSERNAME; }
    if ($DBASTmgrSECRET)   { $ASTmgrSECRET   = $DBASTmgrSECRET; }

    if ($DBASTmgrUSERNAMEupdate) {
        $ASTmgrUSERNAMEupdate = $DBASTmgrUSERNAMEupdate;
    }
    if ($DBASTmgrUSERNAMElisten) {
        $ASTmgrUSERNAMElisten = $DBASTmgrUSERNAMElisten;
    }
    if ($DBASTmgrUSERNAMEsend) { $ASTmgrUSERNAMEsend = $DBASTmgrUSERNAMEsend; }
    if ($DBmax_vicidial_trunks) {
        $max_vicidial_trunks = $DBmax_vicidial_trunks;
    }
    if ($DBanswer_transfer_agent) {
        $answer_transfer_agent = $DBanswer_transfer_agent;
    }
    if ($DBSERVER_GMT)              { $SERVER_GMT  = $DBSERVER_GMT; }
    if ($DBext_context)             { $ext_context = $DBext_context; }
    if ($DBasterisk_version)        { $AST_ver     = $DBasterisk_version; }
    if ( $DBsys_perf_log =~ /Y/ )   { $SYSPERF     = '1'; }
    if ( $DBvd_server_logs =~ /Y/ ) { $SYSLOG      = '1'; }
}
$sthA->finish();
$show_channels_format = 1;
if ( $AST_ver =~ /^1\.0/i ) { $show_channels_format = 0; }
if ( $AST_ver =~ /^1\.4/i ) { $show_channels_format = 2; }
if ( $AST_ver =~ /^1\.6/i ) { $show_channels_format = 3; }
if ( $AST_ver =~ /^1\.8/i ) { $show_channels_format = 4; }
if ( $AST_ver =~ /^10\./i ) { $show_channels_format = 4; }
if ( $AST_ver =~ /^11\./i ) { $show_channels_format = 4; }
if ( $AST_ver =~ /^12\./i ) { $show_channels_format = 4; }
if ( $Q < 1 ) { print STDERR "SHOW CHANNELS format: $show_channels_format\n"; }
$SUrec = 0;
$stmtA = "SELECT count(*) FROM $server_updater where server_ip='$server_ip';";
$sthA  = $dbhA->prepare($stmtA) or die "preparing: ", $dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
@aryA  = $sthA->fetchrow_array;
$SUrec = $aryA[0];
$sthA->finish();
if ($DB) { print STDERR "\n|$SUrec|$stmtA|\n"; }

if ( $SUrec < 1 ) {
    &get_time_now;
    $stmtU =
"INSERT INTO $server_updater set server_ip='$server_ip', last_update='$now_date';";
    if ($DB) { print STDERR "\n|$stmtU|\n"; }
    $affected_rows = $dbhA->do($stmtU);
}
if ( $Q < 1 ) {
    print STDERR "LOOKING FOR Zap/DAHDI clients assigned to this server:\n";
}
$Zap_client_count = 0;
$Zap_client_list  = '|';
$stmtA =
"SELECT extension FROM phones where protocol='Zap' and server_ip='$server_ip'";
if ($DB) { print STDERR "|$stmtA|\n"; }
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
$sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
$sthArows  = $sthA->rows;
$rec_count = 0;

while ( $sthArows > $rec_count ) {
    @aryA = $sthA->fetchrow_array;
    if ( $Q < 1 ) { print STDERR $aryA[0], "\n"; }
    $Zap_client_list .= "$aryA[0]|";
    $Zap_client_count++;
    $rec_count++;
}
$sthA->finish();
if ( $Q < 1 ) {
    print STDERR "LOOKING FOR IAX2 clients assigned to this server:\n";
}
$IAX2_client_count = 0;
$IAX2_client_list  = '|';
$stmtA =
"SELECT extension FROM phones where protocol='IAX2' and server_ip='$server_ip' and phone_type NOT LIKE \"%trunk%\";";
if ($DB) { print STDERR "|$stmtA|\n"; }
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
$sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
$sthArows  = $sthA->rows;
$rec_count = 0;

while ( $sthArows > $rec_count ) {
    @aryA = $sthA->fetchrow_array;
    if ( $Q < 1 ) { print STDERR $aryA[0], "\n"; }
    $IAX2_client_list .= "$aryA[0]|";
    if ( $aryA[0] !~ /\@/ ) { $IAX2_client_list .= "$aryA[0]$AMP$aryA[0]|"; }
    else {
        $IAX_user = $aryA[0];
        $IAX_user =~ s/\@.*$//gi;
        $IAX2_client_list .= "$IAX_user|";
    }
    $IAX2_client_count++;
    $rec_count++;
}
$sthA->finish();
if ( $Q < 1 ) {
    print STDERR "LOOKING FOR SIP clients assigned to this server:\n";
}
$SIP_client_count = 0;
$SIP_client_list  = '|';
$stmtA =
"SELECT extension FROM phones where protocol='SIP' and server_ip='$server_ip'";
if ($DB) { print STDERR "|$stmtA|\n"; }
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
$sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
$sthArows  = $sthA->rows;
$rec_count = 0;

while ( $sthArows > $rec_count ) {
    @aryA = $sthA->fetchrow_array;
    if ( $Q < 1 ) { print STDERR $aryA[0], "\n"; }
    $SIP_client_list .= "$aryA[0]|";
    if ( $aryA[0] !~ /\@/ ) { $SIP_client_list .= "$aryA[0]$AMP$aryA[0]|"; }
    else {
        $SIP_user = $aryA[0];
        $SIP_user =~ s/\@.*$//gi;
        $SIP_client_list .= "$SIP_user|";
    }
    $SIP_client_count++;
    $rec_count++;
}
$sthA->finish();
if ( $Q < 1 ) {
    print STDERR "Zap Clients:  $Zap_client_list\n";
    print STDERR "IAX2 Clients: $IAX2_client_list\n";
    print STDERR "SIP Clients:  $SIP_client_list\n";
}
if ( $run_check > 0 ) {
    my $grepout = `/bin/ps ax | grep $0 | grep -v grep | grep -v '/bin/sh'`;
    my $grepnum = 0;
    $grepnum++ while ( $grepout =~ m/\n/g );
    if ( $grepnum > 2 ) {
        if ($DB) {
            print "I am not alone! Another $0 is running! Exiting...\n";
        }
        $event_string = "I am not alone! Another $0 is running! Exiting...";
        &event_logger;
        exit;
    }
}
$one_day_interval = 12000;    # 2 hour loops for one day
$error_counter    = 0;
while ( $one_day_interval > 0 ) {
    $event_string =
"STARTING NEW MANAGER TELNET CONNECTION||ATTEMPT|ONE DAY INTERVAL:$one_day_interval|";
    &event_logger;
    if ( !$telnet_port ) { $telnet_port = '5038'; }
    $UPtelnetlog = "$PATHlogs/update_telnet_log" . $filedate . ".txt";
    $t           = new Net::Telnet(
        Port                    => $telnet_port,
        Prompt                  => '/.*[\$%#>] $/',
        Output_record_separator => '',
        Timeout                 => 3,
    );
    if ( length($ASTmgrUSERNAMEupdate) > 3 ) {
        $telnet_login = $ASTmgrUSERNAMEupdate;
    }
    else { $telnet_login = $ASTmgrUSERNAME; }
    $t->open("$telnet_host");
    $t->waitfor('/[0123]\n$/');    # print login
    $t->print(
        "Action: Login\nUsername: $telnet_login\nSecret: $ASTmgrSECRET\n\n");
    $t->waitfor('/Authentication accepted/');    # waitfor auth accepted
    $event_string =
"STARTING NEW MANAGER TELNET CONNECTION|$telnet_login|CONFIRMED CONNECTION|ONE DAY INTERVAL:$one_day_interval|";
    &event_logger;
    $gather_stats_first = 1;
    $endless_loop       = 5769999;    # 30 days minutes at .45 seconds per loop

    while ( $endless_loop > 0 ) {
        @DBchannels    = @MT;
        @DBsips        = @MT;
        @list_channels = @MT;
        @test_channels = @MT;
        &get_current_channels;
        &validate_parked_channels;
        $modechange = $t->errmode('return');
        $t->buffer_empty;

        if ( $show_channels_format < 1 ) {
            @list_channels = $t->cmd(
                String => "Action: Command\nCommand: show channels\n\n",
                Prompt => '/--END COMMAND-.*/'
            );
        }
        if ( $show_channels_format == 1 ) {
            @list_channels = $t->cmd(
                String => "Action: Command\nCommand: show channels concise\n\n",
                Prompt => '/--END COMMAND-.*/'
            );
        }
        if ( $show_channels_format > 1 ) {
            @list_channels = $t->cmd(
                String =>
                  "Action: Command\nCommand: core show channels concise\n\n",
                Prompt => '/--END COMMAND-.*/'
            );
        }
        $error_string = $t->errmsg;
        if ( length($error_string) > 0 ) {
            $error_counter++;
            $error_string = "$error_counter|" . $error_string;
            &error_logger;
        }
        else { $error_counter = 0; }
        if ( $error_counter > 1 ) {
            $event_string =
              "ERROR LIMIT REACHED, KILLING CONNECTION: $error_counter";
            &event_logger;
            $ok = $t->close;
            $t  = new Net::Telnet(
                Port                    => $telnet_port,
                Prompt                  => '/.*[\$%#>] $/',
                Output_record_separator => '',
                Timeout                 => 3,
            );
            if ( length($ASTmgrUSERNAMEupdate) > 3 ) {
                $telnet_login = $ASTmgrUSERNAMEupdate;
            }
            else { $telnet_login = $ASTmgrUSERNAME; }
            $t->open("$telnet_host");
            $t->waitfor('/[0123]\n$/');    # print login
            $t->print(
"Action: Login\nUsername: $telnet_login\nSecret: $ASTmgrSECRET\n\n"
            );
            $t->waitfor('/Authentication accepted/');    # waitfor auth accepted
            $event_string =
"STARTED NEW MANAGER TELNET CONNECTION|$telnet_login|CONFIRMED CONNECTION|ONE DAY INTERVAL:$one_day_interval|";
            &event_logger;
        }
        $modechange       = $t->errmode('die');
        @test_channels    = @list_channels;
        $test_zap_count   = 0;
        $test_iax_count   = 0;
        $test_local_count = 0;
        $test_sip_count   = 0;
        $s                = 0;

        foreach (@test_channels) {
            chomp( $test_channels[$s] );
            if ($DBX) { print "$s|$test_channels[$s]\n"; }
            $test_channels[$s] =~ s/Congestion\s+\(Empty\)/ SIP\/CONGEST/gi;
            $test_channels[$s] =~ s/\(Outgoing Line\)|\(None\)/SIP\/ring/gi;
            $test_channels[$s] =~ s/\(Empty\)/SIP\/internal/gi;
            if ( !$show_channels_format ) {
                $test_channels[$s] =~ s/^\s*|\s*$//gi;
                $test_channels[$s] =~ s/\(.*\)//gi;
            }
            else {
                $EXcount = 0;
                $EXcount = @{ [ $test_channels[$s] =~ /\!/g ] };
                if ( $EXcount > 10 ) {
                    @test_chan_12 = split( /\!/, $test_channels[$s] );
                }
                else {
                    @test_chan_12 = split( /:/, $test_channels[$s] );
                }
                if ( length( $test_chan_12[6] ) < 2 ) {
                    $test_chan_12[6] = 'SIP/ring';
                }
                $test_channels[$s] = "$test_chan_12[0]     $test_chan_12[6]";
            }
            if ( $test_channels[$s] =~ /^Zap|^IAX2|^SIP|^Local|^DAHDI/ ) {
                if ( $test_channels[$s] =~ /^(\S+)\s+.+\s+(\S+)$/ ) {
                    $channel   = $1;
                    $extension = $2;
                    if ($show_channels_format) {
                        $extension =~ s/^.*\(|\).*$//gi;
                    }
                    $extension =~ s/^SIP\/|-\S+$//gi;
                    $extension =~ s/\|.*//gi;
                    if ( $channel =~ /^SIP/ )   { $test_sip_count++; }
                    if ( $channel =~ /^Local/ ) { $test_local_count++; }
                    if ($IAX2_client_count) {
                        $channel_match = $channel;
                        $channel_match =~ s/\/\d+$|-\d+$//gi;
                        $channel_match =~ s/^IAX2\///gi;
                        $channel_match =~ s/\*/\\\*/gi;
                        if ( $IAX2_client_list =~ /\|$channel_match\|/i ) {
                            $test_iax_count++;
                        }
                    }
                    if ($Zap_client_count) {
                        $channel_match = $channel;
                        $channel_match =~ s/^Zap\/|^DAHDI\///gi;
                        $channel_match =~ s/\*/\\\*/gi;
                        if ( $Zap_client_list =~ /\|$channel_match\|/i ) {
                            $test_zap_count++;
                        }
                    }
                }
            }
            $s++;
        }
        $DB_live_lines = ( $channel_counter + $sip_counter );
        if ( ( !$DB_live_lines ) or ( $#list_channels < 2 ) ) {
            $PERCENT_static = 0;
        }
        else {
            $PERCENT_static = ( ( $#list_channels / $DB_live_lines ) * 100 );
            $PERCENT_static = sprintf( "%6.2f", $PERCENT_static );
        }
        if ( ( !$test_zap_count ) or ( $zap_client_counter < 2 ) ) {
            $PERCENT_ZC_static = 0;
        }
        else {
            $PERCENT_ZC_static =
              ( ( $test_zap_count / $zap_client_counter ) * 100 );
            $PERCENT_ZC_static = sprintf( "%6.2f", $PERCENT_ZC_static );
        }
        if ( ( !$test_iax_count ) or ( $iax_client_counter < 2 ) ) {
            $PERCENT_IC_static = 0;
        }
        else {
            $PERCENT_IC_static =
              ( ( $test_iax_count / $iax_client_counter ) * 100 );
            $PERCENT_IC_static = sprintf( "%6.2f", $PERCENT_IC_static );
        }
        if ( ( !$test_local_count ) or ( $local_client_counter < 2 ) ) {
            $PERCENT_LC_static = 0;
        }
        else {
            $PERCENT_LC_static =
              ( ( $test_local_count / $local_client_counter ) * 100 );
            $PERCENT_LC_static = sprintf( "%6.2f", $PERCENT_LC_static );
        }
        if ( ( !$test_sip_count ) or ( $sip_client_counter < 2 ) ) {
            $PERCENT_SC_static = 0;
        }
        else {
            $PERCENT_SC_static =
              ( ( $test_sip_count / $sip_client_counter ) * 100 );
            $PERCENT_SC_static = sprintf( "%6.2f", $PERCENT_SC_static );
        }
        if ( ( $endless_loop =~ /0$/ ) && ( $Q < 1 ) ) {
            print
"-$now_date   $PERCENT_static    $#list_channels    $#DBchannels:$channel_counter      $#DBsips:$sip_counter    $PERCENT_ZC_static|$test_zap_count:$zap_client_counter    $PERCENT_IC_static|$test_iax_count:$iax_client_counter    $PERCENT_LC_static|$test_local_count:$local_client_counter    $PERCENT_SC_static|$test_sip_count:$sip_client_counter\n";
        }
        if (
            (
                   ( $PERCENT_static < 10 )
                && ( ( $channel_counter > 3 ) or ( $sip_counter > 4 ) )
            )
            or (   ( $PERCENT_static < 20 )
                && ( ( $channel_counter > 10 ) or ( $sip_counter > 10 ) ) )
            or (   ( $PERCENT_static < 30 )
                && ( ( $channel_counter > 20 ) or ( $sip_counter > 20 ) ) )
            or (   ( $PERCENT_static < 40 )
                && ( ( $channel_counter > 30 ) or ( $sip_counter > 30 ) ) )
            or (   ( $PERCENT_static < 50 )
                && ( ( $channel_counter > 40 ) or ( $sip_counter > 40 ) ) )
            or ( ( $PERCENT_ZC_static < 20 ) && ( $zap_client_counter > 3 ) )
            or ( ( $PERCENT_ZC_static < 40 ) && ( $zap_client_counter > 9 ) )
            or ( ( $PERCENT_IC_static < 20 ) && ( $iax_client_counter > 3 ) )
            or ( ( $PERCENT_IC_static < 40 ) && ( $iax_client_counter > 9 ) )
            or ( ( $PERCENT_SC_static < 20 ) && ( $sip_client_counter > 3 ) )
            or ( ( $PERCENT_SC_static < 40 ) && ( $sip_client_counter > 9 ) )
          )
        {
            $UD_bad_grab++;
            $event_string =
"------ UPDATER BAD GRAB!!!    UBGcount: $UD_bad_grab\n          $PERCENT_static    $#list_channels    $#DBchannels:$channel_counter      $#DBsips:$sip_counter    $PERCENT_ZC_static|$test_zap_count:$zap_client_counter    $PERCENT_IC_static|$test_iax_count:$iax_client_counter    $PERCENT_LC_static|$test_local_count:$local_client_counter    $PERCENT_SC_static|$test_sip_count:$sip_client_counter\n";
            if ( $Q < 1 ) { print "$event_string\n"; }
            &event_logger;
            if ( $UD_bad_grab > 20 ) { $UD_bad_grab = 0; }
        }
        else {
            $UD_bad_grab = 0;
            if (   ( ( $endless_loop =~ /0$/ ) && ($SYSPERF) )
                || ( $endless_loop =~ /00$/ )
                || ( $gather_stats_first >= 1 ) )
            {
                $cpuUSERcent = 0;
                $cpuSYSTcent = 0;
                $cpuIDLEcent = 0;
                (
                    $cpuUSERcent,    $cpuIDLEcent,  $cpuSYSTcent,
                    $cpu_vm_percent, $user_diff,    $nice_diff,
                    $system_diff,    $idle_diff,    $iowait_diff,
                    $irq_diff,       $softirq_diff, $steal_diff,
                    $guest_diff,     $guest_nice_diff
                ) = get_cpu_percent();
                $serverLOAD = get_cpu_load();
                ( $mem_total, $MEMused, $MEMfree ) = get_mem_usage();
                $serverPROCESSES = get_num_processes();
                if ($SYSPERF_rec) {
                    $recording_count = ( $test_local_count / 2 );
                }
                else { $recording_count = 0; }
                if ($SYSPERF) {
                    if ($SYSPERFDB) {
                        print
"$serverLOAD  $MEMfree  $MEMused  $serverPROCESSES  $#list_channels  $cpuUSERcent  $cpuSYSTcent  $cpuIDLEcent\n";
                    }
                    $stmtA =
"INSERT INTO server_performance (start_time,server_ip,sysload,freeram,usedram,processes,channels_total,trunks_total,clients_total,clients_zap,clients_iax,clients_local,clients_sip,live_recordings,cpu_user_percent,cpu_system_percent,cpu_idle_percent) values('$now_date','$server_ip','$serverLOAD','$MEMfree','$MEMused','$serverPROCESSES','$#list_channels','$channel_counter','$sip_counter','$test_zap_count','$test_iax_count','$test_local_count','$test_sip_count','$recording_count','$cpuUSERcent','$cpuSYSTcent','$cpuIDLEcent')";
                    if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                        print STDERR "\n|$stmtA|\n";
                    }
                    $affected_rows = $dbhA->do($stmtA)
                      or die "Couldn't execute query: |$stmtA|\n";
                }
                if (   ( $endless_loop =~ /00$/ )
                    || ( $gather_stats_first >= 1 ) )
                {
                    $disk_usage         = '';
                    $disk_usage         = get_disk_space();
                    $gather_stats_first = 0;
                    $channels_total     = 0;
                    if ( $#list_channels > 0 ) {
                        $channels_total = ( $#list_channels - 1 );
                    }
                    $stmtA =
"UPDATE servers SET sysload='$serverLOAD',channels_total='$channels_total',cpu_idle_percent='$cpuIDLEcent',disk_usage='$disk_usage' where server_ip='$server_ip';";
                    if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                        print STDERR "\n|$stmtA|\n";
                    }
                    $affected_rows = $dbhA->do($stmtA)
                      or die "Couldn't execute query: |$stmtA|\n";
                }
            }
        }
        if ( $endless_loop =~ /00$/ ) {
            if ( $Q < 1 ) {
                print STDERR
                  "LOOKING FOR Zap clients assigned to this server:\n";
            }
            $Zap_client_count = 0;
            $Zap_client_list  = '|';
            $stmtA =
"SELECT extension FROM phones where protocol='Zap' and server_ip='$server_ip'";
            if ($DB) { print STDERR "|$stmtA|\n"; }
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ", $dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ",          $dbhA->errstr;
            $sthArows  = $sthA->rows;
            $rec_count = 0;

            while ( $sthArows > $rec_count ) {
                @aryA = $sthA->fetchrow_array;
                if ( $Q < 1 ) { print STDERR $aryA[0], "\n"; }
                $Zap_client_list .= "$aryA[0]|";
                $Zap_client_count++;
                $rec_count++;
            }
            $sthA->finish();
            if ( $Q < 1 ) {
                print STDERR
                  "LOOKING FOR IAX2 clients assigned to this server:\n";
            }
            $IAX2_client_count = 0;
            $IAX2_client_list  = '|';
            $stmtA =
"SELECT extension FROM phones where protocol='IAX2' and server_ip='$server_ip' and phone_type NOT LIKE \"%trunk%\";";
            if ($DB) { print STDERR "|$stmtA|\n"; }
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ", $dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ",          $dbhA->errstr;
            $sthArows  = $sthA->rows;
            $rec_count = 0;

            while ( $sthArows > $rec_count ) {
                @aryA = $sthA->fetchrow_array;
                if ( $Q < 1 ) { print STDERR $aryA[0], "\n"; }
                $IAX2_client_list .= "$aryA[0]|";
                if ( $aryA[0] !~ /\@/ ) {
                    $IAX2_client_list .= "$aryA[0]$AMP$aryA[0]|";
                }
                else {
                    $IAX_user = $aryA[0];
                    $IAX_user =~ s/\@.*$//gi;
                    $IAX2_client_list .= "$IAX_user|";
                }
                $IAX2_client_count++;
                $rec_count++;
            }
            $sthA->finish();
            if ( $Q < 1 ) {
                print STDERR
                  "LOOKING FOR SIP clients assigned to this server:\n";
            }
            $SIP_client_count = 0;
            $SIP_client_list  = '|';
            $stmtA =
"SELECT extension FROM phones where protocol='SIP' and server_ip='$server_ip'";
            if ($DB) { print STDERR "|$stmtA|\n"; }
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ", $dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ",          $dbhA->errstr;
            $sthArows  = $sthA->rows;
            $rec_count = 0;

            while ( $sthArows > $rec_count ) {
                @aryA = $sthA->fetchrow_array;
                if ( $Q < 1 ) { print STDERR $aryA[0], "\n"; }
                $SIP_client_list .= "$aryA[0]|";
                if ( $aryA[0] !~ /\@/ ) {
                    $SIP_client_list .= "$aryA[0]$AMP$aryA[0]|";
                }
                else {
                    $SIP_user = $aryA[0];
                    $SIP_user =~ s/\@.*$//gi;
                    $SIP_client_list .= "$SIP_user|";
                }
                $SIP_client_count++;
                $rec_count++;
            }
            $sthA->finish();
            if ( $Q < 1 ) {
                print STDERR "Zap Clients:  $Zap_client_list\n";
                print STDERR "IAX2 Clients: $IAX2_client_list\n";
                print STDERR "SIP Clients:  $SIP_client_list\n";
            }
            $stmtA =
"SELECT sys_perf_log,vd_server_logs FROM servers where server_ip='$server_ip';";
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ", $dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ",          $dbhA->errstr;
            $sthArows  = $sthA->rows;
            $rec_count = 0;
            while ( $sthArows > $rec_count ) {
                @aryA             = $sthA->fetchrow_array;
                $DBsys_perf_log   = $aryA[0];
                $DBvd_server_logs = $aryA[1];
                if   ( $DBsys_perf_log =~ /Y/ ) { $SYSPERF = '1'; }
                else                            { $SYSPERF = '0'; }
                if   ( $DBvd_server_logs =~ /Y/ ) { $SYSLOG = '1'; }
                else                              { $SYSLOG = '0'; }
                $rec_count++;
            }
            $sthA->finish();
            if ($SYSPERFDB) {
                print
"SYSPERF RELOAD: $DBsys_perf_log:$SYSPERF|$DBvd_server_logs:$SYSLOG\n";
            }
        }
        @list_chan_12 = @MT;
        $EXcount      = 0;
        $EXcount      = @{ [ $list_channels[2] =~ /\!/g ] };
        if ( $EXcount > 10 ) {
            @list_chan_12 = split( /\!/, $list_channels[2] );
        }
        else {
            @list_chan_12 = split( /:/, $list_channels[2] );
        }
        if ( ($DB) && ($show_channels_format) ) {
            print "concise: $#list_chan_12   loop: $endless_loop\n";
        }
        if (
            (
                (
                       ( $list_channels[1] =~ /State Appl\./ )
                    or
                    ( $list_channels[2] =~ /State Appl\.|Application\(Data\)/ )
                    or
                    ( $list_channels[3] =~ /State Appl\.|Application\(Data\)/ )
                )
                || ( $#list_chan_12 > 8 )
            )
            && ( !$UD_bad_grab )
          )
        {
            $c = 0;
            if ($DB) { print "lines: $#list_channels\n"; }
            if ($DB) { print "DBchn: $#DBchannels\n"; }
            if ($DB) { print "DBsip: $#DBsips\n"; }
            foreach (@list_channels) {
                chomp( $list_channels[$c] );
                if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                    print "-|$c|$list_channels[$c]|\n";
                }
                $list_channels[$c] =~ s/Congestion\s+\(Empty\)/ SIP\/CONGEST/gi;
                $list_channels[$c] =~ s/\(Outgoing Line\)|\(None\)/SIP\/ring/gi;
                $list_channels[$c] =~ s/\(Empty\)/SIP\/internal/gi;
                if ( !$show_channels_format ) {
                    $list_channels[$c] =~ s/^\s*|\s*$//gi;
                    $list_channels[$c] =~ s/\(.*\)//gi;
                }
                else {
                    @list_chan_12 = @MT;
                    if ( $EXcount > 10 ) {
                        @list_chan_12 = split( /\!/, $list_channels[$c] );
                    }
                    else {
                        @list_chan_12 = split( /:/, $list_channels[$c] );
                    }
                    if ($DBX) { print "EXcount: $EXcount\n"; }
                    if ( length( $list_chan_12[6] ) < 2 ) {
                        $list_chan_12[6] = 'SIP/ring';
                    }
                    if ( $list_chan_12[1] =~ /^meetme-enter/ ) {
                        $list_chan_12[6] =~ s/\(.*//gi;
                    }
                    $list_channels[$c] =
                      "$list_chan_12[0]     $list_chan_12[6]";
                }
                $list_SIP[$c] = $list_channels[$c];
                if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                    print "+|$c|$list_channels[$c]|\n\n";
                }
                if ( $list_channels[$c] =~ /^Zap|^IAX2|^SIP|^Local|^DAHDI/ ) {
                    if ( $list_channels[$c] =~ /^(\S+)\s+.+\s+(\S+)$/ ) {
                        $line_type    = '';
                        $channel      = $1;
                        $extension    = $2;
                        $channel_data = $extension;
                        if ($show_channels_format) {
                            $extension =~ s/^.*\(|\).*$//gi;
                        }
                        $extension =~ s/^SIP\/|-\S+$//gi;
                        $extension =~
                          s/\|.*//gi;    # remove everything after the |
                        $extension =~ s/,.*//gi; # remove everything after the ,
                        $QRYchannel = "$channel$US$extension";
                        if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                            print "channel:   |$channel|\n";
                            print "extension: |$extension|\n";
                            print "QRYchannel:|$QRYchannel|\n";
                        }
                        if ( $channel =~ /^SIP|^Zap|^IAX2|^DAHDI/ ) {
                            $line_type = 'TRUNK';
                        }
                        if ( $channel =~ /^Local/ ) { $line_type = 'CLIENT'; }
                        if ($IAX2_client_count) {
                            $channel_match = $channel;
                            $channel_match =~ s/\/\d+$|-\d+$//gi;
                            $channel_match =~ s/^IAX2\///gi;
                            $channel_match =~ s/\*/\\\*/gi;
                            if ( $IAX2_client_list =~ /\|$channel_match\|/i ) {
                                $line_type = 'CLIENT';
                            }
                        }
                        if ($Zap_client_count) {
                            $channel_match = $channel;
                            $channel_match =~ s/^Zap\/|^DAHDI\///gi;
                            $channel_match =~ s/\*/\\\*/gi;
                            if ( $Zap_client_list =~ /\|$channel_match\|/i ) {
                                $line_type = 'CLIENT';
                            }
                        }
                        if ($SIP_client_count) {
                            $channel_match = $channel;
                            $channel_match =~ s/-\S+$//gi;
                            $channel_match =~ s/^SIP\///gi;
                            $channel_match =~ s/\*/\\\*/gi;
                            if ( $SIP_client_list =~ /\|$channel_match\|/i ) {
                                $line_type = 'CLIENT';
                            }
                        }
                        if ( $line_type eq 'TRUNK' ) {
                            if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                                print "current channels: $#DBchannels\n";
                            }
                            $k             = 0;
                            $channel_in_DB = 0;
                            foreach (@DBchannels) {
                                if (   ( $DBchannels[$k] eq "$QRYchannel" )
                                    && ( !$channel_in_DB ) )
                                {
                                    $DBchannels[$k] = '';
                                    $channel_in_DB++;
                                }
                                if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) )
                                {
                                    print "DB $k|$DBchannels[$k]|     |";
                                }
                                $k++;
                            }
                            if (   ( !$channel_in_DB )
                                && ( length($QRYchannel) > 3 ) )
                            {
                                $stmtA =
"INSERT INTO $live_channels (channel,server_ip,extension,channel_data) values('$channel','$server_ip','$extension','$channel_data')";
                                if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) )
                                {
                                    print STDERR "\n|$stmtA|\n";
                                }
                                $affected_rows = $dbhA->do($stmtA)
                                  or die "Couldn't execute query: |$stmtA|\n";
                            }
                        }
                        if ( $line_type eq 'CLIENT' ) {
                            if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                                print "current sips: $#DBsips\n";
                            }
                            $k             = 0;
                            $sipchan_in_DB = 0;
                            foreach (@DBsips) {
                                if (   ( $DBsips[$k] eq "$QRYchannel" )
                                    && ( !$sipchan_in_DB ) )
                                {
                                    $DBsips[$k] = '';
                                    $sipchan_in_DB++;
                                }
                                if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) )
                                {
                                    print "DB $k|$DBsips[$k]|     |";
                                }
                                $k++;
                            }
                            if (   ( !$sipchan_in_DB )
                                && ( length($QRYchannel) > 3 ) )
                            {
                                $stmtA =
"INSERT INTO $live_sip_channels (channel,server_ip,extension,channel_data) values('$channel','$server_ip','$extension','$channel_data')";
                                if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) )
                                {
                                    print STDERR "\n|$stmtA|\n";
                                }
                                $affected_rows = $dbhA->do($stmtA)
                                  or die "Couldn't execute query: |$stmtA|\n";
                            }
                        }
                    }
                }
                $c++;
            }
            if ($DB) { print "COUNT: $c|$#list_channels|$endless_loop\n"; }
            if ( $#DBchannels >= 0 ) {
                $d = 0;
                foreach (@DBchannels) {
                    if ( length( $DBchannels[$d] ) > 4 ) {
                        ( $DELchannel, $DELextension ) =
                          split( /\_\_/, $DBchannels[$d] );
                        $stmtB =
"DELETE FROM $live_channels where server_ip='$server_ip' and channel='$DELchannel' and extension='$DELextension' limit 1";
                        if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                            print STDERR "\n|$stmtB|\n";
                        }
                        $affected_rows = $dbhA->do($stmtB);
                    }
                    $d++;
                }
            }
            if ( $#DBsips >= 0 ) {
                $d = 0;
                foreach (@DBsips) {
                    if ( length( $DBsips[$d] ) > 4 ) {
                        ( $DELchannel, $DELextension ) =
                          split( /\_\_/, $DBsips[$d] );
                        $stmtB =
"DELETE FROM $live_sip_channels where server_ip='$server_ip' and channel='$DELchannel' and extension='$DELextension' limit 1";
                        if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                            print STDERR "\n|$stmtB|\n";
                        }
                        $affected_rows = $dbhA->do($stmtB);
                    }
                    $d++;
                }
            }
            usleep( 1 * 450 * 1000 );
            $endless_loop--;
            if ($DB) { print STDERR "\nloop counter: |$endless_loop|\n"; }
            if ( -e "$PATHhome/update.kill" ) {
                unlink("$PATHhome/update.kill");
                $endless_loop     = 0;
                $one_day_interval = 0;
                print "\nPROCESS KILLED MANUALLY... EXITING\n\n";
            }
            $bad_grabber_counter    = 0;
            $no_channels_12_counter = 0;
        }
        else {
            if (   ( $list_channels[1] !~ /Privilege: Command/ )
                && ($show_channels_format) )
            {
                $bad_grabber_counter++;
                if ($DB) { print STDERR "\nbad grab, trying again\n"; }
                usleep( 1 * 200 * 1000 );
                $event_string =
"BAD GRAB TRYING AGAIN|BAD_GRABS: $bad_grabber_counter|$endless_loop|ONE DAY INTERVAL:$one_day_interval|";
                &event_logger;
                if ( $bad_grabber_counter > 100 ) {
                    $endless_loop = 0;
                    $event_string =
"TOO MANY BAD GRABS, STARTING NEW CONNECTION|BAD_GRABS: $bad_grabber_counter|$endless_loop|ONE DAY INTERVAL:$one_day_interval|";
                    &event_logger;
                    $bad_grabber_counter = 0;
                }
            }
            else {
                $no_channels_12_counter++;
                $channel_response = $list_channels[1];
                chomp($channel_response);
                $event_string =
"NO CHANNELS HERE|COUNTER: $no_channels_12_counter|$endless_loop|ONE DAY INTERVAL:$one_day_interval|$channel_response";
                &event_logger;
                if ($DBX) {
                    print
"*|EMPTY CHANNELS: $no_channels_12_counter|$#list_channels|$list_channels[1]";
                }
                $endless_loop--;
                usleep( 1 * 400 * 1000 );
                if ( $no_channels_12_counter == 3 ) {
                    $event_string =
"NO CHANNELS HERE|COUNTER: $no_channels_12_counter|$endless_loop|ONE DAY INTERVAL:$one_day_interval|$channel_response";
                    &event_logger;
                    $stmtB =
"DELETE FROM $live_sip_channels where server_ip='$server_ip'";
                    if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                        print STDERR "\n|$stmtB|\n";
                    }
                    $affected_rows = $dbhA->do($stmtB);
                    $stmtB =
                      "DELETE FROM $live_channels where server_ip='$server_ip'";
                    if ( ($DB) or ( ($UD_bad_grab) && ( $Q < 1 ) ) ) {
                        print STDERR "\n|$stmtB|\n";
                    }
                    $affected_rows = $dbhA->do($stmtB);
                }
            }
        }
    }
    if ($DB) {
        print
"DONE... Exiting... Goodbye... See you later... Not really, initiating next loop...\n";
    }
    $event_string = 'HANGING UP|';
    &event_logger;
    @hangup = $t->cmd( String => "Action: Logoff\n\n", Prompt => "/.*/" );
    $t->buffer_empty;
    $t->waitfor( Match => '/Message:.*\n\n/', Timeout => 5 );
    $ok = $t->close;
    $one_day_interval--;
}
$event_string = 'CLOSING DB CONNECTION|';
&event_logger;
$dbhA->disconnect();
if ($DB) {
    print
"DONE... Exiting... Goodbye... See you later... Really I mean it this time\n";
}
exit;

sub get_current_channels {
    $channel_counter      = 0;
    $sip_counter          = 0;
    $zap_client_counter   = 0;
    $iax_client_counter   = 0;
    $local_client_counter = 0;
    $sip_client_counter   = 0;
    if ($DB) {
        print STDERR
"\n|SELECT channel,extension FROM $live_channels where server_ip = '$server_ip'|\n";
    }
    $stmtA =
"SELECT channel,extension FROM $live_channels where server_ip='$server_ip';";
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
    $sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
    $sthArows  = $sthA->rows;
    $rec_count = 0;
    while ( $sthArows > $rec_count ) {
        @aryA = $sthA->fetchrow_array;
        if ($DB) { print STDERR $aryA[0], "|", $aryA[1], "\n"; }
        $DBchannels[$channel_counter] = "$aryA[0]$US$aryA[1]";
        $channel_counter++;
        $rec_count++;
    }
    $sthA->finish();
    $stmtA =
"SELECT channel,extension FROM $live_sip_channels where server_ip='$server_ip';";
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
    $sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
    $sthArows      = $sthA->rows;
    $rec_count_sip = 0;
    while ( $sthArows > $rec_count_sip ) {
        @aryA = $sthA->fetchrow_array;
        if ($DB) { print STDERR $aryA[0], "|", $aryA[1], "\n"; }
        $DBsips[$sip_counter] = "$aryA[0]$US$aryA[1]";
        if ( $aryA[0] =~ /^Zap|^DAHDI/ ) { $zap_client_counter++; }
        if ( $aryA[0] =~ /^IAX/ )        { $iax_client_counter++; }
        if ( $aryA[0] =~ /^Local/ )      { $local_client_counter++; }
        if ( $aryA[0] =~ /^SIP/ )        { $sip_client_counter++; }
        $sip_counter++;
        $rec_count_sip++;
    }
    $sthA->finish();
    &get_time_now;
    $stmtU =
"UPDATE $server_updater set last_update='$now_date' where server_ip='$server_ip'";
    if ($DB) { print STDERR "\n|$stmtU|\n"; }
    $affected_rows = $dbhA->do($stmtU);
}

sub validate_parked_channels {
    if ( !$run_validate_parked_channels_now ) {
        $parked_counter     = 0;
        @ARchannel          = @MT;
        @ARextension        = @MT;
        @ARparked_time      = @MT;
        @ARparked_time_UNIX = @MT;
        $stmtA =
"SELECT channel,extension,parked_time,UNIX_TIMESTAMP(parked_time),channel_group FROM $parked_channels where server_ip = '$server_ip' order by channel desc, parked_time desc;";
        $sthA = $dbhA->prepare($stmtA) or die "preparing: ", $dbhA->errstr;
        $sthA->execute or die "executing: $stmtA ",          $dbhA->errstr;
        $sthArows  = $sthA->rows;
        $rec_count = 0;

        while ( $sthArows > $rec_count ) {
            @aryA               = $sthA->fetchrow_array;
            $PQchannel          = $aryA[0];
            $PQextension        = $aryA[1];
            $PQparked_time      = $aryA[2];
            $PQparked_time_UNIX = $aryA[3];
            $PQchannel_group    = $aryA[4];
            if ($DB) {
                print STDERR
"\n|$PQchannel|$PQextension|$PQparked_time|$PQparked_time_UNIX|\n";
            }
            $dbhC = DBI->connect(
                "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
                "$VARDB_user", "$VARDB_pass" )
              or die "Couldn't connect to database: " . DBI->errstr;
            $AR             = 0;
            $record_deleted = 0;
            foreach (@ARchannel) {
                if ( @ARchannel[$AR] eq "$PQchannel" ) {
                    if ( @ARparked_time_UNIX[$AR] > $PQparked_time_UNIX ) {
                        if ($DBX) {
                            print
"Duplicate parked channel delete: |$PQchannel|$PQparked_time|\n";
                        }
                        $stmtPQ =
"DELETE FROM $parked_channels where server_ip='$server_ip' and channel='$PQchannel' and extension='$PQextension' and parked_time='$PQparked_time' limit 1";
                        if ($DB) {
                            print STDERR
"\n|$stmtPQ|$$DEL_chan_park_counter|$DEL_chan_park_counter|\n\n";
                        }
                        $affected_rows          = $dbhC->do($stmtPQ);
                        $DEL_chan_park_counter  = "DEL$PQchannel$PQextension";
                        $$DEL_chan_park_counter = 0;
                        $record_deleted++;
                    }
                }
                $AR++;
            }
            if ( !$record_deleted ) {
                $ARchannel[$rec_count]          = $aryA[0];
                $ARextension[$rec_count]        = $aryA[1];
                $ARparked_time[$rec_count]      = $aryA[2];
                $ARparked_time_UNIX[$rec_count] = $aryA[3];
                $dbhB                           = DBI->connect(
                    "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
                    "$VARDB_user", "$VARDB_pass" )
                  or die "Couldn't connect to database: " . DBI->errstr;
                $event_string =
'LOGGED INTO MYSQL SERVER ON 2 CONNECTIONS TO VALIDATE PARKED CALLS|';
                &event_logger;
                $stmtB =
"SELECT count(*) FROM $live_channels where server_ip='$server_ip' and channel='$PQchannel' and ( (extension='$PQextension') or (extension LIKE \"%.agi\") );";
                $sthB = $dbhB->prepare($stmtB)
                  or die "preparing: ", $dbhB->errstr;
                $sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
                $sthBrows   = $sthB->rows;
                $rec_countB = 0;
                $PQcount    = 0;

                while ( $sthBrows > $rec_countB ) {
                    @aryB    = $sthB->fetchrow_array;
                    $PQcount = $aryB[0];
                    if ($DB) { print STDERR "\n|$PQcount|\n"; }
                    $rec_countB++;
                }
                $sthB->finish();
                if ( $PQcount < 1 ) {
                    $DEL_chan_park_counter = "DEL$PQchannel$PQextension";
                    $$DEL_chan_park_counter++;
                    if ($DBX) {
                        print STDERR
"Parked counter down|$$DEL_chan_park_counter|$DEL_chan_park_counter|\n";
                    }
                    if ( $$DEL_chan_park_counter > 5 ) {
                        if ($DBX) {
                            print
"          parked channel delete: |$PQchannel|$PQparked_time|$PQchannel_group|\n";
                        }
                        $stmtPQ =
"DELETE FROM $parked_channels where server_ip='$server_ip' and channel='$PQchannel' and extension='$PQextension' limit 1;";
                        $affected_rowsPQ = $dbhC->do($stmtPQ);
                        $stmtACQ =
"DELETE FROM vicidial_auto_calls where callerid='$PQchannel_group' limit 1;";
                        $affected_rowsACQ = $dbhC->do($stmtACQ);
                        $event_string =
"PARKED CHANNEL GONE, LOGGING: |$affected_rowsPQ|$affected_rowsACQ|$stmtPQ|$stmtACQ|$$DEL_chan_park_counter|$DEL_chan_park_counter|\n\n";
                        &event_logger;
                        $ARchannel[$rec_count]          = '';
                        $ARextension[$rec_count]        = '';
                        $ARparked_time[$rec_count]      = '';
                        $ARparked_time_UNIX[$rec_count] = '';
                        $$DEL_chan_park_counter         = 0;
                    }
                }
                else {
                    $DEL_chan_park_counter  = "DEL$PQchannel$PQextension";
                    $$DEL_chan_park_counter = 0;
                }
                $event_string =
                  'CLOSING MYSQL CONNECTIONS OPENED TO VALIDATE PARKED CALLS|';
                &event_logger;
                $dbhB->disconnect();
            }
            $dbhC->disconnect();
            $parked_counter++;
            $rec_count++;
        }
        $sthA->finish();
        $run_validate_parked_channels_now =
          5;    # set to run every five times the subroutine runs
    }
    $run_validate_parked_channels_now--;
}

sub get_time_now {
    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    $year = ( $year + 1900 );
    $mon++;
    if ( $mon < 10 )  { $mon  = "0$mon"; }
    if ( $mday < 10 ) { $mday = "0$mday"; }
    if ( $hour < 10 ) { $hour = "0$hour"; }
    if ( $min < 10 )  { $min  = "0$min"; }
    if ( $sec < 10 )  { $sec  = "0$sec"; }
    $now_date_epoch = time();
    $now_date       = "$year-$mon-$mday $hour:$min:$sec";
    $filedate       = "$year$mon$mday$hour$min$sec";
}

sub event_logger {
    if ($SYSLOG) {
        open( Lout, ">>$UPLOGfile" )
          || die "Can't open $UPLOGfile: $!\n";
        print Lout "$now_date|$event_string|\n";
        close(Lout);
    }
    if ( $DBX > 0 ) {
        print "$now_date|$event_string|\n";
    }
    $event_string = '';
}

sub error_logger {
    if ($SYSLOG) {
        open( Eout, ">>$UPERRfile" )
          || die "Can't open $UPERRfile: $!\n";
        print Eout "$now_date|$error_string|\n";
        close(Eout);
    }
    print "ERROR: $now_date|$error_string|\n";
    $error_string = '';
}

sub get_cpu_percent {
    $stat = '/proc/stat';
    open( FH, "<$stat" );
    @lines = <FH>;
    close(FH);
    (
        $cpu, $user,    $nice,  $system, $idle, $iowait,
        $irq, $softirq, $steal, $guest,  $guest_nice
    ) = split( ' ', $lines[0] );
    $cpu_user = $user + $nice;
    $cpu_idle = $idle + $iowait;
    $cpu_sys  = $system + $irq + $softirq;
    $cpu_vm   = $steal + $guest + $guest_nice;

    if ( defined($prev_user) ) {
        $cpu_user_diff   = $cpu_user - $prev_cpu_user;
        $cpu_idle_diff   = $cpu_idle - $prev_cpu_idle;
        $cpu_sys_diff    = $cpu_sys - $prev_cpu_sys;
        $cpu_vm_diff     = $cpu_vm - $prev_cpu_vm;
        $user_diff       = $user - $prev_user;
        $nice_diff       = $nice - $prev_nice;
        $system_diff     = $system - $prev_system;
        $idle_diff       = $idle - $prev_idle;
        $iowait_diff     = $iowait - $prev_iowait;
        $irq_diff        = $irq - $prev_irq;
        $softirq_diff    = $softirq - $prev_softirq;
        $steal_diff      = $steal - $prev_steal;
        $guest_diff      = $guest - $prev_guest;
        $guest_nice_diff = $guest_nice - $prev_guest_nice;
        $cpu_total_diff =
          $cpu_user_diff + $cpu_idle_diff + $cpu_sys_diff + $cpu_vm_diff;
        $cpu_user_percent =
          sprintf( "%.0f", ( ( $cpu_user_diff / $cpu_total_diff ) * 100 ) );
        $cpu_idle_percent =
          sprintf( "%.0f", ( ( $cpu_idle_diff / $cpu_total_diff ) * 100 ) );
        $cpu_sys_percent =
          sprintf( "%.0f", ( ( $cpu_sys_diff / $cpu_total_diff ) * 100 ) );
        $cpu_vm_percent =
          sprintf( "%.0f", ( ( $cpu_vm_diff / $cpu_total_diff ) * 100 ) );
    }
    else {
        $cpu_total = $cpu_user + $cpu_idle + $cpu_sys + $cpu_vm;
        $cpu_user_percent =
          sprintf( "%.0f", ( ( $cpu_user / $cpu_total ) * 100 ) );
        $cpu_idle_percent =
          sprintf( "%.0f", ( ( $cpu_idle / $cpu_total ) * 100 ) );
        $cpu_sys_percent =
          sprintf( "%.0f", ( ( $cpu_sys / $cpu_total ) * 100 ) );
        $cpu_vm_percent = sprintf( "%.0f", ( ( $cpu_vm / $cpu_total ) * 100 ) );
    }
    $prev_user       = $user;
    $prev_nice       = $nice;
    $prev_system     = $system;
    $prev_idle       = $idle;
    $prev_iowait     = $iowait;
    $prev_irq        = $irq;
    $prev_softirq    = $softirq;
    $prev_steal      = $steal;
    $prev_guest      = $guest;
    $prev_guest_nice = $guest_nice;
    $prev_cpu_user   = $cpu_user;
    $prev_cpu_idle   = $cpu_idle;
    $prev_cpu_sys    = $cpu_sys;
    $prev_cpu_vm     = $cpu_vm;
    return (
        $cpu_user_percent, $cpu_idle_percent, $cpu_sys_percent,
        $cpu_vm_percent,   $user_diff,        $nice_diff,
        $system_diff,      $idle_diff,        $iowait_diff,
        $irq_diff,         $softirq_diff,     $steal_diff,
        $guest_diff,       $guest_nice_diff
    );
}

sub get_cpu_load {
    $lavg = '/proc/loadavg';
    open( FH, "<$lavg" );
    @lines = <FH>;
    close(FH);
    $server_load = $lines[0];
    $server_load =~ s/ .*//gi;
    $server_load =~ s/\D//gi;
    return $server_load;
}

sub get_mem_usage {
    $meminfo = '/proc/meminfo';
    open( FH, "<$meminfo" );
    @lines = <FH>;
    close(FH);
    $mem_total = $lines[0];
    $mem_total =~ s/MemTotal: *//g;
    $mem_free = $lines[1];
    $mem_free =~ s/MemFree: *//g;
    $mem_used  = $mem_total - $mem_free;
    $mem_used  = floor( $mem_used / 1024 );
    $mem_total = floor( $mem_total / 1024 );
    $mem_free  = floor( $mem_free / 1023 );
    return ( $mem_total, $mem_used, $mem_free );
}

sub get_disk_space {
    @serverDISK = `$dfbin -B 1048576 -x nfs -x cifs -x sshfs -x ftpfs`;
    $ct         = 0;
    $ct_PCT     = 0;
    $disk_usage = '';
    foreach (@serverDISK) {
        if ( $serverDISK[$ct] =~ /(\d+\%)/ ) {
            $ct_PCT++;
            $usage = $1;
            $usage =~ s/\%//gi;
            $disk_usage .= "$ct_PCT $usage|";
        }
        $ct++;
    }
    return $disk_usage;
}

sub get_num_processes {
    $num_processes = 0;
    opendir( DH, '/proc' );
    while ( readdir(DH) ) {
        if ( looks_like_number($_) ) { $num_processes++; }
    }
    closedir(DH);
    return ($num_processes);
}
