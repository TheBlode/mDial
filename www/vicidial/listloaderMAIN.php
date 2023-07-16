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
require("dbconnect_mysqli.php");
require("functions.php");
$PHP_AUTH_USER=$_SERVER['PHP_AUTH_USER'];
$PHP_AUTH_PW=$_SERVER['PHP_AUTH_PW'];
$PHP_SELF=$_SERVER['PHP_SELF'];
$PHP_SELF = preg_replace('/\.php.*/i', '.php', $PHP_SELF);
if (isset($_GET["DB"])) {
    $DB=$_GET["DB"];
} elseif (isset($_POST["DB"])) {
    $DB=$_POST["DB"];
}
$DB=preg_replace("/[^0-9a-zA-Z]/", "", $DB);
$stmt = "SELECT use_non_latin,webroot_writable,outbound_autodial_active,user_territories_active,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                    $row[0];
    $webroot_writable =                $row[1];
    $SSoutbound_autodial_active =    $row[2];
    $user_territories_active =        $row[3];
    $SSallow_web_debug =            $row[4];
}
if ($SSallow_web_debug < 1) {
    $DB=0;
}
if ($non_latin < 1) {
    $PHP_AUTH_USER = preg_replace('/[^-_0-9a-zA-Z]/', '', $PHP_AUTH_USER);
    $PHP_AUTH_PW = preg_replace('/[^-_0-9a-zA-Z]/', '', $PHP_AUTH_PW);
} else {
    $PHP_AUTH_USER = preg_replace('/[^-_0-9\p{L}]/u', '', $PHP_AUTH_USER);
    $PHP_AUTH_PW = preg_replace('/[^-_0-9\p{L}]/u', '', $PHP_AUTH_PW);
}
$STARTtime = date("U");
$TODAY = date("Y-m-d");
$NOW_TIME = date("Y-m-d H:i:s");
$FILE_datetime = $STARTtime;
$date = date("r");
$ip = getenv("REMOTE_ADDR");
$browser = getenv("HTTP_USER_AGENT");
$auth=0;
$auth_message = user_authorization($PHP_AUTH_USER, $PHP_AUTH_PW, '', 1, 0);
if ($auth_message == 'GOOD') {
    $auth=1;
}
if ($auth < 1) {
    $VDdisplayMESSAGE = "Login incorrect, please try again";
    if ($auth_message == 'LOCK') {
        $VDdisplayMESSAGE = "Too many login attempts, try again in 15 minutes";
        Header("Content-type: text/html; charset=utf-8");
        echo "$VDdisplayMESSAGE: |$PHP_AUTH_USER|$auth_message|\n";
        exit;
    }
    Header("WWW-Authenticate: Basic realm=\"CONTACT-CENTER-ADMIN\"");
    Header("HTTP/1.0 401 Unauthorized");
    echo "$VDdisplayMESSAGE: |$PHP_AUTH_USER|$PHP_AUTH_PW|$auth_message|\n";
    exit;
}
$stmt="SELECT load_leads from vicidial_users where user='$PHP_AUTH_USER';";
$rslt=mysql_to_mysqli($stmt, $link);
$row=mysqli_fetch_row($rslt);
$LOGload_leads = $row[0];
if ($LOGload_leads < 1) {
    echo "You do not have permissions to load leads\n";
    exit;
}
?><HTML>
<HEAD>
<TITLE>Lead Loader Module</TITLE>
</HEAD>
<FRAMESET ROWS="300,*" border=0>
<FRAME SRC="listloader.php" NAME="main">
<FRAME SRC="count.htm" NAME="lead_count">
</HTML>
