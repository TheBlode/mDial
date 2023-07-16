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
require_once("functions.php");
require_once("dbconnect_mysqli.php");
if (isset($_GET["DB"])) {
    $DB=$_GET["DB"];
} elseif (isset($_POST["DB"])) {
    $DB=$_POST["DB"];
}
if (isset($_GET["phone_login"])) {
    $phone_login=$_GET["phone_login"];
} elseif (isset($_POST["phone_login"])) {
    $phone_login=$_POST["phone_login"];
}
if (isset($_GET["phone_pass"])) {
    $phone_pass=$_GET["phone_pass"];
} elseif (isset($_POST["phone_pass"])) {
    $phone_pass=$_POST["phone_pass"];
}
if (isset($_GET["VD_login"])) {
    $VD_login=$_GET["VD_login"];
} elseif (isset($_POST["VD_login"])) {
    $VD_login=$_POST["VD_login"];
}
if (isset($_GET["VD_pass"])) {
    $VD_pass=$_GET["VD_pass"];
} elseif (isset($_POST["VD_pass"])) {
    $VD_pass=$_POST["VD_pass"];
}
if (isset($_GET["VD_campaign"])) {
    $VD_campaign=$_GET["VD_campaign"];
} elseif (isset($_POST["VD_campaign"])) {
    $VD_campaign=$_POST["VD_campaign"];
}
if (isset($_GET["relogin"])) {
    $relogin=$_GET["relogin"];
} elseif (isset($_POST["relogin"])) {
    $relogin=$_POST["relogin"];
}
if (!isset($phone_login)) {
    if (isset($_GET["pl"])) {
        $phone_login=$_GET["pl"];
    } elseif (isset($_POST["pl"])) {
        $phone_login=$_POST["pl"];
    }
}
if (!isset($phone_pass)) {
    if (isset($_GET["pp"])) {
        $phone_pass=$_GET["pp"];
    } elseif (isset($_POST["pp"])) {
        $phone_pass=$_POST["pp"];
    }
}
$DB = preg_replace('/[^-\._0-9\p{L}]/u', "", $DB);
$phone_login = preg_replace('/[^-\._0-9\p{L}]/u', "", $phone_login);
$phone_pass = preg_replace('/[^-\._0-9\p{L}]/u', "", $phone_pass);
$VD_login = preg_replace('/[^-\._0-9\p{L}]/u', "", $VD_login);
$VD_pass = preg_replace('/[^-\._0-9\p{L}]/u', "", $VD_pass);
$VD_campaign = preg_replace('/[^-\._0-9\p{L}]/u', "", $VD_campaign);
$relogin = preg_replace('/[^-\._0-9\p{L}]/u', "", $relogin);
$stmt = "SELECT use_non_latin,admin_home_url,admin_web_directory,enable_languages,language_method,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($mel > 0) {
    mysql_error_logging($NOW_TIME, $link, $mel, $stmt, '00XXX', $VD_login, $server_ip, $session_name, $one_mysql_log);
}
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $non_latin =            $row[0];
    $welcomeURL =            $row[1];
    $admin_web_directory =    $row[2];
    $SSenable_languages =    $row[3];
    $SSlanguage_method =    $row[4];
    $SSallow_web_debug =    $row[5];
}
if ($SSallow_web_debug < 1) {
    $DB=0;
}
$VUselected_language = '';
$stmt="SELECT selected_language from vicidial_users where user='$VD_login';";
if ($DB) {
    echo "|$stmt|\n";
}
$rslt=mysql_to_mysqli($stmt, $link);
if ($mel > 0) {
    mysql_error_logging($NOW_TIME, $link, $mel, $stmt, '00XXX', $VD_login, $server_ip, $session_name, $one_mysql_log);
}
$sl_ct = mysqli_num_rows($rslt);
if ($sl_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $VUselected_language =        $row[0];
}
$URL = "http://192.168.1.60/agc/vicidial.php?phone_login=$phone_login&phone_pass=$phone_pass&DB=$DB&VD_login=$VD_login&VD_pass=$VD_pass&VD_campaign=$VD_campaign&relogin=$relogin";
echo"<TITLE>"._QXZ("Agent Redirect")."</TITLE>\n";
echo"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=iso-8859-1\">\n";
echo"<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=$URL\">\n";
echo"</HEAD>\n";
echo"<BODY BGCOLOR=#FFFFFF marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>\n";
echo"<a href=\"$URL\">"._QXZ("click here to continue").". . .</a>\n";
exit;
?>
