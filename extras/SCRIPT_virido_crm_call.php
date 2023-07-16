<?php
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
?>
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
if (isset($_GET["user_custom_five"]))            {$user_custom_five=$_GET["user_custom_five"];}
    elseif (isset($_POST["user_custom_five"]))    {$user_custom_five=$_POST["user_custom_five"];}
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
    $virido_url = 'http://iconnect1.intellicomsoftware.com/script/dialercall.aspx';
    echo "<B>Client_Code: </B>XYZ<BR>\n";
    echo "<B>Vendor_Code: </B>ABC<BR>\n";
    echo "<B>Campaign_Code: </B>XX12<BR>\n";
    echo "<B>User_Name: </B>$user_custom_five<BR>\n";
    echo "<B>BTN: </B>$phone_number<BR>\n";
    echo "<BR>\n";
    echo "<FORM NAME=button_form ID=button_form ACTION=\"$virido_url\" METHOD=POST>\n";
    echo "<INPUT TYPE=HIDDEN NAME=Client_Code VALUE=\"XYZ\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=Vendor_Code VALUE=\"ABC\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=Campaign_Code VALUE=\"XX12\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=User_Name VALUE=\"$user_custom_five\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=BTN VALUE=\"$phone_number\">\n";
    echo "<INPUT TYPE=SUBMIT NAME=SUBMIT VALUE=\"Initiate Phone Call\">\n";
    echo "</FORM>\n\n";
    }
?>
