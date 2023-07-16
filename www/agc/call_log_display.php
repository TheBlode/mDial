#!/usr/bin/perl
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
<?php
$version = '2.14-24';
$build = '220220-0920';
$php_script = 'call_log_display.php';
$SSagent_debug_logging=0;
$startMS = microtime();
require_once("dbconnect_mysqli.php");
require_once("functions.php");
if (isset($_GET["user"]))                {$user=$_GET["user"];}
    elseif (isset($_POST["user"]))        {$user=$_POST["user"];}
if (isset($_GET["pass"]))                {$pass=$_GET["pass"];}
    elseif (isset($_POST["pass"]))        {$pass=$_POST["pass"];}
if (isset($_GET["server_ip"]))                {$server_ip=$_GET["server_ip"];}
    elseif (isset($_POST["server_ip"]))        {$server_ip=$_POST["server_ip"];}
if (isset($_GET["session_name"]))            {$session_name=$_GET["session_name"];}
    elseif (isset($_POST["session_name"]))    {$session_name=$_POST["session_name"];}
if (isset($_GET["format"]))                {$format=$_GET["format"];}
    elseif (isset($_POST["format"]))    {$format=$_POST["format"];}
if (isset($_GET["exten"]))                {$exten=$_GET["exten"];}
    elseif (isset($_POST["exten"]))        {$exten=$_POST["exten"];}
if (isset($_GET["protocol"]))            {$protocol=$_GET["protocol"];}
    elseif (isset($_POST["protocol"]))    {$protocol=$_POST["protocol"];}
$user=preg_replace("/\'|\"|\\\\|;| /","",$user);
$pass=preg_replace("/\'|\"|\\\\|;| /","",$pass);
if (!isset($format))   {$format="text";}
if (!isset($in_limit))   {$in_limit="100";}
if (!isset($out_limit))   {$out_limit="100";}
$number_dialed = 'number_dialed';
$StarTtime = date("U");
$NOW_DATE = date("Y-m-d");
$NOW_TIME = date("Y-m-d H:i:s");
if (!isset($query_date)) {$query_date = $NOW_DATE;}
if (file_exists('options.php'))
    {
    require_once('options.php');
    }
$stmt = "SELECT use_non_latin,enable_languages,language_method,agent_debug_logging,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
    if ($mel > 0) {mysql_error_logging($NOW_TIME,$link,$mel,$stmt,'03001',$user,$server_ip,$session_name,$one_mysql_log);}
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                $row[0];
    $SSenable_languages =        $row[1];
    $SSlanguage_method =        $row[2];
    $SSagent_debug_logging =    $row[3];
    $SSallow_web_debug =        $row[4];
    }
if ($SSallow_web_debug < 1) {$DB=0;   $format="text";}
$VUselected_language = '';
$stmt="SELECT selected_language from vicidial_users where user='$user';";
if ($DB) {echo "|$stmt|\n";}
$rslt=mysql_to_mysqli($stmt, $link);
    if ($mel > 0) {mysql_error_logging($NOW_TIME,$link,$mel,$stmt,'00XXX',$VD_login,$server_ip,$session_name,$one_mysql_log);}
$sl_ct = mysqli_num_rows($rslt);
if ($sl_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $VUselected_language =        $row[0];
    }
$session_name = preg_replace('/[^-\.\:\_0-9a-zA-Z]/','',$session_name);
$server_ip = preg_replace('/[^-\.\:\_0-9a-zA-Z]/','',$server_ip);
$exten = preg_replace("/\||`|&|\'|\"|\\\\|;| /","",$exten);
$protocol = preg_replace("/\||`|&|\'|\"|\\\\|;| /","",$protocol);
$in_limit = preg_replace('/[^0-9]/','',$in_limit);
$out_limit = preg_replace('/[^0-9]/','',$out_limit);
$format = preg_replace('/[^-_0-9a-zA-Z]/','',$format);
if ($non_latin < 1)
    {
    $user=preg_replace("/[^-_0-9a-zA-Z]/","",$user);
    $pass=preg_replace("/[^-\.\+\/\=_0-9a-zA-Z]/","",$pass);
    }
else
    {
    $user = preg_replace('/[^-_0-9\p{L}]/u','',$user);
    $pass = preg_replace('/[^-\.\+\/\=_0-9\p{L}]/u','',$pass);
    }
if (strlen($SSagent_debug_logging) > 1)
    {
    if ($SSagent_debug_logging == "$user")
        {$SSagent_debug_logging=1;}
    else
        {$SSagent_debug_logging=0;}
    }
$auth=0;
$auth_message = user_authorization($user,$pass,'',0,1,0,0,'call_log_display');
if ($auth_message == 'GOOD')
    {$auth=1;}
if( (strlen($user)<2) or (strlen($pass)<2) or ($auth==0))
    {
    echo _QXZ("Invalid Username/Password:")." |$user|$pass|$auth_message|\n";
    exit;
    }
