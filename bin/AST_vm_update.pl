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
$DB=0;  # Debug flag, set to 0 for no debug messages per minute, can be overridden by CLI flag
$DBX=0;  # Extra Debug flag, set to 0 for no debug messages per minute, can be overridden by CLI flag
$US='__';
$MT[0]='';
$secX = time();
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
        print "  [-t] = test\n";
        print "  [-debug] = verbose debug messages\n";
        print "  [-debugX] = extra verbose debug messages\n";
        print "\n";
        exit;
        }
    else
        {
        if ($args =~ /-debug/i)
            {
            $DB=1; # Debug flag
            print "Debug output enabled\n";
            }
        if ($args =~ /-debugX/i)
            {
            $DBX=1; # Debug flag
            print "Extra Debug output enabled\n";
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
$voicemail_boxes=0;
$voicemail_updates=0;
if (!$VARDB_port) {$VARDB_port='3306';}
use Time::HiRes ('gettimeofday','usleep','sleep');  # necessary to have perl sleep command of less than one second
use DBI;
use Net::Telnet ();
$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;
$stmtA = "SELECT count(*) from system_settings where active_voicemail_server='$server_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
if ($DB) {print "|$stmtA|\n";}
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
$rec_count=0;
if ($sthArows > 0)
    {
    @aryA = $sthA->fetchrow_array;
    $active_voicemail_server = $aryA[0];
    }
$sthA->finish(); 
if ($active_voicemail_server < 1)
    {
    if ($DB) {print "This is not the active voicemail server, exiting: |$server_ip|$active_voicemail_server|\n";}
    exit;
    }
$stmtA = "SELECT telnet_host,telnet_port,ASTmgrUSERNAME,ASTmgrSECRET,ASTmgrUSERNAMEupdate,ASTmgrUSERNAMElisten,ASTmgrUSERNAMEsend,max_vicidial_trunks,answer_transfer_agent,local_gmt,ext_context,asterisk_version FROM servers where server_ip = '$server_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
if ($DBX) {print "|$stmtA|\n";}
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
$rec_count=0;
if ($sthArows > 0)
    {
    @aryA = $sthA->fetchrow_array;
    $DBtelnet_host    =            $aryA[0];
    $DBtelnet_port    =            $aryA[1];
    $DBASTmgrUSERNAME    =        $aryA[2];
    $DBASTmgrSECRET    =            $aryA[3];
    $DBASTmgrUSERNAMEupdate    =    $aryA[4];
    $DBASTmgrUSERNAMElisten    =    $aryA[5];
    $DBASTmgrUSERNAMEsend    =    $aryA[6];
    $DBmax_vicidial_trunks    =    $aryA[7];
    $DBanswer_transfer_agent=    $aryA[8];
    $DBSERVER_GMT        =        $aryA[9];
    $DBext_context    =            $aryA[10];
    $asterisk_version    =        $aryA[11];
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
    }
$sthA->finish(); 
@PTvoicemail_ids=@MT;
$stmtA = "SELECT distinct voicemail_id from phones;";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
if ($DB) {print "$sthArows|$stmtA|\n";}
$rec_count=0;
while ($sthArows > $rec_count)
    {
    @aryA = $sthA->fetchrow_array;
    $PTvoicemail_ids[$rec_count] =     $aryA[0];
    $rec_count++;
    }
$sthA->finish(); 
$max_buffer = 4*1024*1024; # 4 meg buffer
$t = '';
$telnet_log_file = '';
if ($DBX)
    {
    $telnet_log_file = "$PATHlogs/AST_vm_telnet_log.$secX";
        $t = new Net::Telnet (
                Port => $telnet_port,
                Prompt => '/\r\n/',
                Output_record_separator => "\n\n",
                Max_buffer_length => $max_buffer,
                Telnetmode => 0,
        Dump_log => $telnet_log_file
        );
    }
else
    {
    $t = new Net::Telnet (
            Port => $telnet_port,
            Prompt => '/\r\n/',
            Output_record_separator => "\n\n",
            Max_buffer_length => $max_buffer,
            Telnetmode => 0,
    );
    }    
if (length($ASTmgrUSERNAMEsend) > 3) {$telnet_login = $ASTmgrUSERNAMEsend;}
else {$telnet_login = $ASTmgrUSERNAME;}
$t->open("$telnet_host");
$t->waitfor('/Asterisk Call Manager\//');
$ami_version = $t->getline(Errmode => Return, Timeout => 1,);
$ami_version =~ s/\n//gi;
if ($DB) {print "----- AMI Version $ami_version -----\n";}
$t->print("Action: Login\nUsername: $telnet_login\nSecret: $ASTmgrSECRET");
$t->waitfor('/Authentication accepted/');              # waitfor auth accepted
$t->buffer_empty;
%ast_ver_str = parse_asterisk_version($asterisk_version);
$command_end = "\n\n";
if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} >= 13)) { $command_end = '';}
$i=0;
foreach(@PTvoicemail_ids)
    {
    @list_channels=@MT;
    $t->buffer_empty;
    if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 6))
        {
        @list_channels = $t->cmd(String => "Action: MailboxCount\nMailbox: $PTvoicemail_ids[$i]\n\nAction: Ping$command_end", Prompt => '/Response: Pong.*/'); 
        $j=0;
        foreach(@list_channels)
            {
            if ($list_channels[$j] =~ /Mailbox: $PTvoicemail_ids[$i]/)
                {
                $NEW_messages[$i] = "$list_channels[$j+1]";
                $NEW_messages[$i] =~ s/NewMessages: |\n//gi;
                $OLD_messages[$i] = "$list_channels[$j+2]";
                $OLD_messages[$i] =~ s/OldMessages: |\n//gi;
                }
            $j++;
            }
        }
    elsif (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 13))
        {
        @list_channels = $t->cmd(String => "Action: MailboxCount\nMailbox: $PTvoicemail_ids[$i]\n\nAction: Ping$command_end", Prompt => '/Response: Success\nPing: Pong.*/');
        $j=0;
        foreach(@list_channels)
            {
            if($DBX){print "$j - $list_channels[$j]";}
            if ($list_channels[$j] =~ /Mailbox: $PTvoicemail_ids[$i]/)
                {
                $URG_messages[$i] = "$list_channels[$j+1]";
                $URG_messages[$i] =~ s/UrgMessages: |\n//gi;
                $NEW_messages[$i] = "$list_channels[$j+2]";
                $NEW_messages[$i] =~ s/NewMessages: |\n//gi;
                $OLD_messages[$i] = "$list_channels[$j+3]";
                $OLD_messages[$i] =~ s/OldMessages: |\n//gi;
                }
            $j++;
            }
        }
    else
        {
            ( $now_sec, $now_micro_sec ) = gettimeofday();
            $now_micro_epoch = $now_sec * 1000000;
            $now_micro_epoch = $now_micro_epoch + $now_micro_sec;
            $begin_micro_epoch = $now_micro_epoch;
            $action_id = "$now_sec.$now_micro_sec";
            @list_channels = $t->cmd(String => "Action: MailboxCount\nActionID: $action_id\nMailbox: $PTvoicemail_ids[$i]\n\nAction: Ping$command_end", Prompt => '/Response: Success\nPing: Pong.*/');
            $j=0;
            foreach(@list_channels)
                {
                if($DBX){print "$j - $list_channels[$j]";}
                if ($list_channels[$j] =~ /Mailbox: $PTvoicemail_ids[$i]/)
                    {
                    $URG_messages[$i] = "$list_channels[$j+1]";
                    $URG_messages[$i] =~ s/UrgMessages: |\n//gi;
                    $NEW_messages[$i] = "$list_channels[$j+2]";
                    $NEW_messages[$i] =~ s/NewMessages: |\n//gi;
                    $OLD_messages[$i] = "$list_channels[$j+3]";
                    $OLD_messages[$i] =~ s/OldMessages: |\n//gi;
                    }
                $j++;
                }
            }
    @PTextensions=@MT;   @PTmessages=@MT;   @PTold_messages=@MT;   @PTserver_ips=@MT;
    $stmtA = "SELECT extension,messages,old_messages,server_ip from phones where voicemail_id='$PTvoicemail_ids[$i]';";
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
    $sthArows=$sthA->rows;
    if ($DBX) {print "$sthArows|$stmtA|\n";}
    $rec_countX=0;
    while ($sthArows > $rec_countX)
        {
        @aryA = $sthA->fetchrow_array;
        $PTextensions[$rec_countX] =    $aryA[0];
        $PTmessages[$rec_countX] =        $aryA[1];
        $PTold_messages[$rec_countX] =    $aryA[2];
        $PTserver_ips[$rec_countX] =    $aryA[3];
        $rec_countX++;
        }
    $sthA->finish(); 
    $rec_countX=0;
    while ($sthArows > $rec_countX)
        {
        if($DB){print "MailboxCount- $PTvoicemail_ids[$i]    NEW:|$NEW_messages[$i]|  OLD:|$OLD_messages[$i]|    ";}
        if ( ($NEW_messages[$i] eq $PTmessages[$rec_countX]) && ($OLD_messages[$i] eq $PTold_messages[$rec_countX]) )
            {
            if($DB){print "MESSAGE COUNT UNCHANGED, DOING NOTHING FOR THIS MAILBOX: |$PTserver_ips[$rec_countX]|$PTextensions[$rec_countX]|\n";}
            }
        else
            {
            $stmtA = "UPDATE phones set messages='$NEW_messages[$i]', old_messages='$OLD_messages[$i]' where server_ip='$PTserver_ips[$rec_countX]' and extension='$PTextensions[$rec_countX]'";
                if($DBX){print STDERR "\n|$stmtA|\n";}
            $affected_rows = $dbhA->do($stmtA); #  or die  "Couldn't execute query:|$stmtA|\n";
            $voicemail_updates = ($voicemail_updates + $affected_rows);
            }
        $rec_countX++;
        }
    $i++;
    $voicemail_boxes++;
    usleep(1*50*1000);
    }
