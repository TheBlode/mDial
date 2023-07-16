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
<?php
header ("Content-type: text/html; charset=utf-8");
require("dbconnect_mysqli.php");
require("functions.php");
if (isset($_GET["phone"]))                {$phone=$_GET["phone"];}
    elseif (isset($_POST["phone"]))        {$phone=$_POST["phone"];}
if (isset($_GET["did"]))                {$did=$_GET["did"];}
    elseif (isset($_POST["did"]))        {$did=$_POST["did"];}
if (isset($_GET["hours"]))                {$hours=$_GET["hours"];}
    elseif (isset($_POST["hours"]))        {$hours=$_POST["hours"];}
if (isset($_GET["DB"]))                    {$DB=$_GET["DB"];}
    elseif (isset($_POST["DB"]))        {$DB=$_POST["DB"];}
$stmt = "SELECT use_non_latin,webroot_writable FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
$ss_conf_ct = mysqli_num_rows($rslt);
if ($ss_conf_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                    $row[0];
    $webroot_writable =                $row[1];
    }
if ($non_latin < 1)
    {
    $phone=preg_replace('/[^-_0-9a-zA-Z]/','',$phone);
    $did=preg_replace('/[^-_0-9a-zA-Z]/','',$did);
    }
else
    {
    $phone = preg_replace("/'|\"|\\\\|;/","",$phone);
    $did = preg_replace("/'|\"|\\\\|;/","",$did);
    }
$hours=preg_replace('/[^0-9]/','',$hours);
$phone_count=0;
if (strlen($phone) > 6)
    {
    if ( ($did == 'ALL') or ($did == '') )
        {$didSQL='';}
    else
        {$didSQL=" and extension='$did'";}
    if ( ($hours == 'ALL') or ($hours == '') )
        {$hoursSQL=' and (call_date < (NOW() - INTERVAL 10 SECOND))';}
    else
        {$hoursSQL=" and (call_date < (NOW() - INTERVAL 10 SECOND) and call_date > (NOW() - INTERVAL $hours HOUR))";}
    $stmt = "SELECT count(*) FROM vicidial_did_log where caller_id_number='$phone' $didSQL $hoursSQL;";
    $rslt=mysql_to_mysqli($stmt, $link);
    $did_call_ct = mysqli_num_rows($rslt);
    if ($did_call_ct > 0)
        {
        $row=mysqli_fetch_row($rslt);
        $phone_count =    $row[0];
        }
    if ( ($DB > 0) and ($webroot_writable > 0) )
        {
        $fp = fopen ("./did_recent_call_log.txt", "a");
        fwrite ($fp, "$date|$phone_count|$did_call_ct|$stmt\n");
        fclose($fp);
        }
    }
echo "$phone_count\n";
?>
