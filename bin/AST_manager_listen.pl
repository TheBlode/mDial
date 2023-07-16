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
$DB          = 1;   # Debug flag, set to 0 for no debug messages, lots of output
$US          = '__';
$MT[0]       = '';
$vdcl_update = 0;
$vddl_update = 0;
$run_check   = 1;   # concurrency check
$last_keepalive_epoch = time();
$keepalive_skips      = 0;

if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--help/i ) {
        print "allowed run time options:\n";
        print "  [--test] = test\n";
        print "  [--debug] = verbose debug messages\n";
        print "  [--debugX] = Extra-verbose debug messages\n";
        print "  [--help] = this screen\n";
        print "\n";
        exit;
    }
    else {
        if ( $args =~ /--debug/i ) {
            $DB = 1;    # Debug flag
            print "\n----- DEBUGGING ENABLED -----\n\n";
        }
        if ( $args =~ /--debugX/i ) {
            $DBX = 1;
            print "\n----- SUPER-DUPER DEBUGGING -----\n\n";
        }
        if ( $args =~ /--test/i ) {
            $TEST = 1;
            $T    = 1;
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
if ( !$VARDB_port ) { $VARDB_port = '3306'; }
&get_time_now;
use Time::HiRes ( 'gettimeofday', 'usleep', 'sleep' )
  ;    # necessary to have perl sleep command of less than one second
use DBI;
use Net::Telnet ();
$dbhA = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$stmtA =
"SELECT telnet_host,telnet_port,ASTmgrUSERNAME,ASTmgrSECRET,ASTmgrUSERNAMEupdate,ASTmgrUSERNAMElisten,ASTmgrUSERNAMEsend,max_vicidial_trunks,answer_transfer_agent,local_gmt,ext_context,vd_server_logs,asterisk_version FROM servers where server_ip = '$server_ip';";
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
    $DBvd_server_logs        = $aryA[11];
    $asterisk_version        = $aryA[12];
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
    if   ($DBSERVER_GMT)              { $SERVER_GMT  = $DBSERVER_GMT; }
    if   ($DBext_context)             { $ext_context = $DBext_context; }
    if   ( $DBvd_server_logs =~ /Y/ ) { $SYSLOG      = '1'; }
    else                              { $SYSLOG      = '0'; }
}
$sthA->finish();
if ( !$telnet_port ) { $telnet_port = '5038'; }
$event_string = 'LOGGED INTO MYSQL SERVER ON 1 CONNECTION|';
&event_logger;
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
$one_day_interval = 90;    # 1 day loops for 3 months
while ( $one_day_interval > 0 ) {
    $event_string =
"STARTING NEW MANAGER TELNET CONNECTION||ATTEMPT|ONE DAY INTERVAL:$one_day_interval|";
    &event_logger;
    $tn = new Net::Telnet(
        Port                    => $telnet_port,
        Prompt                  => '/.*[\$%#>] $/',
        Output_record_separator => '',
        Max_buffer_length       => 4 * 1024 * 1024,
    );
    if ( length($ASTmgrUSERNAMElisten) > 3 ) {
        $telnet_login = $ASTmgrUSERNAMElisten;
    }
    else { $telnet_login = $ASTmgrUSERNAME; }
    $tn->open("$telnet_host");
    $tn->waitfor('/[0123]\n$/');    # print login
    $tn->print(
        "Action: Login\nUsername: $telnet_login\nSecret: $ASTmgrSECRET\n\n");
    $tn->waitfor('/Authentication accepted/');    # waitfor auth accepted
    $tn->buffer_empty;
    $event_string =
"STARTING NEW MANAGER TELNET CONNECTION|$telnet_login|CONFIRMED CONNECTION|ONE DAY INTERVAL:$one_day_interval|";
    &event_logger;
    $endless_loop = 864000;    # 1 day at .10 seconds per loop
    %ast_ver_str  = parse_asterisk_version($asterisk_version);

    if ( ( $ast_ver_str{major} = 1 ) && ( $ast_ver_str{minor} < 6 ) ) {
        while ( $endless_loop > 0 ) {
            usleep( 1 * 100 * 1000 );
            $msg              = '';
            $read_input_buf   = $tn->get( Errmode => Return, Timeout => 1, );
            $input_buf_length = length($read_input_buf);
            $msg              = $tn->errmsg;
            if ( ( $msg =~ /read timed-out/i ) || ( $msg eq '' ) ) {
            }
            else {
                print "ERRMSG: |$msg|\n";
            }
            if ( $msg =~ /filehandle isn\'t open/i ) {
                $endless_loop     = 0;
                $one_day_interval = 0;
                print "ERRMSG: |$msg|\n";
                print
"\nAsterisk server shutting down, PROCESS KILLED... EXITING\n\n";
                $event_string =
"Asterisk server shutting down, PROCESS KILLED... EXITING|ONE DAY INTERVAL:$one_day_interval|$msg|";
                &event_logger;
            }
            if ( ( $read_input_buf !~ /\n\n/ ) or ( $input_buf_length < 10 ) ) {
                if ( $endless_loop =~ /00$|50$/ ) {
                    $input_buf = "$input_buf$keepalive_lines$read_input_buf";
                    $input_buf =~ s/\n\n\n/\n\n/gi;
                    $keepalive_lines = '';
                }
                else { $input_buf = "$input_buf$read_input_buf"; }
            }
            else {
                $partial           = 0;
                $partial_input_buf = '';
                @input_lines       = @MT;
                if ( $read_input_buf !~ /\n\n$/ ) {
                    $read_input_buf =~ s/\(|\)/ /gi; # replace parens with space
                    $partial_input_buf = $read_input_buf;
                    $partial_input_buf =~ s/\n/-----/gi;
                    $partial_input_buf =~ s/\*/\\\*/gi;
                    $partial_input_buf =~ s/.*----------//gi;
                    $partial_input_buf =~ s/-----/\n/gi;
                    $read_input_buf    =~ s/$partial_input_buf$//gi;
                    $partial++;
                }
                if ( $endless_loop =~ /00$|50$/ ) {
                    $input_buf = "$input_buf$keepalive_lines$read_input_buf";
                    $input_buf =~ s/\n\n\n/\n\n/gi;
                    $keepalive_lines = '';
                }
                else { $input_buf = "$input_buf$read_input_buf"; }
                @input_lines = split( /\n\n/, $input_buf );
                if ($DB) {
                    print
"input buffer: $input_buf_length     lines: $#input_lines     partial: $partial\n";
                }
                if ( ($DB) && ($partial) ) {
                    print "-----[$partial_input_buf]-----\n\n";
                }
                if ($DB) { print "|$input_buf|\n"; }
                $manager_string = "$input_buf";
                &manager_output_logger;
                $input_buf    = "$partial_input_buf";
                @command_line = @MT;
                $ILcount      = 0;
                foreach (@input_lines) {
                    if (
                           ( $input_lines[$ILcount] =~ /CallerIDName: DCagcW/ )
                        && ( $input_lines[$ILcount] =~ /Event: Dial|State: Up/ )
                      )
                    {
                        $input_lines[$ILcount] =~ s/^\n|^\n\n//gi;
                        @command_line = split( /\n/, $input_lines[$ILcount] );
                        if ( $input_lines[$ILcount] =~ /Event: Dial/ ) {
                            if ( $command_line[3] =~ /Destination: /i ) {
                                $channel = $command_line[3];
                                $channel =~ s/Destination: |\s*$//gi;
                                $callid = $command_line[5];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[6];
                                $uniqueid =~ s/SrcUniqueID: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                if ( $channel !~ /local/i ) {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
"|$affected_rows Conference DIALs updated|\n";
                                    }
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~ /State: Up/ ) {
                            if ( $command_line[2] =~ /Channel: /i ) {
                                $channel = $command_line[2];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[5];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[6];
                                $uniqueid =~ s/SrcUniqueID: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid' and status='SENT';";
                                print STDERR "|$stmtA|\n";
                                my $affected_rows = $dbhA->do($stmtA);
                                if ($DB) {
                                    print
"|$affected_rows Conference DIALs updated|\n";
                                }
                            }
                        }
                    }
                    if (
                        (
                            $input_lines[$ILcount] =~
/State: Ringing|State: Up|State: Dialing|Event: Newstate|Event: Hangup|Event: Newcallerid|Event: Shutdown|Event: CPD-Result|Event: SIP-Hangup-Cause/
                        )
                        && ( $input_lines[$ILcount] !~ /ZOMBIE/ )
                      )
                    {
                        $input_lines[$ILcount] =~ s/^\n|^\n\n//gi;
                        @command_line = split( /\n/, $input_lines[$ILcount] );
                        if ($DB) {
                            $cmd_counter = 0;
                            foreach (@command_line) {
                                print "command_line[$cmd_counter] = $_\n";
                                $cmd_counter++;
                            }
                            print "\n";
                        }
                        if ( $input_lines[$ILcount] =~ /Event: Shutdown/ ) {
                            $endless_loop     = 0;
                            $one_day_interval = 0;
                            print
"\nAsterisk server shutting down, PROCESS KILLED... EXITING\n\n";
                            $event_string =
"Asterisk server shutting down, PROCESS KILLED... EXITING|ONE DAY INTERVAL:$one_day_interval|";
                            &event_logger;
                        }
                        if ( $input_lines[$ILcount] =~ /Event: Hangup/ ) {
                            if (   ( $command_line[2] =~ /^Channel: /i )
                                && ( $command_line[3] =~ /^Uniqueid: /i ) )
                            {
                                $channel = $command_line[2];
                                $channel =~ s/Channel: |\s*$//gi;
                                $uniqueid = $command_line[3];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='DEAD', channel='$channel' where server_ip = '$server_ip' and uniqueid = '$uniqueid' and callerid NOT LIKE \"DCagcW%\" and cmd_line_d!='Exten: 8309' and cmd_line_d!='Exten: 8310';";
                                if (   ( $channel !~ /local/i )
                                    && ( $channel !~ /CXFER/i ) )
                                {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows HANGUPS updated|\n";
                                    }
                                }
                                else {
                                    print STDERR
"Ignoring CXFER Local Hangup: |$channel|$server_ip|$uniqueid|$command_line[5]|\n";
                                }
                            }
                            else {
                                if (   ( $command_line[3] =~ /^Channel: /i )
                                    && ( $command_line[4] =~ /^Uniqueid: /i )
                                  ) ### post 2006-03-20 SVN -- Added Timestamp line
                                {
                                    $channel = $command_line[3];
                                    $channel =~ s/Channel: |\s*$//gi;
                                    $uniqueid = $command_line[4];
                                    $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                    $stmtA =
"UPDATE vicidial_manager set status='DEAD', channel='$channel' where server_ip = '$server_ip' and uniqueid = '$uniqueid' and callerid NOT LIKE \"DCagcW%\" and cmd_line_d!='Exten: 8309' and cmd_line_d!='Exten: 8310';";
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows HANGUPS updated|\n";
                                    }
                                }
                                else {
                                    $channel = $command_line[1];
                                    $channel =~ s/Channel: |\s*$//gi;
                                    $uniqueid = $command_line[2];
                                    $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                    $stmtA =
"UPDATE vicidial_manager set status='DEAD', channel='$channel' where server_ip = '$server_ip' and uniqueid = '$uniqueid' and callerid NOT LIKE \"DCagcW%\" and cmd_line_d!='Exten: 8309' and cmd_line_d!='Exten: 8310';";
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows HANGUPS updated|\n";
                                    }
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~ /State: Dialing/ ) {
                            if (   ( $command_line[1] =~ /^Channel: /i )
                                && ( $command_line[4] =~ /^Uniqueid: /i )
                              )    ### pre 2004-10-07 CVS
                            {
                                $channel = $command_line[1];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[3];
                                $callid =~ s/Callerid: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[4];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='SENT', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                print STDERR "|$stmtA|\n";
                                my $affected_rows = $dbhA->do($stmtA);
                                if ($DB) {
                                    print "|$affected_rows DIALINGs updated|\n";
                                }
                            }
                            if (   ( $command_line[1] =~ /^Channel: /i )
                                && ( $command_line[4] =~ /^CalleridName: /i )
                              )    ### post 2004-10-07 CVS
                            {
                                $channel = $command_line[1];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[4];
                                $callid =~ s/CalleridName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[5];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='SENT', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                print STDERR "|$stmtA|\n";
                                my $affected_rows = $dbhA->do($stmtA);
                                if ($DB) {
                                    print "|$affected_rows DIALINGs updated|\n";
                                }
                            }
                            if (   ( $command_line[2] =~ /^Channel: /i )
                                && ( $command_line[5] =~ /^CalleridName: /i )
                              )    ### post 2005-08-07 CVS
                            {
                                $channel = $command_line[2];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[5];
                                $callid =~ s/CalleridName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[6];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='SENT', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                print STDERR "|$stmtA|\n";
                                my $affected_rows = $dbhA->do($stmtA);
                                if ($DB) {
                                    print "|$affected_rows DIALINGs updated|\n";
                                }
                            }
                            if (   ( $command_line[3] =~ /^Channel: /i )
                                && ( $command_line[6] =~ /^CalleridName: /i )
                              )    ### post 2006-03-20 -- Added Timestamp line
                            {
                                $channel = $command_line[3];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[6];
                                $callid =~ s/CalleridName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[7];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='SENT', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                print STDERR "|$stmtA|\n";
                                my $affected_rows = $dbhA->do($stmtA);
                                if ($DB) {
                                    print "|$affected_rows DIALINGs updated|\n";
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~
                            /State: Ringing|State: Up/ )
                        {
                            if (   ( $command_line[1] =~ /^Channel: /i )
                                && ( $command_line[4] =~ /^Uniqueid: /i )
                              )    ### pre 2004-10-07 CVS
                            {
                                $channel = $command_line[1];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[3];
                                $callid =~ s/Callerid: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[4];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                if ( $channel !~ /local/i ) {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows RINGINGs updated|\n";
                                    }
                                }
                            }
                            if (   ( $command_line[1] =~ /^Channel: /i )
                                && ( $command_line[4] =~ /^CalleridName: /i )
                              )    ### post 2004-10-07 CVS
                            {
                                $channel = $command_line[1];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[4];
                                $callid =~ s/CalleridName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[5];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                if ( $channel !~ /local/i ) {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows RINGINGs updated|\n";
                                    }
                                }
                            }
                            if (   ( $command_line[2] =~ /^Channel: /i )
                                && ( $command_line[5] =~ /^CalleridName: /i )
                              )    ### post 2005-08-07 CVS
                            {
                                $channel = $command_line[2];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[5];
                                $callid =~ s/CalleridName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[6];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                if ( $channel !~ /local/i ) {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows RINGINGs updated|\n";
                                    }
                                }
                            }
                            if (   ( $command_line[3] =~ /^Channel: /i )
                                && ( $command_line[6] =~ /^CalleridName: /i )
                              )  ### post 2006-03-20 SVN -- Added Timestamp line
                            {
                                $channel = $command_line[3];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[6];
                                $callid =~ s/CalleridName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[7];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                if ( $channel !~ /local/i ) {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows RINGINGs updated|\n";
                                    }
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~ /Event: Newcallerid/ ) {
                            if (   ( $command_line[1] =~ /^Channel: /i )
                                && ( $command_line[3] =~ /^Uniqueid: /i ) )
                            {
                                $channel = $command_line[1];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[2];
                                $callid =~ s/Callerid: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[3];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                if ( $channel =~ /local/i ) {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows RINGINGs updated|\n";
                                    }
                                }
                            }
                            if (   ( $command_line[3] =~ /^Channel: /i )
                                && ( $command_line[6] =~ /^Uniqueid: /i )
                              )  ### post 2006-03-20 SVN -- Added Timestamp line
                            {
                                $channel = $command_line[3];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[5];
                                $callid =~ s/Callerid: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[6];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                if ( $channel =~ /local/i ) {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows RINGINGs updated|\n";
                                    }
                                }
                            }
                            if (   ( $command_line[2] =~ /^Channel: /i )
                                && ( $command_line[5] =~ /^Uniqueid: /i )
                                && ( $command_line[4] =~ /^CallerIDName: DC/i )
                              )
                            {
                                $channel = $command_line[2];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[4];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[5];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                if ( $channel =~ /local/i ) {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
"|$affected_rows Consultative XFERs updated|\n";
                                    }
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~ /Event: CPD-Result/ ) {
                            if (   ( $command_line[3] =~ /^Channel: /i )
                                && ( $command_line[5] =~ /^Uniqueid: /i ) )
                            {
                                &get_time_now;
                                $channel = $command_line[3];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[4];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[5];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $result = $command_line[6];
                                $result =~ s/Result: |\s*$//gi;
                                if ( length($result) > 0 ) {
                                    $lead_id = substr( $callid, 10, 10 );
                                    $lead_id = ( $lead_id + 0 );
                                    $stmtA =
"INSERT INTO vicidial_cpd_log set channel='$channel', uniqueid='$uniqueid', callerid='$callid', server_ip='$server_ip', lead_id='$lead_id', event_date='$now_date', result='$result';";
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
"|$affected_rows CPD_log inserted|$HRnow_date|$s_hires|$usec|\n";
                                    }
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~
                            /Event: SIP-Hangup-Cause/ )
                        {
                            if (   ( $command_line[3] =~ /^Channel: /i )
                                && ( $command_line[5] =~ /^Uniqueid: /i ) )
                            {
                                &get_time_now;
                                $channel = $command_line[3];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[4];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[5];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $result = $command_line[6];
                                $result =~ s/Result: |\s*$//gi;
                                @result_details = split( /\|/, $result );
                                if (   ( length($result) > 0 )
                                    && ( $result_details[0] !~ /^407/ ) )
                                {
                                    $lead_id       = substr( $callid, 10, 10 );
                                    $lead_id       = ( $lead_id + 0 );
                                    $beginUNIQUEID = $uniqueid;
                                    $beginUNIQUEID =~ s/\..*//gi;
                                    $stmtA =
"UPDATE vicidial_dial_log SET sip_hangup_cause='$result_details[0]',sip_hangup_reason='$result_details[1]',uniqueid='$uniqueid' where caller_code='$callid' and server_ip='$server_ip' and lead_id='$lead_id';";
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
"|$affected_rows dial_log updated|$callid|$server_ip|$result|\n";
                                    }
                                    $vddl_update =
                                      ( $vddl_update + $affected_rows );
                                    $preCtarget = ( $beginUNIQUEID - 180 )
                                      ;    # 180 seconds before call start
                                    (
                                        $preCsec,  $preCmin,  $preChour,
                                        $preCmday, $preCmon,  $preCyear,
                                        $preCwday, $preCyday, $preCisdst
                                    ) = localtime($preCtarget);
                                    $preCyear = ( $preCyear + 1900 );
                                    $preCmon++;
                                    if ( $preCmon < 10 ) {
                                        $preCmon = "0$preCmon";
                                    }
                                    if ( $preCmday < 10 ) {
                                        $preCmday = "0$preCmday";
                                    }
                                    if ( $preChour < 10 ) {
                                        $preChour = "0$preChour";
                                    }
                                    if ( $preCmin < 10 ) {
                                        $preCmin = "0$preCmin";
                                    }
                                    if ( $preCsec < 10 ) {
                                        $preCsec = "0$preCsec";
                                    }
                                    $preCSQLdate =
"$preCyear-$preCmon-$preCmday $preChour:$preCmin:$preCsec";
                                    $postCtarget = ( $beginUNIQUEID + 10 )
                                      ;    # 10 seconds after call start
                                    (
                                        $postCsec,  $postCmin,  $postChour,
                                        $postCmday, $postCmon,  $postCyear,
                                        $postCwday, $postCyday, $postCisdst
                                    ) = localtime($postCtarget);
                                    $postCyear = ( $postCyear + 1900 );
                                    $postCmon++;
                                    if ( $postCmon < 10 ) {
                                        $postCmon = "0$postCmon";
                                    }
                                    if ( $postCmday < 10 ) {
                                        $postCmday = "0$postCmday";
                                    }
                                    if ( $postChour < 10 ) {
                                        $postChour = "0$postChour";
                                    }
                                    if ( $postCmin < 10 ) {
                                        $postCmin = "0$postCmin";
                                    }
                                    if ( $postCsec < 10 ) {
                                        $postCsec = "0$postCsec";
                                    }
                                    $postCSQLdate =
"$postCyear-$postCmon-$postCmday $postChour:$postCmin:$postCsec";
                                    $stmtA =
"UPDATE vicidial_carrier_log SET sip_hangup_cause='$result_details[0]',sip_hangup_reason='$result_details[1]' where server_ip='$server_ip' and caller_code='$callid' and lead_id='$lead_id' and call_date > \"$preCSQLdate\" and call_date < \"$postCSQLdate\" order by call_date desc limit 1;";
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
"|$affected_rows carrier_log updated|$callid|$server_ip|$uniqueid|$result_details[0]|$result_details[1]|\n";
                                    }
                                    $vdcl_update =
                                      ( $vdcl_update + $affected_rows );
                                }
                            }
                        }
                    }
                    $ILcount++;
                }
            }
            $endless_loop--;
            $keepalive_count_loop++;
            if ($DB) {
                print STDERR
"      loop counter: |$endless_loop|$keepalive_count_loop|     |$vddl_update|$vdcl_update|\r";
            }
            if ( ( -e "$PATHhome/listenmgr.kill" ) or ($sendonlyone) ) {
                unlink("$PATHhome/listenmgr.kill");
                $endless_loop     = 0;
                $one_day_interval = 0;
                print "\nPROCESS KILLED MANUALLY... EXITING\n\n";
            }
            if ( $endless_loop =~ /00$|50$/ ) {
                $keepalive_lines = '';
                &get_time_now;
                $stmtA =
"SELECT vd_server_logs FROM servers where server_ip = '$VARserver_ip';";
                $sthA = $dbhA->prepare($stmtA)
                  or die "preparing: ", $dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                $sthArows = $sthA->rows;
                if ( $sthArows > 0 ) {
                    @aryA             = $sthA->fetchrow_array;
                    $DBvd_server_logs = $aryA[0];
                    if   ( $DBvd_server_logs =~ /Y/ ) { $SYSLOG = '1'; }
                    else                              { $SYSLOG = '0'; }
                }
                $sthA->finish();
                $stmtA =
"SELECT last_update FROM server_updater where server_ip = '$server_ip';";
                $sthA = $dbhA->prepare($stmtA)
                  or die "preparing: ", $dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                @aryA        = $sthA->fetchrow_array;
                $last_update = $aryA[0];
                $sthA->finish();
                $keepalive_epoch = time();
                $keepalive_sec   = ( $keepalive_epoch - $last_keepalive_epoch );

                if ( $keepalive_sec > 40 ) {
                    $keepalive_skips  = 0;
                    @keepalive_output = $tn->cmd(
                        String  => "Action: Command\nCommand: show uptime\n\n",
                        Prompt  => '/--END COMMAND--.*/',
                        Errmode => Return,
                        Timeout => 1
                    );
                    $msg     = $tn->errmsg;
                    $buf_ref = $tn->buffer;
                    $buf_len = length($$buf_ref);
                    if ($DB) {
                        print
"keepalive length: $#keepalive_output|$now_date|$msg|$buf_len|\n";
                    }
                    if ($DB) {
                        print
"+++++++++++++++++++++++++++++++sending keepalive transmit line: $keepalive_sec seconds   $endless_loop|$now_date|$last_update|\n";
                    }
                    $k = 0;
                    foreach (@keepalive_output) {
                        $keepalive_lines .= "$keepalive_output[$k]";
                        $k++;
                    }
                    $manager_string =
"PROCESS: keepalive length: $#keepalive_output|$k|$now_date";
                    &manager_output_logger;
                    $last_keepalive_epoch = time();
                }
                else {
                    $keepalive_skips++;
                    $buf_ref = $tn->buffer;
                    $buf_len = length($$buf_ref);
                    if ($DB) {
                        print
"-------------------------------no keepalive transmit necessary: $keepalive_sec seconds($keepalive_skips in a row)   $endless_loop|$now_date|$last_update|$buf_len|\n";
                    }
                    $manager_string =
"PROCESS: keepalive skip: $keepalive_sec seconds($keepalive_skips in a row)|$now_date";
                    &manager_output_logger;
                }
                $keepalive_count_loop = 0;
            }
        }
    }
    else {
        while ( $endless_loop > 0 ) {
            usleep( 1 * 100 * 1000 );
            $msg              = '';
            $read_input_buf   = $tn->get( Errmode => Return, Timeout => 1, );
            $input_buf_length = length($read_input_buf);
            $msg              = $tn->errmsg;
            if ( ( $msg =~ /read timed-out/i ) || ( $msg eq '' ) ) {
            }
            else {
                print "ERRMSG: |$msg|\n";
            }
            if ( $msg =~ /filehandle isn\'t open/i ) {
                $endless_loop     = 0;
                $one_day_interval = 0;
                print "ERRMSG: |$msg|\n";
                print
"\nAsterisk server shutting down, PROCESS KILLED... EXITING\n\n";
                $event_string =
"Asterisk server shutting down, PROCESS KILLED... EXITING|ONE DAY INTERVAL:$one_day_interval|$msg|";
                &event_logger;
            }
            if ( ( $read_input_buf !~ /\n\n/ ) or ( $input_buf_length < 10 ) ) {
                if ( $endless_loop =~ /00$|50$/ ) {
                    $input_buf = "$input_buf$keepalive_lines$read_input_buf";
                    $input_buf =~ s/\n\n\n/\n\n/gi;
                    $keepalive_lines = '';
                }
                else { $input_buf = "$input_buf$read_input_buf"; }
            }
            else {
                $partial           = 0;
                $partial_input_buf = '';
                @input_lines       = @MT;
                if ( $read_input_buf !~ /\n\n$/ ) {
                    $read_input_buf =~ s/\(|\)/ /gi; # replace parens with space
                    $partial_input_buf = $read_input_buf;
                    $partial_input_buf =~ s/\n/-----/gi;
                    $partial_input_buf =~ s/\*/\\\*/gi;
                    $partial_input_buf =~ s/.*----------//gi;
                    $partial_input_buf =~ s/-----/\n/gi;
                    $read_input_buf    =~ s/$partial_input_buf$//gi;
                    $partial++;
                }
                if ( $endless_loop =~ /00$|50$/ ) {
                    $input_buf = "$input_buf$keepalive_lines$read_input_buf";
                    $input_buf =~ s/\n\n\n/\n\n/gi;
                    $keepalive_lines = '';
                }
                else { $input_buf = "$input_buf$read_input_buf"; }
                @input_lines = split( /\n\n/, $input_buf );
                if ($DB) {
                    print
"input buffer: $input_buf_length     lines: $#input_lines     partial: $partial\n";
                }
                if ( ($DB) && ($partial) ) {
                    print "-----[$partial_input_buf]-----\n\n";
                }
                if ($DB) { print "|$input_buf|\n"; }
                $manager_string = "$input_buf";
                &manager_output_logger;
                $input_buf    = "$partial_input_buf";
                @command_line = @MT;
                $ILcount      = 0;
                foreach (@input_lines) {
                    if (
                        ( $input_lines[$ILcount] =~ /CallerIDName: DCagcW/ )
                        && ( $input_lines[$ILcount] =~
                            /Event: Dial|ChannelStateDesc: Up/ )
                      )
                    {
                        $input_lines[$ILcount] =~ s/^\n|^\n\n//gi;
                        @command_line = split( /\n/, $input_lines[$ILcount] );
                        $cmd_counter  = 0;
                        foreach (@command_line) {
                            print "command_line[$cmd_counter] = $_\n";
                            $cmd_counter++;
                        }
                        print "\n";
                        if ( $input_lines[$ILcount] =~ /Event: Dial/ ) {
                            if ( $command_line[4] =~ /Destination: /i ) {
                                $channel = $command_line[4];
                                $channel =~ s/Destination: |\s*$//gi;
                                $callid = $command_line[6];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[6];
                                $uniqueid =~ s/SrcUniqueID: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                if ( $channel !~ /local/i ) {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
"|$affected_rows Conference DIALs updated|\n";
                                    }
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~ /ChannelStateDesc: Up/ )
                        {
                            if ( $command_line[2] =~ /Channel: /i ) {
                                $channel = $command_line[2];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[6];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[9];
                                $uniqueid =~ s/SrcUniqueID: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid' and status='SENT';";
                                print STDERR "|$stmtA|\n";
                                my $affected_rows = $dbhA->do($stmtA);
                                if ($DB) {
                                    print
"|$affected_rows Conference DIALs updated|\n";
                                }
                            }
                        }
                    }
                    if (
                        (
                            $input_lines[$ILcount] =~
/Event: Newstate|Event: Hangup|Event: NewCallerid|Event: Shutdown|Event: CPD-Result|Event: SIP-Hangup-Cause|Event: DTMF/
                        )
                        && ( $input_lines[$ILcount] !~ /ZOMBIE/ )
                      )
                    {
                        $input_lines[$ILcount] =~ s/^\n|^\n\n//gi;
                        @command_line = split( /\n/, $input_lines[$ILcount] );
                        if ($DB) {
                            $cmd_counter = 0;
                            foreach (@command_line) {
                                print "command_line[$cmd_counter] = $_\n";
                                $cmd_counter++;
                            }
                            print "\n";
                        }
                        if ( $input_lines[$ILcount] =~ /Event: Shutdown/ ) {
                            $endless_loop     = 0;
                            $one_day_interval = 0;
                            print
"\nAsterisk server shutting down, PROCESS KILLED... EXITING\n\n";
                            $event_string =
"Asterisk server shutting down, PROCESS KILLED... EXITING|ONE DAY INTERVAL:$one_day_interval|";
                            &event_logger;
                        }
                        if ( $input_lines[$ILcount] =~ /Event: Hangup/ ) {
                            if (   ( $command_line[2] =~ /^Channel: /i )
                                && ( $command_line[3] =~ /^Uniqueid: /i ) )
                            {
                                $channel = $command_line[2];
                                $channel =~ s/Channel: |\s*$//gi;
                                $uniqueid = $command_line[3];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='DEAD', channel='$channel' where server_ip = '$server_ip' and uniqueid = '$uniqueid' and callerid NOT LIKE \"DCagcW%\" and cmd_line_d!='Exten: 8309' and cmd_line_d!='Exten: 8310';";
                                if (   ( $channel !~ /local/i )
                                    && ( $channel !~ /CXFER/i ) )
                                {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows HANGUPS updated|\n";
                                    }
                                }
                                else {
                                    print STDERR
"Ignoring CXFER Local Hangup: |$channel|$server_ip|$uniqueid|$command_line[5]|\n";
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~ /Event: Newstate/ ) {
                            if (   ( $command_line[2] =~ /^Channel: /i )
                                && ( $command_line[6] =~ /^CallerIDName: /i ) )
                            {
                                $channel = $command_line[2];
                                $channel =~ s/Channel: |\s*$//gi;
                                $state = $command_line[4];
                                $state =~ s/ChannelStateDesc: |\s*$//gi;
                                $callid = $command_line[6];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;    # remove leading quotes
                                $callid =~ s/\".*$//gi
                                  ;   # remove trailing quotes and anything else

                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }   # remove everything after the space for Orex
                                $uniqueid = $command_line[9];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                if ( $state =~ /Dialing/ ) {
                                    $stmtA =
"UPDATE vicidial_manager set status='SENT', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows DIALINGs updated|\n";
                                    }
                                }
                                if ( $state =~ /Ringing|Up/ ) {
                                    $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                    print STDERR "|$stmtA|\n";
                                    if ( $channel !~ /local/i ) {
                                        print STDERR
"|$channel|NON LOCAL CHANNEL >>>> EXECUTING ABOVE STATMENT|\n";
                                        my $affected_rows = $dbhA->do($stmtA);
                                        if ($DB) {
                                            print
"|$affected_rows RINGINGs updated|\n";
                                        }
                                    }
                                    else {
                                        print STDERR
"|$channel|LOCAL CHANNEL >>>> ABOVE STATMENT IGNORED|\n";
                                    }
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~ /Event: NewCallerid/ ) {
                            if (   ( $command_line[2] =~ /^Channel: /i )
                                && ( $command_line[5] =~ /^Uniqueid: /i ) )
                            {
                                $channel = $command_line[2];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[4];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;    # remove leading quotes
                                $callid =~ s/\".*$//gi
                                  ;   # remove trailing quotes and anything else
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }   # remove everything after the space for Orex
                                $uniqueid = $command_line[5];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $stmtA =
"UPDATE vicidial_manager set status='UPDATED', channel='$channel', uniqueid = '$uniqueid' where server_ip = '$server_ip' and callerid = '$callid'";
                                if ( $channel =~ /local/i ) {
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
                                          "|$affected_rows RINGINGs updated|\n";
                                    }
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~ /Event: DTMF/ ) {
                            if (   ( $command_line[2] =~ /^Channel: /i )
                                && ( $command_line[3] =~ /^Uniqueid: /i ) )
                            {
                                $channel = $command_line[2];
                                $channel =~ s/Channel: |\s*$//gi;
                                $uniqueid = $command_line[3];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $digit = $command_line[4];
                                $digit =~ s/Digit: |\s*$//gi;
                                $direction = $command_line[5];
                                $direction =~ s/Direction: |\s*$//gi;
                                $begin = $command_line[6];
                                $begin =~ s/Begin: |\s*$//gi;
                                $end = $command_line[7];
                                $end =~ s/End: |\s*$//gi;
                                $state = '';
                                if ( $begin eq 'Yes' ) { $state = 'Begin'; }
                                else {
                                    if ( $end eq 'Yes' ) { $state = 'End'; }
                                }
                                $stmtA =
"INSERT INTO vicidial_dtmf_log SET dtmf_time=NOW(),channel='$channel',server_ip='$server_ip',uniqueid='$uniqueid',digit='$digit',direction='$direction',state='$state'";
                                print STDERR "|$stmtA|\n";
                                my $affected_rows = $dbhA->do($stmtA);
                                ( $s_hires, $usec ) = gettimeofday()
                                  ; # get seconds and microseconds since the epoch
                                $usec   = sprintf( "%06s", $usec );
                                $HRmsec = substr( $usec, -6 );
                                (
                                    $HRsec,  $HRmin,  $HRhour,
                                    $HRmday, $HRmon,  $HRyear,
                                    $HRwday, $HRyday, $HRisdst
                                ) = localtime($s_hires);
                                $HRyear = ( $HRyear + 1900 );
                                $HRmon++;
                                if ( $HRmon < 10 )  { $HRmon   = "0$HRmon"; }
                                if ( $HRmday < 10 ) { $HRmday  = "0$HRmday"; }
                                if ( $HRhour < 10 ) { $HRFhour = "0$HRhour"; }
                                if ( $HRmin < 10 )  { $HRmin   = "0$HRmin"; }
                                if ( $HRsec < 10 )  { $HRsec   = "0$HRsec"; }
                                $HRnow_date =
"$HRyear-$HRmon-$HRmday $HRhour:$HRmin:$HRsec.$HRmsec";

                                if ($DB) {
                                    print
"|$affected_rows vicidial_dtmf inserted|$HRnow_date|$s_hires|$usec|\n";
                                }
                                $dtmf_string =
"$HRnow_date|$s_hires|$usec|$channel|$uniqueid|$digit|$direction|$state";
                                &dtmf_logger;
                            }
                        }
                        if ( $input_lines[$ILcount] =~ /Event: CPD-Result/ ) {
                            if (   ( $command_line[3] =~ /^Channel: /i )
                                && ( $command_line[5] =~ /^Uniqueid: /i ) )
                            {
                                &get_time_now;
                                $channel = $command_line[3];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[4];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;    # remove leading quotes
                                $callid =~ s/\".*$//gi
                                  ;   # remove trailing quotes and anything else
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }   # remove everything after the space for Orex
                                $uniqueid = $command_line[5];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $cpd_result = $command_line[6];
                                $cpd_result =~ s/CPDResult: |\s*$//gi;
                                $cpd_detailed_result = $command_line[7];
                                $cpd_detailed_result =~
                                  s/CPDDetailedResult: |\s*$//gi;
                                $cpd_call_id = $command_line[8];
                                $cpd_call_id =~ s/CPDCallID: |\s*$//gi;
                                $cpd_ref_id = $command_line[9];
                                $cpd_ref_id =~ s/CPDReferenceID: |\s*$//gi;
                                $cpd_camp_name = $command_line[10];
                                $cpd_camp_name =~ s/CPDCampaignName: |\s*$//gi;
                                print STDERR
"|cpd_result = $cpd_result|cpd_detailed_result = $cpd_detailed_result|cpd_call_id = $cpd_call_id|cpd_ref_id = $cpd_ref_id|cpd_camp_name = $cpd_camp_name|\n";

                                if ( length($cpd_result) > 0 ) {
                                    $lead_id = substr( $callid, 10, 10 );
                                    $lead_id = ( $lead_id + 0 );
                                    $stmtA =
"INSERT INTO vicidial_cpd_log set channel='$channel', uniqueid='$uniqueid', callerid='$callid', server_ip='$server_ip', lead_id='$lead_id', event_date='$now_date', result='$cpd_result';";
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
"|$affected_rows CPD_log inserted|$HRnow_date|$s_hires|$usec|\n";
                                    }
                                }
                            }
                        }
                        if ( $input_lines[$ILcount] =~
                            /Event: SIP-Hangup-Cause/ )
                        {
                            if (   ( $command_line[3] =~ /^Channel: /i )
                                && ( $command_line[5] =~ /^Uniqueid: /i ) )
                            {
                                &get_time_now;
                                $channel = $command_line[3];
                                $channel =~ s/Channel: |\s*$//gi;
                                $callid = $command_line[4];
                                $callid =~ s/CallerIDName: |\s*$//gi;
                                $callid =~ s/^\"//gi;
                                $callid =~ s/\".*$//gi;
                                if ( $callid =~
                                    /\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S\S/ )
                                {
                                    $callid =~ s/ .*//gi;
                                }
                                $uniqueid = $command_line[5];
                                $uniqueid =~ s/Uniqueid: |\s*$//gi;
                                $result = $command_line[6];
                                $result =~ s/Result: |\s*$//gi;
                                @result_details = split( /\|/, $result );
                                if (   ( length($result) > 0 )
                                    && ( $result_details[0] !~ /^407/ ) )
                                {
                                    $lead_id       = substr( $callid, 10, 10 );
                                    $lead_id       = ( $lead_id + 0 );
                                    $beginUNIQUEID = $uniqueid;
                                    $beginUNIQUEID =~ s/\..*//gi;
                                    $stmtA =
"UPDATE vicidial_dial_log SET sip_hangup_cause='$result_details[0]',sip_hangup_reason='$result_details[1]',uniqueid='$uniqueid' where caller_code='$callid' and server_ip='$server_ip' and lead_id='$lead_id';";
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
"|$affected_rows dial_log updated|$callid|$server_ip|$result|\n";
                                    }
                                    $vddl_update =
                                      ( $vddl_update + $affected_rows );
                                    $preCtarget = ( $beginUNIQUEID - 180 )
                                      ;    # 180 seconds before call start
                                    (
                                        $preCsec,  $preCmin,  $preChour,
                                        $preCmday, $preCmon,  $preCyear,
                                        $preCwday, $preCyday, $preCisdst
                                    ) = localtime($preCtarget);
                                    $preCyear = ( $preCyear + 1900 );
                                    $preCmon++;
                                    if ( $preCmon < 10 ) {
                                        $preCmon = "0$preCmon";
                                    }
                                    if ( $preCmday < 10 ) {
                                        $preCmday = "0$preCmday";
                                    }
                                    if ( $preChour < 10 ) {
                                        $preChour = "0$preChour";
                                    }
                                    if ( $preCmin < 10 ) {
                                        $preCmin = "0$preCmin";
                                    }
                                    if ( $preCsec < 10 ) {
                                        $preCsec = "0$preCsec";
                                    }
                                    $preCSQLdate =
"$preCyear-$preCmon-$preCmday $preChour:$preCmin:$preCsec";
                                    $postCtarget = ( $beginUNIQUEID + 10 )
                                      ;    # 10 seconds after call start
                                    (
                                        $postCsec,  $postCmin,  $postChour,
                                        $postCmday, $postCmon,  $postCyear,
                                        $postCwday, $postCyday, $postCisdst
                                    ) = localtime($postCtarget);
                                    $postCyear = ( $postCyear + 1900 );
                                    $postCmon++;
                                    if ( $postCmon < 10 ) {
                                        $postCmon = "0$postCmon";
                                    }
                                    if ( $postCmday < 10 ) {
                                        $postCmday = "0$postCmday";
                                    }
                                    if ( $postChour < 10 ) {
                                        $postChour = "0$postChour";
                                    }
                                    if ( $postCmin < 10 ) {
                                        $postCmin = "0$postCmin";
                                    }
                                    if ( $postCsec < 10 ) {
                                        $postCsec = "0$postCsec";
                                    }
                                    $postCSQLdate =
"$postCyear-$postCmon-$postCmday $postChour:$postCmin:$postCsec";
                                    $stmtA =
"UPDATE vicidial_carrier_log SET sip_hangup_cause='$result_details[0]',sip_hangup_reason='$result_details[1]' where server_ip='$server_ip' and caller_code='$callid' and lead_id='$lead_id' and call_date > \"$preCSQLdate\" and call_date < \"$postCSQLdate\" order by call_date desc limit 1;";
                                    print STDERR "|$stmtA|\n";
                                    my $affected_rows = $dbhA->do($stmtA);
                                    if ($DB) {
                                        print
"|$affected_rows carrier_log updated|$callid|$server_ip|$uniqueid|$result_details[0]|$result_details[1]|\n";
                                    }
                                    $vdcl_update =
                                      ( $vdcl_update + $affected_rows );
                                }
                            }
                        }
                    }
                    $ILcount++;
                }
            }
            $endless_loop--;
            $keepalive_count_loop++;
            if ($DB) {
                print STDERR
"      loop counter: |$endless_loop|$keepalive_count_loop|     |$vddl_update|$vdcl_update|\r";
            }
            if ( ( -e "$PATHhome/listenmgr.kill" ) or ($sendonlyone) ) {
                unlink("$PATHhome/listenmgr.kill");
                $endless_loop     = 0;
                $one_day_interval = 0;
                print "\nPROCESS KILLED MANUALLY... EXITING\n\n";
            }
            if ( $endless_loop =~ /00$|50$/ ) {
                $keepalive_lines = '';
                &get_time_now;
                $stmtA =
"SELECT vd_server_logs FROM servers where server_ip = '$VARserver_ip';";
                $sthA = $dbhA->prepare($stmtA)
                  or die "preparing: ", $dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                $sthArows = $sthA->rows;
                if ( $sthArows > 0 ) {
                    @aryA             = $sthA->fetchrow_array;
                    $DBvd_server_logs = $aryA[0];
                    if   ( $DBvd_server_logs =~ /Y/ ) { $SYSLOG = '1'; }
                    else                              { $SYSLOG = '0'; }
                }
                $sthA->finish();
                $stmtA =
"SELECT last_update FROM server_updater where server_ip = '$server_ip';";
                $sthA = $dbhA->prepare($stmtA)
                  or die "preparing: ", $dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                @aryA        = $sthA->fetchrow_array;
                $last_update = $aryA[0];
                $sthA->finish();
                $keepalive_epoch = time();
                $keepalive_sec   = ( $keepalive_epoch - $last_keepalive_epoch );

                if ( $keepalive_sec > 40 ) {
                    $keepalive_skips  = 0;
                    @keepalive_output = $tn->cmd(
                        String =>
                          "Action: Command\nCommand: core show uptime\n\n",
                        Prompt  => '/--END COMMAND--.*/',
                        Errmode => Return,
                        Timeout => 1
                    );
                    $msg     = $tn->errmsg;
                    $buf_ref = $tn->buffer;
                    $buf_len = length($$buf_ref);
                    if ($DB) {
                        print
"keepalive length: $#keepalive_output|$now_date|$msg|$buf_len|\n";
                    }
                    if ($DB) {
                        print
"+++++++++++++++++++++++++++++++sending keepalive transmit line: $keepalive_sec seconds   $endless_loop|$now_date|$last_update|\n";
                    }
                    $k = 0;
                    foreach (@keepalive_output) {
                        $keepalive_lines .= "$keepalive_output[$k]";
                        $k++;
                    }
                    $manager_string =
"PROCESS: keepalive length: $#keepalive_output|$k|$now_date";
                    &manager_output_logger;
                    $last_keepalive_epoch = time();
                }
                else {
                    $keepalive_skips++;
                    $buf_ref = $tn->buffer;
                    $buf_len = length($$buf_ref);
                    if ($DB) {
                        print
"-------------------------------no keepalive transmit necessary: $keepalive_sec seconds($keepalive_skips in a row)   $endless_loop|$now_date|$last_update|$buf_len|\n";
                    }
                    $manager_string =
"PROCESS: keepalive skip: $keepalive_sec seconds($keepalive_skips in a row)|$now_date";
                    &manager_output_logger;
                }
                $keepalive_count_loop = 0;
            }
        }
    }
    if ($DB) {
        print
"DONE... Exiting... Goodbye... See you later... Not really, initiating next loop...$one_day_interval left\n";
    }
    $event_string = 'HANGING UP|';
    &event_logger;
    @hangup = $tn->cmd(
        String  => "Action: Logoff\n\n",
        Prompt  => "/.*/",
        Errmode => Return,
        Timeout => 1
    );
    $tn->buffer_empty;
    $tn->waitfor( Match => '/Message:.*\n\n/', Timeout => 10 );
    $ok = $tn->close;
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

