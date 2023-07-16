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
header ("Content-type: text/html; charset=utf-8");
require("dbconnect_mysqli.php");
require("functions.php");
if (isset($_GET["phone"]))                {$phone=$_GET["phone"];}
    elseif (isset($_POST["phone"]))        {$phone=$_POST["phone"];}
if (isset($_GET["DB"]))                    {$DB=$_GET["DB"];}
    elseif (isset($_POST["DB"]))        {$DB=$_POST["DB"];}
$DB=preg_replace("/[^0-9a-zA-Z]/","",$DB);
$stmt = "SELECT enable_vtiger_integration,vtiger_server_ip,vtiger_dbname,vtiger_login,vtiger_pass,vtiger_url,use_non_latin FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($DB) {echo "$stmt\n";}
$ss_conf_ct = mysqli_num_rows($rslt);
if ($ss_conf_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $enable_vtiger_integration =    $row[0];
    $vtiger_server_ip    =            $row[1];
    $vtiger_dbname =                $row[2];
    $vtiger_login =                    $row[3];
    $vtiger_pass =                    $row[4];
    $vtiger_url =                    $row[5];
    $non_latin =                    $row[6];
    }
if ($non_latin < 1)
    {
    $phone=preg_replace('/[^-_0-9a-zA-Z]/','',$phone);
    }
else
    {
    $phone = preg_replace("/'|\"|\\\\|;/","",$phone);
    }
$phone_count=0;
if ( ($enable_vtiger_integration > 0) and (strlen($vtiger_server_ip) > 5) and (strlen($phone) > 6) )
    {
    $linkV=mysqli_connect("$vtiger_server_ip", "$vtiger_login", "$vtiger_pass", "$vtiger_dbname");
    if (!$linkV) {die("Could not connect: $vtiger_server_ip|$vtiger_dbname|$vtiger_login|$vtiger_pass" . mysqli_connect_error());}
    if ($DB) {echo 'Connected successfully';}
    $stmt="SELECT count(*) from vtiger_contactdetails where phone='$phone';";
    if ($DB) {echo "$stmt\n";}
    $rslt=mysql_to_mysqli($stmt, $linkV);
    $row=mysqli_fetch_row($rslt);
    $phone_count = $row[0];
    if (!$rslt) {die("Could not execute: $stmt" . mysqli_error());}
    if ($phone_count < 1)
        {
        $stmt="SELECT count(*) from vtiger_contactsubdetails where homephone='$phone';";
        if ($DB) {echo "$stmt\n";}
        $rslt=mysql_to_mysqli($stmt, $linkV);
        $row=mysqli_fetch_row($rslt);
        $phone_count = $row[0];
        if (!$rslt) {die("Could not execute: $stmt" . mysqli_error());}
        }
    }
echo "$phone_count\n";
?>
