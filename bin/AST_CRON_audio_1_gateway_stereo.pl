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
$MIX    = 0;
$STEREO = 0;
$HTTPS  = 0;
if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--help/i ) {
        print "allowed run time options:\n";
        print "  [--debug] = debug\n";
        print "  [--debugX] = super debug\n";
        print "  [-t] = test\n";
        print "  [--MIX] = mix audio files in MIX directory\n";
        print "  [--STEREO] = mix audio files in STEREO directory\n";
        print "  [--HTTPS] = use https instead of http in local location\n";
        print "\n";
        exit;
    }
    else {
        if ( $args =~ /--debug/i ) {
            $DB = 1;
            print "\n----- DEBUG -----\n\n";
        }
        if ( $args =~ /--debugX/i ) {
            $DBX = 1;
            print "\n----- SUPER DEBUG -----\n\n";
        }
        if ( $args =~ /-t/i ) {
            $T    = 1;
            $TEST = 1;
            print "\n-----TESTING -----\n\n";
        }
        if ( $args =~ /--MIX/i ) {
            $MIX = 1;
            if ($DB) { print "MIX directory audio processing only\n"; }
        }
        if ( $args =~ /--STEREO/i ) {
            $STEREO = 1;
            if ($DB) { print "STEREO directory audio processing only\n"; }
        }
        if ( $args =~ /--HTTPS/i ) {
            $HTTPS = 1;
            if ($DB) { print "HTTPS location option enabled\n"; }
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
    if ( ( $line =~ /^PATHDONEmonitor/ ) && ( $CLIDONEmonitor < 1 ) ) {
        $PATHDONEmonitor = $line;
        $PATHDONEmonitor =~ s/.*=//gi;
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
    if ( ( $line =~ /^VARFTP_host/ ) && ( $CLIFTP_host < 1 ) ) {
        $VARFTP_host = $line;
        $VARFTP_host =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARFTP_user/ ) && ( $CLIFTP_user < 1 ) ) {
        $VARFTP_user = $line;
        $VARFTP_user =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARFTP_pass/ ) && ( $CLIFTP_pass < 1 ) ) {
        $VARFTP_pass = $line;
        $VARFTP_pass =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARFTP_port/ ) && ( $CLIFTP_port < 1 ) ) {
        $VARFTP_port = $line;
        $VARFTP_port =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARFTP_dir/ ) && ( $CLIFTP_dir < 1 ) ) {
        $VARFTP_dir = $line;
        $VARFTP_dir =~ s/.*=//gi;
    }
    if ( ( $line =~ /^VARHTTP_path/ ) && ( $CLIHTTP_path < 1 ) ) {
        $VARHTTP_path = $line;
        $VARHTTP_path =~ s/.*=//gi;
    }
    $i++;
}
$server_ip = $VARserver_ip;    # Asterisk server IP
if ( !$VARDB_port ) { $VARDB_port = '3306'; }
use Time::HiRes ( 'gettimeofday', 'usleep', 'sleep' )
  ;    # necessary to have perl sleep command of less than one second
