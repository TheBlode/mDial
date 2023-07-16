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
$PATHvoices = '/tmp/swift_voices';
$PATHswift = '/opt/swift/bin/swift';
$PATHconf =        '/etc/astguiclient.conf';
open(conf, "$PATHconf") || die "can't open $PATHconf: $!\n";
@conf = <conf>;
close(conf);
$i=0;
foreach(@conf)
    {
    $line = $conf[$i];
    $line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
    if ( ($line =~ /^PATHagi/) && ($CLIagi < 1) )
        {$PATHagi = $line;   $PATHagi =~ s/.*=//gi;}
    if ( ($line =~ /^PATHsounds/) && ($CLIsounds < 1) )
        {$PATHsounds = $line;   $PATHsounds =~ s/.*=//gi;}
    $i++;
    }
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
        print "  [-debugX] = Extra-verbose debug messages\n";
        print "  [-voice=Allison-8kHz] = Cepstral voice to use(Allison-8kHz is default)\n\n";
        print "  [-dialog=Hello] = Message to generate\n\n";
        print "   (This must be the LAST option)\n\n";
        }
    else
        {
        if ($args =~ /-debug/i)
            {
            $DB=1; # Debug flag
            }
        if ($args =~ /--debugX/i)
            {
            $DBX=1;
            print "\n----- SUPER-DUPER DEBUGGING -----\n\n";
            }
        if ($args =~ /-t/i)
            {
            $TEST=1;
            $T=1;
            }
        if ($args =~ /-voice=/i)
            {
            @data_in = split(/-voice=/,$args);
                $voice = $data_in[1];
                $voice =~ s/ .*//gi;
            if ($DBX > 0) {print "\n----- VOICE: $voice -----\n\n";}
            }
        else
            {$voice = 'Allison-8kHz';}
        if ($args =~ /-dialog=/i)
            {
            @data_in = split(/-dialog=/,$args);
                $dialog = $data_in[1];
                $dialog =~ s/\n|\r|\l|\t//gi;
            if ($DBX > 0) {print "\n----- DIALOG: $dialog -----\n\n";}
            }
        else
            {$dialog = '';}
        }
    }
