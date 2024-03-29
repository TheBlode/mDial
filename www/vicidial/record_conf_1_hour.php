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
if (isset($_GET["server_ip"])) {
    $server_ip=$_GET["server_ip"];
} elseif (isset($_POST["server_ip"])) {
    $server_ip=$_POST["server_ip"];
}
if (isset($_GET["station"])) {
    $station=$_GET["station"];
} elseif (isset($_POST["station"])) {
    $station=$_POST["station"];
}
if (isset($_GET["session_id"])) {
    $session_id=$_GET["session_id"];
} elseif (isset($_POST["session_id"])) {
    $session_id=$_POST["session_id"];
}
if (isset($_GET["NEW_RECORDING"])) {
    $NEW_RECORDING=$_GET["NEW_RECORDING"];
} elseif (isset($_POST["NEW_RECORDING"])) {
    $NEW_RECORDING=$_POST["NEW_RECORDING"];
}
if (isset($_GET["submit"])) {
    $submit=$_GET["submit"];
} elseif (isset($_POST["submit"])) {
    $submit=$_POST["submit"];
}
if (isset($_GET["SUBMIT"])) {
    $SUBMIT=$_GET["SUBMIT"];
} elseif (isset($_POST["SUBMIT"])) {
    $SUBMIT=$_POST["SUBMIT"];
}
if (isset($_GET["DB"])) {
    $DB=$_GET["DB"];
} elseif (isset($_POST["DB"])) {
    $DB=$_POST["DB"];
}
$DB=preg_replace("/[^0-9a-zA-Z]/", "", $DB);
$STARTtime = date("U");
$TODAY = date("Y-m-d");
$mysql_datetime = date("Y-m-d H:i:s");
$FILE_datetime = date("Ymd-His_");
$secX = $STARTtime;
$date = date("r");
$ip = getenv("REMOTE_ADDR");
$browser = getenv("HTTP_USER_AGENT");
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
$session_id = preg_replace('/[^-_0-9a-zA-Z]/', '', $session_id);
$server_ip = preg_replace('/[^-\.\:\_0-9a-zA-Z]/', '', $server_ip);
$NEW_RECORDING = preg_replace('/[^-_0-9a-zA-Z]/', '', $NEW_RECORDING);
$submit = preg_replace('/[^-_0-9a-zA-Z]/', '', $submit);
$SUBMIT = preg_replace('/[^-_0-9a-zA-Z]/', '', $SUBMIT);
if ($non_latin < 1) {
    $PHP_AUTH_USER = preg_replace('/[^-_0-9a-zA-Z]/', '', $PHP_AUTH_USER);
    $PHP_AUTH_PW = preg_replace('/[^-_0-9a-zA-Z]/', '', $PHP_AUTH_PW);
    $station = preg_replace('/[^-_0-9a-zA-Z]/', '', $station);
} else {
    $PHP_AUTH_USER = preg_replace('/[^-_0-9\p{L}]/u', '', $PHP_AUTH_USER);
    $PHP_AUTH_PW = preg_replace('/[^-_0-9\p{L}]/u', '', $PHP_AUTH_PW);
    $station = preg_replace('/[^-_0-9\p{L}]/u', '', $station);
}
$auth=0;
$reports_auth=0;
$admin_auth=0;
$auth_message = user_authorization($PHP_AUTH_USER, $PHP_AUTH_PW, 'REPORTS', 1, 0);
if ($auth_message == 'GOOD') {
    $auth=1;
}
if ($auth > 0) {
    $stmt="SELECT count(*) from vicidial_users where user='$PHP_AUTH_USER' and user_level > 7 and view_reports='1';";
    if ($DB) {
        echo "|$stmt|\n";
    }
    $rslt=mysql_to_mysqli($stmt, $link);
    $row=mysqli_fetch_row($rslt);
    $admin_auth=$row[0];
    $stmt="SELECT count(*) from vicidial_users where user='$PHP_AUTH_USER' and user_level > 6 and view_reports='1';";
    if ($DB) {
        echo "|$stmt|\n";
    }
    $rslt=mysql_to_mysqli($stmt, $link);
    $row=mysqli_fetch_row($rslt);
    $reports_auth=$row[0];
    if ($reports_auth < 1) {
        $VDdisplayMESSAGE = "You are not allowed to view reports";
        Header("Content-type: text/html; charset=utf-8");
        echo "$VDdisplayMESSAGE: |$PHP_AUTH_USER|$auth_message|\n";
        exit;
    }
    if (($reports_auth > 0) and ($admin_auth < 1)) {
        $ADD=999999;
        $reports_only_user=1;
    }
} else {
    $VDdisplayMESSAGE = "Login incorrect, please try again";
    if ($auth_message == 'LOCK') {
        $VDdisplayMESSAGE = "Too many login attempts, try again in 15 minutes";
        Header("Content-type: text/html; charset=utf-8");
        echo "$VDdisplayMESSAGE: |$PHP_AUTH_USER|$auth_message|\n";
        exit;
    }
    if ($auth_message == 'IPBLOCK') {
        $VDdisplayMESSAGE = _QXZ("Your IP Address is not allowed") . ": $ip";
        Header("Content-type: text/html; charset=utf-8");
        echo "$VDdisplayMESSAGE: |$PHP_AUTH_USER|$auth_message|\n";
        exit;
    }
    Header("WWW-Authenticate: Basic realm=\"CONTACT-CENTER-ADMIN\"");
    Header("HTTP/1.0 401 Unauthorized");
    echo "$VDdisplayMESSAGE: |$PHP_AUTH_USER|$PHP_AUTH_PW|$auth_message|\n";
    exit;
}
$stmt="SELECT full_name from vicidial_users where user='$PHP_AUTH_USER';";
$rslt=mysql_to_mysqli($stmt, $link);
$row=mysqli_fetch_row($rslt);
$LOGfullname=$row[0];
$stmt="SELECT full_name from vicidial_users where user='$user';";
$rslt=mysql_to_mysqli($stmt, $link);
$row=mysqli_fetch_row($rslt);
$full_name = $row[0];
require("screen_colors.php");
?>
<html>
<head>
<title>RECORD CONFERENCE: 1 hour</title>
<?php
echo "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">\n";
?>
</head>
<BODY BGCOLOR=white marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>
<CENTER>
<?php
if ($NEW_RECORDING) {
    if ((strlen($server_ip) > 8) && (strlen($session_id) > 3) && (strlen($station) > 3)) {
        $local_DEF = 'Local/';
        $local_AMP = '@';
        $conf_silent_prefix = '7';
        $ext_context = 'demo';
        $stmt="INSERT INTO vicidial_manager values('','','$mysql_datetime','NEW','N','" . mysqli_real_escape_string($link, $server_ip) . "','','Originate','RB$FILE_datetime" . mysqli_real_escape_string($link, $station) . "','Channel: $local_DEF$conf_silent_prefix" . mysqli_real_escape_string($link, $session_id) . "$local_AMP$ext_context','Context: $ext_context','Exten: 8309','Priority: 1','Callerid: $FILE_datetime" . mysqli_real_escape_string($link, $station) . "','','','','','')";
        echo "|$stmt|\n<BR><BR>\n";
        $rslt=mysql_to_mysqli($stmt, $link);
        $stmt="INSERT INTO recording_log (channel,server_ip,extension,start_time,start_epoch,filename) values('" . mysqli_real_escape_string($link, $session_id) . "','" . mysqli_real_escape_string($link, $server_ip) . "','" . mysqli_real_escape_string($link, $station) . "','$mysql_datetime','$secX','$FILE_datetime" . mysqli_real_escape_string($link, $station) . "')";
        echo "|$stmt|\n<BR><BR>\n";
        $rslt=mysql_to_mysqli($stmt, $link);
        echo "Recording started\n<BR><BR>\n";
        echo "<a href=\"$PHP_SELF\">Back to main recording screen</a>\n<BR><BR>\n";
    } else {
        echo "ERROR!!!!    Not all info entered properly\n<BR><BR>\n";
        echo "|$server_ip| |$session_id| |$station|\n<BR><BR>\n";
        echo "<a href=\"$PHP_SELF\">Back to main recording screen</a>\n<BR><BR>\n";
    }
} else {
    echo "<br>Start recording a conference for 1 hour: <form action=$PHP_SELF method=POST>\n";
    echo "<input type=hidden name=NEW_RECORDING value=1>\n";
    echo "<input type=hidden name=DB value='$DB'>\n";
    echo "server_ip: <input type=text name=server_ip size=15 maxlength=15> | \n";
    echo "session_id: <input type=text name=session_id size=7 maxlength=7> | \n";
    echo "station: <input type=text name=station size=5 maxlength=5> | \n";
    echo "<input style='background-color:#$SSbutton_color' type=submit name=submit value='"._QXZ("submit")."'>\n";
    echo "<BR><BR><BR>\n";
}
?>
</BODY></HTML>