use DBI;
$dbhA = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$soxmixbin = '';
if ( -e ('/usr/bin/soxmix') ) { $soxmixbin = '/usr/bin/soxmix'; }
else {
    if ( -e ('/usr/local/bin/soxmix') ) {
        $soxmixbin = '/usr/local/bin/soxmix';
    }
    else {
        if ($DB) { print "Can't find soxmix binary! Trying sox...\n"; }
        if ( -e ('/usr/bin/sox') ) { $soxmixbin = '/usr/bin/sox -m'; }
        else {
            if ( -e ('/usr/local/bin/sox') ) {
                $soxmixbin = '/usr/local/bin/sox -m';
            }
            else {
                print "Can't find sox binary! Exiting...\n";
                exit;
            }
        }
    }
}
$soxibin = '';
if ( -e ('/usr/bin/soxi') ) { $soxibin = '/usr/bin/soxi'; }
else {
    if ( -e ('/usr/local/bin/soxi') ) { $soxibin = '/usr/local/bin/soxi'; }
    else {
        if ( -e ('/usr/sbin/soxi') ) { $soxibin = '/usr/sbin/soxi'; }
        else {
            if ($DB) {
                print
"Can't find soxi binary! No length calculations will be available...\n";
            }
        }
    }
}
$dir1       = "$PATHmonitor";
$dir2       = "$PATHDONEmonitor";
$STEREOarch = '';
if ( $MIX > 0 ) { $dir1 = "$PATHmonitor/MIX"; }
if ( $STEREO > 0 ) {
    $dir1 = "$PATHmonitor/STEREO";
    $dir2 = "$PATHDONEmonitor";
}
opendir( FILE, "$dir1/" );
@FILES = readdir(FILE);
$i     = 0;
$calls = 0;
foreach (@FILES) {
    $FILEsize1[$i] = 0;
    if ( ( length( $FILES[$i] ) > 4 ) && ( !-d "$dir1/$FILES[$i]" ) ) {
        $FILEsize1[$i] = ( -s "$dir1/$FILES[$i]" );
        if ($DBX) { print "$FILES[$i] $FILEsize1[$i]\n"; }
        if ( $FILES[$i] !~ /^DIALER_/i ) { $calls++; }
    }
    $i++;
}
if ($DB) { print "Total recording files found: $i (calls: $calls)\n"; }
sleep(5);
$i = 0;
foreach (@FILES) {
    $FILEsize2[$i] = 0;
    if ( ( length( $FILES[$i] ) > 4 ) && ( !-d "$dir1/$FILES[$i]" ) ) {
        $FILEsize2[$i] = ( -s "$dir1/$FILES[$i]" );
        if ($DBX) { print "$FILES[$i] $FILEsize2[$i]\n\n"; }
        if (   ( $FILES[$i] !~ /^CARRIER_|lost\+found/i )
            && ( $FILEsize1[$i] eq $FILEsize2[$i] )
            && ( length( $FILES[$i] ) > 4 ) )
        {
            $INfile  = $FILES[$i];
            $OUTfile = $FILES[$i];
            $OUTfile =~ s/DIALER_/CARRIER_/gi;
            $ALLfile = $FILES[$i];
            $ALLfile =~ s/DIALER_//gi;
            $SQLFILE = $FILES[$i];
            $SQLFILE =~ s/DIALER_|\.wav//gi;
            $length_in_sec = 0;
            $stmtA =
"select recording_id,length_in_sec from recording_log where filename='$SQLFILE' order by recording_id desc LIMIT 1;";
            if ($DBX) { print STDERR "\n|$stmtA|\n"; }
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ", $dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ",          $dbhA->errstr;
            $sthArows = $sthA->rows;

            if ( $sthArows > 0 ) {
                @aryA          = $sthA->fetchrow_array;
                $recording_id  = $aryA[0];
                $length_in_sec = $aryA[1];
            }
            $sthA->finish();
            if ($DB) {
                print
"|$recording_id|$length_in_sec|$INfile|$OUTfile|     |$ALLfile|\n";
            }
            `$soxmixbin -M "$dir1/$INfile" "$dir1/$OUTfile" "$dir2/$ALLfile"`;
            $lengthSQL = '';
            if (
                (
                       ( $length_in_sec < 1 )
                    || ( $length_in_sec =~ /^NULL$/i )
                    || ( length($length_in_sec) < 1 )
                )
                && ( length($soxibin) > 3 )
              )
            {
                @soxi_output = `$soxibin -D $dir2/$ALLfile`;
                $soxi_sec    = $soxi_output[0];
                $soxi_sec =~ s/\..*|\n|\r| //gi;
                $soxi_min = ( $soxi_sec / 60 );
                $soxi_min = sprintf( "%.2f", $soxi_min );
                $lengthSQL =
                  ",length_in_sec='$soxi_sec',length_in_min='$soxi_min'";
            }
            $HTTP = 'http';
            if ( $HTTPS > 0 ) { $HTTP = 'https'; }
            $stmtA =
"UPDATE recording_log set location='$HTTP://$server_ip/RECORDINGS$STEREOarch/$ALLfile' $lengthSQL where recording_id='$recording_id';";
            if ($DBX) { print STDERR "\n|$stmtA|\n"; }
            $affected_rows =
              $dbhA->do($stmtA); #  or die  "Couldn't execute query:|$stmtA|\n";
            if ( !$T ) {
                `mv -f "$dir1/$INfile" "$dir2/ORIG/$INfile"`;
                `mv -f "$dir1/$OUTfile" "$dir2/ORIG/$OUTfile"`;
            }
            usleep( 1 * 200 * 1000 );
        }
    }
    $i++;
}
if ($DB) { print "DONE... EXITING\n\n"; }
$dbhA->disconnect();
exit;
