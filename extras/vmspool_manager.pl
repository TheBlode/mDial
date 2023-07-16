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
use strict;
=head1 vmspool_manager.pl
This is a utility which does some checks on existing asterisk voicemail files and deletes old lock files and mail messages.  This is best run on a system that is not being used due the file renumbering and deleting of files which Asterisk could be accessing at the same time.
=head1 Options
--active:          Run in active mode, deleting files.  Default is to 'report'
--age=<#>:         Time after which a message is considered old in days.  Default is 14 days.
--bad:             Remove message files that do not have the expected number of files.
--context=<name>:  The context for Asterisk,  set to 'default' by default.
--debug:           Debug mode.
--group=<name>:    Name of group, default is "asterisk"
--help:            Help message.
--mailbox=<#>:     Run for a particular mailbox.
--spool=<path>:    Set to path to mail spool.  Default is "/var/spool/asterisk/voicemail"
--user=<name>:     Name of user, default is "asterisk"
=head1 USAGE:  To delete files over 30 days old.  Also remove bad lock files.
fixup-voicemail.perl --age=30 --active
=head1 FUNCTIONS
=cut
use Getopt::Long;
use Pod::Usage;
our $DEBUG=0;
our $REPORT=1;
our $VM_USER="asterisk";
our $VM_GROUP="asterisk";
our $VM_CONTEXT="default";
our $VM_SPOOL="/var/spool/asterisk/voicemail";
our $MAX_AGE=14;                 # days
our $MAX_LOCK_AGE=30;            # minutes
our $VMDIR;     # This is the directory handle
our @SUFFIXES=("WAV", "gsm", "txt", "wav");
our @MAILBOX_TYPES=("Old", "INBOX");
our $ACTIVE = undef;
our $BAD = undef;
our $HELP = undef;
our $ONE_MAILBOX = undef;
my $result = GetOptions ("active"      => \$ACTIVE,
             "age=i"       => \$MAX_AGE,      # numeric
                         "bad"         => \$BAD,          # string
                         "context=s"   => \$VM_CONTEXT,   # string
                         "debug"       => \$DEBUG,        # flag
                         "group=s"     => \$VM_GROUP,     # string
                         "help"        => \$HELP,         # flag
                         "mailbox=i"   => \$ONE_MAILBOX,  # flag
                         "spool=s"     => \$VM_SPOOL,
                         "user=s"      => \$VM_USER) or pod2usage(2); 
