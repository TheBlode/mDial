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
$version = '2.14-5';
$build = '220222-1917';
$php_script='nanpa_type.php';
$startMS = microtime();
require("dbconnect_mysqli.php");
require("functions.php");
if (isset($_GET["user"])) {
    $user=$_GET["user"];
} elseif (isset($_POST["user"])) {
    $user=$_POST["user"];
}
if (isset($_GET["pass"])) {
    $pass=$_GET["pass"];
} elseif (isset($_POST["pass"])) {
    $pass=$_POST["pass"];
}
if (isset($_GET["function"])) {
    $function=$_GET["function"];
} elseif (isset($_POST["function"])) {
    $function=$_POST["function"];
}
if (isset($_GET["phone_number"])) {
    $phone_number=$_GET["phone_number"];
} elseif (isset($_POST["phone_number"])) {
    $phone_number=$_POST["phone_number"];
}
if (isset($_GET["DB"])) {
    $DB=$_GET["DB"];
} elseif (isset($_POST["DB"])) {
    $DB=$_POST["DB"];
}
if (file_exists('options.php')) {
    require('options.php');
}
header("Content-type: text/html; charset=utf-8");
header("Cache-Control: no-cache, must-revalidate");  // HTTP/1.1
header("Pragma: no-cache");                          // HTTP/1.0
$stmt = "SELECT use_non_latin,pass_hash_enabled,allow_web_debug FROM system_settings;";
$rslt=mysqli_query($link, $stmt);
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                $row[0];
    $SSpass_hash_enabled =        $row[1];
    $SSallow_web_debug =        $row[2];
}
if ($SSallow_web_debug < 1) {
    $DB=0;
}
$DB=preg_replace('/[^0-9]/', '', $DB);
$function = preg_replace('/[^-\_0-9a-zA-Z]/', '', $function);
$phone_number = preg_replace('/[^\|0-9]/', '', $phone_number);
if ($non_latin < 1) {
    $user = preg_replace('/[^-_0-9a-zA-Z]/', '', $user);
    $pass = preg_replace('/[^-_0-9a-zA-Z]/', '', $pass);
} else {
    $user = preg_replace('/[^-_0-9\p{L}]/u', '', $user);
    $pass = preg_replace('/[^-_0-9\p{L}]/u', '', $pass);
}
if ($function == 'version') {
    $NOW_TIME = date("Y-m-d H:i:s");
    $data = "VERSION: $version|BUILD: $build|DATE: $NOW_TIME";
    echo "$data\n";
    exit;
}
$auth=0;
$auth_message = user_authorization($user, $pass, 'REPORTS', 1, 0);
if ($auth_message == 'GOOD') {
    $auth=1;
}
if ($auth < 1) {
    $VDdisplayMESSAGE = "ERROR: Login incorrect, please try again";
    if ($auth_message == 'LOCK') {
        $VDdisplayMESSAGE = "ERROR: Too many login attempts, try again in 15 minutes";
        Header("Content-type: text/html; charset=utf-8");
        echo "$VDdisplayMESSAGE: |$user|$auth_message|\n";
        exit;
    }
    if ($auth_message == 'IPBLOCK') {
        $VDdisplayMESSAGE = _QXZ("Your IP Address is not allowed") . ": $ip";
        Header("Content-type: text/html; charset=utf-8");
        echo "$VDdisplayMESSAGE: |$PHP_AUTH_USER|$auth_message|\n";
        exit;
    }
    Header("Content-type: text/html; charset=utf-8");
    echo "$VDdisplayMESSAGE: |$user|$pass|$auth_message|\n";
    exit;
}
$stmt="SELECT count(*) from nanpa_prefix_exchanges_fast;";
if ($DB>0) {
    echo "DEBUG: npef count query - $stmt\n";
}
$rslt=mysqli_query($link, $stmt);
$row=mysqli_fetch_row($rslt);
$npef_count=$row[0];
if ($npef_count < 100) {
    $result = 'ERROR';
    $result_reason = "nanpa_prefix_exchanges_fast table incomplete";
    echo "$result: $result_reason: |$user|$npef_count|\n";
    exit;
}
$stmt="SELECT count(*) from nanpa_wired_to_wireless;";
if ($DB>0) {
    echo "DEBUG: wired count query - $stmt\n";
}
$rslt=mysqli_query($link, $stmt);
$row=mysqli_fetch_row($rslt);
$wired_count=$row[0];
if ($wired_count < 100) {
    $result = 'ERROR';
    $result_reason = "nanpa_wired_to_wireless table incomplete";
    echo "$result: $result_reason: |$user|$wired_count|\n";
    exit;
}
$stmt="SELECT count(*) from nanpa_wireless_to_wired;";
if ($DB>0) {
    echo "DEBUG: wireless count query - $stmt\n";
}
$rslt=mysqli_query($link, $stmt);
$row=mysqli_fetch_row($rslt);
$wireless_count=$row[0];
if ($wireless_count < 100) {
    $result = 'ERROR';
    $result_reason = "nanpa_wired_to_wireless table incomplete";
    echo "$result: $result_reason: |$user|$wireless_count|\n";
    exit;
}
if ($function == 'status') {
    $data = "PREFIXES: $npef_count|TO_WIRELESS: $wired_count|TO_WIRED: $wireless_count";
    echo "$data\n";
    exit;
}
if (strlen($phone_number) < 10) {
    $result = 'ERROR';
    $result_reason = "invalid phone number";
    echo "$result: $result_reason: |$user|$phone_number|\n";
    exit;
} else {
    $numbers = explode('|', $phone_number);
    $i=0;
    $numbers_ct = count($numbers);
    while($i < $numbers_ct) {
        $type='';
        if ((strlen($numbers[$i]) > 9) and (strlen($numbers[$i]) < 11)) {
            $area =     substr($numbers[$i], 0, 3);
            $prefix =     substr($numbers[$i], 3, 4);
            $stmt="SELECT type from nanpa_prefix_exchanges_fast where ac_prefix='$area$prefix';";
            if ($DB>0) {
                echo "DEBUG: prefix lookup query |$numbers[$i]| - $stmt\n";
            }
            $rslt=mysqli_query($link, $stmt);
            $prefix_ct = mysqli_num_rows($rslt);
            if ($prefix_ct > 0) {
                $row=mysqli_fetch_row($rslt);
                $type = $row[0];
                if ($type == 'V') {
                    $type='S';
                    if ($DB>0) {
                        echo "DEBUG: prefix match type V changing to type S landline |$numbers[$i]| - $stmt\n";
                    }
                }
                if ($type != 'S') {
                    $stmt="SELECT count(*) from nanpa_wireless_to_wired where phone='$numbers[$i]';";
                    if ($DB>0) {
                        echo "DEBUG: wireless_to_wired lookup query |$numbers[$i]|$type| - $stmt\n";
                    }
                    $rslt=mysqli_query($link, $stmt);
                    $row=mysqli_fetch_row($rslt);
                    $type='C';
                    if ($row[0] > 0) {
                        $type='S';
                        if ($DB>0) {
                            echo "DEBUG: wireless_to_wired lookup match |$numbers[$i]|$type| - $stmt\n";
                        }
                    }
                } else {
                    $stmt="SELECT count(*) from nanpa_wired_to_wireless where phone='$numbers[$i]';";
                    if ($DB>0) {
                        echo "DEBUG: wired_to_wireless lookup query |$numbers[$i]|$type| - $stmt\n";
                    }
                    $rslt=mysqli_query($link, $stmt);
                    $row=mysqli_fetch_row($rslt);
                    if ($row[0] > 0) {
                        $type='C';
                        if ($DB>0) {
                            echo "DEBUG: wired_to_wireless lookup match |$numbers[$i]|$type| - $stmt\n";
                        }
                    }
                }
            } else {
                $type='I';
            }
        } else {
            $type='I';
        }
        echo "$type|$numbers[$i]\n";
        $i++;
    }
    $endMS = microtime();
    $startMSary = explode(" ", $startMS);
    $endMSary = explode(" ", $endMS);
    $runS = ($endMSary[0] - $startMSary[0]);
    $runM = ($endMSary[1] - $startMSary[1]);
    $TOTALrun = ($runS + $runM);
    if ($DB>0) {
        echo "DEBUG: runtime |$TOTALrun|\n";
    }
}
?>