sub get_time_now #get the current date and time and epoch for logging call lengths and datetimes
{
    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    $year = ( $year + 1900 );
    $mon++;
    if ( $mon < 10 )  { $mon  = "0$mon"; }
    if ( $mday < 10 ) { $mday = "0$mday"; }
    if ( $hour < 10 ) { $hour = "0$hour"; }
    if ( $min < 10 )  { $min  = "0$min"; }
    if ( $sec < 10 )  { $sec  = "0$sec"; }
    $now_date_epoch  = time();
    $now_date        = "$year-$mon-$mday $hour:$min:$sec";
    $action_log_date = "$year-$mon-$mday";
}

sub event_logger {
    if ($SYSLOG) {
        open( Lout, ">>$PATHlogs/listen_process.$action_log_date" )
          || die "Can't open $PATHlogs/listen_process.$action_log_date: $!\n";
        print Lout "$now_date|$event_string|\n";
        close(Lout);
    }
    $event_string = '';
}

sub manager_output_logger {
    if ($SYSLOG) {
        open( MOout, ">>$PATHlogs/listen.$action_log_date" )
          || die "Can't open $PATHlogs/listen.$action_log_date: $!\n";
        print MOout "$now_date|$manager_string|\n";
        close(MOout);
    }
}

sub dtmf_logger {
    if ($SYSLOG) {
        open( Dout, ">>$PATHlogs/dtmf.$action_log_date" )
          || die "Can't open $PATHlogs/dttmf.$action_log_date: $!\n";
        print Dout "|$dtmf_string|\n";
        close(Dout);
    }
}

sub parse_asterisk_version {
    my $ast_ver_str     = $_[0];
    my @hyphen_parts    = split( /-/, $ast_ver_str );
    my $ast_ver_postfix = $hyphen_parts[1];
    my @dot_parts       = split( /\./, $hyphen_parts[0] );
    my %ast_ver_hash;
    if ( $dot_parts[0] <= 1 ) {
        %ast_ver_hash = (
            "major"    => $dot_parts[0],
            "minor"    => $dot_parts[1],
            "build"    => $dot_parts[2],
            "revision" => $dot_parts[3],
            "postfix"  => $ast_ver_postfix
        );
    }
    if ( $dot_parts[0] > 1 ) {
        %ast_ver_hash = (
            "major"    => 1,
            "minor"    => $dot_parts[0],
            "build"    => $dot_parts[1],
            "revision" => $dot_parts[2],
            "postfix"  => $ast_ver_postfix
        );
    }
    return (%ast_ver_hash);
}