pod2usage(1) if $HELP;
our $VM_SPOOL_PATH="$VM_SPOOL/$VM_CONTEXT";
if ($ACTIVE){
    $REPORT = undef;
}
opendir(VMDIR,$VM_SPOOL_PATH) || die "Can't open $VM_SPOOL_PATH\n";
my @mailboxes = grep { /^\d./ && -d "$VM_SPOOL_PATH/$_" } readdir(VMDIR);
if ($ONE_MAILBOX){
    if ( -d "$VM_SPOOL_PATH/$ONE_MAILBOX" ){
        @mailboxes = ( $ONE_MAILBOX );
    } else {
        die "Mailbox $VM_SPOOL_PATH/$ONE_MAILBOX does not exist\n";
    }
}
foreach my $vmbox (@mailboxes){
    foreach my $mailbox_type (@MAILBOX_TYPES){
        print "MAILBOX $vmbox/$mailbox_type\n";
        my $MAILBOX;
        my $path = "$VM_SPOOL_PATH/$vmbox/$mailbox_type";
        if(opendir($MAILBOX, $path)){
            delete_old_messages($MAILBOX, $path);
            renumber($MAILBOX, $path);
        } #  end of if has a vmbox/old
    }
}
closedir VMDIR;
=head2 delete_old_messages
Delete the Contents of the passed directory.
=cut
sub delete_old_messages{
    my $MAILBOX=shift;
    my $path=shift;
    if (! delete_lock_file( $MAILBOX, $path)){
        foreach my $filename (sort grep ( /^msg.*/, readdir($MAILBOX))){
            my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat("$path/$filename");
            if ($DEBUG and !$REPORT){ print "\tFile $size: ".localtime($mtime).": $filename\n"; }
            if( $mtime < (time()-(60*60*24*$MAX_AGE))){
                print "\tDELETE:  $size: ".localtime($mtime).": $filename\n";
                if ($ACTIVE){ unlink "$path/$filename"; }
                if ($DEBUG and !$REPORT){ "DELETE $filename\n"; }
            } else { if ($REPORT){print "\tKEEP:  $size: ".localtime($mtime).": $filename\n"} };
        }
        rewinddir($MAILBOX); 
    } else {
        if ($REPORT){print "Mailbox $MAILBOX is LOCKED\n"};
    }
}
=head2 delete_lock_file
Delete a lockfile older than 30 minutes in the passed mailbox.
=cut
sub delete_lock_file {
    my $MAILBOX=shift;
    my $path=shift;
    my $retval=0;
    foreach my $filename (sort grep ( /^\.lock*/, readdir($MAILBOX))){
        my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat("$path/$filename");
        $retval=1;
        if( $mtime < (time()-(60*$MAX_LOCK_AGE))){
            $retval=0;
            if ($REPORT){ print "\tDELETE LOCK:  $size:".localtime($mtime).": $filename\n";}
            else { unlink "$path/$filename";}
        }
    }
    rewinddir($MAILBOX); # Make sure we rewind!
    return $retval;
}
=head2 check_message_files
Check that there are the right number of messages using the array SUFFIXES.  Delete 'bad' messages if in active mode.
=cut
sub check_message_files{
    my $file_names=shift;    # This is an array of the filenames.
    my $path=shift;
    my %mboxindx=();
    foreach my $fixfile (@{$file_names}){
        if($fixfile =~ /^msg/){
            my ($prefix,$suffix)=split(/\./,$fixfile);
            if ($DEBUG){print "\tCheck presence:  $prefix\.$suffix\n";}
            $mboxindx{$prefix}++;
        }
    } # End of foreach $fixfile 
    foreach my $index (keys %mboxindx){
        if ($mboxindx{$index} != $#SUFFIXES + 1) { 
            print "Broken Mailbox:  $index:  $mboxindx{$index}\n" ;
        }
    }
}
=head2 renumber
Asterisk needs a message with 'msg0000.XXX' in each mailbox to function.  This function will renumber the lowest number message to msg0000.XXX if one does not exist.
=cut
sub renumber {
    my $MAILBOX=shift;
    my $path = shift;
    my @OLDMAILBOX=();
    @OLDMAILBOX = sort grep (/^msg.*/ , readdir($MAILBOX));
    if($#OLDMAILBOX > -1 ) {
        if ($DEBUG){ print "\tHas mail messages: " . ($#OLDMAILBOX + 1)/($#SUFFIXES + 1) . "\n";}
        if ($DEBUG){ print "\tFIRST FILE:  $OLDMAILBOX[0]\n";}
        if($OLDMAILBOX[0] !~ /msg0000.*/) {
            print "Has renumber broken msglist\n";
            rename_first_message($path, $OLDMAILBOX[0]);
        }
    }
    check_message_files(\@OLDMAILBOX, $path);
    rewinddir($MAILBOX); # Make sure we rewind!
}
=head2 rename_first_message
This function will renumber the passed message to msg0000.XXX.
=cut
sub rename_first_message {
    my $path = shift;
    my $filename = shift;
    if ($filename =~ /^msg.*/){
        my ($prefix,$suffix)=split(/\./,$filename);
        foreach my $suff (@SUFFIXES){
            print "\tRenaming files: $path/$prefix.$suff to $path/msg0000\.$suff\n";
            if ($ACTIVE){ 
                rename "$path/$prefix.$suff", "$path/msg0000\.$suff";
            } else { 
                print "\tWould rename files: $path/$prefix.$suff to $path/msg0000\.$suff\n"; 
            }
        }
    }
}