else
    {
    if( (strlen($server_ip)<6) or (!isset($server_ip)) or ( (strlen($session_name)<12) or (!isset($session_name)) ) )
        {
        echo _QXZ("Invalid server_ip: %1s or Invalid session_name: %2s",0,'',$server_ip,$session_name)."\n";
        exit;
        }
    else
        {
        $stmt="SELECT count(*) from web_client_sessions where session_name='$session_name' and server_ip='$server_ip';";
        if ($DB) {echo "|$stmt|\n";}
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        $SNauth=$row[0];
        if($SNauth==0)
            {
            echo _QXZ("Invalid session_name:")." |$session_name|$server_ip|\n";
            exit;
            }
        else
            {
            }
        }
    }
if ($format=='debug')
    {
    echo "<html>\n";
    echo "<head>\n";
    echo "<!-- VERSION: $version     BUILD: $build    EXTEN: $exten   server_ip: $server_ip-->\n";
    echo "<title>".QXZ("Call Log Display");
    echo "</title>\n";
    echo "</head>\n";
    echo "<BODY BGCOLOR=white marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>\n";
    }
    $row='';   $rowx='';
    $channel_live=1;
if ( (strlen($exten)<1) or (strlen($protocol)<3) )
    {
    $channel_live=0;
    echo _QXZ("Exten %1s is not valid or protocol %2s is not valid",0,'',$exten,$protocol)."\n";
    exit;
    }
else
    {
    $stmt="SELECT uniqueid,start_time,$number_dialed,length_in_sec FROM call_log where server_ip = '$server_ip' and channel LIKE \"$protocol/$exten%\" order by start_time desc limit $out_limit;";
        if ($format=='debug') {echo "\n<!-- $stmt -->";}
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($rslt) {$out_calls_count = mysqli_num_rows($rslt);}
    echo "$out_calls_count|";
    $loop_count=0;
    while ($out_calls_count>$loop_count)
        {
        $loop_count++;
        $row=mysqli_fetch_row($rslt);
        $call_time_M = ($row[3] / 60);
        $call_time_M = round($call_time_M, 2);
        $call_time_M_int = intval("$call_time_M");
        $call_time_SEC = ($call_time_M - $call_time_M_int);
        $call_time_SEC = ($call_time_SEC * 60);
        $call_time_SEC = round($call_time_SEC, 0);
        if ($call_time_SEC < 10) {$call_time_SEC = "0$call_time_SEC";}
        $call_time_MS = "$call_time_M_int:$call_time_SEC";
        if ($number_dialed == 'extension') {$row[2] = substr($row[2],-10);}
        echo "$row[0] ~$row[1] ~$row[2] ~$call_time_MS|";
        }
    echo "\n";
    $stmt="SELECT call_log.uniqueid,live_inbound_log.start_time,live_inbound_log.extension,caller_id,length_in_sec from live_inbound_log,call_log where phone_ext='$exten' and live_inbound_log.server_ip = '$server_ip' and call_log.uniqueid=live_inbound_log.uniqueid order by start_time desc limit $in_limit;";
        if ($format=='debug') {echo "\n<!-- $stmt -->";}
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($rslt) {$in_calls_count = mysqli_num_rows($rslt);}
    echo "$in_calls_count|";
    $loop_count=0;
    while ($in_calls_count>$loop_count)
        {
        $loop_count++;
        $row=mysqli_fetch_row($rslt);
        $call_time_M = ($row[4] / 60);
        $call_time_M = round($call_time_M, 2);
        $call_time_M_int = intval("$call_time_M");
        $call_time_SEC = ($call_time_M - $call_time_M_int);
        $call_time_SEC = ($call_time_SEC * 60);
        $call_time_SEC = round($call_time_SEC, 0);
        if ($call_time_SEC < 10) {$call_time_SEC = "0$call_time_SEC";}
        $call_time_MS = "$call_time_M_int:$call_time_SEC";
        $callerIDnum = $row[3];   $callerIDname = $row[3];
        $callerIDnum = preg_replace("/.*<|>.*/","",$callerIDnum);
        $callerIDname = preg_replace("/\"| <\d*>/","",$callerIDname);
        echo "$row[0] ~$row[1] ~$row[2] ~$callerIDnum ~$callerIDname ~$call_time_MS|";
        }
    echo "\n";
    }
if ($format=='debug') 
    {
    $ENDtime = date("U");
    $RUNtime = ($ENDtime - $StarTtime);
    echo "\n<!-- script runtime: $RUNtime seconds -->";
    echo "\n</body>\n</html>\n";
    }
if ($SSagent_debug_logging > 0) {vicidial_ajax_log($NOW_TIME,$startMS,$link,$ACTION,$php_script,$user,$stage,$lead_id,$session_name,$stmt);}
exit; 
?>
