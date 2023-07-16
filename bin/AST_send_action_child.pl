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
$|++;
use Getopt::Long;
use Net::Telnet;
my $secX = time();    #Start time
my ( $CLOhelp, $SYSLOG, $PATHlogs, $telnet_host, $telnet_port,
    $ASTmgrUSERNAME );
my ( $ASTmgrSECRET, $ASTmgrUSERNAMEsend, $man_id, $action, $cmd_line_b,
    $cmd_line_c );
my ( $cmd_line_d, $cmd_line_e, $cmd_line_f, $cmd_line_g, $cmd_line_h );
my ( $cmd_line_i, $cmd_line_j, $cmd_line_k, $DB,         $DBX );
my $FULL_LOG = 1;

if ( scalar @ARGV ) {
    GetOptions(
        'help!'                => \$CLOhelp,
        'SYSLOG!'              => \$SYSLOG,
        'PATHlogs=s'           => \$PATHlogs,
        'telnet_host=s'        => \$telnet_host,
        'telnet_port=s'        => \$telnet_port,
        'ASTmgrUSERNAME=s'     => \$ASTmgrUSERNAME,
        'ASTmgrSECRET=s'       => \$ASTmgrSECRET,
        'ASTmgrUSERNAMEsend=s' => \$ASTmgrUSERNAMEsend,
        'man_id=s'             => \$man_id,
        'action=s'             => \$action,
        'cmd_line_b=s'         => \$cmd_line_b,
        'cmd_line_c=s'         => \$cmd_line_c,
        'cmd_line_d=s'         => \$cmd_line_d,
        'cmd_line_e=s'         => \$cmd_line_e,
        'cmd_line_f=s'         => \$cmd_line_f,
        'cmd_line_g=s'         => \$cmd_line_g,
        'cmd_line_h=s'         => \$cmd_line_h,
        'cmd_line_i=s'         => \$cmd_line_i,
        'cmd_line_j=s'         => \$cmd_line_j,
        'cmd_line_k=s'         => \$cmd_line_k,
        'debug!'               => \$DB,
        'debugX!'              => \$DBX,
        'fulllog!'             => \$FULL_LOG
    );
    $DB = 1 if ($DBX);
    if ($DB) {
        print "\n----- DEBUGGING -----\n\n";
        print "\n----- SUPER-DUPER DEBUGGING -----\n\n"    if ($DBX);
        print "  SYSLOG:                $SYSLOG\n"         if ($SYSLOG);
        print "  telnet_host:           $telnet_host\n"    if ($telnet_host);
        print "  telnet_port:           $telnet_port\n"    if ($telnet_port);
        print "  ASTmgrUSERNAME:        $ASTmgrUSERNAME\n" if ($ASTmgrUSERNAME);
        print "  ASTmgrSECRET:          $ASTmgrSECRET\n"   if ($ASTmgrSECRET);
        print "  ASTmgrUSERNAMEsend:    $ASTmgrUSERNAMEsend\n"
          if ($ASTmgrUSERNAMEsend);
        print "  man_id:                $man_id\n"     if ($man_id);
        print "  cmd_line_b:            $cmd_line_b\n" if ($cmd_line_b);
        print "  cmd_line_c:            $cmd_line_c\n" if ($cmd_line_c);
        print "  cmd_line_d:            $cmd_line_d\n" if ($cmd_line_d);
        print "  cmd_line_e:            $cmd_line_e\n" if ($cmd_line_e);
        print "  cmd_line_f:            $cmd_line_f\n" if ($cmd_line_f);
        print "  cmd_line_g:            $cmd_line_g\n" if ($cmd_line_g);
        print "  cmd_line_h:            $cmd_line_h\n" if ($cmd_line_h);
        print "  cmd_line_i:            $cmd_line_i\n" if ($cmd_line_i);
        print "  cmd_line_j:            $cmd_line_j\n" if ($cmd_line_j);
        print "  cmd_line_k:            $cmd_line_k\n" if ($cmd_line_k);
        print "\n";
    }
    if ($CLOhelp) {
        print "allowed run time options:\n";
        print "  [--help] = this help screen\n";
        print "  [--SYSLOG] = whether to log actions or not\n";
        print "required flags:\n";
        print "  [--PATHlogs] = logs directory path\n";
        print "  [--telnet_host] = IP address to connect to Asterisk Manager\n";
        print "  [--telnet_port] = port to connect to Asterisk Manager\n";
        print "  [--ASTmgrUSERNAME] = username for Asterisk Manager login\n";
        print
"  [--ASTmgrSECRET] = secret or password for Asterisk Manager login\n";
        print
"  [--ASTmgrUSERNAMEsend] = username specific for sending actions for Asterisk Manager login\n";
        print "  [--man_id] = ID of the action in the vicidial_manager table\n";
        print "  [--action] = type of manager action to send\n";
        print "  [--cmd_line_X] = lines to send to Manager after action\n";
        print "                   X replaced with b-k (10 lines)\n";
        print "\n";
        print "You may prefix an option with 'no' to disable it.\n";
        print " ie. --noSYSLOG or --noFULLLOG\n";
        exit 0;
    }
}
if ($action) {
    $PATHlogs   =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $cmd_line_b =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $cmd_line_c =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $cmd_line_d =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $cmd_line_e =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $cmd_line_f =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $cmd_line_g =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $cmd_line_h =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $cmd_line_i =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $cmd_line_j =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $cmd_line_k =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;

    if ($DB) {
        print "  SYSLOG:                $SYSLOG\n"         if ($SYSLOG);
        print "  telnet_host:           $telnet_host\n"    if ($telnet_host);
        print "  telnet_port:           $telnet_port\n"    if ($telnet_port);
        print "  ASTmgrUSERNAME:        $ASTmgrUSERNAME\n" if ($ASTmgrUSERNAME);
        print "  ASTmgrSECRET:          $ASTmgrSECRET\n"   if ($ASTmgrSECRET);
        print "  ASTmgrUSERNAMEsend:    $ASTmgrUSERNAMEsend\n"
          if ($ASTmgrUSERNAMEsend);
        print "  man_id:                $man_id\n"     if ($man_id);
        print "  cmd_line_b:            $cmd_line_b\n" if ($cmd_line_b);
        print "  cmd_line_c:            $cmd_line_c\n" if ($cmd_line_c);
        print "  cmd_line_d:            $cmd_line_d\n" if ($cmd_line_d);
        print "  cmd_line_e:            $cmd_line_e\n" if ($cmd_line_e);
        print "  cmd_line_f:            $cmd_line_f\n" if ($cmd_line_f);
        print "  cmd_line_g:            $cmd_line_g\n" if ($cmd_line_g);
        print "  cmd_line_h:            $cmd_line_h\n" if ($cmd_line_h);
        print "  cmd_line_i:            $cmd_line_i\n" if ($cmd_line_i);
        print "  cmd_line_j:            $cmd_line_j\n" if ($cmd_line_j);
        print "  cmd_line_k:            $cmd_line_k\n" if ($cmd_line_k);
    }
    $telnet_port = '5038' if ( !$telnet_port );
    my $tn = new Net::Telnet(
        Port                    => $telnet_port,
        Prompt                  => '/\r\n/',
        Output_record_separator => '',
        Errmode                 => "return"
    );
    if ( length($ASTmgrUSERNAMEsend) > 3 ) {
        $telnet_login = $ASTmgrUSERNAMEsend;
    }
    else { $telnet_login = $ASTmgrUSERNAME; }
    $tn->open("$telnet_host");
    $tn->waitfor('/Asterisk Call Manager\//');
    $ami_version = $tn->getline( Errmode => Return, Timeout => 1, );
    $ami_version =~ s/\n//gi;
    if ($DB) { print "----- AMI Version $ami_version -----\n"; }
    $tn->print(
        "Action: Login\nUsername: $telnet_login\nSecret: $ASTmgrSECRET\n\n");
    $tn->waitfor('/Authentication accepted/');    # waitfor auth accepted
    $tn->buffer_empty;

    if ( $cmd_line_b =~ /XXYYXXYYXXYYXX/ ) {
        my $meetme_command =
          "Action: Command\nCommand: meetme list $cmd_line_k\n\n";
        print nowDate() . "|$SYSLOG|\n$meetme_command";
        my $participant;
        my @list_meetme = $tn->cmd(
            String => $meetme_command,
            Prompt => '/--END COMMAND-.*/'
        );
        foreach my $meetme (@list_meetme) {
            if ( $meetme =~ /$cmd_line_j /i ) {
                $meetme =~ s/User \#: //gi;
                my @participants = split( / /, $meetme );
                $participant = ( $participants[0] + 0 );
            }
        }
        $cmd_line_b =~ s/XXYYXXYYXXYYXX/$participant/gi if ( $participant > 0 );
        $cmd_line_j = '';
        $cmd_line_k = '';
    }
    my $originate_command;
    $originate_command .= "Action: $action\n";
    $originate_command .= $cmd_line_b . "\n" if ($cmd_line_b);
    $originate_command .= $cmd_line_c . "\n" if ($cmd_line_c);
    $originate_command .= $cmd_line_d . "\n" if ($cmd_line_d);
    $originate_command .= $cmd_line_e . "\n" if ($cmd_line_e);
    $originate_command .= $cmd_line_f . "\n" if ($cmd_line_f);
    $originate_command .= $cmd_line_g . "\n" if ($cmd_line_g);
    $originate_command .= $cmd_line_h . "\n" if ($cmd_line_h);
    $originate_command .= $cmd_line_i . "\n" if ($cmd_line_i);
    $originate_command .= $cmd_line_j . "\n" if ($cmd_line_j);
    $originate_command .= $cmd_line_k . "\n" if ($cmd_line_k);
    $originate_command .= "\n";
    print nowDate() . "|$SYSLOG|$man_id|\n$originate_command";
    my $event_string = $man_id . "|0|" . $SYSLOG . "|";
    $event_string .= "\n" . $originate_command;
    eventLogger( $PATHlogs, 'full', $event_string )
      if ( $FULL_LOG and $SYSLOG );
    my @list_channels = $tn->cmd(
        String => $originate_command,
        Prompt => '/.*/'
    );
    $tn->waitfor( Match => '/Response:.*\n/',  Timeout => 10 );
    $tn->waitfor( Match => '/Message:.*\n\n/', Timeout => 10 );
    my $data1;    # ? Useless ?

    if ( $FULL_LOG and $SYSLOG ) {
        my $event_string = $man_id . "|1|" . $data1 . "|";
        foreach my $channel (@list_channels) {
            $event_string .= $channel;
        }
        my $read_input_buf = $tn->get(
            Errmode => "return",
            Timeout => 1
        );
        $event_string .= $read_input_buf;
        eventLogger( $PATHlogs, 'full', $event_string );
    }
    $tn->buffer_empty;
    $tn->cmd( String => "Action: Logoff\n\n", Prompt => "/.*/" );
    $tn->buffer_empty;
    $tn->waitfor( Match => '/Message:.*\n\n/', Timeout => 15 );
    if ( $FULL_LOG and $SYSLOG ) {
        my $event_string = $man_id . "|2|" . $data1 . "|";
        foreach my $channel (@list_channels) {
            $event_string .= $channel;
        }
        my $read_input_buf = $tn->get(
            Errmode => "return",
            Timeout => 1
        );
        $event_string .= $read_input_buf;
        eventLogger( $PATHlogs, 'full', $event_string );
    }
    $tn->buffer_empty;
    $tn->close;
}
my $secZ        = time();
my $script_time = ( $secZ - $secX );
if ($DB) { print "DONE execute time: $script_time seconds\n"; }
exit 0;