else
    {
    }
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year = ($year + 1900);
$mon++;
if ($hour < 10) {$hour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
$SQL_date = "$year-$mon-$mday $hour:$min:$sec";
use Digest::MD5 qw(md5_hex);
use Asterisk::AGI;
$AGI = new Asterisk::AGI;
if (length($dialog) > 1)
    {
    $enc = md5_hex("$dialog-$voice");    # the hash
    $enc_ftl = substr($enc, 0, 2);    # first letter of hash
    $enc_file = "tts/" . $enc_ftl . "/tts-" . $enc . ".wav";
    if ($DB > 0)
        {print "$SQL_date - Creating $dialog - $voice   file: $enc_file\n";}
    &gen_cepstral("$dialog","$voice");
    }
exit;
sub get_cep_voice {
    my $number = $_[0];
    if ($number <= 0) {
        return 0;    # failure
    }
    my $cepstral_app = "$PATHswift";
    my $command = $cepstral_app.' --voices | tail +8 | tr -d " " > '.$PATHvoices;
    system( $command );    # Ask swift for the voices
    my @voice;
    my @voice_lines;
    my $voice_count;
    open(VFILE,"$PATHvoices");    # read in the file with the voices
    @voice_lines = <VFILE>;
    close(VFILE);
    foreach my $voice_line(@voice_lines) {
        chomp($voice_line);
        $voice_count++;
        if ($voice_count == $number) {
            @voice = split(/\|/,$voice_line);
        }
    }
    return @voice;
}
sub get_cep_num_voices {
    my $cepstral_app = "$PATHswift";
        my $command = $cepstral_app.' --voices | tail +8 | tr -d " " > '.$PATHvoices;
        system( $command );    # Ask swift for the voices
        my @voice_lines;
    my $number = 0;
        open(VFILE,"$PATHvoices");
        @voice_lines = <VFILE>;
        close(VFILE);
        foreach (@voice_lines) {
        $number++;
        }    
    return $number;
}
sub gen_cepstral {
    my $text = $_[0];    # the text to play
    my $voice = $_[1];    # voice to use
    my $hash = md5_hex("$text-$voice");    # the hash
    my $hash_ftl = substr($hash, 0, 2);    # first two letters of hash
    my $astsounddir = $PATHsounds;     # asterisk sound directory
    my $ttssounddir = $astsounddir."/tts";
    my $astsubdir = "tts/".$hash_ftl;         # sub directory that holds the file
    my $sounddir = $astsounddir . "/" . $astsubdir;     # full path to the directory
    my $wavefile = "tts-".$hash;             # wave file without the .wav at the end
    my $wavepath = $sounddir."/".$wavefile.".wav";     # full path to the wavefile
    my $astwavpath = $astsubdir."/".$wavefile;     # asterisk path to .wav file without .wav
    my $textfile = "tts-text-".$hash.".txt";    # file to hold the words to say
    my $textpath = $sounddir."/".$textfile;        # full path to the text file
    if (!(&real_gen_cepstral($text, $voice, $ttssounddir, $sounddir, $wavepath, $textpath))) {
        return 0; # failure
    }    
    return 1; # success
}
sub say_cepstral {
    my $text = $_[0];    # the text to play
    my $voice = $_[1];    # voice to use
    my %input = $AGI->ReadParse(); 
        my $hash = md5_hex("$text-$voice");    # the hash
        my $hash_ftl = substr($hash, 0, 2);    # first letter of hash
        my $astsounddir = $PATHsounds;   # asterisk sound directory
        my $ttssounddir = $astsounddir."/tts";
        my $astsubdir = "tts/".$hash_ftl;                # sub directory that holds the file
        my $sounddir = $astsounddir."/".$astsubdir;     # full path to the directory
        my $wavefile = "tts-".$hash;                    # wave file without the .wav at the end
        my $wavepath = $sounddir."/".$wavefile.".wav";  # full path to the wavefile
        my $astwavpath = $astsubdir."/".$wavefile;      # asterisk path to .wav file without .wav
        my $textfile = "tts-text-".$hash.".txt";        # file to hold the words to say
        my $textpath = $sounddir."/".$textfile;         # full path to the text file
    if (!(&real_gen_cepstral($text, $voice, $ttssounddir, $sounddir, $wavepath, $textpath))) { 
        return 0; # failure
    }
    my $i = 0;
    while ( ($i < 100) && !(-f $wavepath) && (-f $textpath) ) {
        usleep(10000);
        $i++;
    }
    $AGI->stream_file($astwavpath);     # play the tts
    return 1; # success
}
sub real_gen_cepstral {
    my $text = $_[0];
    my $voice = $_[1];
    my $ttssounddir = $_[2];
    my $sounddir = $_[3];
    my $wavepath = $_[4];
    my $textpath = $_[5];
        my $cepstral_app = "$PATHswift";      # the executable
        my $cepstral_opt = "-p speech/rate=140";                          # the command line options
        if (!(-d $ttssounddir)) {
                if (!(mkdir($ttssounddir))) {
                        return 0; # failure - cannot make the tts directory
                }
        }
        if (!(-d $sounddir)) {
                if (!(mkdir($sounddir))) {
                        return 0; # failure - cannot make the sub directory
                }
        }
        if (!( -f $wavepath ) && !( -f $textpath )) {
                open(fileOUT, ">$textpath");
                print fileOUT "$text";
                close(fileOUT);
                my $command=$cepstral_app." ".$cepstral_opt." -n ".$voice." -o ".$wavepath." -f ".$textpath." > /dev/null";
                system($command);
                unlink($textpath);
        }
        return 1; # success
}