$stmtA = "SELECT count(*) from system_settings where active_voicemail_server='$server_ip';";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
if ($DB) {print "|$stmtA|\n";}
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
$rec_count=0;
if ($sthArows > 0)
    {
    @aryA = $sthA->fetchrow_array;
    $active_voicemail_server = $aryA[0];
    }
$sthA->finish(); 
if ($active_voicemail_server > 0)
    {
    if($DB){print "Active Voicemail Server, checking vicidial_voicemail boxes...\n";}
    @PTvoicemail_ids=@MT; @PTmessages=@MT; @PTold_messages=@MT; @NEW_messages=@MT; @OLD_messages=@MT;
    $stmtA = "SELECT voicemail_id,messages,old_messages from vicidial_voicemail where active='Y';";
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
    $sthArows=$sthA->rows;
    if ($DB) {print "$sthArows|$stmtA|\n";}
    $rec_count=0;
    while ($sthArows > $rec_count)
        {
        @aryA = $sthA->fetchrow_array;
        $PTvoicemail_ids[$rec_count] =     $aryA[0];
        $PTmessages[$rec_count] =         $aryA[1];
        $PTold_messages[$rec_count] =     $aryA[2];
        $rec_count++;
        }
    $sthA->finish(); 
    $i=0;
    foreach(@PTvoicemail_ids)
        {
        @list_channels=@MT;
        $t->buffer_empty;
        %ast_ver_str = parse_asterisk_version($asterisk_version);
        if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 6))
            {
            @list_channels = $t->cmd(String => "Action: MailboxCount\nMailbox: $PTvoicemail_ids[$i]\n\nAction: Ping$command_end", Prompt => '/Response: Pong.*/');
            $j=0;
            foreach(@list_channels)
                {
                if ($list_channels[$j] =~ /Mailbox: $PTvoicemail_ids[$i]/)
                    {
                    $NEW_messages[$i] = "$list_channels[$j+1]";
                    $NEW_messages[$i] =~ s/NewMessages: |\n//gi;
                    $OLD_messages[$i] = "$list_channels[$j+2]";
                    $OLD_messages[$i] =~ s/OldMessages: |\n//gi;
                    }
                $j++;
                }
            }
        elsif (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 13))
            {
            @list_channels = $t->cmd(String => "Action: MailboxCount\nMailbox: $PTvoicemail_ids[$i]\n\nAction: Ping$command_end", Prompt => '/Response: Success\nPing: Pong.*/');
            $j=0;
            foreach(@list_channels)
                {
                if($DBX){print "$j - $list_channels[$j]";}
                if ($list_channels[$j] =~ /Mailbox: $PTvoicemail_ids[$i]/)
                    {
                    $URG_messages[$i] = "$list_channels[$j+1]";
                    $URG_messages[$i] =~ s/UrgMessages: |\n//gi;
                    $NEW_messages[$i] = "$list_channels[$j+2]";
                    $NEW_messages[$i] =~ s/NewMessages: |\n//gi;
                    $OLD_messages[$i] = "$list_channels[$j+3]";
                    $OLD_messages[$i] =~ s/OldMessages: |\n//gi;
                    }
                $j++;
                }
            }
        else
            {
            ( $now_sec, $now_micro_sec ) = gettimeofday();
            $now_micro_epoch = $now_sec * 1000000;
            $now_micro_epoch = $now_micro_epoch + $now_micro_sec;
            $begin_micro_epoch = $now_micro_epoch;
            $action_id = "$now_sec.$now_micro_sec";
            @list_channels = $t->cmd(String => "Action: MailboxCount\nActionID: $action_id\nMailbox: $PTvoicemail_ids[$i]\n\nAction: Ping$command_end", Prompt => '/Response: Success\nPing: Pong.*/');
            $j=0;
            foreach(@list_channels)
                {
                if($DB){print "$j - $list_channels[$j]";}
                if ($list_channels[$j] =~ /Mailbox: $PTvoicemail_ids[$i]/)
                    {
                    $URG_messages[$i] = "$list_channels[$j+1]";
                    $URG_messages[$i] =~ s/UrgMessages: |\n//gi;
                    $NEW_messages[$i] = "$list_channels[$j+2]";
                    $NEW_messages[$i] =~ s/NewMessages: |\n//gi;
                    $OLD_messages[$i] = "$list_channels[$j+3]";
                    $OLD_messages[$i] =~ s/OldMessages: |\n//gi;
                    }
                $j++;
                }
            }
        if($DB){print "MailboxCount- $PTvoicemail_ids[$i]    NEW:|$NEW_messages[$i]|  OLD:|$OLD_messages[$i]|    ";}
        if ( ($NEW_messages[$i] eq $PTmessages[$i]) && ($OLD_messages[$i] eq $PTold_messages[$i]) )
            {
            if($DB){print "MESSAGE COUNT UNCHANGED, DOING NOTHING FOR THIS MAILBOX: |$PTvoicemail_ids[$i]|\n";}
            }
        else
            {
            $stmtA = "UPDATE vicidial_voicemail set messages='$NEW_messages[$i]',old_messages='$OLD_messages[$i]' where voicemail_id='$PTvoicemail_ids[$i]';";
                if($DB){print STDERR "\n|$stmtA|\n";}
            $affected_rows = $dbhA->do($stmtA); #  or die  "Couldn't execute query:|$stmtA|\n";
            $voicemail_updates = ($voicemail_updates + $affected_rows);
            }
        $i++;
        $voicemail_boxes++;
        usleep(1*50*1000);
        }
    }
$t->buffer_empty;
@hangup = $t->cmd(String => "Action: Logoff$command_end", Prompt => "/.*/"); 
$t->buffer_empty;
$t->waitfor(Match => '/Message:.*\n\n/', Timeout => 10);
$ok = $t->close;
$dbhA->disconnect();
if($DBX)
    {
    open (FILE, '<', "$telnet_log_file") or die "could not open the log file\n";
    print <FILE>;
    close (FILE);
    unlink($telnet_log_file) or die "Can't delete $telnet_log_file: $!\n";
    }
if($DB)
    {
    $secY = time();
    $runtime = ($secY - $secX);
    print "Summary:\n";
    print "Voicemail Boxes checked:    $voicemail_boxes\n";
    print "Voicemail Boxes updated:    $voicemail_updates\n";
    print "Run time:                   $runtime seconds \n";
    print "\n";
    print "DONE... Exiting... Goodbye... See you later... \n";
    }
exit;
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
