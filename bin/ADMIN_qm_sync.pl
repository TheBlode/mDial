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
$version        = '130131-2225';
$US             = '__';
$MT[0]          = '';
$CLIQMDB_host   = 0;
$CLIQMDB_dbname = 0;
$CLIQMDB_user   = 0;
$CLIQMDB_pass   = 0;

if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--version/i ) {
        print "version: $version\n";
        exit;
    }
    elsif ( $args =~ /--help/i ) {
        print "allowed run time options:\n";
        print "  [--user] = will synchronize users\n";
        print
"  [--remote-agents] = will check for remote agents and sync for the number of lines defined for each\n";
        print "  [--dids] = will sync did entries to dnis entries in QM\n";
        print "  [--ivrs] = will sync call menu entries to ivr entries in QM\n";
        print
"  [--ingroups] = will sync in-group entries to queue entries in QM\n";
        print
"  [--campaigns] = will sync campaign entries to queue entries in QM\n";
        print "  [--all-sync] = will sync all of the above in QM\n";
        print
"  [--all-alias-sync] = will sync all queues in QM into the default \"00 All Queues\" alias\n";
        print
"  [--key-id-ig] = will ensure that the queue has the in-group id set as a key\n";
        print
"  [--key-id-allq] = will ensure that the queue has \"ALLQ\" id set as a key\n";
        print
"  [--key-id-wipe] = will start with a blank queue key before the other key options\n";
        print "  [--qm-db-server=XXX] = alternate QM mysql server\n";
        print "  [--qm-db-dbname=XXX] = alternate QM mysql database name\n";
        print
          "  [--qm-db-login=XXX] = alternate QM mysql server login account\n";
        print "  [--qm-db-pass=XXX] = alternate QM mysql server password\n";
        print "  [--quiet] = quiet, no output\n";
        print "  [--test] = test\n";
        print "  [--version] = display version of this script\n";
        print "  [--debug] = verbose debug messages\n";
        print "  [--debugX] = Extra-verbose debug messages\n\n";
        exit;
    }
    else {
        if ( $args =~ /--quiet/i ) {
            $Q = 1;    # quiet
        }
        if ( $args =~ /--debug/i ) {
            $DB = 1;    # Debug flag
            if ( $Q < 1 ) { print "\n----- DEBUGGING -----\n\n"; }
        }
        if ( $args =~ /--debugX/i ) {
            $DBX = 1;
            if ( $Q < 1 ) { print "\n----- SUPER-DUPER DEBUGGING -----\n\n"; }
        }
        if ( $args =~ /--test/i ) {
            $TEST = 1;
            $T    = 1;
            if ( $Q < 1 ) { print "\n----- TEST RUN, NO UPDATES -----\n\n"; }
        }
        if ( $args =~ /--all-alias-sync/i ) {
            $SYNC_all_alias = 1;
            if ( $Q < 1 ) { print "\n----- ALL ALIAS SYNC -----\n\n"; }
        }
        if ( $args =~ /--all-sync/i ) {
            $SYNC_user         = 1;
            $SYNC_remoteagents = 1;
            $SYNC_dids         = 1;
            $SYNC_ivrs         = 1;
            $SYNC_ingroups     = 1;
            $SYNC_campaigns    = 1;
            if ( $Q < 1 ) { print "\n----- ALL SYNC -----\n\n"; }
        }
        if ( $args =~ /--user/i ) {
            $SYNC_user = 1;
            if ( $Q < 1 ) { print "\n----- USER SYNC -----\n\n"; }
        }
        if ( $args =~ /--remote-agents/i ) {
            $SYNC_remoteagents = 1;
            if ( $Q < 1 ) { print "\n----- REMOTE AGENT SYNC -----\n\n"; }
        }
        if ( $args =~ /--dids/i ) {
            $SYNC_dids = 1;
            if ( $Q < 1 ) { print "\n----- DID SYNC -----\n\n"; }
        }
        if ( $args =~ /--ivrs/i ) {
            $SYNC_ivrs = 1;
            if ( $Q < 1 ) { print "\n----- IVR SYNC -----\n\n"; }
        }
        if ( $args =~ /--ingroups/i ) {
            $SYNC_ingroups = 1;
            if ( $Q < 1 ) { print "\n----- IN-GROUP SYNC -----\n\n"; }
        }
        if ( $args =~ /--campaigns/i ) {
            $SYNC_campaigns = 1;
            if ( $Q < 1 ) { print "\n----- CAMPAIGN SYNC -----\n\n"; }
        }
        if ( $args =~ /--key-id-wipe/i ) {
            $KEY_wipe = 1;
            if ( $Q < 1 ) { print "\n----- QUEUE KEY WIPE -----\n\n"; }
        }
        if ( $args =~ /--key-id-ig/i ) {
            $KEY_ingroup = 1;
            if ( $Q < 1 ) { print "\n----- QUEUE KEY INGROUP -----\n\n"; }
        }
        if ( $args =~ /--key-id-allq/i ) {
            $KEY_allq = 1;
            if ( $Q < 1 ) { print "\n----- QUEUE KEY ALLQ -----\n\n"; }
        }
        if ( $args =~ /--qm-db-server=/i ) {
            my @data_in = split( /--qm-db-server=/, $args );
            $VARQMDB_host = $data_in[1];
            $VARQMDB_host =~ s/ .*//gi;
            $CLIQMDB_host = 1;
            if ( $DB > 0 ) {
                print "\n----- QM DB SERVER: $VARQMDB_host -----\n\n";
            }
        }
        if ( $args =~ /--qm-db-login=/i ) {
            my @data_in = split( /--qm-db-login=/, $args );
            $VARQMDB_user = $data_in[1];
            $VARQMDB_user =~ s/ .*//gi;
            $CLIQMDB_user = 1;
            if ( $DB > 0 ) {
                print "\n----- QM DB LOGIN: $VARQMDB_user -----\n\n";
            }
        }
        if ( $args =~ /--qm-db-pass=/i ) {
            my @data_in = split( /--qm-db-pass=/, $args );
            $VARQMDB_pass = $data_in[1];
            $VARQMDB_pass =~ s/ .*//gi;
            $CLIQMDB_pass = 1;
            if ( $DB > 0 ) {
                print "\n----- QM DB PASS: $VARQMDB_pass -----\n\n";
            }
        }
        if ( $args =~ /--qm-db-dbname=/i ) {
            my @data_in = split( /--qm-db-dbname=/, $args );
            $VARQMDB_dbname = $data_in[1];
            $VARQMDB_dbname =~ s/ .*//gi;
            $CLIQMDB_dbname = 1;
            if ( $DB > 0 ) {
                print "\n----- QM DB DBNAME: $VARQMDB_dbname -----\n\n";
            }
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
if ( !$CLEANLOGfile ) {
    $CLEANLOGfile = "$PATHlogs/qmsync.$Hyear-$Hmon-$Hmday";
}
if ( !$VARDB_port ) { $VARDB_port = '3306'; }
use DBI;
$dbhA = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$stmtA =
"SELECT enable_queuemetrics_logging,queuemetrics_server_ip,queuemetrics_dbname,queuemetrics_login,queuemetrics_pass,queuemetrics_log_id FROM system_settings;";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
$sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
$sthArows = $sthA->rows;

if ( $sthArows > 0 ) {
    @aryA                        = $sthA->fetchrow_array;
    $enable_queuemetrics_logging = $aryA[0];
    $queuemetrics_server_ip      = $aryA[1];
    $queuemetrics_dbname         = $aryA[2];
    $queuemetrics_login          = $aryA[3];
    $queuemetrics_pass           = $aryA[4];
    $queuemetrics_log_id         = $aryA[5];
}
$sthA->finish();
if ( $CLIQMDB_host > 0 )   { $queuemetrics_server_ip = $VARQMDB_host; }
if ( $CLIQMDB_dbname > 0 ) { $queuemetrics_dbname    = $VARQMDB_dbname; }
if ( $CLIQMDB_user > 0 )   { $queuemetrics_login     = $VARQMDB_user; }
if ( $CLIQMDB_pass > 0 )   { $queuemetrics_pass      = $VARQMDB_pass; }
$dbhB =
  DBI->connect( "DBI:mysql:$queuemetrics_dbname:$queuemetrics_server_ip:3306",
    "$queuemetrics_login", "$queuemetrics_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
if ($DBX) {
    print
"CONNECTED TO QM DATABASE:  $queuemetrics_server_ip|$queuemetrics_dbname\n";
}
if ( $SYNC_user > 0 ) {
    if ($DBX) { print "\n\n"; }
    if ($DB)  { print " - starting sync of vicidial_users to agenti_noti\n"; }
    $found_records   = 0;
    $updated_records = 0;
    $added_records   = 0;
    $stmtA = "SELECT user,full_name from vicidial_users limit 100000;";
    if ($DBX) { print "$stmtA\n"; }
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
    $sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
    $sthArowsU = $sthA->rows;
    $i         = 0;

    while ( $sthArowsU > $i ) {
        @aryA          = $sthA->fetchrow_array;
        $Vuser[$i]     = $aryA[0];
        $Vfullname[$i] = $aryA[1];
        $i++;
    }
    $sthA->finish();
    $i = 0;
    while ( $sthArowsU > $i ) {
        $stmtB =
"SELECT count(*) FROM agenti_noti where nome_agente='Agent/$Vuser[$i]' and descr_agente='$Vfullname[$i]';";
        $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
        $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
        $AN_records = $sthB->rows;
        if ( $AN_records > 0 ) {
            @aryB     = $sthB->fetchrow_array;
            $AN_count = $aryB[0];
        }
        $sthB->finish();
        if ( $AN_count < 1 ) {
            $stmtB =
"SELECT count(*) FROM agenti_noti where nome_agente='Agent/$Vuser[$i]';";
            $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
            $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
            $ANX_records = $sthB->rows;
            if ( $ANX_records > 0 ) {
                @aryB      = $sthB->fetchrow_array;
                $ANX_count = $aryB[0];
            }
            $sthB->finish();
            if ( $ANX_count < 1 ) {
                $stmtB =
"INSERT INTO agenti_noti(nome_agente,descr_agente,location,current_terminal,xmpp_address,payroll_code,sys_dt_creazione,sys_user_creazione,sys_dt_modifica,sys_user_modifica,chiave_agente) values('agent/$Vuser[$i]','$Vfullname[$i]','7','-','','',NOW(),'32',NOW(),'32','');";
                if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                if ($DB) {
                    print
                      "     AGENT record inserted: $Baffected_rows|$stmtB|\n";
                }
                $event_string =
"AGENT INSERT: $i|$Vuser[$i]|$Vfullname[$i]|$Baffected_rows|$stmtB";
                &event_logger;
                $added_records++;
            }
            else {
                $stmtB =
"UPDATE agenti_noti SET descr_agente='$Vfullname[$i]' where nome_agente='agent/$Vuser[$i]' LIMIT 1;";
                if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                if ($DB) {
                    print
                      "     AGENT record updated: $Baffected_rows|$stmtB|\n";
                }
                $event_string =
"AGENT UPDATE: $i|$Vuser[$i]|$Vfullname[$i]|$Baffected_rows|$stmtB";
                &event_logger;
                $updated_records++;
            }
        }
        else {
            if ($DB) { print "   agent exists: $Vuser[$i] - $Vfullname[$i]\n"; }
            $found_records++;
        }
        $i++;
    }
    if ($DB) { print " - finished user sync:\n"; }
    if ($DB) { print "     records scanned:       $i\n"; }
    if ($DB) { print "     records found:      $found_records\n"; }
    if ($DB) { print "     records updated:    $updated_records\n"; }
    if ($DB) { print "     records added:      $added_records\n"; }
}
if ( $SYNC_remoteagents > 0 ) {
    if ($DBX) { print "\n\n"; }
    if ($DB) {
        print " - starting sync of vicidial_remote_agents to agenti_noti\n";
    }
    $found_records   = 0;
    $updated_records = 0;
    $added_records   = 0;
    $stmtA =
"SELECT user_start,number_of_lines,full_name from vicidial_remote_agents vra,vicidial_users vu where vu.user=vra.user_start and number_of_lines > 0 limit 100000;";
    if ($DBX) { print "$stmtA\n"; }
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
    $sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
    $sthArowsU = $sthA->rows;
    $i         = 0;

    while ( $sthArowsU > $i ) {
        @aryA                 = $sthA->fetchrow_array;
        $Vuser[$i]            = $aryA[0];
        $Vnumber_of_lines[$i] = $aryA[1];
        $Vfullname[$i]        = $aryA[2];
        $i++;
    }
    $sthA->finish();
    $i = 0;
    while ( $sthArowsU > $i ) {
        $ra_count = 0;
        while ( $ra_count < $Vnumber_of_lines[$i] ) {
            $Vuser[$i]++;
            $stmtB =
"SELECT count(*) FROM agenti_noti where nome_agente='Agent/$Vuser[$i]' and descr_agente='$Vfullname[$i]';";
            $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
            $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
            $AN_records = $sthB->rows;
            if ( $AN_records > 0 ) {
                @aryB     = $sthB->fetchrow_array;
                $AN_count = $aryB[0];
            }
            $sthB->finish();
            if ( $AN_count < 1 ) {
                $stmtB =
"SELECT count(*) FROM agenti_noti where nome_agente='Agent/$Vuser[$i]';";
                $sthB = $dbhB->prepare($stmtB)
                  or die "preparing: ", $dbhB->errstr;
                $sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
                $ANX_records = $sthB->rows;
                if ( $ANX_records > 0 ) {
                    @aryB      = $sthB->fetchrow_array;
                    $ANX_count = $aryB[0];
                }
                $sthB->finish();
                if ( $ANX_count < 1 ) {
                    $stmtB =
"INSERT INTO agenti_noti(nome_agente,descr_agente,location,current_terminal,xmpp_address,payroll_code,sys_dt_creazione,sys_user_creazione,sys_dt_modifica,sys_user_modifica,chiave_agente) values('agent/$Vuser[$i]','$Vfullname[$i]','7','-','','',NOW(),'32',NOW(),'32','');";
                    if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                    if ($DB) {
                        print
"     AGENT record inserted: $Baffected_rows|$ra_count|$stmtB|\n";
                    }
                    $event_string =
"AGENT INSERT: $i|$ra_count|$Vuser[$i]|$Vfullname[$i]|$Baffected_rows|$stmtB";
                    &event_logger;
                    $added_records++;
                }
                else {
                    $stmtB =
"UPDATE agenti_noti SET descr_agente='$Vfullname[$i]' where nome_agente='agent/$Vuser[$i]' LIMIT 1;";
                    if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                    if ($DB) {
                        print
"     AGENT record updated: $Baffected_rows|$ra_count|$stmtB|\n";
                    }
                    $event_string =
"AGENT UPDATE: $i|$ra_count|$Vuser[$i]|$Vfullname[$i]|$Baffected_rows|$stmtB";
                    &event_logger;
                    $updated_records++;
                }
            }
            else {
                if ($DB) {
                    print "   agent exists: $Vuser[$i] - $Vfullname[$i]\n";
                }
                $found_records++;
            }
            $ra_count++;
        }
        $i++;
    }
    if ($DB) { print " - finished remote agent sync:\n"; }
    if ($DB) { print "     records scanned:       $i\n"; }
    if ($DB) { print "     records found:      $found_records\n"; }
    if ($DB) { print "     records updated:    $updated_records\n"; }
    if ($DB) { print "     records added:      $added_records\n"; }
}
if ( $SYNC_dids > 0 ) {
    if ($DBX) { print "\n\n"; }
    if ($DB)  { print " - starting sync of vicidial_inbound_dids to dnis\n"; }
    $found_records   = 0;
    $updated_records = 0;
    $added_records   = 0;
    $stmtA =
"SELECT did_pattern,did_description from vicidial_inbound_dids limit 1000000;";
    if ($DBX) { print "$stmtA\n"; }
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
    $sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
    $sthArowsD = $sthA->rows;
    $i         = 0;

    while ( $sthArowsD > $i ) {
        @aryA             = $sthA->fetchrow_array;
        $Vdid[$i]         = $aryA[0];
        $Vdescription[$i] = $aryA[1];
        $i++;
    }
    $sthA->finish();
    $i = 0;
    while ( $sthArowsD > $i ) {
        $stmtB =
"SELECT count(*) FROM dnis where dnis_k='$Vdid[$i]' and dnis_v='$Vdid[$i] - $Vdescription[$i]';";
        $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
        $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
        $AN_records = $sthB->rows;
        if ( $AN_records > 0 ) {
            @aryB     = $sthB->fetchrow_array;
            $AN_count = $aryB[0];
        }
        $sthB->finish();
        if ( $AN_count < 1 ) {
            $stmtB = "SELECT count(*) FROM dnis where dnis_k='$Vdid[$i]';";
            $sthB  = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
            $sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
            $ANX_records = $sthB->rows;
            if ( $ANX_records > 0 ) {
                @aryB      = $sthB->fetchrow_array;
                $ANX_count = $aryB[0];
            }
            $sthB->finish();
            if ( $ANX_count < 1 ) {
                $stmtB =
"INSERT INTO dnis (dnis_k,dnis_v,sys_dt_creazione,sys_user_creazione,sys_dt_modifica,sys_user_modifica,sys_optilock) values('$Vdid[$i]','$Vdid[$i] - $Vdescription[$i]',NOW(),'32',NOW(),'32','82946');";
                if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                if ($DB) {
                    print
                      "     DNIS record inserted: $Baffected_rows|$stmtB|\n";
                }
                $event_string =
"DNIS INSERT: $i|$Vdid[$i]|$Vdescription[$i]|$Baffected_rows|$stmtB";
                &event_logger;
                $added_records++;
            }
            else {
                $stmtB =
"UPDATE dnis SET dnis_v='$Vdid[$i] - $Vdescription[$i]' where dnis_k='$Vdid[$i]' LIMIT 1;";
                if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                if ($DB) {
                    print "     DNIS record updated: $Baffected_rows|$stmtB|\n";
                }
                $event_string =
"DNIS UPDATE: $i|$Vdid[$i]|$Vdescription[$i]|$Baffected_rows|$stmtB";
                &event_logger;
                $updated_records++;
            }
        }
        else {
            if ($DB) { print "   did exists: $Vdid[$i] - $Vdescription[$i]\n"; }
            $found_records++;
        }
        $i++;
    }
    if ($DB) { print " - finished did sync:\n"; }
    if ($DB) { print "     records scanned:       $i\n"; }
    if ($DB) { print "     records found:      $found_records\n"; }
    if ($DB) { print "     records updated:    $updated_records\n"; }
    if ($DB) { print "     records added:      $added_records\n"; }
}
if ( $SYNC_ivrs > 0 ) {
    if ($DBX) { print "\n\n"; }
    if ($DB)  { print " - starting sync of vicidial_call_menu to ivr\n"; }
    $found_records   = 0;
    $updated_records = 0;
    $added_records   = 0;
    $stmtA = "SELECT menu_id,menu_name from vicidial_call_menu limit 1000000;";
    if ($DBX) { print "$stmtA\n"; }
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
    $sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
    $sthArowsD = $sthA->rows;
    $i         = 0;

    while ( $sthArowsD > $i ) {
        @aryA             = $sthA->fetchrow_array;
        $Vivr[$i]         = $aryA[0];
        $Vdescription[$i] = $aryA[1];
        $i++;
    }
    $sthA->finish();
    $i = 0;
    while ( $sthArowsD > $i ) {
        $stmtB =
"SELECT count(*) FROM ivr where ivr_k='$Vivr[$i]' and ivr_v='$Vivr[$i] - $Vdescription[$i]';";
        $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
        $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
        $AN_records = $sthB->rows;
        if ( $AN_records > 0 ) {
            @aryB     = $sthB->fetchrow_array;
            $AN_count = $aryB[0];
        }
        $sthB->finish();
        if ( $AN_count < 1 ) {
            $stmtB = "SELECT count(*) FROM ivr where ivr_k='$Vivr[$i]';";
            $sthB  = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
            $sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
            $ANX_records = $sthB->rows;
            if ( $ANX_records > 0 ) {
                @aryB      = $sthB->fetchrow_array;
                $ANX_count = $aryB[0];
            }
            $sthB->finish();
            if ( $ANX_count < 1 ) {
                $stmtB =
"INSERT INTO ivr (ivr_k,ivr_v,sys_dt_creazione,sys_user_creazione,sys_dt_modifica,sys_user_modifica,sys_optilock) values('$Vivr[$i]','$Vivr[$i] - $Vdescription[$i]',NOW(),'32',NOW(),'32','82946');";
                if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                if ($DB) {
                    print "     ivr record inserted: $Baffected_rows|$stmtB|\n";
                }
                $event_string =
"ivr INSERT: $i|$Vivr[$i]|$Vdescription[$i]|$Baffected_rows|$stmtB";
                &event_logger;
                $added_records++;
            }
            else {
                $stmtB =
"UPDATE ivr SET ivr_v='$Vivr[$i] - $Vdescription[$i]' where ivr_k='$Vivr[$i]' LIMIT 1;";
                if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                if ($DB) {
                    print "     ivr record updated: $Baffected_rows|$stmtB|\n";
                }
                $event_string =
"ivr UPDATE: $i|$Vivr[$i]|$Vdescription[$i]|$Baffected_rows|$stmtB";
                &event_logger;
                $updated_records++;
            }
        }
        else {
            if ($DB) { print "   ivr exists: $Vivr[$i] - $Vdescription[$i]\n"; }
            $found_records++;
        }
        $i++;
    }
    if ($DB) { print " - finished ivr sync:\n"; }
    if ($DB) { print "     records scanned:       $i\n"; }
    if ($DB) { print "     records found:      $found_records\n"; }
    if ($DB) { print "     records updated:    $updated_records\n"; }
    if ($DB) { print "     records added:      $added_records\n"; }
}
if ( $SYNC_ingroups > 0 ) {
    if ($DBX) { print "\n\n"; }
    if ($DB) {
        print " - starting sync of vicidial_inbound_groups to code_possibili\n";
    }
    $found_records   = 0;
    $updated_records = 0;
    $added_records   = 0;
    $stmtA =
      "SELECT group_id,group_name from vicidial_inbound_groups limit 1000000;";
    if ($DBX) { print "$stmtA\n"; }
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
    $sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
    $sthArowsD = $sthA->rows;
    $i         = 0;

    while ( $sthArowsD > $i ) {
        @aryA             = $sthA->fetchrow_array;
        $Vid[$i]          = $aryA[0];
        $Vdescription[$i] = $aryA[1];
        $i++;
    }
    $sthA->finish();
    $i = 0;
    while ( $sthArowsD > $i ) {
        $visibility_keySEARCH = '';
        if ( $KEY_ingroup > 0 ) {
            $visibility_keySEARCH = " and visibility_key LIKE \"%$Vid[$i]%\"";
        }
        if ( $KEY_allq > 0 ) {
            $visibility_keySEARCH .= " and visibility_key LIKE \"%ALLQ%\"";
        }
        if ( $KEY_wipe > 0 ) {
            $visibility_keySEARCH = '';
            if ( ( $KEY_ingroup > 0 ) && ( $KEY_allq > 0 ) ) {
                $visibility_keySEARCH = " and visibility_key = '$Vid[$i] ALLQ'";
            }
            else {
                if ( $KEY_ingroup > 0 ) {
                    $visibility_keySEARCH .= " and visibility_key ='$Vid[$i]'";
                }
                if ( $KEY_allq > 0 ) {
                    $visibility_keySEARCH .= " and visibility_key ='ALLQ'";
                }
            }
        }
        $stmtB =
"SELECT count(*) FROM code_possibili where composizione_coda='$Vid[$i]' and nome_coda='$Vdescription[$i]' and q_direction='inbound' $visibility_keySEARCH;";
        $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
        $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
        $AN_records = $sthB->rows;
        if ( $AN_records > 0 ) {
            @aryB     = $sthB->fetchrow_array;
            $AN_count = $aryB[0];
        }
        $sthB->finish();
        if ( $AN_count < 1 ) {
            $stmtB =
"SELECT count(*) FROM code_possibili where composizione_coda='$Vid[$i]';";
            $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
            $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
            $ANX_records = $sthB->rows;
            if ( $ANX_records > 0 ) {
                @aryB      = $sthB->fetchrow_array;
                $ANX_count = $aryB[0];
            }
            $sthB->finish();
            if ( $ANX_count < 1 ) {
                if ( $KEY_ingroup > 0 ) {
                    $PREvisibility_key  = ',visibility_key';
                    $POSTvisibility_key = ",'$Vid[$i]'";
                    if ( $KEY_allq > 0 ) {
                        $POSTvisibility_key = ",'$Vid[$i] ALLQ'";
                    }
                }
                else {
                    if ( $KEY_allq > 0 ) {
                        $PREvisibility_key  = ',visibility_key';
                        $POSTvisibility_key = ",'ALLQ'";
                    }
                }
                $stmtB =
"INSERT INTO code_possibili (composizione_coda,nome_coda,q_direction,sys_dt_creazione,sys_user_creazione,sys_dt_modifica,sys_user_modifica $PREvisibility_key) values('$Vid[$i]','$Vdescription[$i]','inbound',NOW(),'32',NOW(),'32'$POSTvisibility_key);";
                if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                if ($DB) {
                    print
"     code_possibili in-group record inserted: $Baffected_rows|$stmtB|\n";
                }
                $event_string =
"code_possibili INSERT: $i|$Vid[$i]|$Vdescription[$i]|$Baffected_rows|$stmtB";
                &event_logger;
                $added_records++;
            }
            else {
                if ( ( $KEY_ingroup > 0 ) || ( $KEY_allq > 0 ) ) {
                    $visibility_key = '';
                    $stmtB =
"SELECT visibility_key FROM code_possibili where composizione_coda='$Vid[$i]';";
                    $sthB = $dbhB->prepare($stmtB)
                      or die "preparing: ", $dbhB->errstr;
                    $sthB->execute or die "executing: $stmtB ", $dbhB->errstr;
                    $ANX_records = $sthB->rows;
                    if ( $ANX_records > 0 ) {
                        @aryB           = $sthB->fetchrow_array;
                        $visibility_key = $aryB[0];
                    }
                    $sthB->finish();
                    if ( $KEY_wipe > 0 ) { $visibility_key = ''; }
                    if ( length($visibility_key) < 2 ) {
                        if ( $KEY_ingroup > 0 ) {
                            $visibility_keySQL = ",visibility_key='$Vid[$i]'";
                            if ( $KEY_allq > 0 ) {
                                $visibility_keySQL =
                                  ",visibility_key='$Vid[$i] ALLQ'";
                            }
                        }
                        else {
                            if ( $KEY_allq > 0 ) {
                                $visibility_keySQL = ",visibility_key='ALLQ'";
                            }
                        }
                    }
                    else {
                        $VKupdate = 0;
                        if ( $KEY_ingroup > 0 ) {
                            $igcheck = $Vid[$i];
                            if ( $visibility_key !~ /$igcheck/i ) {
                                $visibility_key .= " $igcheck";
                                $VKupdate++;
                            }
                        }
                        if ( $KEY_allq > 0 ) {
                            if ( $visibility_key !~ /ALLQ/i ) {
                                $visibility_key .= " ALLQ";
                                $VKupdate++;
                            }
                        }
                        if ( $VKupdate > 0 ) {
                            $visibility_keySQL =
                              ",visibility_key='$visibility_key'";
                        }
                    }
                }
                $stmtB =
"UPDATE code_possibili SET nome_coda='$Vdescription[$i]',q_direction='inbound' $visibility_keySQL where composizione_coda='$Vid[$i]' LIMIT 1;";
                if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                if ($DB) {
                    print
"     code_possibili in-group record updated: $Baffected_rows|$stmtB|\n";
                }
                $event_string =
"code_possibili UPDATE: $i|$Vid[$i]|$Vdescription[$i]|$Baffected_rows|$stmtB";
                &event_logger;
                $updated_records++;
            }
        }
        else {
            if ($DB) {
                print
"   code_possibili in-group exists: $Vid[$i] - $Vdescription[$i]\n";
            }
            $found_records++;
        }
        $i++;
    }
    if ($DB) { print " - finished inbound queue sync:\n"; }
    if ($DB) { print "     records scanned:       $i\n"; }
    if ($DB) { print "     records found:      $found_records\n"; }
    if ($DB) { print "     records updated:    $updated_records\n"; }
    if ($DB) { print "     records added:      $added_records\n"; }
}
if ( $SYNC_campaigns > 0 ) {
    if ($DBX) { print "\n\n"; }
    if ($DB) {
        print " - starting sync of vicidial_campaigns to code_possibili\n";
    }
    $found_records   = 0;
    $updated_records = 0;
    $added_records   = 0;
    $stmtA =
      "SELECT campaign_id,campaign_name from vicidial_campaigns limit 100000;";
    if ($DBX) { print "$stmtA\n"; }
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
    $sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
    $sthArowsD = $sthA->rows;
    $i         = 0;

    while ( $sthArowsD > $i ) {
        @aryA             = $sthA->fetchrow_array;
        $Vid[$i]          = $aryA[0];
        $Vdescription[$i] = $aryA[1];
        $i++;
    }
    $sthA->finish();
    $i = 0;
    while ( $sthArowsD > $i ) {
        $stmtB =
"SELECT count(*) FROM code_possibili where composizione_coda='$Vid[$i]' and nome_coda='$Vdescription[$i]' and q_direction='outbound';";
        $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
        $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
        $AN_records = $sthB->rows;
        if ( $AN_records > 0 ) {
            @aryB     = $sthB->fetchrow_array;
            $AN_count = $aryB[0];
        }
        $sthB->finish();
        if ( $AN_count < 1 ) {
            $stmtB =
"SELECT count(*) FROM code_possibili where composizione_coda='$Vid[$i]';";
            $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
            $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
            $ANX_records = $sthB->rows;
            if ( $ANX_records > 0 ) {
                @aryB      = $sthB->fetchrow_array;
                $ANX_count = $aryB[0];
            }
            $sthB->finish();
            if ( $ANX_count < 1 ) {
                $stmtB =
"INSERT INTO code_possibili (composizione_coda,nome_coda,q_direction,sys_dt_creazione,sys_user_creazione,sys_dt_modifica,sys_user_modifica) values('$Vid[$i]','$Vdescription[$i]','outbound',NOW(),'32',NOW(),'32');";
                if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                if ($DB) {
                    print
"     code_possibili campaign record inserted: $Baffected_rows|$stmtB|\n";
                }
                $event_string =
"code_possibili INSERT: $i|$Vid[$i]|$Vdescription[$i]|$Baffected_rows|$stmtB";
                &event_logger;
                $added_records++;
            }
            else {
                $stmtB =
"UPDATE code_possibili SET nome_coda='$Vdescription[$i]',q_direction='outbound' where composizione_coda='$Vid[$i]' LIMIT 1;";
                if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
                if ($DB) {
                    print
"     code_possibili campaign record updated: $Baffected_rows|$stmtB|\n";
                }
                $event_string =
"code_possibili UPDATE: $i|$Vid[$i]|$Vdescription[$i]|$Baffected_rows|$stmtB";
                &event_logger;
                $updated_records++;
            }
        }
        else {
            if ($DB) {
                print
"   code_possibili campaign exists: $Vid[$i] - $Vdescription[$i]\n";
            }
            $found_records++;
        }
        $i++;
    }
    if ($DB) { print " - finished campaign queue sync:\n"; }
    if ($DB) { print "     records scanned:       $i\n"; }
    if ($DB) { print "     records found:      $found_records\n"; }
    if ($DB) { print "     records updated:    $updated_records\n"; }
    if ($DB) { print "     records added:      $added_records\n"; }
}
if ( $SYNC_all_alias > 0 ) {
    if ($DBX) { print "\n\n"; }
    if ($DB)  { print " - starting sync of code_possibili All Queues alias\n"; }
    $found_records   = 0;
    $updated_records = 0;
    $added_records   = 0;
    $stmtB =
      "SELECT count(*) FROM code_possibili where nome_coda='00 All Queues';";
    $sthB = $dbhB->prepare($stmtB) or die "preparing: ",        $dbhB->errstr;
    $sthB->execute                 or die "executing: $stmtB ", $dbhB->errstr;
    $AAQ_records = $sthB->rows;

    if ( $AAQ_records > 0 ) {
        @aryB      = $sthB->fetchrow_array;
        $AAQ_count = $aryB[0];
    }
    $sthB->finish();
    if ( $AAQ_count < 1 ) {
        if ($DB) { print " - All Alias queue does not exist\n"; }
    }
    else {
        $AAQ_list = '';
        $stmtB =
"SELECT composizione_coda FROM code_possibili where nome_coda NOT IN('00 All Queues','00 All');";
        $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
        $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
        $AAQD_records = $sthB->rows;
        $i            = 0;
        while ( $AAQD_records > $i ) {
            @aryB = $sthB->fetchrow_array;
            $AAQ_list .= "$aryB[0]|";
            $i++;
        }
        $sthB->finish();
        chop($AAQ_list);
        $stmtB =
"SELECT count(*) FROM code_possibili where composizione_coda='$AAQ_list' and nome_coda='00 All Queues';";
        $sthB = $dbhB->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
        $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
        $AN_records = $sthB->rows;
        if ( $AN_records > 0 ) {
            @aryB     = $sthB->fetchrow_array;
            $AN_count = $aryB[0];
        }
        $sthB->finish();
        if ( $AN_count < 1 ) {
            $stmtB =
"UPDATE code_possibili SET composizione_coda='$AAQ_list' where nome_coda='00 All Queues' LIMIT 1;";
            if ( $TEST < 1 ) { $Baffected_rows = $dbhB->do($stmtB); }
            if ($DB) {
                print
"     code_possibili all alias record updated: $Baffected_rows|$stmtB|\n";
            }
            $event_string =
              "code_possibili UPDATE: $i|all alias|$Baffected_rows|$stmtB";
            &event_logger;
            $updated_records++;
        }
        if ($DB) { print " - finished All Alias queue sync:\n"; }
        if ($DB) { print "     records scanned:       $i\n"; }
        if ($DB) { print "     records found:      $AAQ_count\n"; }
        if ($DB) { print "     records updated:    $updated_records\n"; }
    }
}
if ($DB) { print STDERR "\nDONE\n"; }
$dbhB->disconnect();
exit;

sub event_logger {
    open( Lout, ">>$CLEANLOGfile" )
      || die "Can't open $CLEANLOGfile: $!\n";
    print Lout "$HDSQLdate|$event_string|\n";
    close(Lout);
    $event_string = '';
}
