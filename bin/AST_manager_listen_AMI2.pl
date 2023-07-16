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
$DB=0;  # Debug flag, set to 0 for no debug messages, lots of output
$DBX=0;
$full_listen_log=0; # set to 1 to log all output to log file
$run_check=1; # concurrency check
$last_keepalive_epoch = time();
$keepalive_skips=0;
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
        print "allowed run time options:\n";
        print "  [--test] = test\n";
        print "  [--debug] = verbose debug messages\n";
        print "  [--debugX] = Extra-verbose debug messages\n";
        print "  [--help] = this screen\n";
        print "\n";
        exit;
        }
    else
        {
        if ($args =~ /--debug/i)
            {
            $DB=1; # Debug flag
            print "\n----- DEBUGGING ENABLED -----\n\n";
            }
        if ($args =~ /--debugX/i)
            {
            $DBX=1;
            print "\n----- SUPER-DUPER DEBUGGING -----\n\n";
            }
        if ($args =~ /--test/i)
            {
            $TEST=1;
            $T=1;
            }
        }
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
    if ($line =~ /^PATHhome/)    {$PATHhome = $line;   $PATHhome =~ s/.*=//gi;}
    if ($line =~ /^PATHlogs/)    {$PATHlogs = $line;   $PATHlogs =~ s/.*=//gi;}
    if ($line =~ /^PATHagi/)    {$PATHagi = $line;   $PATHagi =~ s/.*=//gi;}
    if ($line =~ /^PATHweb/)    {$PATHweb = $line;   $PATHweb =~ s/.*=//gi;}
    if ($line =~ /^PATHsounds/)    {$PATHsounds = $line;   $PATHsounds =~ s/.*=//gi;}
    if ($line =~ /^PATHmonitor/)    {$PATHmonitor = $line;   $PATHmonitor =~ s/.*=//gi;}
    if ($line =~ /^VARserver_ip/)    {$VARserver_ip = $line;   $VARserver_ip =~ s/.*=//gi;}
    if ($line =~ /^VARDB_server/)    {$VARDB_server = $line;   $VARDB_server =~ s/.*=//gi;}
    if ($line =~ /^VARDB_database/)    {$VARDB_database = $line;   $VARDB_database =~ s/.*=//gi;}
    if ($line =~ /^VARDB_user/)    {$VARDB_user = $line;   $VARDB_user =~ s/.*=//gi;}
    if ($line =~ /^VARDB_pass/)    {$VARDB_pass = $line;   $VARDB_pass =~ s/.*=//gi;}
    if ($line =~ /^VARDB_port/)    {$VARDB_port = $line;   $VARDB_port =~ s/.*=//gi;}
    $i++;
    }
$server_ip = $VARserver_ip;        # Asterisk server IP
if (!$VARDB_port) {$VARDB_port='3306';}
&get_time_now;
use Time::HiRes ('gettimeofday','usleep','sleep');  # necessary to have perl sleep command of less than one second
use DBI;
use Net::Telnet ();
use Switch;
$module = 'String::Escape qw( backslash unbackslash )';
$bs_loaded=0;
if (try_load($module)) 
    {
    $bs_loaded=1;
    }
$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
or die "Couldn't connect to database: " . DBI->errstr;
$stmtA = "SELECT telnet_host,telnet_port,ASTmgrUSERNAME,ASTmgrSECRET,ASTmgrUSERNAMEupdate,ASTmgrUSERNAMElisten,ASTmgrUSERNAMEsend,max_vicidial_trunks,answer_transfer_agent,local_gmt,ext_context,vd_server_logs,asterisk_version FROM servers where server_ip = '$server_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
if ($sthArows > 0)
    {
    @aryA = $sthA->fetchrow_array;
    $DBtelnet_host    =        $aryA[0];
    $DBtelnet_port    =        $aryA[1];
    $DBASTmgrUSERNAME =        $aryA[2];
    $DBASTmgrSECRET    =        $aryA[3];
    $DBASTmgrUSERNAMEupdate    =    $aryA[4];
    $DBASTmgrUSERNAMElisten    =    $aryA[5];
    $DBASTmgrUSERNAMEsend    =    $aryA[6];
    $DBmax_vicidial_trunks    =    $aryA[7];
    $DBanswer_transfer_agent=    $aryA[8];
    $DBSERVER_GMT        =    $aryA[9];
    $DBext_context        =    $aryA[10];
    $DBvd_server_logs     =    $aryA[11];
    $asterisk_version     =    $aryA[12];
    if ($DBtelnet_host)        {$telnet_host = $DBtelnet_host;}
    if ($DBtelnet_port)        {$telnet_port = $DBtelnet_port;}
    if ($DBASTmgrUSERNAME)        {$ASTmgrUSERNAME = $DBASTmgrUSERNAME;}
    if ($DBASTmgrSECRET)        {$ASTmgrSECRET = $DBASTmgrSECRET;}
    if ($DBASTmgrUSERNAMEupdate)    {$ASTmgrUSERNAMEupdate = $DBASTmgrUSERNAMEupdate;}
    if ($DBASTmgrUSERNAMElisten)    {$ASTmgrUSERNAMElisten = $DBASTmgrUSERNAMElisten;}
    if ($DBASTmgrUSERNAMEsend)    {$ASTmgrUSERNAMEsend = $DBASTmgrUSERNAMEsend;}
    if ($DBmax_vicidial_trunks)    {$max_vicidial_trunks = $DBmax_vicidial_trunks;}
    if ($DBanswer_transfer_agent)    {$answer_transfer_agent = $DBanswer_transfer_agent;}
    if ($DBSERVER_GMT)        {$SERVER_GMT = $DBSERVER_GMT;}
    if ($DBext_context)        {$ext_context = $DBext_context;}
    if ($DBvd_server_logs =~ /Y/)    {$SYSLOG = '1';}
        else {$SYSLOG = '0';}
    }
$sthA->finish();
if (!$telnet_port) {$telnet_port = '5038';}
$event_string='LOGGED INTO MYSQL SERVER ON 1 CONNECTION|';
&event_logger;
if ($run_check > 0)
    {
    my $grepout = `/bin/ps ax | grep $0 | grep -v grep | grep -v '/bin/sh'`;
    my $grepnum=0;
    $grepnum++ while ($grepout =~ m/\n/g);
    if ($grepnum > 2) 
        {
        if ($DB) {print "I am not alone! Another $0 is running! Exiting...\n";}
        $event_string = "I am not alone! Another $0 is running! Exiting...";
        &event_logger;
        exit;
        }
    }
$event_string="STARTING NEW MANAGER TELNET CONNECTION||ATTEMPT|ONE DAY INTERVAL:$one_day_interval|";
&event_logger;
$max_buffer = 4*1024*1024; # 4 meg buffer
$tn = new Net::Telnet (
    Port => $telnet_port,
    Prompt => '/\r\n/',
    Output_record_separator => "\n\n",
    Max_buffer_length => $max_buffer, 
    Telnetmode => 0,
);
$LItelnetlog = "$PATHlogs/listen_telnet_log.txt";  # uncomment for telnet log
if (length($ASTmgrUSERNAMElisten) > 3) {$telnet_login = $ASTmgrUSERNAMElisten;}
else {$telnet_login = $ASTmgrUSERNAME;}
$tn->open("$telnet_host"); 
$tn->waitfor('/Asterisk Call Manager\//');
$ami_version = $tn->getline(Errmode => Return, Timeout => 1,);
$ami_version =~ s/\n//gi;
print "----- AMI Version $ami_version -----\n";
$tn->print("Action: Login\nUsername: $telnet_login\nSecret: $ASTmgrSECRET");
$tn->waitfor('/Authentication accepted/');        # waitfor auth accepted
$tn->buffer_empty;
$event_string="STARTING NEW MANAGER TELNET CONNECTION|$telnet_login|CONFIRMED CONNECTION|AMI Version $ami_version|ONE DAY INTERVAL:$one_day_interval|";
&event_logger;
$loop_time = 1*100*1000;    # each loop show take 10 hundredths of a second
$sleep_micro_sec = 0;        # time to actually sleep in micro seconds
$begin_sec = 0;                # the seconds at the beginning of the loop
$begin_micro_sec = 0;        # the microseconds at the beginning of the loop
$end_sec = 0;                # the seconds at the end of the loop
$end_micro_sec = 0;            # the microseconds at the end of the loop
$sleep_diff = 0;            # how off the sleep actually was
$last_keep_alive_epoch = time();
$last_partial_keep_alive_epoch = $last_keep_alive_epoch;
$last_event_epoch = $last_keep_alive_epoch;
$keep_alive_sec = 30;
$keep_alive_skips = 0;
$keep_alive_response = 1;
$keep_alive_no_responses = 0;
%ast_ver_str = parse_asterisk_version($asterisk_version);
if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 13))
    {
    print "Asterisk version too low for this script. Exiting.\n\n\n";
    $event_string = "Asterisk version too low for this script. Exiting.";
    &event_logger;
    exit;
    }
else 
    {
    $endless_loop = 1;
    while($endless_loop > 0)
        {
        $breakout = 1;
        $record_line = '';
        %event_hash = ();
            ( $read_input_buf, $match ) = $tn->waitfor(Errmode => Return, Timeout => 1, Match => "/\n\n/" );
        chomp( $read_input_buf );
        if (($DBX) && ($bs_loaded) && (length($read_input_buf) > 0)) { print "|read|" . backslash( $read_input_buf ) . "|\n"; }
        if (($DBX) && ($bs_loaded) && (length($read_input_buf) > 0)) { print "|match|" . backslash( $match ) . "|\n"; }
        $msg='';
        $msg = $tn->errmsg;
        if ( ( $msg ne '' ) && ( $msg !~  /pattern match timed-out/i ) )
            {
            if ($msg =~ /filehandle isn\'t open/i)
                {
                $endless_loop=0;
                $one_day_interval=0;
                print "ERRMSG: |$msg|\n";
                print "\nAsterisk server shutting down, PROCESS KILLED... EXITING\n\n";
                $event_string="Asterisk server shutting down, PROCESS KILLED... EXITING|ONE DAY INTERVAL:$one_day_interval|$msg|";
                &event_logger;
                }
            else
                {
                print "ERRMSG: |$msg|\n";
                }
            }
        else
            {
            @lines = split( /\n/, $read_input_buf );
            $line_log='';
            foreach my $line ( @lines )
                {
                $line_log .= "$line\n";
                ($key,$value) = split( /: /, $line );
                if ($key ne "")
                    {
                    $value =~ s/\n//gi;    # remove new lines
                    $value =~ s/^ +//gi;    # remove leading white space
                    $value =~ s/ +$//gi;    # remove trailing white space
                    $event_hash{"$key"} = $value;
                    }
                }
            if ($full_listen_log > 0) 
                {
                $manager_string="$line_log";
                &manager_output_logger;
                }
            }
        $keep_alive_epoch = time();
        if ( $keep_alive_epoch - $last_partial_keep_alive_epoch >= 1 )
            {
            $last_partial_keep_alive_epoch = $keep_alive_epoch;
            if ( $buf_len > ($max_buffer * 0.9) )
                {
                if ($DB) { print "WARNING: BUFFER 90% full!!!! Purging it so we keep running.";}
                $manager_string="WARNING: BUFFER 90% full!!!! Purging it so we keep running.";
                &manager_output_logger;
                $tn->buffer_empty;
                }
            $stmtA = "SELECT vd_server_logs FROM servers where server_ip = '$server_ip';";
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
            $sthArows=$sthA->rows;
            if ($sthArows > 0)
                {
                @aryA = $sthA->fetchrow_array;
                $DBvd_server_logs =             $aryA[0];
                if ($DBvd_server_logs =~ /Y/)   {$SYSLOG = '1';}
                else {$SYSLOG = '0';}
                }
            $sthA->finish();
            if ( -e "$PATHhome/listenmgr.kill" ) 
                {
                unlink("$PATHhome/listenmgr.kill");
                $endless_loop=0;
                $one_day_interval=0;
                print "\nPROCESS KILLED MANUALLY... EXITING\n\n";
                }
            if ( $keep_alive_response == 0 ) 
                {
                $response_wait = $keep_alive_epoch - $last_keep_alive_epoch;
                if($DB) { print "No response to keep alive in $response_wait seconds.\n"; }
                }
            if ( $keep_alive_no_responses > 10 ) 
                {
                if($DB) { print "$keep_alive_no_responses failed to get a response. Exiting!!!" }
                $endless_loop=0;
                $one_day_interval=0;
                }
            &get_time_now;
            if ( $keep_alive_epoch - $last_event_epoch >= $keep_alive_sec )
                {
                if ( $keep_alive_epoch - $last_keep_alive_epoch >= $keep_alive_sec )
                    {
                    $keep_alive_skips = 0;
                    if ( $keep_alive_response == 0 ) { $keep_alive_no_responses++; }
                    $keep_alive_response = 0;
                    $keep_alive_string = "Action: Ping";
                    $tn->print($keep_alive_string);
                    $msg = $tn->errmsg;                    
                    $buf_ref = $tn->buffer;
                    $buf_len = length( $$buf_ref );
                    $output_size = @keep_alive_output;
                    if($DB) { print "++++++++++++++++sending keepalive |$keep_alive_type|em:$msg|$output_size|$endless_loop|$now_date|$buf_len|$keep_alive_no_responses\n"; }
                    if($DBX) { print "---@keep_alive_output---\n"; }
                    $manager_string="PROCESS: keepalive length: $output_size|$now_date";
                    &manager_output_logger;
                    $last_keep_alive_epoch = time();
                    }
                else
                    {
                    $keep_alive_skips++;
                    $buf_ref = $tn->buffer;
                    $buf_len = length( $$buf_ref );
                    if($DB){print "----------------no keepalive transmit necessary ($keep_alive_skips in a row) $endless_loop|$now_date|$buf_len|$keep_alive_no_responses\n";}
                    $manager_string="PROCESS: keepalive skip ($keep_alive_skips in a row)|$now_date";
                    &manager_output_logger;
                    }
                }
            else
                {
                if($DB){ print "Event recieved within the last $keep_alive_sec seconds. No keep alive needed.\n"; }
                }
            }
        $event_hash{'AMIVersion'} = $ami_version;
        $event_hash{'ServerIP'} = $server_ip;
        if ( ($DB) && ( keys %event_hash > 2 ) )
            {
            &get_time_now;
            print "\n\n$now_date|EVENT HASH:\n";
            foreach $key ( sort keys %event_hash )
                {
                $value = $event_hash{"$key"};
                print "  $key -> $value\n";
                } 
            print "\n";
            }
        $retcode = 1;
        if (exists($event_hash{"Event"})) 
            {
            $retcode = handle_event( %event_hash );
            $last_event_epoch = time();
            }
        elsif ( ( exists($event_hash{"Response"}) ) && ( exists($event_hash{"Ping"}) ) )
            {
            $keep_alive_response = 1;
            $keep_alive_no_responses = 0;
            }
        if ( $retcode == 0 )
            {
            $endless_loop=0;
            $one_day_interval=0;
            print "\nAsterisk server shutting down, PROCESS KILLED... EXITING\n\n";
            $event_string="Asterisk server shutting down, PROCESS KILLED... EXITING|ONE DAY INTERVAL:$one_day_interval|";
            &event_logger;
            }
        }
    usleep(1*100*1000);
    }
if($DB){print "DONE... Exiting... Goodbye... See you later... Not really, initiating next loop...$one_day_interval left\n";}
$event_string='HANGING UP|';
&event_logger;
@hangup = $tn->cmd(String => "Action: Logoff\n\n", Prompt => "/.*/", Errmode    => Return, Timeout    => 1); 
$tn->buffer_empty;
$tn->waitfor(Match => '/Message:.*\n\n/', Timeout => 10);
$ok = $tn->close;
$event_string='CLOSING DB CONNECTION|';
&event_logger;
$dbhA->disconnect();
if($DB){print "DONE... Exiting... Goodbye... See you later... Really I mean it this time\n";}
exit;
sub validate_cid_name
    {
    my ($cid_name) = @_;
    if (
        ( $cid_name =~ /DC\d\d\d\d\d\dW\d\d\d\d\d\d\d\d\d\dW/ ) ||    # 3way transfers
        ( $cid_name =~ /M\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d/) ||    # Manual Dials
        ( $cid_name =~ /V\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d/) ||    # Auto Dials
        ( $cid_name =~ /Y\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d\d/) ||    # Inbound Calls
        ( $cid_name =~ /^RINGAGENT|^RA_/ )
    ) 
        {
        return 1; # if so return 1 for true
        } 
    else 
        {
        return 0; # if not return 0 for false
        }
    }
sub get_valid_callid
    {
    my ( $CallerIDName, $ConnectedLineName ) = @_;
    if ( $CallerIDName =~ /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/) {$CallerIDName =~ s/ .*//gi;}
    if ( $ConnectedLineName =~ /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/) {$ConnectedLineName =~ s/ .*//gi;}
    if (  !(validate_cid_name($CallerIDName)) && (validate_cid_name($ConnectedLineName)) )
        {
        return $ConnectedLineName;
        }
    else
        {
        return $CallerIDName;
        }
    }
sub handle_event
    {
    my %event_hash = @_;
    switch ($event_hash{'Event'}) 
        {
        case "Shutdown" { return 0; }
        case "DTMFBegin" { return handle_dtmf_begin_event( %event_hash ); }
        case "DTMFEnd" { return handle_dtmf_end_event( %event_hash ); }        
        case "NewCallerid" { return handle_newcid_event( %event_hash ); }
        case "Newstate" { return handle_newstate_event( %event_hash ); }
        case "Hangup" { return handle_hangup_event( %event_hash ); }
        case "SIPCriticalTimeout" { return handle_sip_crit_timeout_event( %event_hash ); }
        case "PeerRegistered" { return handle_peer_registered_event( %event_hash ); }
        case "SIPRTPDisconnect" { return handle_sip_rtp_disconnect_event( %event_hash ); }
        case "PeerStatus" { return handle_peer_status_event( %event_hash ); }
        else { return 2; }
        }
    }
sub handle_sip_crit_timeout_event
    {
    my %event_hash = @_;
    if (
        ( exists $event_hash{'Type'} ) &&
        ( exists $event_hash{'CallID'} ) &&
        ( exists $event_hash{'SeqNo'} ) &&
        ( exists $event_hash{'Host'} ) &&
        ( exists $event_hash{'Timeout'} )
    )
        {
        my ($ip,$port) = split( ':', $event_hash{'Host'});
        $stmtA = "INSERT INTO vicidial_peer_event_log SET event_date=NOW(), event_type='CRITICALTIMEOUT', server_ip='$server_ip', host_ip='$ip', port='$port', channel_type='SIP', data='|Type=$event_hash{'Type'}|CallID=$event_hash{'CallID'}|SeqNo=$event_hash{'SeqNo'}|Timeout=$event_hash{'Timeout'}|'";
                if($DB){print STDERR "|$stmtA|";}
                my $affected_rows = $dbhA->do($stmtA);
        if($DB){print STDERR "$affected_rows|\n";}
        return 1;
        }
    else
        {
        print STDERR "SIPCriticalTimeout event does not have a Type, CallID, SeqNo, Host, or Timeout ?!!!\n";
        return 3;
        }
    }
sub handle_peer_registered_event
    {
    my %event_hash = @_;
    if (
        ( exists $event_hash{'ChannelType'} ) &&
        ( exists $event_hash{'Peer'} ) &&
        ( exists $event_hash{'Host'} )
    )
        {
        my ($ip,$port) = split( ':', $event_hash{'Host'});
        my ($type,$phone_extension) = split( '/', $event_hash{'Peer'});
        $stmtA = "INSERT INTO vicidial_peer_event_log SET event_date=NOW(6), event_type='REGISTERED', server_ip='$server_ip', host_ip='$ip', port='$port', channel_type='$event_hash{'ChannelType'}', peer='$event_hash{'Peer'}'";
                if($DB){print STDERR "|$stmtA|";}
                my $affected_rows = $dbhA->do($stmtA);
                if($DB){print STDERR "$affected_rows|\n";}
        $stmtA = "UPDATE phones set phone_ip='$ip' where server_ip='$server_ip' and extension='$phone_extension' and protocol='$event_hash{'ChannelType'}';";
        if($DB){print STDERR "|$stmtA|\n";}
        my $affected_rows = $dbhA->do($stmtA);
        if($DB){print "|$affected_rows phones updated|\n";}
                return 1;
        }
    else
        {
        print STDERR "PeerRegistered event does not have a ChannelType, Peer, or Host ?!!!\n";
        return 3;
        }
    }
sub handle_sip_rtp_disconnect_event
    {
    my %event_hash = @_;
    if (
        ( exists $event_hash{'Channel'} ) &&
        ( exists $event_hash{'RTPLastRX'} ) 
    )
        {
        my ($type,$phone_extension) = split( '/', $event_hash{'Channel'});
        $stmtA = "INSERT INTO vicidial_peer_event_log SET event_date=NOW(6), event_type='RTPDISCONNECT', server_ip='$server_ip', channel_type='$type', channel='$event_hash{'Channel'}', data='|RTPLastRX=$event_hash{'RTPLastRX'}|'";
                if($DB){print STDERR "|$stmtA|";}
                my $affected_rows = $dbhA->do($stmtA);
                if($DB){print STDERR "$affected_rows|\n";}
        return 1;
        }
    else
        {
        print STDERR "SIPRTPDisconnect event does not have a Channel or RTPLastRX ?!!!\n";
        return 3;
        }
    }
sub handle_peer_status_event
    {
    my %event_hash = @_;
    if (
        ( exists $event_hash{'ChannelType'} ) &&
        ( exists $event_hash{'PeerStatus'} ) &&
        ( exists $event_hash{'Peer'} )
    )
        {
        my ($type,$phone_extension) = split( '/', $event_hash{'Peer'});
        my $data = '|';
        if ( exists( $event_hash{'PingTime'} )) { $data .= "PingTime=$event_hash{'PingTime'}|";}
        if ( exists( $event_hash{'Time'} )) { $data .= "Time=$event_hash{'Time'}|";}
        if ( exists( $event_hash{'MaxPing'} )) { $data .= "MaxPing=$event_hash{'MaxPing'}|";}
        $stmtA = "INSERT INTO vicidial_peer_event_log SET event_date=NOW(6), event_type='$event_hash{'PeerStatus'}', server_ip='$server_ip', channel_type='$event_hash{'ChannelType'}', peer='$event_hash{'Peer'}', data='$data'";
                if($DB){print STDERR "|$stmtA|";}
                my $affected_rows = $dbhA->do($stmtA);
                if($DB){print STDERR "$affected_rows|\n";}
        if ( exists( $event_hash{'PingTime'} )) 
            {
            $stmtA = "UPDATE phones set peer_status = '$event_hash{'PeerStatus'}', ping_time = '$event_hash{'PingTime'}' where server_ip='$server_ip' and extension='$phone_extension' and protocol='$event_hash{'ChannelType'}';";
            }
        else
            {
            $stmtA = "UPDATE phones set peer_status = '$event_hash{'PeerStatus'}' where server_ip='$server_ip' and extension='$phone_extension' and protocol='$event_hash{'ChannelType'}';";
            }
                if($DB){print STDERR "|$stmtA|\n";}
                my $affected_rows = $dbhA->do($stmtA);
                if($DB){print "|$affected_rows phones updated|\n";}
                return 1;
        }
    else
        {
        print STDERR "PeerStatus event does not have a ChannelType, PeerStatus, Peer, or Time ?!!!\n";
        return 3;
        }
    }
sub handle_hangup_event
    {
    my %event_hash = @_;
    if ( 
        ( exists $event_hash{'Channel'} ) && 
        ( exists $event_hash{'Uniqueid'} ) &&
        ( exists $event_hash{'CallerIDName'} ) &&
        ( exists $event_hash{'ConnectedLineName'} )
    ) 
        {
        $call_id = get_valid_callid( $event_hash{'CallerIDName'}, $event_hash{'ConnectedLineName'} ); 
        if ( ( $event_hash{'Channel'} !~ /local/i) && ( $event_hash{'Channel'} !~ /cxfer/i) )
            {
            $stmtA = "UPDATE vicidial_manager set status='DEAD', channel='$event_hash{'Channel'}' where server_ip = '$server_ip' and uniqueid = '$event_hash{'Uniqueid'}' and cmd_line_d!='Exten: 8309' and cmd_line_d!='Exten: 8310';";
            if($DB){print STDERR "|$stmtA|\n";}
            my $affected_rows = $dbhA->do($stmtA);
            if($DB){print "|$affected_rows HANGUPS updated|\n";}
            return 1;
            }
        else
            {
            if($DB){print STDERR "Ignoring CXFER Local Hangup: |$event_hash{'Channel'}|$server_ip|$event_hash{'Uniqueid'}|$callid|\n";}
            return 1;
            }
        }
    else 
        {
        print STDERR "Hangup event does not have a Channel, Uniqueid, or CallerIDName ?!!!\n";
        return 3;
        }
    }
sub handle_newstate_event
    {
    my %event_hash = @_;
    if (
        ( exists $event_hash{'Channel'} ) &&
        ( exists $event_hash{'Uniqueid'} ) &&
        ( exists $event_hash{'CallerIDName'} ) &&
        ( exists $event_hash{'ChannelStateDesc'} ) &&
        ( exists $event_hash{'ConnectedLineName'} )
    )
        {
        $call_id = get_valid_callid( $event_hash{'CallerIDName'}, $event_hash{'ConnectedLineName'} );
        if ($event_hash{'ChannelStateDesc'} =~ /Dialing/)
            {
            $stmtA = "UPDATE vicidial_manager set status='SENT', channel='$event_hash{'Channel'}', uniqueid = '$event_hash{'Uniqueid'}' where server_ip = '$event_hash{'ServerIP'}' and callerid = '$call_id'";
            if($DB){print STDERR "|$stmtA|\n";}
            my $affected_rows = $dbhA->do($stmtA);
            if($DB){print "|$affected_rows DIALINGs updated|\n";}
            }
        elsif ($event_hash{'ChannelStateDesc'} =~ /Ringing|Up/)
            {
            $stmtA = "UPDATE vicidial_manager set status='UPDATED', channel='$event_hash{'Channel'}', uniqueid = '$event_hash{'Uniqueid'}' where server_ip = '$event_hash{'ServerIP'}' and callerid = '$call_id' and status != 'NEW'";
            if($DB){print STDERR "|$stmtA|\n";}
            if ($event_hash{'Channel'} !~ /local/i)
                {
                if($DB){print STDERR "|$event_hash{'Channel'}|NON LOCAL CHANNEL >>>> EXECUTING ABOVE STATMENT|\n";}
                my $affected_rows = $dbhA->do($stmtA);
                if($DB){print "|$affected_rows RINGINGs updated|\n";}
                }
            else
                {
                if($DB){print STDERR "|$event_hash{'Channel'}|LOCAL CHANNEL >>>> ABOVE STATMENT IGNORED|\n";}
                }
            }
        else 
            {
            if ( $DBX ) { print "Channel State $event_hash{'ChannelStateDesc'} not Dialing, Ringing, or Up. Ignoring."; }
            }
        return 1;
        }
    else
        {
        print STDERR "Newstate event does not have a Channel, Uniqueid, ChannelStateDesc, ConnectedLineName, or CallerIDName ?!!!\n";
        return 3;
        }
    }
sub handle_newcid_event
    {
    my %event_hash = @_;
    if (
        ( exists $event_hash{'Channel'} ) &&
        ( exists $event_hash{'Uniqueid'} ) &&
        ( exists $event_hash{'CallerIDName'} ) &&
        ( exists $event_hash{'ConnectedLineName'} )
    )
        {
        $call_id = get_valid_callid( $event_hash{'CallerIDName'}, $event_hash{'ConnectedLineName'} );
        $stmtA = "UPDATE vicidial_manager set status='UPDATED', channel='$event_hash{'Channel'}', uniqueid = '$event_hash{'Uniqueid'}' where server_ip = '$event_hash{'ServerIP'}' and callerid = '$call_id'";
        if ($event_hash{'Channel'} =~ /local/i)
            {
            if($DB){print STDERR "|$stmtA|\n";}
            my $affected_rows = $dbhA->do($stmtA);
            if($DB){print "|$affected_rows RINGINGs updated|\n";}
            }
        return 1;
        }
    else
        {
        print STDERR "NewCallerid event does not have a Channel, Uniqueid, ConnectedLineName, or CallerIDName ?!!!\n";
        return 3;
        }
    }
sub handle_dtmf_begin_event
    {
    my %event_hash = @_;
    if (
        ( exists $event_hash{'Channel'} ) &&
        ( exists $event_hash{'Uniqueid'} ) &&
        ( exists $event_hash{'Direction'} ) &&
        ( exists $event_hash{'Digit'} ) &&
        ( exists $event_hash{'CallerIDName'} ) &&
        ( exists $event_hash{'ConnectedLineName'} )
    )
        {
        $call_id = get_valid_callid( $event_hash{'CallerIDName'}, $event_hash{'ConnectedLineName'} );
        $stmtA = "INSERT INTO vicidial_dtmf_log SET dtmf_time=NOW(),channel='$event_hash{'Channel'}',server_ip='$event_hash{'ServerIP'}',uniqueid='$event_hash{'Uniqueid'}',digit='$event_hash{'Digit'}',direction='$event_hash{'Direction'}',state='Begin'";
        if($DB){print STDERR "|$stmtA|\n";}
        my $affected_rows = $dbhA->do($stmtA);
        ($s_hires, $usec) = gettimeofday();   # get seconds and microseconds since the epoch
        $usec = sprintf("%06s", $usec);
        $HRmsec = substr($usec, -6);
        ($HRsec,$HRmin,$HRhour,$HRmday,$HRmon,$HRyear,$HRwday,$HRyday,$HRisdst) = localtime($s_hires);
        $HRyear = ($HRyear + 1900);
        $HRmon++;
        if ($HRmon < 10) {$HRmon = "0$HRmon";}
        if ($HRmday < 10) {$HRmday = "0$HRmday";}
        if ($HRhour < 10) {$HRFhour = "0$HRhour";}
        if ($HRmin < 10) {$HRmin = "0$HRmin";}
        if ($HRsec < 10) {$HRsec = "0$HRsec";}
        $HRnow_date = "$HRyear-$HRmon-$HRmday $HRhour:$HRmin:$HRsec.$HRmsec";
        if($DB){print "|$affected_rows vicidial_dtmf inserted|$HRnow_date|$s_hires|$usec|\n";}
        $dtmf_string = "$HRnow_date|$s_hires|$usec|$event_hash{'Channel'}|$event_hash{'Uniqueid'}|$event_hash{'Digit'}|$event_hash{'Direction'}|Begin|$event_hash{'CallerIDName'}";
        &dtmf_logger;
        return 1;
        }
    else
        {
        print STDERR "DTMFBegin event does not have a Channel, Uniqueid, Direction, Digit, ConnectedLineName, or CallerIDName ?!!!\n";
        return 3;
        }
    }
sub handle_dtmf_end_event
    {
    my %event_hash = @_;
    if (
        ( exists $event_hash{'Channel'} ) &&
        ( exists $event_hash{'Uniqueid'} ) &&
        ( exists $event_hash{'Direction'} ) &&
        ( exists $event_hash{'Digit'} ) &&
        ( exists $event_hash{'CallerIDName'} ) &&
        ( exists $event_hash{'ConnectedLineName'} )
    )
        {
        $call_id = get_valid_callid( $event_hash{'CallerIDName'}, $event_hash{'ConnectedLineName'} );
        $stmtA = "INSERT INTO vicidial_dtmf_log SET dtmf_time=NOW(),channel='$event_hash{'Channel'}',server_ip='$event_hash{'ServerIP'}',uniqueid='$event_hash{'Uniqueid'}',digit='$event_hash{'Digit'}',direction='$event_hash{'Direction'}',state='End'";
        if($DB){print STDERR "|$stmtA|\n";}
        my $affected_rows = $dbhA->do($stmtA);
        ($s_hires, $usec) = gettimeofday();   # get seconds and microseconds since the epoch
        $usec = sprintf("%06s", $usec);
        $HRmsec = substr($usec, -6);
        ($HRsec,$HRmin,$HRhour,$HRmday,$HRmon,$HRyear,$HRwday,$HRyday,$HRisdst) = localtime($s_hires);
        $HRyear = ($HRyear + 1900);
        $HRmon++;
        if ($HRmon < 10) {$HRmon = "0$HRmon";}
        if ($HRmday < 10) {$HRmday = "0$HRmday";}
        if ($HRhour < 10) {$HRFhour = "0$HRhour";}
        if ($HRmin < 10) {$HRmin = "0$HRmin";}
        if ($HRsec < 10) {$HRsec = "0$HRsec";}
        $HRnow_date = "$HRyear-$HRmon-$HRmday $HRhour:$HRmin:$HRsec.$HRmsec";
        if($DB){print "|$affected_rows vicidial_dtmf inserted|$HRnow_date|$s_hires|$usec|\n";}
        $dtmf_string = "$HRnow_date|$s_hires|$usec|$event_hash{'Channel'}|$event_hash{'Uniqueid'}|$event_hash{'Digit'}|$event_hash{'Direction'}|End|$event_hash{'CallerIDName'}";
        &dtmf_logger;
        return 1;
        }
    else
        {
        print STDERR "DTMFEnd event does not have a Channel, Uniqueid, Direction, Digit, ConnectedLineName, or CallerIDName ?!!!\n";
        return 3;
        }
    }
sub get_time_now    #get the current date and time and epoch for logging call lengths and datetimes
    {
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year = ($year + 1900);
    $mon++;
    if ($mon < 10) {$mon = "0$mon";}
    if ($mday < 10) {$mday = "0$mday";}
    if ($hour < 10) {$hour = "0$hour";}
    if ($min < 10) {$min = "0$min";}
    if ($sec < 10) {$sec = "0$sec";}
    $now_date_epoch = time();
    $now_date = "$year-$mon-$mday $hour:$min:$sec";
    $action_log_date = "$year-$mon-$mday";
    }
sub event_logger 
    {
    if ($SYSLOG)
        {
        open(Lout, ">>$PATHlogs/listen_process.$action_log_date")
                || die "Can't open $PATHlogs/listen_process.$action_log_date: $!\n";
        print Lout "$now_date|$event_string|\n";
        close(Lout);
        }
    $event_string='';
    }
sub manager_output_logger
    {
    if ($SYSLOG)
        {
        open(MOout, ">>$PATHlogs/listen.$action_log_date")
                || die "Can't open $PATHlogs/listen.$action_log_date: $!\n";
        print MOout "$now_date|$manager_string|\n";
        close(MOout);
        }
    }
sub dtmf_logger
    {
    if ($SYSLOG)
        {
        open(Dout, ">>$PATHlogs/dtmf.$action_log_date")
                || die "Can't open $PATHlogs/dtmf.$action_log_date: $!\n";
        print Dout "|$dtmf_string|\n";
        close(Dout);
        }
    }
sub parse_asterisk_version
    {
    my $ast_ver_str = $_[0];
    my @hyphen_parts = split( /-/ , $ast_ver_str );
    my $ast_ver_postfix = $hyphen_parts[1];
    my @dot_parts = split( /\./ , $hyphen_parts[0] );
    my %ast_ver_hash;
    if ( $dot_parts[0] <= 1 )
        {
            %ast_ver_hash = (
                "major" => $dot_parts[0],
                "minor" => $dot_parts[1],
                "build" => $dot_parts[2],
                "revision" => $dot_parts[3],
                "postfix" => $ast_ver_postfix
            );
        }
    if ( $dot_parts[0] > 1 )
        {
            %ast_ver_hash = (
                "major" => 1,
                "minor" => $dot_parts[0],
                "build" => $dot_parts[1],
                "revision" => $dot_parts[2],
                "postfix" => $ast_ver_postfix
            );
        }
    return ( %ast_ver_hash );
    }
sub try_load 
    {
     my $mod = shift;
    eval("use $mod");
    if ($@) 
        {
        return(0);
        }
    else 
        {
        return(1);
        }
    }