sub eventLogger {
    my ( $path, $type, $string ) = @_;
    open( LOG, ">>" . $path . "/action_" . $type . "." . logDate() )
      || die "Can't open "
      . $path
      . "/action_"
      . $type . "."
      . logDate() . ": "
      . $! . "\n";
    print LOG nowDate() . "|" . $string . "|\n";
    close(LOG);
}

sub getTime {
    my ($tms) = @_;
    $tms = time unless ($tms);
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime($tms);
    $year += 1900;
    $mon++;
    $mon  = "0" . $mon  if ( $mon < 10 );
    $mday = "0" . $mday if ( $mday < 10 );
    $min  = "0" . $min  if ( $min < 10 );
    $sec  = "0" . $sec  if ( $sec < 10 );
    return ( $sec, $min, $hour, $mday, $mon, $year );
}

sub nowDate {
    my ($tms) = @_;
    my ( $sec, $min, $hour, $mday, $mon, $year ) = getTime($tms);
    return $year . '-' . $mon . '-' . $mday . ' ' . $hour . ':' . $min . ':'
      . $sec;
}

sub logDate {
    my ($tms) = @_;
    my ( $sec, $min, $hour, $mday, $mon, $year ) = getTime($tms);
    return $year . '-' . $mon . '-' . $mday;
}
