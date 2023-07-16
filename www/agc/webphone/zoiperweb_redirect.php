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
if (isset($_GET["DB"]))                            {$DB=$_GET["DB"];}
        elseif (isset($_POST["DB"]))            {$DB=$_POST["DB"];}
if (isset($_GET["phone_login"]))                {$phone_login=$_GET["phone_login"];}
        elseif (isset($_POST["phone_login"]))    {$phone_login=$_POST["phone_login"];}
if (isset($_GET["phone_pass"]))                    {$phone_pass=$_GET["phone_pass"];}
        elseif (isset($_POST["phone_pass"]))    {$phone_pass=$_POST["phone_pass"];}
if (isset($_GET["server_ip"]))                    {$server_ip=$_GET["server_ip"];}
        elseif (isset($_POST["server_ip"]))        {$server_ip=$_POST["server_ip"];}
if (isset($_GET["callerid"]))                    {$callerid=$_GET["callerid"];}
        elseif (isset($_POST["callerid"]))        {$callerid=$_POST["callerid"];}
if (isset($_GET["protocol"]))                    {$protocol=$_GET["protocol"];}
        elseif (isset($_POST["protocol"]))        {$protocol=$_POST["protocol"];}
if (isset($_GET["codecs"]))                        {$codecs=$_GET["codecs"];}
        elseif (isset($_POST["codecs"]))        {$codecs=$_POST["codecs"];}
if (isset($_GET["options"]))                    {$options=$_GET["options"];}
        elseif (isset($_POST["options"]))        {$options=$_POST["options"];}
if (isset($_GET["system_key"]))                    {$system_key=$_GET["system_key"];}
        elseif (isset($_POST["system_key"]))    {$system_key=$_POST["system_key"];}
$DB = preg_replace('/[^-\._0-9\p{L}]/u',"",$DB);
$phone_login = preg_replace('/[^-\._0-9\p{L}]/u',"",$phone_login);
$phone_pass = preg_replace('/[^-\._0-9\p{L}]/u',"",$phone_pass);
$server_ip = preg_replace('/[^-\*\#\.\:\/\@\_0-9\p{L}]/u','',$server_ip);
$callerid = preg_replace('/[^-\*\#\.\:\/\@\_0-9\p{L}]/u','',$callerid);
$protocol = preg_replace('/[^-\*\#\.\:\/\@\_0-9\p{L}]/u','',$protocol);
$codecs = preg_replace('/[^-\*\#\.\:\/\@\_0-9\p{L}]/u','',$codecs);
$options = preg_replace('/[^-\*\#\.\:\/\@\_0-9\p{L}]/u','',$options);
$system_key = preg_replace('/[^-\*\#\.\:\/\@\_0-9\p{L}]/u','',$system_key);
$query_string = "/agc/webphone/zoiperweb.php?DB=$DB&phone_login=$phone_login&phone_pass=$phone_pass&server_ip=$server_ip&callerid=$callerid&protocol=$protocol&codecs=$codecs&options=$options&system_key=$system_key";
$servers = array("sslagent1.server.net","sslagent2.server.net");
$server = $servers[array_rand($servers)];
$URL = "https://$server$query_string";
header("Location: $URL");
echo"<TITLE>Webphone Redirect</TITLE>\n";
echo"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=iso-8859-1\">\n";
echo"<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=$URL\">\n";
echo"</HEAD>\n";
echo"<BODY BGCOLOR=#FFFFFF marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>\n";
echo"<a href=\"$URL\">click here to continue. . .</a>\n";
exit;
?>
