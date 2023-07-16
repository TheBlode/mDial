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
$build = '180515-1711';
require("dbconnect_mysqli.php");
$query_string = getenv("QUERY_STRING");
if (isset($_GET["outlet"])) {
    $outlet=$_GET["outlet"];
} elseif (isset($_POST["outlet"])) {
    $outlet=$_POST["outlet"];
}
if (isset($_GET["stage"])) {
    $stage=$_GET["stage"];
} elseif (isset($_POST["stage"])) {
    $stage=$_POST["stage"];
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
$outlet=preg_replace("/[^-_0-9a-zA-Z]/", "", $outlet);
$stage=preg_replace("/[^-_0-9a-zA-Z]/", "", $stage);
if ((strlen($outlet) < 1) or (strlen($stage) < 2)) {
    echo "ERROR: invalid outlet or stage: |$outlet|$stage|\n";
} else {
    $command = "/usr/bin/curl -s -o /tmp/Xtest http://cycle:test@192.168.1.157:80/outlet\?".$outlet.'='.$stage;
    exec($command);
    echo "Command sent: |$outlet|$stage|";
}
exit;
?>
