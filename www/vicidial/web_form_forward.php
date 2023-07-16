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
if (isset($_GET["phone_number"]))    {$phone_number=$_GET["phone_number"];}
if (isset($_GET["source_id"]))        {$source_id=$_GET["source_id"];}
if (isset($_GET["user"]))            {$user=$_GET["user"];}
$user = preg_replace("/\<|\>|\'|\"|\\\\|;| /", '', $user);
$source_id = preg_replace("/\<|\>|\'|\"|\\\\|;/", '', $source_id);
$phone_number = preg_replace("/\<|\>|\'|\"|\\\\|;/", '', $phone_number);
require("dbconnect_mysqli.php");
require("functions.php");
$stmt="SELECT full_name from vicidial_users where user='$user';";
$rslt=mysql_to_mysqli($stmt, $link);
$row=mysqli_fetch_row($rslt);
$fullname=$row[0];
$URL = "http://astguiclient.sf.net/test.php?userid=$user&phone=$phone_number&Rep=$fullname&source_id=$source_id";
header("Location: $URL");
echo"<HTML><HEAD>\n";
echo"<TITLE>Group1</TITLE>\n";
echo"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=iso-8859-1\">\n";
echo"<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=$URL\">\n";
echo"</HEAD>\n";
echo"<BODY BGCOLOR=#FFFFFF marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>\n";
echo"<a href=\"$URL\">click here to continue. . .</a>\n";
echo"</BODY></HTML>\n";
?>
