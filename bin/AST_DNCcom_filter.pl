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
$DB = 0;    # Debug flag, set to 0 for no debug messages per minute
if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--help/i ) {
        print "allowed run time options:\n";
        print "  [--debug] = verbose debug messages\n";
        print "  [--lists=LISTID1-LISTID2] = the list ids to be filters\n";
        print "\n";
        exit;
    }
    else {
        if ( $args =~ /--debug/i ) {
            $DB = 1;    # Debug flag
            print "-- DEBUGGING ENABLED --\n\n";
        }
        if ( $args =~ /--lists=/i ) {
            @data_in  = split( /--lists=/, $args );
            $CLIlists = $data_in[1];
            $CLIlists =~ s/ .*$//gi;
            if ( $CLIlists =~ /-/ ) {
                $CLIlists =~ s/-/,/gi;
            }
        }
        if ( length($CLIlists) < 2 ) {
            print "no lists defined, exiting.\n";
            exit;
        }
        if ($DB) { print "|$CLIlists|\n"; }
    }
}
else {
    print "no command line options set\n";
    exit;
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
use DBI;
use Time::HiRes qw( gettimeofday );
use WWW::Curl::Easy;
use WWW::Curl::Form;
$dbhA = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$stmtA =
"SELECT container_entry FROM vicidial_settings_containers WHERE container_id = 'DNCDOTCOM';";
if ($DB) { print "|$stmtA|\n"; }
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
$sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
$sthArows  = $sthA->rows;
$rec_count = 0;

if ( $sthArows > 0 ) {
    foreach $list_id ( split /,/, $CLIlists ) {
        $now = get_mysql_date_string( time() );
        $stmtA =
"INSERT INTO vicidial_admin_log SET event_date = '$now', user = 'VDAD', ip_address = '1.1.1.1', event_section = 'LISTS', event_type = 'OTHER', record_id = '$list_id', event_sql='', event_code='DNC.com SCRUB STARTED', event_notes='DNC.com scrub of list $list_id started at $now';";
        if ($DB) { print "|$stmtA|\n"; }
        $dbhA->do($stmtA) or die "executing: $stmtA ", $dbhA->errstr;
    }
    @aryA            = $sthA->fetchrow_array;
    $container_entry = $aryA[0];
    %dnccom_settings = get_container_settings($container_entry);
    if (   exists( $dnccom_settings{'LOGIN_ID'} )
        && exists( $dnccom_settings{'CAMPAIGN_ID'} )
        && exists( $dnccom_settings{'PROJ_ID'} )
        && exists( $dnccom_settings{'VERSION'} ) )
    {
        $base_url = $dnccom_settings{"DNC_DOT_COM_URL"};
        $url =
"$base_url?loginId=$dnccom_settings{'LOGIN_ID'}&version=$dnccom_settings{'VERSION'}&projId=$dnccom_settings{'PROJ_ID'}&campaignId=$dnccom_settings{'CAMPAIGN_ID'}&phoneList=";
        if ($DB) { print "|$url|\n"; }
        $skip_statuses = $dnccom_settings{'VICI_STATUS_SKIP'};
        $skip_statuses = "'$skip_statuses'";
        $skip_statuses =~ s/-/','/gi;
        if ($DB) { print "|$skip_statuses|\n"; }
        $lead_id_pos    = 0;
        $lead_grab      = 1000;     # number of leads to grab at a time
        $scrub_grab     = 50000;    # number of leads to send to DNC.com
        $scrub_attempts = 5
          ; # number of times to attempt to connect to DNC.com before erroring out
        $loop        = 1;
        $scrub_count = 0;
        $x_count     = 0;
        $c_count     = 0;
        $o_count     = 0;
        $e_count     = 0;
        $r_count     = 0;
        $w_count     = 0;
        $g_count     = 0;
        $h_count     = 0;
        $l_count     = 0;
        $f_count     = 0;
        $v_count     = 0;
        $i_count     = 0;
        $m_count     = 0;
        $b_count     = 0;
        $p_count     = 0;
        $d_count     = 0;
        $s_count     = 0;
        $t_count     = 0;
        $y_count     = 0;

        while ( $loop > 0 ) {
            $scrub_success  = 0;
            $good_num_count = 0;
            $phone_string   = '';
            my @leads;
            $grabbed_leads = 0;
            while ( ( $good_num_count < $scrub_grab ) && ( $loop > 0 ) ) {
                $stmtA =
"SELECT lead_id, phone_number, status, list_id FROM vicidial_list WHERE list_id IN ($CLIlists) AND status NOT IN ($skip_statuses) AND lead_id > $lead_id_pos ORDER BY lead_id LIMIT $lead_grab;";
                if ($DB) { print "|$stmtA|\n"; }
                $sthA = $dbhA->prepare($stmtA)
                  or die "preparing: ", $dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                $sthArows = $sthA->rows;
                if ( $sthArows > 0 ) {
                    $grabbed_leads = 1;
                    $rec_count     = 0;
                    while ( $sthArows > $rec_count ) {
                        @aryA         = $sthA->fetchrow_array;
                        $lead_id      = $aryA[0];
                        $phone_number = $aryA[1];
                        $status       = $aryA[2];
                        $list_id      = $aryA[3];
                        if ( $phone_number =~ /^\d\d\d\d\d\d\d\d\d\d$/ ) {
                            if ( $good_num_count == 0 ) {
                                $phone_string = "$phone_number";
                            }
                            else {
                                $phone_string = "$phone_string,$phone_number";
                            }
                            $leads[$good_num_count][0] = $lead_id;
                            $leads[$good_num_count][1] = $phone_number;
                            $leads[$good_num_count][2] = $status;
                            $leads[$good_num_count][3] = $list_id;
                            $good_num_count++;
                            $scrub_count++;
                        }
                        else {
                            if ($DB) {
                                print "$phone_number is not 10 digits\n";
                            }
                        }
                        $lead_id_pos = $lead_id;
                        $rec_count++;
                    }
                }
                else {
                    $loop = 0;
                }
            }
            while (( $scrub_attempts > 0 )
                && ( $scrub_success != 1 )
                && ( $grabbed_leads == 1 ) )
            {
                if ($DB) { print "|$phone_string|\n"; }
                my $dnccom_body;    # string to hold their response
                my $curl = WWW::Curl::Easy->new;
                $curl->setopt( CURLOPT_HEADER,    0 );
                $curl->setopt( CURLOPT_URL,       "$base_url" );
                $curl->setopt( CURLOPT_WRITEDATA, \$dnccom_body );
                my $curlf = WWW::Curl::Form->new;
                $curlf->formadd( "loginId", "$dnccom_settings{'LOGIN_ID'}" );
                $curlf->formadd( "version", "$dnccom_settings{'VERSION'}" );
                $curlf->formadd( "projId",  "$dnccom_settings{'PROJ_ID'}" );
                $curlf->formadd( "campaignId",
                    "$dnccom_settings{'CAMPAIGN_ID'}" );
                $curlf->formadd( "phoneList", "$phone_string" );
                $curl->setopt( CURLOPT_HTTPPOST, $curlf );
                ( $before_seconds, $before_microseconds ) = gettimeofday();
                my $retcode = $curl->perform;
                ( $after_seconds, $after_microseconds ) = gettimeofday();
                $url_seconds = $after_seconds - $before_seconds;

                if ($DB) {
                    print
"$before_seconds|$after_seconds|request time = $url_seconds\n";
                }
                if ( $retcode == 0 ) {
                    $scrub_success = 1;
                    $result_count  = 0;
                    if ($DB) { print "Spliting\n"; }
                    foreach $line ( split /\n/, $dnccom_body ) {
                        @line_results = split /,/, $line;
                        $dnccom_pn    = $line_results[0];
                        $dnccom_rc    = $line_results[1];
                        if ( $dnccom_pn eq $leads[$result_count][1] ) {
                            if ( $dnccom_rc eq 'X' ) {
                                $x_count++;
                                $up_status = $dnccom_settings{"STATUS_X"};
                            }
                            if ( $dnccom_rc eq 'C' ) {
                                $c_count++;
                                $up_status = $dnccom_settings{"STATUS_C"};
                            }
                            if ( $dnccom_rc eq 'O' ) {
                                $o_count++;
                                $up_status = $dnccom_settings{"STATUS_O"};
                            }
                            if ( $dnccom_rc eq 'E' ) {
                                $e_count++;
                                $up_status = $dnccom_settings{"STATUS_E"};
                            }
                            if ( $dnccom_rc eq 'R' ) {
                                $r_count++;
                                $up_status = $dnccom_settings{"STATUS_R"};
                            }
                            if ( $dnccom_rc eq 'W' ) {
                                $w_count++;
                                $up_status = $dnccom_settings{"STATUS_W"};
                            }
                            if ( $dnccom_rc eq 'G' ) {
                                $g_count++;
                                $up_status = $dnccom_settings{"STATUS_G"};
                            }
                            if ( $dnccom_rc eq 'H' ) {
                                $h_count++;
                                $up_status = $dnccom_settings{"STATUS_H"};
                            }
                            if ( $dnccom_rc eq 'L' ) {
                                $l_count++;
                                $up_status = $dnccom_settings{"STATUS_L"};
                            }
                            if ( $dnccom_rc eq 'F' ) {
                                $f_count++;
                                $up_status = $dnccom_settings{"STATUS_F"};
                            }
                            if ( $dnccom_rc eq 'V' ) {
                                $v_count++;
                                $up_status = $dnccom_settings{"STATUS_V"};
                            }
                            if ( $dnccom_rc eq 'I' ) {
                                $i_count++;
                                $up_status = $dnccom_settings{"STATUS_I"};
                            }
                            if ( $dnccom_rc eq 'M' ) {
                                $m_count++;
                                $up_status = $dnccom_settings{"STATUS_M"};
                            }
                            if ( $dnccom_rc eq 'B' ) {
                                $b_count++;
                                $up_status = $dnccom_settings{"STATUS_B"};
                            }
                            if ( $dnccom_rc eq 'P' ) {
                                $p_count++;
                                $up_status = $dnccom_settings{"STATUS_P"};
                            }
                            if ( $dnccom_rc eq 'D' ) {
                                $d_count++;
                                $up_status = $dnccom_settings{"STATUS_D"};
                            }
                            if ( $dnccom_rc eq 'S' ) {
                                $s_count++;
                                $up_status = $dnccom_settings{"STATUS_S"};
                            }
                            if ( $dnccom_rc eq 'T' ) {
                                $t_count++;
                                $up_status = $dnccom_settings{"STATUS_T"};
                            }
                            if ( $dnccom_rc eq 'Y' ) {
                                $y_count++;
                                $up_status = $dnccom_settings{"STATUS_Y"};
                            }
                            if ( $dnccom_settings{'ADD_INFO_TO_COMMENTS'} eq
                                'YES' )
                            {
                                $line =~ s/['"`]//g;
                                $line =~ s/[^a-zA-Z0-9 _-]/|/g;
                                $stmtA =
"UPDATE vicidial_list SET status = '$up_status', comments = CONCAT(comments,'!N$leads[$result_count][2]!N$line') where lead_id=$leads[$result_count][0] and phone_number='$leads[$result_count][1]';";
                            }
                            else {
                                $stmtA =
"UPDATE vicidial_list SET status = '$up_status' where lead_id=$leads[$result_count][0] and phone_number='$leads[$result_count][1]';";
                            }
                            if ($DB) { print "|$stmtA|\n"; }
                            $dbhA->do($stmtA)
                              or die "executing: $stmtA ", $dbhA->errstr;
                            $now = get_mysql_date_string( time() );
                            $stmtA =
"INSERT INTO vicidial_dnccom_filter_log SET lead_id = $leads[$result_count][0], list_id = $leads[$result_count][3], filter_date = '$now', new_status = '$up_status', old_status= '$leads[$result_count][2]', phone_number = '$leads[$result_count][1]', dnccom_data = '$line';";
                            if ($DB) { print "|$stmtA|\n"; }
                            $dbhA->do($stmtA)
                              or die "executing: $stmtA ", $dbhA->errstr;
                        }
                        else {
                            print
"leads phone_number doesnt match DNC.com. Exiting.\n";
                            exit();
                        }
                        $result_count++;
                    }
                }
                else {
                    $error =
                        "An error happened: $retcode "
                      . $curl->strerror($retcode) . " "
                      . $curl->errbuf;
                    $scrub_attempts--;
                    if ($DB) { print("$error\n"); }
                    foreach $list_id ( split /,/, $CLIlists ) {
                        $now = get_mysql_date_string( time() );
                        $stmtA =
"INSERT INTO vicidial_admin_log SET event_date = '$now', user = 'VDAD', ip_address = '1.1.1.1', event_section = 'LISTS', event_type = 'OTHER', record_id = '$list_id', event_sql='', event_code='DNC.com SCRUB ERROR', event_notes='DNC.com scrub of lists $CLIlists had an error: \'$error\' after processing $scrub_count leads.';";
                        if ($DB) { print "|$stmtA|\n"; }
                        $dbhA->do($stmtA)
                          or die "executing: $stmtA ", $dbhA->errstr;
                    }
                }
            }
            if ( $scrub_attempts == 0 ) {
                foreach $list_id ( split /,/, $CLIlists ) {
                    $now = get_mysql_date_string( time() );
                    $stmtA =
"INSERT INTO vicidial_admin_log SET event_date = '$now', user = 'VDAD', ip_address = '1.1.1.1', event_section = 'LISTS', event_type = 'OTHER', record_id = '$list_id', event_sql='', event_code='DNC.com SCRUB FAILED', event_notes='DNC.com scrub of lists $CLIlists failed after processing $scrub_count leads due to connection errors.';";
                    if ($DB) { print "|$stmtA|\n"; }
                    $dbhA->do($stmtA)
                      or die "executing: $stmtA ", $dbhA->errstr;
                }
            }
        }
        $result_str =
"|X$x_count|C$c_count|O$o_count|E$e_count|R$r_count|W$w_count|G$g_count|H$h_count|L$l_count|F$f_count|V$v_count|I$i_count|M$m_count|B$b_count|P$p_count|D$d_count|S$s_count|T$t_count|Y$y_count|";
        if ($DB) { print "$result_str\n"; }
        foreach $list_id ( split /,/, $CLIlists ) {
            $now = get_mysql_date_string( time() );
            $stmtA =
"INSERT INTO vicidial_admin_log SET event_date = '$now', user = 'VDAD', ip_address = '1.1.1.1', event_section = 'LISTS', event_type = 'OTHER', record_id = '$list_id', event_sql='', event_code='DNC.com SCRUB FINISHED', event_notes='DNC.com scrub of lists $CLIlists finished after processing $scrub_count leads with the following results:\n$result_str';";
            if ($DB) { print "|$stmtA|\n"; }
            $dbhA->do($stmtA) or die "executing: $stmtA ", $dbhA->errstr;
        }
    }
    else {
        print "DNC.com support not setup properly. Exiting.";
        exit();
    }
}
else {
    print
"DNC.com support not setup properly. You must have a Settings Container called 'DNCDOTCOM' set up on your Vicidial System. Exiting.";
    exit();
}

sub get_container_settings {
    my %settings_hash;
    my $container_entry = $_[0];
    foreach $line ( split /\n/, $container_entry ) {
        $line =~ s/[#;].*$//gi;    # remove comment
        $line =~ s/^\s+//gi;       # remove leading whitespace
        $line =~ s/\s+$//gi;       # remove trailing whitespace
        if ( $line ne "" ) {
            my @setting_parts = split( /=>/, $line );
            $setting_parts[0] =~ s/^\s+//gi;
            $setting_parts[0] =~ s/\s+$//gi;
            $setting_parts[1] =~ s/^\s+//gi;
            $setting_parts[1] =~ s/\s+$//gi;
            $settings_hash{"$setting_parts[0]"} = $setting_parts[1];
        }
    }
    if ($DB) {
        foreach ( sort keys %settings_hash ) {
            print "$_ : $settings_hash{$_}\n";
        }
    }
    return %settings_hash;
}

sub get_mysql_date_string {
    my $time = $_[0];
    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime($time);
    $year = ( $year + 1900 );
    $mon++;
    if ( $mon < 10 )  { $mon  = "0$mon"; }
    if ( $mday < 10 ) { $mday = "0$mday"; }
    if ( $hour < 10 ) { $hour = "0$hour"; }
    if ( $min < 10 )  { $min  = "0$min"; }
    if ( $sec < 10 )  { $sec  = "0$sec"; }
    $mysql_date = "$year-$mon-$mday $hour:$min:$sec";
    return $mysql_date;
}
