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
if (length($ARGV[0])>1)
    {
    $i=0;
    while ($#ARGV >= $i)
        {
        $args = "$args $ARGV[$i]";
        $i++;
        }
    if ($args =~ /--help|-h/i)
        {
        print "allowed run time options:\n  [-forcelistid=1234] = overrides the listID given in the file with the 1234\n  [-h] = this help screen\n\n";
        exit;
        }
    else
        {
        if ($args =~ /-duplicate-check/i)
            {$dupcheck=1;}
        if ($args =~ /-duplicate-campaign-check/i)
            {$dupcheckcamp=1;}
        if ($args =~ /-duplicate-system-check/i)
            {$dupchecksys=1;}
        if ($args =~ /-duplicate-tap-list-check/i)
            {$duptapchecklist=1;}
        if ($args =~ /-duplicate-tap-system-check/i)
            {$duptapchecksys=1;}
        if ($args =~ /-postal-code-gmt/i)
            {$postalgmt=1;}
        if ($args =~ /--forcelistid=/i)
            {
            @data_in = split(/--forcelistid=/,$args);
            $forcelistid = $data_in[1];
            $forcelistid =~ s/ .*//gi;
            print "\n----- FORCE LISTID OVERRIDE: $forcelistid -----\n\n";
            }
        else
            {$forcelistid = '';}
        if ($args =~ /--forcephonecode=/i)
            {
            @data_in = split(/--forcephonecode=/,$args);
            $forcephonecode = $data_in[1];
            $forcephonecode =~ s/ .*//gi;
            print "\n----- FORCE PHONECODE OVERRIDE: $forcephonecode -----\n\n";
            }
        else
            {$forcephonecode = '';}
        if ($args =~ /--lead-file=/i)
            {
            @data_in = split(/--lead-file=/,$args);
            $lead_file = $data_in[1];
            $lead_file =~ s/ .*//gi;
            }
        else
            {$lead_file = './vicidial_temp_file.xls';}
        }
    }
use Spreadsheet::ParseExcel;
use Time::Local;
use DBI;      
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
if (!$VARDB_port) {$VARDB_port='3306';}
$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;
$|=0;
$secX = time();
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year = ($year + 1900);
$mon++;
if ($hour < 10) {$hour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
$pulldate0 = "$year-$mon-$mday $hour:$min:$sec";
$pulldate="$year-$mon-$mday $hour:$min:$sec";
$inSD = $pulldate0;
$dsec = ( ( ($hour * 3600) + ($min * 60) ) + $sec );
$stmtA = "SELECT use_non_latin FROM system_settings;";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
if ($sthArows > 0)
    {
    @aryA = $sthA->fetchrow_array;
    $non_latin        =        "$aryA[0]";
    }
$sthA->finish();
if ($non_latin > 0) {$affected_rows = $dbhA->do("SET NAMES 'UTF8'");}
    $stmtA = "SELECT local_gmt FROM servers where server_ip = '$server_ip';";
    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
    $sthArows=$sthA->rows;
    $rec_count=0;
    while ($sthArows > $rec_count)
        {
        @aryA = $sthA->fetchrow_array;
        $DBSERVER_GMT        =        "$aryA[0]";
        if ($DBSERVER_GMT)                {$SERVER_GMT = $DBSERVER_GMT;}
        $rec_count++;
        }
    $sthA->finish();
    $LOCAL_GMT_OFF = $SERVER_GMT;
    $LOCAL_GMT_OFF_STD = $SERVER_GMT;
if ($isdst) {$LOCAL_GMT_OFF++;} 
if ($DB) {print "SEED TIME  $secX      :   $year-$mon-$mday $hour:$min:$sec  LOCAL GMT OFFSET NOW: $LOCAL_GMT_OFF\n";}
$total=0; $good=0; $bad=0;
print "<center><font face='arial, helvetica' size=3 color='#009900'><B>Processing Excel file...\n";
open(STMT_FILE, "> $PATHlogs/listloader_stmts.txt");
$oBook = Spreadsheet::ParseExcel::Workbook->Parse("$lead_file");
my($iR, $iC, $oWkS, $oWkC);
foreach $oWkS (@{$oBook->{Worksheet}}) {
    for($iR = 0 ; defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow} ; $iR++) {
        $entry_date =            "$pulldate";
        $modify_date =            "";
        $status =                "NEW";
        $user =                    "";
        $oWkC = $oWkS->{Cells}[$iR][0];
        if ($oWkC) {$vendor_lead_code=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][1];
        if ($oWkC) {$source_code=$oWkC->Value; }
        $source_id=$source_code;
        $oWkC = $oWkS->{Cells}[$iR][2];
        if ($oWkC) {$list_id=$oWkC->Value; }
        $gmt_offset =            '0';
        $called_since_last_reset='N';
        $oWkC = $oWkS->{Cells}[$iR][3];
        if ($oWkC) {$phone_code=$oWkC->Value; }
        $phone_code=~s/[^0-9]//g;
        $oWkC = $oWkS->{Cells}[$iR][4];
        if ($oWkC) {$phone_number=$oWkC->Value; }
        $phone_number=~s/[^0-9]//g;
            $USarea =             substr($phone_number, 0, 3);
        $oWkC = $oWkS->{Cells}[$iR][5];
        if ($oWkC) {$title=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][6];
        if ($oWkC) {$first_name=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][7];
        if ($oWkC) {$middle_initial=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][8];
        if ($oWkC) {$last_name=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][9];
        if ($oWkC) {$address1=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][10];
        if ($oWkC) {$address2=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][11];
        if ($oWkC) {$address3=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][12];
        if ($oWkC) {$city=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][13];
        if ($oWkC) {$state=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][14];
        if ($oWkC) {$province=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][15];
        if ($oWkC) {$postal_code=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][16];
        if ($oWkC) {$country=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][17];
        if ($oWkC) {$gender=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][18];
        if ($oWkC) {$date_of_birth=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][19];
        if ($oWkC) {$alt_phone=$oWkC->Value; }
        $alt_phone=~s/[^0-9]//g;
        $oWkC = $oWkS->{Cells}[$iR][20];
        if ($oWkC) {$email=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][21];
        if ($oWkC) {$security_phrase=$oWkC->Value; }
        $oWkC = $oWkS->{Cells}[$iR][22];
        if ($oWkC) {$comments=$oWkC->Value; }
        $comments=~s/^\s*(.*?)\s*$/$1/;
        $oWkC = $oWkS->{Cells}[$iR][23];
        if ($oWkC) {$rank=$oWkC->Value; }
        if (length($rank)<1) {$rank='0';}
        $oWkC = $oWkS->{Cells}[$iR][24];
        if ($oWkC) {$owner=$oWkC->Value; }
        $entry_date                     =~ s/\'|\\|\"|;|\`|\224//gi;
        $modify_date                    =~ s/\'|\\|\"|;|\`|\224//gi;
        $status                         =~ s/\'|\\|\"|;|\`|\224//gi;
        $user                           =~ s/\'|\\|\"|;|\`|\224//gi;
        $vendor_lead_code               =~ s/\'|\\|\"|;|\`|\224//gi;
        $source_id                      =~ s/\'|\\|\"|;|\`|\224//gi;
        $list_id                        =~ s/\'|\\|\"|;|\`|\224//gi;
        $gmt_offset                     =~ s/\'|\\|\"|;|\`|\224//gi;
        $called_since_last_reset        =~ s/\'|\\|\"|;|\`|\224//gi;
        $phone_code                     =~ s/\'|\\|\"|;|\`|\224//gi;
        $phone_number                   =~ s/\'|\\|\"|;|\`|\224//gi;
        $title                          =~ s/\'|\\|\"|;|\`|\224//gi;
        $first_name                     =~ s/\'|\\|\"|;|\`|\224//gi;
        $middle_initial                 =~ s/\'|\\|\"|;|\`|\224//gi;
        $last_name                      =~ s/\'|\\|\"|;|\`|\224//gi;
        $address1                       =~ s/\'|\\|\"|;|\`|\224//gi;
        $address2                       =~ s/\'|\\|\"|;|\`|\224//gi;
        $address3                       =~ s/\'|\\|\"|;|\`|\224//gi;
        $city                           =~ s/\'|\\|\"|;|\`|\224//gi;
        $state                          =~ s/\'|\\|\"|;|\`|\224//gi;
        $province                       =~ s/\'|\\|\"|;|\`|\224//gi;
        $postal_code                    =~ s/\'|\\|\"|;|\`|\224//gi;
        $country                        =~ s/\'|\\|\"|;|\`|\224//gi;
        $gender                         =~ s/\'|\\|\"|;|\`|\224//gi;
        $date_of_birth                  =~ s/\'|\\|\"|;|\`|\224//gi;
        $alt_phone                      =~ s/\'|\\|\"|;|\`|\224//gi;
        $email                          =~ s/\'|\\|\"|;|\`|\224//gi;
        $security_phrase                =~ s/\'|\\|\"|;|\`|\224//gi;
        $comments                       =~ s/\'|\\|\"|;|\`|\224//gi;
        $rank                           =~ s/\'|\\|\"|;|\`|\224//gi;
        $owner                          =~ s/\'|\\|\"|;|\`|\224//gi;
        if (length($forcelistid) > 0)
            {
            $list_id =    $forcelistid;        # set list_id to override value
            }
        if (length($forcephonecode) > 0)
            {
            $phone_code =    $forcephonecode;    # set phone_code to override value
            }
        if ($dupchecksys > 0)
            {
            $dup_lead=0;
            $stmtA = "select count(*) from vicidial_list where phone_number='$phone_number';";
                if($DBX){print STDERR "\n|$stmtA|\n";}
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
            $sthArows=$sthA->rows;
            if ($sthArows > 0)
                {
                @aryA = $sthA->fetchrow_array;
                $dup_lead = $aryA[0];
                $dup_lead_list=$list_id;
                }
            $sthA->finish();
            if ($dup_lead < 1)
                {
                if ($phone_list =~ /\|$phone_number$US$list_id\|/)
                    {$dup_lead++;}
                }
            }
        if ($dupcheck > 0)
            {
            $dup_lead=0;
            $stmtA = "select list_id from vicidial_list where phone_number='$phone_number' and list_id='$list_id' limit 1;";
                if($DBX){print STDERR "\n|$stmtA|\n";}
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
            $sthArows=$sthA->rows;
            if ($sthArows > 0)
                {
                @aryA = $sthA->fetchrow_array;
                $dup_lead_list = $aryA[0];
                $dup_lead++;
                }
            $sthA->finish();
            if ($dup_lead < 1)
                {
                if ($phone_list =~ /\|$phone_number$US$list_id\|/)
                    {$dup_lead++;}
                }
            }
        if ($dupcheckcamp > 0)
            {
            $dup_lead=0;
            $dup_lists='';
            $stmtA = "select count(*) from vicidial_lists where list_id='$list_id';";
                if($DBX){print STDERR "\n|$stmtA|\n";}
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                @aryA = $sthA->fetchrow_array;
                $ci_recs = $aryA[0];
            $sthA->finish();
            if ($ci_recs > 0)
                {
                $stmtA = "select campaign_id from vicidial_lists where list_id='$list_id';";
                    if($DBX){print STDERR "\n|$stmtA|\n";}
                $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                    @aryA = $sthA->fetchrow_array;
                    $dup_camp = $aryA[0];
                $sthA->finish();
                $stmtA = "select list_id from vicidial_lists where campaign_id='$dup_camp';";
                $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                $sthArows=$sthA->rows;
                $rec_count=0;
                while ($sthArows > $rec_count)
                    {
                    @aryA = $sthA->fetchrow_array;
                    $dup_lists .=    "'$aryA[0]',";
                    $rec_count++;
                    }
                $sthA->finish();
                chop($dup_lists);
                $stmtA = "select list_id from vicidial_list where phone_number='$phone_number' and list_id IN($dup_lists) limit 1;";
                $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                $sthArows=$sthA->rows;
                $rec_count=0;
                while ($sthArows > $rec_count)
                    {
                    @aryA = $sthA->fetchrow_array;
                    $dup_lead_list =    "'$aryA[0]',";
                    $rec_count++;
                    $dup_lead=1;
                    }
                $sthA->finish();
                }
            if ($dup_lead < 1)
                {
                if ($phone_list =~ /\|$phone_number$US$list_id\|/)
                    {$dup_lead++;}
                }
            }
        if ($duptapchecksys > 0)
            {
            $dup_lead=0;
            $stmtA = "select count(*) from vicidial_list where title='$title' and alt_phone='$alt_phone';";
                if($DBX){print STDERR "\n|$stmtA|\n";}
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
            $sthArows=$sthA->rows;
            if ($sthArows > 0)
                {
                @aryA = $sthA->fetchrow_array;
                $dup_lead = $aryA[0];
                $dup_lead_list=$list_id;
                }
            $sthA->finish();
            if ($dup_lead < 1)
                {
                if ($phone_list =~ /\|$alt_phone$title$US$list_id\|/)
                    {$dup_lead++;}
                }
            }
        if ($duptapchecklist > 0)
            {
            $dup_lead=0;
            $stmtA = "select list_id from vicidial_list where title='$title' and alt_phone='$alt_phone' and list_id='$list_id' limit 1;";
                if($DBX){print STDERR "\n|$stmtA|\n";}
            $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
            $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
            $sthArows=$sthA->rows;
            if ($sthArows > 0)
                {
                @aryA = $sthA->fetchrow_array;
                $dup_lead_list = $aryA[0];
                $dup_lead++;
                }
            $sthA->finish();
            if ($dup_lead < 1)
                {
                if ($phone_list =~ /\|$alt_phone$title$US$list_id\|/)
                    {$dup_lead++;}
                }
            }
        if ( (length($phone_number)>6) && ($dup_lead < 1) && ($list_id >= 100)
            {
            if ( ($duptapchecklist > 0) || ($duptapchecksys > 0) )
                {$phone_list .= "$alt_phone$title$US$list_id|";}
            else
                {$phone_list .= "$phone_number$US$list_id|";}
            $postalgmt_found=0;
            if (length($phone_code)<1) {$phone_code = '1';}
            if ( ($postalgmt > 0) && (length($postal_code)>4) )
                {
                if ($phone_code =~ /^1$/)
                    {
                    $stmtA = "select postal_code,state,GMT_offset,DST,DST_range,country,country_code from vicidial_postal_codes where country_code='$phone_code' and postal_code LIKE \"$postal_code%\";";
                        if($DBX){print STDERR "\n|$stmtA|\n";}
                    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                    $sthArows=$sthA->rows;
                    $rec_count=0;
                    while ($sthArows > $rec_count)
                        {
                        @aryA = $sthA->fetchrow_array;
                        $gmt_offset =    $aryA[2];  $gmt_offset =~ s/\+| //gi;
                        $dst =            $aryA[3];
                        $dst_range =    $aryA[4];
                        $PC_processed++;
                        $rec_count++;
                        $postalgmt_found++;
                        if ($DBX) {print "     Postal GMT record found for $postal_code: |$gmt_offset|$dst|$dst_range|\n";}
                        }
                    $sthA->finish();
                    }
                }
            if ($postalgmt_found < 1)
                {
                $PC_processed=0;
                if ($phone_code =~ /^1$/)
                    {
                    $stmtA = "select country_code,country,areacode,state,GMT_offset,DST,DST_range,geographic_description from vicidial_phone_codes where country_code='$phone_code' and areacode='$USarea';";
                        if($DBX){print STDERR "\n|$stmtA|\n";}
                    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                    $sthArows=$sthA->rows;
                    $rec_count=0;
                    while ($sthArows > $rec_count)
                        {
                        @aryA = $sthA->fetchrow_array;
                        $gmt_offset =    $aryA[4];  $gmt_offset =~ s/\+| //gi;
                        $dst =            $aryA[5];
                        $dst_range =    $aryA[6];
                        $PC_processed++;
                        $rec_count++;
                        }
                    $sthA->finish();
                    }
                if ($phone_code =~ /^52$/)
                    {
                    $stmtA = "select country_code,country,areacode,state,GMT_offset,DST,DST_range,geographic_description from vicidial_phone_codes where country_code='$phone_code' and areacode='$USarea';";
                        if($DBX){print STDERR "\n|$stmtA|\n";}
                    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                    $sthArows=$sthA->rows;
                    $rec_count=0;
                    while ($sthArows > $rec_count)
                        {
                        @aryA = $sthA->fetchrow_array;
                        $gmt_offset =    $aryA[4];  $gmt_offset =~ s/\+| //gi;
                        $dst =            $aryA[5];
                        $dst_range =    $aryA[6];
                        $PC_processed++;
                        $rec_count++;
                        }
                    $sthA->finish();
                    }
                if ($phone_code =~ /^61$/)
                    {
                    $stmtA = "select country_code,country,areacode,state,GMT_offset,DST,DST_range,geographic_description from vicidial_phone_codes where country_code='$phone_code' and state='$state';";
                        if($DBX){print STDERR "\n|$stmtA|\n";}
                    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                    $sthArows=$sthA->rows;
                    $rec_count=0;
                    while ($sthArows > $rec_count)
                        {
                        @aryA = $sthA->fetchrow_array;
                        $gmt_offset =    $aryA[4];  $gmt_offset =~ s/\+| //gi;
                        $dst =            $aryA[5];
                        $dst_range =    $aryA[6];
                        $PC_processed++;
                        $rec_count++;
                        }
                    $sthA->finish();
                    }
                if (!$PC_processed)
                    {
                    $stmtA = "select country_code,country,areacode,state,GMT_offset,DST,DST_range,geographic_description from vicidial_phone_codes where country_code='$phone_code';";
                        if($DBX){print STDERR "\n|$stmtA|\n";}
                    $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
                    $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
                    $sthArows=$sthA->rows;
                    $rec_count=0;
                    while ($sthArows > $rec_count)
                        {
                        @aryA = $sthA->fetchrow_array;
                        $gmt_offset =    $aryA[4];  $gmt_offset =~ s/\+| //gi;
                        $dst =            $aryA[5];
                        $dst_range =    $aryA[6];
                        $PC_processed++;
                        $rec_count++;
                        }
                    $sthA->finish();
                    }
                }
                $AC_GMT_diff = ($gmt_offset - $LOCAL_GMT_OFF_STD);
                $AC_localtime = ($secX + (3600 * $AC_GMT_diff));
                ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($AC_localtime);
                $year = ($year + 1900);
                $mon++;
                if ($mon < 10) {$mon = "0$mon";}
                if ($mday < 10) {$mday = "0$mday";}
                if ($hour < 10) {$hour = "0$hour";}
                if ($min < 10) {$min = "0$min";}
                if ($sec < 10) {$sec = "0$sec";}
                $dsec = ( ( ($hour * 3600) + ($min * 60) ) + $sec );
                $AC_processed=0;
                if ( (!$AC_processed) && ($dst_range =~ /SSM-FSN/) )
                    {
                    if ($DBX) {print "     Second Sunday March to First Sunday November\n";}
                    &USACAN_dstcalc;
                    if ($DBX) {print "     DST: $USACAN_DST\n";}
                    if ($USACAN_DST) {$area_GMT++;}
                    $AC_processed++;
                    }
                if ( (!$AC_processed) && ($dst_range =~ /FSA-LSO/) )
                    {
                    if ($DBX) {print "     First Sunday April to Last Sunday October\n";}
                    &NA_dstcalc;
                    if ($DBX) {print "     DST: $NA_DST\n";}
                    if ($NA_DST) {$area_GMT++;}
                    $AC_processed++;
                    }
                if ( (!$AC_processed) && ($dst_range =~ /LSM-LSO/) )
                    {
                    if ($DBX) {print "     Last Sunday March to Last Sunday October\n";}
                    &GBR_dstcalc;
                    if ($DBX) {print "     DST: $GBR_DST\n";}
                    if ($GBR_DST) {$gmt_offset++;}
                    $AC_processed++;
                    }
                if ( (!$AC_processed) && ($dst_range =~ /LSO-LSM/) )
                    {
                    if ($DBX) {print "     Last Sunday October to Last Sunday March\n";}
                    &AUS_dstcalc;
                    if ($DBX) {print "     DST: $AUS_DST\n";}
                    if ($AUS_DST) {$gmt_offset++;}
                    $AC_processed++;
                    }
                if ( (!$AC_processed) && ($dst_range =~ /FSO-LSM/) )
                    {
                    if ($DBX) {print "     First Sunday October to Last Sunday March\n";}
                    &AUST_dstcalc;
                    if ($DBX) {print "     DST: $AUST_DST\n";}
                    if ($AUST_DST) {$gmt_offset++;}
                    $AC_processed++;
                    }
                if ( (!$AC_processed) && ($area_GMT_method =~ /FSO-FSA/) )
                    {
                    if ($DBX) {print "     First Sunday October to First Sunday April\n";}
                    &AUSE_dstcalc;
                    if ($DBX) {print "     DST: $AUSE_DST\n";}
                    if ($AUSE_DST) {$area_GMT++;}
                    $AC_processed++;
                    }
                if ( (!$AC_processed) && ($dst_range =~ /FSO-TSM/) )
                    {
                    if ($DBX) {print "     First Sunday October to Third Sunday March\n";}
                    &NZL_dstcalc;
                    if ($DBX) {print "     DST: $NZL_DST\n";}
                    if ($NZL_DST) {$gmt_offset++;}
                    $AC_processed++;
                    }
                if ( (!$AC_processed) && ($area_GMT_method =~ /LSS-FSA/) )
                    {
                    if ($DBX) {print "     Last Sunday September to First Sunday April\n";}
                    &NZLN_dstcalc;
                    if ($DBX) {print "     DST: $NZLN_DST\n";}
                    if ($NZLN_DST) {$area_GMT++;}
                    $AC_processed++;
                    }
                if ( (!$AC_processed) && ($dst_range =~ /TSO-LSF/) )
                    {
                    if ($DBX) {print "     Third Sunday October to Last Sunday February\n";}
                    &BZL_dstcalc;
                    if ($DBX) {print "     DST: $BZL_DST\n";}
                    if ($BZL_DST) {$area_GMT++;}
                    $AC_processed++;
                    }
                if (!$AC_processed)
                    {
                    if ($DBX) {print "     No DST Method Found\n";}
                    if ($DBX) {print "     DST: 0\n";}
                    $AC_processed++;
                    }
            if ($multi_insert_counter > 8) {
                $stmtZ = "INSERT INTO vicidial_list (lead_id,entry_date,modify_date,status,user,vendor_lead_code,source_id,list_id,gmt_offset_now,called_since_last_reset,phone_code,phone_number,title,first_name,middle_initial,last_name,address1,address2,address3,city,state,province,postal_code,country_code,gender,date_of_birth,alt_phone,email,security_phrase,comments,called_count,last_local_call_time,rank,owner,entry_list_id) values$multistmt('','$entry_date','$modify_date','$status','$user','$vendor_lead_code','$source_id','$list_id','$gmt_offset','$called_since_last_reset','$phone_code','$phone_number','$title','$first_name','$middle_initial','$last_name','$address1','$address2','$address3','$city','$state','$province','$postal_code','$country','$gender','$date_of_birth','$alt_phone','$email','$security_phrase','$comments',0,'2008-01-01 00:00:00','$rank','$owner','0');";
                $affected_rows = $dbhA->do($stmtZ);
                print STMT_FILE $stmtZ."\r\n";
                $multistmt='';
                $multi_insert_counter=0;
            } else {
                $multistmt .= "('','$entry_date','$modify_date','$status','$user','$vendor_lead_code','$source_id','$list_id','$gmt_offset','$called_since_last_reset','$phone_code','$phone_number','$title','$first_name','$middle_initial','$last_name','$address1','$address2','$address3','$city','$state','$province','$postal_code','$country','$gender','$date_of_birth','$alt_phone','$email','$security_phrase','$comments',0,'2008-01-01 00:00:00','$rank','$owner','0'),";
                $multi_insert_counter++;
            }
            $good++;
        } else {
            if ($bad < 1000000)
                {
                if ( $list_id < 100 )
                    {
                    print "<BR></b><font size=1 color=red>record $total BAD- PHONE: $phone_number ROW: |$row[0]| INVALID LIST ID</font><b>\n";
                    }
                else
                    {
                    print "<BR></b><font size=1 color=red>record $total BAD- PHONE: $phone_number ROW: |$row[0]| DUP: $dup_lead  $dup_lead_list</font><b>\n";
                    }
                }
            $bad++;
        }
        $total++;
        if ($total%100==0) {
            print "<script language='JavaScript1.2'>ShowProgress($good, $bad, $total, $dup_lead, $postalgmt_found)</script>";
            sleep(1);
        }
    }
}
if ($multi_insert_counter > 0) {
    $stmtZ = "INSERT INTO vicidial_list (lead_id,entry_date,modify_date,status,user,vendor_lead_code,source_id,list_id,gmt_offset_now,called_since_last_reset,phone_code,phone_number,title,first_name,middle_initial,last_name,address1,address2,address3,city,state,province,postal_code,country_code,gender,date_of_birth,alt_phone,email,security_phrase,comments,called_count,last_local_call_time,rank,owner,entry_list_id) values ".substr($multistmt, 0, -1).";";
    $affected_rows = $dbhA->do($stmtZ);
    print STMT_FILE $stmtZ."\r\n";
}
print "<BR><BR>Done</B> GOOD: $good &nbsp; &nbsp; &nbsp; BAD: $bad &nbsp; &nbsp; &nbsp; TOTAL: $total</font></center>";
exit;
sub USACAN_dstcalc {
    $USACAN_DST=0;
    $mm = $mon;
    $dd = $mday;
    $ns = $dsec;
    $dow= $wday;
    if ($mm < 3 || $mm > 11) {
    $USACAN_DST=0;   return 0;
    } elsif ($mm >= 4 && $mm <= 10) {
    $USACAN_DST=1;   return 1;
    } elsif ($mm == 3) {
    if ($dd > 13) {
        $USACAN_DST=1;   return 1;
    } elsif ($dd >= ($dow+8)) {
        if ($timezone) {
        if ($dow == 0 && $ns < (7200+$timezone*3600)) {
            $USACAN_DST=0;   return 0;
        } else {
            $USACAN_DST=1;   return 1;
        }
        } else {
        if ($dow == 0 && $ns < 7200) {
            $USACAN_DST=0;   return 0;
        } else {
            $USACAN_DST=1;   return 1;
        }
        }
    } else {
        $USACAN_DST=0;   return 0;
    }
    } elsif ($mm == 11) {
    if ($dd > 7) {
        $USACAN_DST=0;   return 0;
    } elsif ($dd < ($dow+1)) {
        $USACAN_DST=1;   return 1;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (7200+($timezone-1)*3600)) {
            $USACAN_DST=1;   return 1;
        } else {
            $USACAN_DST=0;   return 0;
        }
        } else { # local time calculations
        if ($ns < 7200) {
            $USACAN_DST=1;   return 1;
        } else {
            $USACAN_DST=0;   return 0;
        }
        }
    } else {
        $USACAN_DST=0;   return 0;
    }
    } # end of month checks
} # end of subroutine dstcalc
sub NA_dstcalc {
    $NA_DST=0;
    $mm = $mon;
    $dd = $mday;
    $ns = $dsec;
    $dow= $wday;
    if ($mm < 4 || $mm > 10) {
    $NA_DST=0;   return 0;
    } elsif ($mm >= 5 && $mm <= 9) {
    $NA_DST=1;   return 1;
    } elsif ($mm == 4) {
    if ($dd > 7) {
        $NA_DST=1;   return 1;
    } elsif ($dd >= ($dow+1)) {
        if ($timezone) {
        if ($dow == 0 && $ns < (7200+$timezone*3600)) {
            $NA_DST=0;   return 0;
        } else {
            $NA_DST=1;   return 1;
        }
        } else {
        if ($dow == 0 && $ns < 7200) {
            $NA_DST=0;   return 0;
        } else {
            $NA_DST=1;   return 1;
        }
        }
    } else {
        $NA_DST=0;   return 0;
    }
    } elsif ($mm == 10) {
    if ($dd < 25) {
        $NA_DST=1;   return 1;
    } elsif ($dd < ($dow+25)) {
        $NA_DST=1;   return 1;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (7200+($timezone-1)*3600)) {
            $NA_DST=1;   return 1;
        } else {
            $NA_DST=0;   return 0;
        }
        } else { # local time calculations
        if ($ns < 7200) {
            $NA_DST=1;   return 1;
        } else {
            $NA_DST=0;   return 0;
        }
        }
    } else {
        $NA_DST=0;   return 0;
    }
    } # end of month checks
} # end of subroutine dstcalc
sub GBR_dstcalc {
    $GBR_DST=0;
    $mm = $mon;
    $dd = $mday;
    $ns = $dsec;
    $dow= $wday;
    if ($mm < 3 || $mm > 10) {
    $GBR_DST=0;   return 0;
    } elsif ($mm >= 4 && $mm <= 9) {
    $GBR_DST=1;   return 1;
    } elsif ($mm == 3) {
    if ($dd < 25) {
        $GBR_DST=0;   return 0;
    } elsif ($dd < ($dow+25)) {
        $GBR_DST=0;   return 0;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (3600+($timezone-1)*3600)) {
            $GBR_DST=0;   return 0;
        } else {
            $GBR_DST=1;   return 1;
        }
        } else { # local time calculations
        if ($ns < 3600) {
            $GBR_DST=0;   return 0;
        } else {
            $GBR_DST=1;   return 1;
        }
        }
    } else {
        $GBR_DST=1;   return 1;
    }
    } elsif ($mm == 10) {
    if ($dd < 25) {
        $GBR_DST=1;   return 1;
    } elsif ($dd < ($dow+25)) {
        $GBR_DST=1;   return 1;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (3600+($timezone-1)*3600)) {
            $GBR_DST=1;   return 1;
        } else {
            $GBR_DST=0;   return 0;
        }
        } else { # local time calculations
        if ($ns < 3600) {
            $GBR_DST=1;   return 1;
        } else {
            $GBR_DST=0;   return 0;
        }
        }
    } else {
        $GBR_DST=0;   return 0;
    }
    } # end of month checks
} # end of subroutine dstcalc
sub AUS_dstcalc {
    $AUS_DST=0;
    $mm = $mon;
    $dd = $mday;
    $ns = $dsec;
    $dow= $wday;
    if ($mm < 3 || $mm > 10) {
    $AUS_DST=1;   return 1;
    } elsif ($mm >= 4 && $mm <= 9) {
    $AUS_DST=0;   return 0;
    } elsif ($mm == 3) {
    if ($dd < 25) {
        $AUS_DST=1;   return 1;
    } elsif ($dd < ($dow+25)) {
        $AUS_DST=1;   return 1;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (3600+($timezone-1)*3600)) {
            $AUS_DST=1;   return 1;
        } else {
            $AUS_DST=0;   return 0;
        }
        } else { # local time calculations
        if ($ns < 3600) {
            $AUS_DST=1;   return 1;
        } else {
            $AUS_DST=0;   return 0;
        }
        }
    } else {
        $AUS_DST=0;   return 0;
    }
    } elsif ($mm == 10) {
    if ($dd < 25) {
        $AUS_DST=0;   return 0;
    } elsif ($dd < ($dow+25)) {
        $AUS_DST=0;   return 0;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (3600+($timezone-1)*3600)) {
            $AUS_DST=0;   return 0;
        } else {
            $AUS_DST=1;   return 1;
        }
        } else { # local time calculations
        if ($ns < 3600) {
            $AUS_DST=0;   return 0;
        } else {
            $AUS_DST=1;   return 1;
        }
        }
    } else {
        $AUS_DST=1;   return 1;
    }
    } # end of month checks
} # end of subroutine dstcalc
sub AUST_dstcalc {
    $AUST_DST=0;
    $mm = $mon;
    $dd = $mday;
    $ns = $dsec;
    $dow= $wday;
    if ($mm < 3 || $mm > 10) {
    $AUST_DST=1;   return 1;
    } elsif ($mm >= 4 && $mm <= 9) {
    $AUST_DST=0;   return 0;
    } elsif ($mm == 3) {
    if ($dd < 25) {
        $AUST_DST=1;   return 1;
    } elsif ($dd < ($dow+25)) {
        $AUST_DST=1;   return 1;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (3600+($timezone-1)*3600)) {
            $AUST_DST=1;   return 1;
        } else {
            $AUST_DST=0;   return 0;
        }
        } else { # local time calculations
        if ($ns < 3600) {
            $AUST_DST=1;   return 1;
        } else {
            $AUST_DST=0;   return 0;
        }
        }
    } else {
        $AUST_DST=0;   return 0;
    }
    } elsif ($mm == 10) {
    if ($dd >= 8) {
        $AUST_DST=1;   return 1;
    } elsif ($dd >= ($dow+1)) {
        if ($timezone) {
        if ($dow == 0 && $ns < (7200+$timezone*3600)) {
            $AUST_DST=0;   return 0;
        } else {
            $AUST_DST=1;   return 1;
        }
        } else {
        if ($dow == 0 && $ns < 3600) {
            $AUST_DST=0;   return 0;
        } else {
            $AUST_DST=1;   return 1;
        }
        }
    } else {
        $AUST_DST=0;   return 0;
    }
    } # end of month checks
} # end of subroutine dstcalc
sub AUSE_dstcalc {
    $AUSE_DST=0;
    $mm = $mon;
    $dd = $mday;
    $ns = $dsec;
    $dow= $wday;
    if ($mm < 4 || $mm > 10) {
    $AUSE_DST=1;   return 1;
    } elsif ($mm >= 5 && $mm <= 9) {
    $AUSE_DST=0;   return 0;
    } elsif ($mm == 4) {
    if ($dd > 7) {
        $AUSE_DST=0;   return 1;
    } elsif ($dd >= ($dow+1)) {
        if ($timezone) {
        if ($dow == 0 && $ns < (3600+$timezone*3600)) {
            $AUSE_DST=1;   return 0;
        } else {
            $AUSE_DST=0;   return 1;
        }
        } else {
        if ($dow == 0 && $ns < 7200) {
            $AUSE_DST=1;   return 0;
        } else {
            $AUSE_DST=0;   return 1;
        }
        }
    } else {
        $AUSE_DST=1;   return 0;
    }
    } elsif ($mm == 10) {
    if ($dd >= 8) {
        $AUSE_DST=1;   return 1;
    } elsif ($dd >= ($dow+1)) {
        if ($timezone) {
        if ($dow == 0 && $ns < (7200+$timezone*3600)) {
            $AUSE_DST=0;   return 0;
        } else {
            $AUSE_DST=1;   return 1;
        }
        } else {
        if ($dow == 0 && $ns < 3600) {
            $AUSE_DST=0;   return 0;
        } else {
            $AUSE_DST=1;   return 1;
        }
        }
    } else {
        $AUSE_DST=0;   return 0;
    }
    } # end of month checks
} # end of subroutine dstcalc
sub NZL_dstcalc {
    $NZL_DST=0;
    $mm = $mon;
    $dd = $mday;
    $ns = $dsec;
    $dow= $wday;
    if ($mm < 3 || $mm > 10) {
    $NZL_DST=1;   return 1;
    } elsif ($mm >= 4 && $mm <= 9) {
    $NZL_DST=0;   return 0;
    } elsif ($mm == 3) {
    if ($dd < 14) {
        $NZL_DST=1;   return 1;
    } elsif ($dd < ($dow+14)) {
        $NZL_DST=1;   return 1;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (3600+($timezone-1)*3600)) {
            $NZL_DST=1;   return 1;
        } else {
            $NZL_DST=0;   return 0;
        }
        } else { # local time calculations
        if ($ns < 3600) {
            $NZL_DST=1;   return 1;
        } else {
            $NZL_DST=0;   return 0;
        }
        }
    } else {
        $NZL_DST=0;   return 0;
    }
    } elsif ($mm == 10) {
    if ($dd >= 8) {
        $NZL_DST=1;   return 1;
    } elsif ($dd >= ($dow+1)) {
        if ($timezone) {
        if ($dow == 0 && $ns < (7200+$timezone*3600)) {
            $NZL_DST=0;   return 0;
        } else {
            $NZL_DST=1;   return 1;
        }
        } else {
        if ($dow == 0 && $ns < 3600) {
            $NZL_DST=0;   return 0;
        } else {
            $NZL_DST=1;   return 1;
        }
        }
    } else {
        $NZL_DST=0;   return 0;
    }
    } # end of month checks
} # end of subroutine dstcalc
sub NZLN_dstcalc {
    $NZLN_DST=0;
    $mm = $mon;
    $dd = $mday;
    $ns = $dsec;
    $dow= $wday;
    if ($mm < 4 || $mm > 9) {
    $NZLN_DST=1;   return 1;
    } elsif ($mm >= 5 && $mm <= 9) {
    $NZLN_DST=0;   return 0;
    } elsif ($mm == 4) {
    if ($dd > 7) {
        $NZLN_DST=0;   return 1;
    } elsif ($dd >= ($dow+1)) {
        if ($timezone) {
        if ($dow == 0 && $ns < (3600+$timezone*3600)) {
            $NZLN_DST=1;   return 0;
        } else {
            $NZLN_DST=0;   return 1;
        }
        } else {
        if ($dow == 0 && $ns < 7200) {
            $NZLN_DST=1;   return 0;
        } else {
            $NZLN_DST=0;   return 1;
        }
        }
    } else {
        $NZLN_DST=1;   return 0;
    }
    } elsif ($mm == 9) {
    if ($dd < 25) {
        $NZLN_DST=0;   return 0;
    } elsif ($dd < ($dow+25)) {
        $NZLN_DST=0;   return 0;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (3600+($timezone-1)*3600)) {
            $NZLN_DST=0;   return 0;
        } else {
            $NZLN_DST=1;   return 1;
        }
        } else { # local time calculations
        if ($ns < 3600) {
            $NZLN_DST=0;   return 0;
        } else {
            $NZLN_DST=1;   return 1;
        }
        }
    } else {
        $NZLN_DST=1;   return 1;
    }
    } # end of month checks
} # end of subroutine dstcalc
sub BZL_dstcalc {
    $BZL_DST=0;
    $mm = $mon;
    $dd = $mday;
    $ns = $dsec;
    $dow= $wday;
    if ($mm < 2 || $mm > 10) {
    $BZL_DST=1;   return 1;
    } elsif ($mm >= 3 && $mm <= 9) {
    $BZL_DST=0;   return 0;
    } elsif ($mm == 2) {
    if ($dd < 22) {
        $BZL_DST=1;   return 1;
    } elsif ($dd < ($dow+22)) {
        $BZL_DST=1;   return 1;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (3600+($timezone-1)*3600)) {
            $BZL_DST=1;   return 1;
        } else {
            $BZL_DST=0;   return 0;
        }
        } else { # local time calculations
        if ($ns < 3600) {
            $BZL_DST=1;   return 1;
        } else {
            $BZL_DST=0;   return 0;
        }
        }
    } else {
        $BZL_DST=0;   return 0;
    }
    } elsif ($mm == 10) {
    if ($dd < 22) {
        $BZL_DST=0;   return 0;
    } elsif ($dd < ($dow+22)) {
        $BZL_DST=0;   return 0;
    } elsif ($dow == 0) {
        if ($timezone) { # UTC calculations
        if ($ns < (3600+($timezone-1)*3600)) {
            $BZL_DST=0;   return 0;
        } else {
            $BZL_DST=1;   return 1;
        }
        } else { # local time calculations
        if ($ns < 3600) {
            $BZL_DST=0;   return 0;
        } else {
            $BZL_DST=1;   return 1;
        }
        }
    } else {
        $BZL_DST=1;   return 1;
    }
    } # end of month checks
} # end of subroutine dstcalc
