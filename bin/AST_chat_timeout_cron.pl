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
if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--help/i ) {
        print "allowed run time options:\n";
        print "  [--help] = this screen";
        print "  [--debug] = verbose debug messages\n";
        print "\n";
        exit;
    }
    else {
        if ( $args =~ /--version/i ) {
            print "version: $build\n";
            exit;
        }
        if ( $args =~ /--debug/i ) {
            $DB    = 1;    # Debug flag
            $debug = 1;
        }
        if ( $args =~ /--debugX/i ) {
            $DBX = 1;
            print "\n----- SUPER-DUPER DEBUGGING -----\n\n";
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
    if ( ( $line =~ /^PATHlogs/ ) && ( $CLIlogs < 1 ) ) {
        $PATHlogs = $line;
        $PATHlogs =~ s/.*=//gi;
    }
    if ( ( $line =~ /^PATHsounds/ ) && ( $CLIsounds < 1 ) ) {
        $PATHsounds = $line;
        $PATHsounds =~ s/.*=//gi;
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
    if ( ( $line =~ /^VARDB_custom_user/ ) && ( $CLIDB_custom_user < 1 ) ) {
        $VARDB_custom_user = $line;
        $VARDB_custom_user =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARDB_custom_pass/ ) && ( $CLIDB_custom_pass < 1 ) ) {
        $VARDB_custom_pass = $line;
        $VARDB_custom_pass =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARDB_port/ ) && ( $CLIDB_port < 1 ) ) {
        $VARDB_port = $line;
        $VARDB_port =~ s/.*=//gi;
    }
    $i++;
}
$server_ip            = $VARserver_ip;    # Asterisk server IP
$THISserver_voicemail = 0;
$voicemail_server_id  = '';
if ( !$VARDB_port ) { $VARDB_port = '3306'; }
use DBI;
$dbhA = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$dbhA2 = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$dbhA3 = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$timeout_stmt = "select allow_chats, chat_timeout from system_settings";
$timeout_rslt = $dbhA->prepare($timeout_stmt);
$timeout_rslt->execute();
@trow         = $timeout_rslt->fetchrow_array;
$allow_chats  = $trow[0];
$chat_timeout = $trow[1];

