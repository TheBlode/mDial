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
$version = '2.14-1';
$build = '180522-1334';
require("dbconnect_mysqli.php");
$query_string = getenv("QUERY_STRING");
if (isset($_GET["room"])) {
    $room=$_GET["room"];
} elseif (isset($_POST["room"])) {
    $room=$_POST["room"];
}
if (isset($_GET["auth_token"])) {
    $auth_token=$_GET["auth_token"];
} elseif (isset($_POST["auth_token"])) {
    $auth_token=$_POST["auth_token"];
}
if (isset($_GET["color"])) {
    $color=$_GET["color"];
} elseif (isset($_POST["color"])) {
    $color=$_POST["color"];
}
if (isset($_GET["message"])) {
    $message=$_GET["message"];
} elseif (isset($_POST["message"])) {
    $message=$_POST["message"];
}
if (isset($_GET["notify"])) {
    $notify=$_GET["notify"];
} elseif (isset($_POST["notify"])) {
    $notify=$_POST["notify"];
}
if (isset($_GET["format"])) {
    $format=$_GET["format"];
} elseif (isset($_POST["format"])) {
    $format=$_POST["format"];
}
if (isset($_GET["DB"])) {
    $DB=$_GET["DB"];
} elseif (isset($_POST["DB"])) {
    $DB=$_POST["DB"];
}
header("Content-type: text/html; charset=utf-8");
header("Cache-Control: no-cache, must-revalidate");  // HTTP/1.1
header("Pragma: no-cache");                          // HTTP/1.0
$txt = '.txt';
$StarTtime = date("U");
$NOW_DATE = date("Y-m-d");
$NOW_TIME = date("Y-m-d H:i:s");
$CIDdate = date("mdHis");
$ENTRYdate = date("YmdHis");
$MT[0]='';
$room=preg_replace("/[^-_0-9a-zA-Z]/", "", $room);
$auth_token=preg_replace("/[^-_0-9a-zA-Z]/", "", $auth_token);
$color=preg_replace("/[^-_0-9a-zA-Z]/", "", $color);
$message=preg_replace('/[^- \.\,\_0-9a-zA-Z]/', '', $message);
$notify=preg_replace("/[^-_0-9a-zA-Z]/", "", $notify);
$format=preg_replace("/[^-_0-9a-zA-Z]/", "", $format);
$DB=preg_replace("/[^-_0-9a-zA-Z]/", "", $DB);
if ((strlen($room) < 1) or (strlen($auth_token) < 2) or (strlen($message) < 1)) {
    echo "ERROR: invalid room, auth_token or message: |$room|$auth_token|$message|\n";
} else {
    if (strlen($color) < 1) {
        $color='green';
    }
    if (strlen($notify) < 1) {
        $notify='true';
    }
    if (strlen($format) < 1) {
        $format='text';
    }
    $url = "https://cdpcl.hipchat.com/v2/room/".$room."/notification?auth_token=".$auth_token;
    $ch = curl_init($url);
    $payload = json_encode(array( "color"=> $color, "message"=> $message, "notify"=> $notify, "message_format"=> $format ));
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $result = curl_exec($ch);
    curl_close($ch);
    echo "$result";
}
exit;
?>
