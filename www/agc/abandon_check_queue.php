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
$api_script = 'abandonchk';
$php_script = 'abandon_check_queue.php';
require_once("dbconnect_mysqli.php");
require_once("functions.php");
$filedate = date("Ymd");
$filetime = date("H:i:s");
$IP = getenv("REMOTE_ADDR");
$BR = getenv("HTTP_USER_AGENT");
$PHP_AUTH_USER=$_SERVER['PHP_AUTH_USER'];
$PHP_AUTH_PW=$_SERVER['PHP_AUTH_PW'];
if (isset($_GET["lead_id"])) {
    $lead_id=$_GET["lead_id"];
} elseif (isset($_POST["lead_id"])) {
    $lead_id=$_POST["lead_id"];
}
if (isset($_GET["dispo"])) {
    $dispo=$_GET["dispo"];
} elseif (isset($_POST["dispo"])) {
    $dispo=$_POST["dispo"];
}
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
if (isset($_GET["DB"])) {
    $DB=$_GET["DB"];
} elseif (isset($_POST["DB"])) {
    $DB=$_POST["DB"];
}
if (isset($_GET["log_to_file"])) {
    $log_to_file=$_GET["log_to_file"];
} elseif (isset($_POST["log_to_file"])) {
    $log_to_file=$_POST["log_to_file"];
}
if (isset($_GET["source"])) {
    $source=$_GET["source"];
} elseif (isset($_POST["source"])) {
    $source=$_POST["source"];
}
$DB=preg_replace("/[^0-9a-zA-Z]/", "", $DB);
$US = '_';
$TD = '---';
$STARTtime = date("U");
$NOW_TIME = date("Y-m-d H:i:s");
$four_hours_ago = date("Y-m-d H:i:s", mktime(date("H")-4, date("i"), date("s"), date("m"), date("d"), date("Y")));
$original_sale_status = $sale_status;
$sale_status = "$TD$sale_status$TD";
$search_value='';
$match_found=0;
$primary_match_found=0;
$age_trigger=0;
$k=0;
$user=preg_replace("/\'|\"|\\\\|;| /", "", $user);
$pass=preg_replace("/\'|\"|\\\\|;| /", "", $pass);
if (file_exists('options.php')) {
    require_once('options.php');
}
header("Content-type: text/html; charset=utf-8");
$stmt = "SELECT use_non_latin,enable_languages,language_method,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                $row[0];
    $SSenable_languages =        $row[1];
    $SSlanguage_method =        $row[2];
    $SSallow_web_debug =        $row[3];
}
if ($SSallow_web_debug < 1) {
    $DB=0;
}
$VUselected_language = '';
$stmt="SELECT selected_language from vicidial_users where user='$user';";
if ($DB) {
    echo "|$stmt|\n";
}
$rslt=mysql_to_mysqli($stmt, $link);
$sl_ct = mysqli_num_rows($rslt);
if ($sl_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $VUselected_language =        $row[0];
}
$lead_id = preg_replace('/[^_0-9]/', '', $lead_id);
$log_to_file = preg_replace('/[^-_0-9a-zA-Z]/', '', $log_to_file);
if ($non_latin < 1) {
    $user=preg_replace("/[^-_0-9a-zA-Z]/", "", $user);
    $pass=preg_replace("/[^-\.\+\/\=_0-9a-zA-Z]/", "", $pass);
    $dispo = preg_replace('/[^-_0-9a-zA-Z]/', '', $dispo);
    $source = preg_replace('/[^-_0-9a-zA-Z]/', '', $source);
} else {
    $user = preg_replace('/[^-_0-9\p{L}]/u', '', $user);
    $pass = preg_replace('/[^-\.\+\/\=_0-9\p{L}]/u', '', $pass);
    $dispo = preg_replace('/[^-_0-9\p{L}]/u', '', $dispo);
    $source = preg_replace('/[^-_0-9\p{L}]/u', '', $source);
}
if ($DB>0) {
    echo "$lead_id|$dispo|$user|$pass|$DB|$log_to_file|$source|\n";
}
if (strlen($dispo) < 1) {
    echo _QXZ("No dispo set").": 1|$dispo|\n";
    exit;
} else {
    if ($non_latin < 1) {
        $user=preg_replace("/[^-_0-9a-zA-Z]/", "", $user);
    }
    if (preg_match("/NOAGENTURL/", $user)) {
        $PADlead_id = sprintf("%010s", $lead_id);
        if ((strlen($pass) > 15) and (preg_match("/$PADlead_id$/", $pass))) {
            $stmt="SELECT count(*) from vicidial_log_extended where caller_code='$pass' and call_date > \"$four_hours_ago\";";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
            $row=mysqli_fetch_row($rslt);
            $authlive=$row[0];
            $auth=$row[0];
            if ($authlive < 1) {
                echo _QXZ("Call Not Found:")." 2|$user|$pass|$authlive|\n";
                exit;
            }
        } else {
            echo _QXZ("Invalid Call ID:")." 1|$user|$pass|$PADlead_id|\n";
            exit;
        }
    } else {
        $auth=0;
        $auth_message = user_authorization($user, $pass, '', 0, 0, 0, 0, 'abandon_check_queue');
        if ($auth_message == 'GOOD') {
            $auth=1;
        }
        $stmt="SELECT count(*) from vicidial_live_agents where user='$user';";
        if ($DB) {
            echo "|$stmt|\n";
        }
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        $authlive=$row[0];
    }
    if ((strlen($user)<2) or (strlen($pass)<2) or ($auth==0) or ($authlive==0)) {
        echo _QXZ("Invalid Username/Password:")." |$user|$pass|$auth|$authlive|$auth_message|\n";
        exit;
    }
    if (strlen($lead_id) > 0) {
        $search_count=0;
        $stmt = "SELECT phone_number FROM vicidial_list where lead_id='$lead_id';";
        $rslt=mysql_to_mysqli($stmt, $link);
        if ($DB) {
            echo "$stmt\n";
        }
        $search_count = mysqli_num_rows($rslt);
        if ($search_count > 0) {
            $row=mysqli_fetch_row($rslt);
            $phone_number = $row[0];
        }
        if ($search_count > 0) {
            $check_status='NEW';
            $reject_reason='';
            $hopper_count=0;
            $stmt = "SELECT count(*) FROM vicidial_hopper where lead_id='$lead_id';";
            $rslt=mysql_to_mysqli($stmt, $link);
            if ($DB) {
                echo "$stmt\n";
            }
            $hc = mysqli_num_rows($rslt);
            if ($hc > 0) {
                $row=mysqli_fetch_row($rslt);
                $hopper_count = $row[0];
            }
            if ($hopper_count > 0) {
                $check_status='REJECT';
                $reject_reason='Lead already in hopper';
            }
            $vacq_call_count=0;
            $stmt = "SELECT count(*) FROM vicidial_abandon_check_queue where call_id='$pass';";
            $rslt=mysql_to_mysqli($stmt, $link);
            if ($DB) {
                echo "$stmt\n";
            }
            $hc = mysqli_num_rows($rslt);
            if ($hc > 0) {
                $row=mysqli_fetch_row($rslt);
                $vacq_call_count = $row[0];
            }
            if ($vacq_call_count > 0) {
                $check_status='REJECT';
                $reject_reason='Call already in abandon queue';
            }
            $vacq_count=0;
            $stmt = "SELECT count(*) FROM vicidial_abandon_check_queue where lead_id='$lead_id' and check_status IN('NEW','QUEUE','PROCESSING') and abandon_time > \"$four_hours_ago\";";
            $rslt=mysql_to_mysqli($stmt, $link);
            if ($DB) {
                echo "$stmt\n";
            }
            $hc = mysqli_num_rows($rslt);
            if ($hc > 0) {
                $row=mysqli_fetch_row($rslt);
                $vacq_count = $row[0];
            }
            if ($vacq_count > 0) {
                $check_status='REJECT';
                $reject_reason='Lead already active in abandon queue';
            }
            $stmt="INSERT INTO vicidial_abandon_check_queue SET lead_id='$lead_id',phone_number='$phone_number',call_id='$pass',abandon_time=NOW(),dispo='$dispo',check_status='$check_status',reject_reason='$reject_reason',source='$source';";
            if ($DB) {
                echo "$stmt\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
            $affected_rows = mysqli_affected_rows($link);
            $SQL_log = "$stmt|$affected_rows|";
            $SQL_log = preg_replace('/;/', '', $SQL_log);
            $SQL_log = addslashes($SQL_log);
            $stmt="INSERT INTO vicidial_api_log set user='$user',agent_user='$user',function='abandon_check_queue',value='$lead_id',result='$affected_rows',result_reason='$check_status',source='vdc',data='$SQL_log',api_date='$NOW_TIME',api_script='$api_script';";
            $rslt=mysql_to_mysqli($stmt, $link);
            $MESSAGE = _QXZ("DONE: %1s match found, %2s update to lead %3s", 0, '', $search_count, $affected_rows, $lead_id);
            echo "$MESSAGE\n";
        } else {
            $MESSAGE = _QXZ("DONE: no match found for lead %1s", 0, '', $lead_id);
            echo "$MESSAGE\n";
        }
    } else {
        $MESSAGE = _QXZ("DONE: lead %1s is not populated", 0, '', $lead_id);
        echo "$MESSAGE\n";
    }
}
if ($log_to_file > 0) {
    $fp = fopen("./abandon_check_queue.txt", "w");
    fwrite($fp, "$NOW_TIME|\n");
    fclose($fp);
}