if ( $allow_chats == 1 && $chat_timeout > 0 ) {
    $stmt =
"select distinct chat_id from vicidial_chat_participants where vd_agent='N' and ping_date<=now()-INTERVAL "
      . $chat_timeout
      . " SECOND";
    if ($debug) { print $stmt. "\n\n"; }
    $rslt = $dbhA->prepare($stmt);
    $rslt->execute();
    if ( $rslt->rows > 0 ) {
        $chat_id_str = "";
        while ( @row = $rslt->fetchrow_array ) {
            $chat_id_str .= "$row[0],";
        }
        $chat_id_str =~ s/,$//;
        $archive_stmt =
"insert ignore into vicidial_chat_archive select chat_id, chat_start_time, 'DROP' as status, chat_creator, group_id, lead_id from vicidial_live_chats where chat_id in ("
          . $chat_id_str . ")";
        $dbhA->do($archive_stmt);
        $archive_log_stmt =
"insert ignore into vicidial_chat_log_archive select * from vicidial_chat_log where chat_id in ("
          . $chat_id_str . ")";
        $dbhA->do($archive_log_stmt);
        $del_stmt =
"delete from vicidial_chat_participants where vd_agent='N' and ping_date<=now()-INTERVAL "
          . $chat_timeout
          . " SECOND and chat_id in ("
          . $chat_id_str . ")";
        $del_rslt = $dbhA->do($del_stmt);
        if ($debug) { print $del_stmt. "\n\n"; }
        $sel_stmt =
            "select lead_id from vicidial_live_chats where chat_id in ("
          . $chat_id_str
          . ") and status='WAITING' and chat_creator='NONE'";
        $sel_rslt = $dbhA->prepare($sel_stmt);
        $sel_rslt->execute();
        $lead_id_str = "";

        while ( @sel_row->$sel_rslt->fetchrow_array ) {
            $lead_id_str .= "$sel_row[0],";
        }
        $lead_id_str =~ s/,$//;
        $upd_stmt = "update vicidial_list set status='CDROP' where lead_id in ("
          . $lead_id_str . ")";
        $upd_rslt = $dbhA->do($upd_stmt);
        $del_stmt =
            "delete from vicidial_live_chats where chat_id in ("
          . $chat_id_str
          . ") and status='WAITING' and chat_creator='NONE'";
        $del_rslt = $dbhA->do($del_stmt);
        if ($debug) { print $del_stmt. "\n\n"; }
        $del_log_stmt = "delete from vicidial_chat_log where chat_id in ("
          . $chat_id_str . ")";
        $del_log_rslt = $dbhA->do($del_log_stmt);
        $sel_stmt =
"select lead_id, chat_creator, chat_id from vicidial_live_chats where chat_id in ("
          . $chat_id_str
          . ") and status='LIVE' and chat_creator!='NONE'";
        $sel_rslt = $dbhA->prepare($sel_stmt);
        $sel_rslt->execute();

        while ( @sel_row->$sel_rslt->fetchrow_array ) {
            $lead_id_str .= "$sel_row[0],";
            $lead_id      = $sel_row[0];
            $chat_creator = $sel_row[1];
            $chat_id      = $sel_row[2];
            $ins_alert_stmt =
"insert into vicidial_chat_log(poster, chat_member_name, message_time, message, chat_id, chat_level) select '$chat_creator', full_name, now(), 'Customer seems to have abandoned chat', '$chat_id', '1' from vicidial_users where user='$chat_creator'";
            $ins_alert_rslt = $dbhA2->do($ins_alert_stmt);
        }
        $lead_id_str =~ s/,$//;
    }
}
if ( $allow_chats == 1 ) {
    $live_stmt = "select user from vicidial_live_agents";
    if ($debug) { print "$live_stmt\n"; }
    $live_rslt = $dbhA->prepare($live_stmt);
    $live_rslt->execute();
    $agent_str = "";
    while ( @live_row = $live_rslt->fetchrow_array ) {
        $agent_str .= "$live_row[0],";
    }
    $agent_str =~ s/,$//;
    if ( $live_rslt->rows > 0 ) {
        $archive_stmt =
"insert ignore into vicidial_manager_chat_log_archive select * from vicidial_manager_chat_log where user not in ($agent_str)";
        $dbhA2->do($archive_stmt);
        if ($debug) { print $archive_stmt. "\n\n"; }
        $del_stmt =
"delete from vicidial_manager_chat_log where user not in ($agent_str)";
        $del_rslt = $dbhA2->do($del_stmt);
        if ($debug) { print $del_stmt. "\n\n"; }
        $chat_stmt =
          "select distinct manager_chat_id from vicidial_manager_chat_log";
        $chat_rslt = $dbhA2->prepare($chat_stmt);
        $chat_rslt->execute();

        if ( $chat_rslt->rows == 0 ) {
            $ins_stmt =
"insert ignore into vicidial_manager_chats_archive select * from vicidial_manager_chats";
            $dbhA3->do($ins_stmt);
            $del_stmt = "delete from vicidial_manager_chats";
            $del_rslt = $dbhA3->do($del_stmt);
            if ($debug) { print $del_stmt. "\n\n"; }
        }
        else {
            $chat_str = "";
            while ( @chat_row = $chat_rslt->fetchrow_array ) {
                $chat_str .= "$chat_row[0],";
            }
            $chat_str =~ s/,$//;
            $ins_stmt =
"insert ignore into vicidial_manager_chats_archive select * from vicidial_manager_chats where manager_chat_id not in ($chat_str)";
            $dbhA3->do($ins_stmt);
            $del_stmt =
"delete from vicidial_manager_chats where manager_chat_id not in ($chat_str)";
            $del_rslt = $dbhA3->do($del_stmt);
        }
    }
    else {
        $archive_stmt =
"insert ignore into vicidial_manager_chat_log_archive select * from vicidial_manager_chat_log";
        $dbhA2->do($archive_stmt);
        if ($debug) { print $archive_stmt. "\n\n"; }
        $del_stmt = "delete from vicidial_manager_chat_log";
        $del_rslt = $dbhA2->do($del_stmt);
        if ($debug) { print $del_stmt. "\n\n"; }
        $ins_stmt =
"insert ignore into vicidial_manager_chats_archive select * from vicidial_manager_chats";
        $dbhA3->do($ins_stmt);
        $del_stmt = "delete from vicidial_manager_chats";
        $del_rslt = $dbhA3->do($del_stmt);
    }
}
