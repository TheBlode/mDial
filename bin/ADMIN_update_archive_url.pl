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
use DBI;

sub print_help {
    print "$0 - updates the url in the recording_log\n";
    print "command-line options:\n";
    print "  [--debug]          = shows the sql as it is being executed.\n";
    print "  [--test]           = activates debuging and does not actually\n";
    print "                       execute the updates.\n";
    print "  [--old-server-url] = the old url used to access the recordings.\n";
    print "                       This is a required argument.\n";
    print "  [--new-server-url] = the new url used to access the recordings.\n";
    print "                       This is a required argument.\n\n";
    exit;
}
$PATHconf = '/etc/astguiclient.conf';
open( CONFIG, "$PATHconf" ) || die "can't open $PATHconf: $!\n";
@config = <CONFIG>;
close(CONFIG);
$i = 0;
foreach (@config) {
    $line = $config[$i];
    $line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
    if ( $line =~ /^VARserver_ip/ ) {
        $VARserver_ip = $line;
        $VARserver_ip =~ s/.*=//gi;
    }
    if ( $line =~ /^VARDB_server/ ) {
        $VARDB_server = $line;
        $VARDB_server =~ s/.*=//gi;
    }
    if ( $line =~ /^VARDB_database/ ) {
        $VARDB_database = $line;
        $VARDB_database =~ s/.*=//gi;
    }
    if ( $line =~ /^VARDB_user/ ) {
        $VARDB_user = $line;
        $VARDB_user =~ s/.*=//gi;
    }
    if ( $line =~ /^VARDB_pass/ ) {
        $VARDB_pass = $line;
        $VARDB_pass =~ s/.*=//gi;
    }
    if ( $line =~ /^VARDB_port/ ) {
        $VARDB_port = $line;
        $VARDB_port =~ s/.*=//gi;
    }
    $i++;
}
$old_url = "";
$new_url = "";
$DB      = 0;
$TEST    = 0;
if ( length( $ARGV[0] ) > 1 ) {
    $i = 0;
    while ( $#ARGV >= $i ) {
        $args = "$args $ARGV[$i]";
        $i++;
    }
    if ( $args =~ /--help/i ) {
        &print_help;
    }
    else {
        if ( $args =~ /--debug/i ) {
            $DB = 1;
        }
        if ( $args =~ /--test/i ) {
            $DB   = 1;
            $TEST = 1;
        }
        if ( $args =~ /--old-server-url=/i ) {
            @CLIoldurlARY = split( /--old-server-url=/, $args );
            @CLIoldurlARX = split( / /,                 $CLIoldurlARY[1] );
            $old_url      = $CLIoldurlARX[0];
        }
        if ( $args =~ /--new-server-url=/i ) {
            @CLInewurlARY = split( /--new-server-url=/, $args );
            @CLInewurlARX = split( / /,                 $CLInewurlARY[1] );
            $new_url      = $CLInewurlARX[0];
        }
    }
}
else {
    &print_help;
}
if ( ( $new_url eq "" ) || ( $old_url eq "" ) ) {
    &print_help;
}
$dbhA = DBI->connect( "DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port",
    "$VARDB_user", "$VARDB_pass" )
  or die "Couldn't connect to database: " . DBI->errstr;
$stmtA =
"SELECT recording_id, location from recording_log where location LIKE '$old_url%';";
if ($DB) {
    print $stmtA . "\n";
}
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",        $dbhA->errstr;
$sthA->execute                 or die "executing: $stmtA ", $dbhA->errstr;
$sthArows  = $sthA->rows;
$rec_count = 0;
while ( $sthArows > $rec_count ) {
    @aryA     = $sthA->fetchrow_array;
    $rec_id   = "$aryA[0]";
    $location = "$aryA[1]";
    $new_loc  = $location;
    $new_loc =~ s/$old_url/$new_url/gi;
    $stmtB =
"UPDATE recording_log SET location='$new_loc' where recording_id='$rec_id';";
    if ($DB) {
        print $stmtB . "\n";
    }
    if ( $TEST == 0 ) {
        $sthB = $dbhA->prepare($stmtB) or die "preparing: ", $dbhB->errstr;
        $sthB->execute or die "executing: $stmtB ",          $dbhB->errstr;
        $sthB->finish();
    }
    $rec_count++;
}
print "Updated $rec_count records in the recording_log table\n";
$sthA->finish();
$dbhA->disconnect();
