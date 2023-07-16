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
if (isset($_GET["button_id"]))                {$button_id=$_GET["button_id"];}
    elseif (isset($_POST["button_id"]))        {$button_id=$_POST["button_id"];}
if (isset($_GET["lead_id"]))                {$lead_id=$_GET["lead_id"];}
    elseif (isset($_POST["lead_id"]))        {$lead_id=$_POST["lead_id"];}
if (isset($_GET["vendor_id"]))                {$vendor_id=$_GET["vendor_id"];}
    elseif (isset($_POST["vendor_id"]))        {$vendor_id=$_POST["vendor_id"];}
if (isset($_GET["list_id"]))                {$list_id=$_GET["list_id"];}
    elseif (isset($_POST["list_id"]))        {$list_id=$_POST["list_id"];}
if (isset($_GET["phone_number"]))            {$phone_number=$_GET["phone_number"];}
    elseif (isset($_POST["phone_number"]))    {$phone_number=$_POST["phone_number"];}
if (isset($_GET["user"]))                    {$user=$_GET["user"];}
    elseif (isset($_POST["user"]))            {$user=$_POST["user"];}
if (isset($_GET["campaign"]))                {$campaign=$_GET["campaign"];}
    elseif (isset($_POST["campaign"]))        {$campaign=$_POST["campaign"];}
if (isset($_GET["stage"]))                    {$stage=$_GET["stage"];}
    elseif (isset($_POST["stage"]))            {$stage=$_POST["stage"];}
if (isset($_GET["epoch"]))                    {$epoch=$_GET["epoch"];}
    elseif (isset($_POST["epoch"]))            {$epoch=$_POST["epoch"];}
$button_id=preg_replace("/[^0-9]/","",$button_id);
$lead_id=preg_replace("/[^0-9]/","",$lead_id);
$list_id=preg_replace("/[^0-9]/","",$list_id);
$phone_number=preg_replace("/[^0-9]/","",$phone_number);
$vendor_id = preg_replace("/[^- \:\/\_0-9a-zA-Z]/","",$vendor_id);
$user=preg_replace("/[^0-9a-zA-Z]/","",$user);
$campaign = preg_replace("/[^-\_0-9a-zA-Z]/","",$campaign);
$stage = preg_replace("/[^-\_0-9a-zA-Z]/","",$stage);
$epoch = preg_replace("/[^0-9]/","",$epoch);
require("dbconnect.php");
if (preg_match("/CLICK/i",$stage))
    {
    $epochNOW = date("U");
    $click_seconds = ($epochNOW - $epoch);
    if ( ($click_seconds < 0) or ($click_seconds > 3600) )
        {$click_seconds=0;}
    $stmt="UPDATE qr_busy_button_log SET stage='$stage',click_seconds='$click_seconds' where button_id='$button_id';";
    if ($DB) {echo "|$stmt|\n";}
    $rslt=mysql_query($stmt, $link);
    echo "Thank you for clicking the button\n";
    exit;
    }
else
    {
    $CL=':';
    $script_name = getenv("SCRIPT_NAME");
    $server_name = getenv("SERVER_NAME");
    $server_port = getenv("SERVER_PORT");
    if (preg_match("/443/i",$server_port)) {$HTTPprotocol = 'https://';}
      else {$HTTPprotocol = 'http://';}
    if (($server_port == '80') or ($server_port == '443') ) {$server_port='';}
    else {$server_port = "$CL$server_port";}
    $agcPAGE = "$HTTPprotocol$server_name$server_port$script_name";
    $epoch = date("U");
    $SQLdate = date("Y-m-d H:i:s");
    $stmt="INSERT INTO qr_busy_button_log SET lead_id='$lead_id',list_id='$list_id',phone_number='$phone_number',vendor_lead_code='$vendor_id',user='$user',campaign_id='$campaign',stage='DISPLAY',event_time='$SQLdate';";
    if ($DB) {echo "|$stmt|\n";}
    $rslt=mysql_query($stmt, $link);
    $button_id = mysql_insert_id($link);
    echo "<FORM NAME=button_form ID=button_form ACTION=\"$agcPAGE\" METHOD=POST>\n";
    echo "<INPUT TYPE=HIDDEN NAME=button_id VALUE=\"$button_id\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=stage VALUE=\"CLICK\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=epoch VALUE=\"$epoch\">\n";
    echo "<INPUT TYPE=SUBMIT NAME=SUBMIT VALUE=\"PLEASE CLICK THIS TEST BUTTON\">\n";
    echo "</FORM>\n\n";
    }
?>
