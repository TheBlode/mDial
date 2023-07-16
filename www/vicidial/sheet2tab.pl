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
use Spreadsheet::Read;
use Spreadsheet::XLSX;
use File::Basename;
use open ':std', ':encoding(UTF-8)';

sub scrub_lead_field {
    my $lead_field = $_[0];
    $lead_field =~ s/\\|\"|;|\`|\224//gi;
    $lead_field =~ s/\n|\r|\t|\174/ /gi;
    return $lead_field;
}
my $infile;
my $outfile;
my $error_log      = "sheet2tab_error.txt";
my $csv_chuck_size = 500;
my $crap_loop_time = 5;
if ( $#ARGV == 1 ) {
    $infile  = $ARGV[0];
    $outfile = $ARGV[1];
}
else {
    print STDERR "Incorrect number of arguments\n";
    exit(1);
}
open( OUTFILE, ">$outfile" ) or die $!;
my $debug      = 0;
my $out_delim  = "\t";
my $count      = 0;
my $colPos     = 0;
my $rowPos     = 0;
my $time       = time();
my $tempfile   = "sheet2tab_temp_file_$time.csv";
my @exts       = qw(.csv);
my $exten_file = $infile;
chomp $exten_file;
my ( $dir, $name, $ext ) = fileparse( $exten_file, @exts );

if ( $ext eq '.csv' ) {
    open( IN,      $infile )      or die "can't open $infile: $!\n";
    open( TMPFILE, ">$tempfile" ) or die $!;
    my $cur_loop_time = time();
    my $old_loop_time = time();
    my $loop_time     = 0;
    my $loop_sleep    = 0;
    my $loop_count    = 0;
    while (<IN>) {
        $loop_count++;
        print TMPFILE $_;
        if ($debug) { print STDERR "csv line = '$_'\n"; }
        if ( $loop_count % $csv_chuck_size == 0 ) {
            close(TMPFILE);
            my $parser = ReadData("$tempfile");
            my $maxCol = $parser->[1]{maxcol};
            my $maxRow = $parser->[1]{maxrow};
            if ( ( $maxCol >= 100 ) || ( $maxCol == 0 ) ) {
                print STDERR "ERROR: Improperly formatted lead file.\n";
                print OUTFILE
"BAD_LEAD_FILE\tBAD_LEAD_FILE\tBAD_LEAD_FILE\tBAD_LEAD_FILE\tBAD_LEAD_FILE\tBAD_LEAD_FILE\tBAD_LEAD_FILE\t\n";
                exit;
            }
            if ($debug) { print STDERR "maxCol = '$maxCol'\n"; }
            if ($debug) { print STDERR "maxRow = '$maxRow'\n"; }
            for ( $rowPos = 1 ; $rowPos <= $maxRow ; $rowPos++ ) {
                for ( $colPos = 1 ; $colPos <= $maxCol ; $colPos++ ) {
                    my $cell = cr2cell( $colPos, $rowPos );
                    if ($debug) { print STDERR "cell = '$cell'\n"; }
                    my $field;
                    if ( $parser->[1]{$cell} ) {
                        $field = $parser->[1]{$cell};
                    }
                    else {
                        $field = "";
                    }
                    if ($debug) { print STDERR "field = '$field'\n"; }
                    $field = scrub_lead_field($field);
                    print OUTFILE $field;
                    if ( $colPos < $maxCol ) {
                        print OUTFILE $out_delim;
                    }
                    else {
                        print OUTFILE "\n";
                    }
                }
            }
            unlink($tempfile)             or die $!;
            open( TMPFILE, ">$tempfile" ) or die $!;
            $old_loop_time = $cur_loop_time;
            $cur_loop_time = time();
            $loop_time     = $cur_loop_time - $old_loop_time;
            if ( $loop_time > $crap_loop_time ) {
                $loop_sleep = $loop_sleep + $loop_time;
                if ( $loop_sleep > 60 ) {
                    close(TMPFILE);
                    close(IN);
                    unlink($tempfile) or die $!;
                    open( ERRFILE, ">>$error_log" );
                    print ERRFILE
"$cur_loop_time: Sheet2tab.pl aborting. Penalized them long enough for their junk leads in $infile \n\n";
                    close(ERRFILE);
                    exit;
                }
                sleep($loop_sleep);
                open( ERRFILE, ">>$error_log" );
                print ERRFILE
"$cur_loop_time: Sheet2tab.pl took $loop_time to process $csv_chuck_size leads from the $infile lead file. Making them sleep $loop_sleep so we can recover.\n\n";
                close(ERRFILE);
                $cur_loop_time = time();
            }
        }
    }
    close(TMPFILE);
    close(IN);
    my $temp_file_size = -s $tempfile;
    if ( $temp_file_size == 0 ) {
        unlink($tempfile) or die $!;
        exit;
    }
    my $parser = ReadData("$tempfile");
    my $maxCol = $parser->[1]{maxcol};
    my $maxRow = $parser->[1]{maxrow};
    if ( ( $maxCol >= 100 ) || ( $maxCol == 0 ) ) {
        print STDERR "ERROR: Improperly formatted lead file.\n";
        print OUTFILE
"BAD_LEAD_FILE\tBAD_LEAD_FILE\tBAD_LEAD_FILE\tBAD_LEAD_FILE\tBAD_LEAD_FILE\tBAD_LEAD_FILE\tBAD_LEAD_FILE\t\n";
        exit;
    }
    if ($debug) { print STDERR "maxCol = '$maxCol'\n"; }
    if ($debug) { print STDERR "maxRow = '$maxRow'\n"; }
    for ( $rowPos = 1 ; $rowPos <= $maxRow ; $rowPos++ ) {
        for ( $colPos = 1 ; $colPos <= $maxCol ; $colPos++ ) {
            my $cell = cr2cell( $colPos, $rowPos );
            if ($debug) { print STDERR "cell = '$cell'\n"; }
            my $field;
            if ( $parser->[1]{$cell} ) {
                $field = $parser->[1]{$cell};
            }
            else {
                $field = "";
            }
            if ($debug) { print STDERR "field = '$field'\n"; }
            $field = scrub_lead_field($field);
            print OUTFILE $field;
            if ( $colPos < $maxCol ) {
                print OUTFILE $out_delim;
            }
            else {
                print OUTFILE "\n";
            }
        }
    }
    unlink($tempfile) or die $!;
}
else {
    my $parser = ReadData("$infile");
    my $maxCol = $parser->[1]{maxcol};
    my $maxRow = $parser->[1]{maxrow};
    if ($debug) { print STDERR "maxCol = '$maxCol'\n"; }
    if ($debug) { print STDERR "maxRow = '$maxRow'\n"; }
    for ( $rowPos = 1 ; $rowPos <= $maxRow ; $rowPos++ ) {
        for ( $colPos = 1 ; $colPos <= $maxCol ; $colPos++ ) {
            my $cell = cr2cell( $colPos, $rowPos );
            if ($debug) { print STDERR "cell = '$cell'\n"; }
            my $field;
            if ( $parser->[1]{$cell} ) {
                $field = $parser->[1]{$cell};
            }
            else {
                $field = "";
            }
            if ($debug) { print STDERR "field = '$field'\n"; }
            $field = scrub_lead_field($field);
            print OUTFILE $field;
            if ( $colPos < $maxCol ) {
                print OUTFILE $out_delim;
            }
            else {
                print OUTFILE "\n";
            }
        }
    }
}
exit;
