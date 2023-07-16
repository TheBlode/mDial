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
$version = '2.14-17';
$build = '220220-0855';
$php_script = 'voicemail_check.php';
$SSagent_debug_logging=0;
$startMS = microtime();
require_once("dbconnect_mysqli.php");
require_once("functions.php");
if (isset($_GET["user"]))                    {$user=$_GET["user"];}
    elseif (isset($_POST["user"]))            {$user=$_POST["user"];}
if (isset($_GET["pass"]))                    {$pass=$_GET["pass"];}
    elseif (isset($_POST["pass"]))            {$pass=$_POST["pass"];}
if (isset($_GET["server_ip"]))                {$server_ip=$_GET["server_ip"];}
    elseif (isset($_POST["server_ip"]))        {$server_ip=$_POST["server_ip"];}
if (isset($_GET["session_name"]))            {$session_name=$_GET["session_name"];}
    elseif (isset($_POST["session_name"]))    {$session_name=$_POST["session_name"];}
if (isset($_GET["format"]))                    {$format=$_GET["format"];}
    elseif (isset($_POST["format"]))        {$format=$_POST["format"];}
if (isset($_GET["vmail_box"]))                {$vmail_box=$_GET["vmail_box"];}
    elseif (isset($_POST["vmail_box"]))        {$vmail_box=$_POST["vmail_box"];}
$user=preg_replace("/\'|\"|\\\\|;| /","",$user);
$pass=preg_replace("/\'|\"|\\\\|;| /","",$pass);
if (!isset($format))   {$format="text";}
$StarTtime = date("U");
$NOW_DATE = date("Y-m-d");
$NOW_TIME = date("Y-m-d H:i:s");
if (!isset($query_date)) {$query_date = $NOW_DATE;}
if (file_exists('options.php'))
    {
    require_once('options.php');
    }
$VUselected_language = '';
$stmt="SELECT selected_language from vicidial_users where user='$user';";
$rslt=mysql_to_mysqli($stmt, $link);
    if ($mel > 0) {mysql_error_logging($NOW_TIME,$link,$mel,$stmt,'00XXX',$user,$server_ip,$session_name,$one_mysql_log);}
$sl_ct = mysqli_num_rows($rslt);
if ($sl_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $VUselected_language =        $row[0];
    }
$stmt = "SELECT use_non_latin,enable_languages,language_method,agent_debug_logging,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
    if ($mel > 0) {mysql_error_logging($NOW_TIME,$link,$mel,$stmt,'00XXX',$user,$server_ip,$session_name,$one_mysql_log);}
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
if ($SSallow_web_debug < 1) {$DB=0;}
$session_name = preg_replace('/[^-\.\:\_0-9a-zA-Z]/','',$session_name);
$server_ip = preg_replace('/[^-\.\:\_0-9a-zA-Z]/','',$server_ip);
$vmail_box = preg_replace('/[^-_0-9\p{L}]/u',"",$vmail_box);
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
$auth=0;
$auth_message = user_authorization($user,$pass,'',0,1,0,0,'voicemail_check');
if ($auth_message == 'GOOD')
    {$auth=1;}
if (strlen($SSagent_debug_logging) > 1)
    {
    if ($SSagent_debug_logging == "$user")
        {$SSagent_debug_logging=1;}
    else
        {$SSagent_debug_logging=0;}
    }
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
    echo "<!-- VERSION: $version     BUILD: $build    VMBOX: $vmail_box   server_ip: $server_ip-->\n";
    echo "<title>"._QXZ("Voicemail Check");
    echo "</title>\n";
    echo "</head>\n";
    echo "<BODY BGCOLOR=white marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>\n";
    }
$MT[0]='';
$row='';   $rowx='';
if (strlen($vmail_box)<1)
    {
    $channel_live=0;
    echo _QXZ("voicemail box %1s is not valid",0,'',$vmail_box)."\n";
    exit;
    }
else
    {
    $stmt="SELECT messages,old_messages FROM phones where server_ip='$server_ip' and voicemail_id='$vmail_box' limit 1;";
        if ($format=='debug') {echo "\n<!-- $stmt -->";}
    $rslt=mysql_to_mysqli($stmt, $link);
    $vmails_list = mysqli_num_rows($rslt);
    $loop_count=0;
        while ($vmails_list>$loop_count)
        {
        $loop_count++;
        $row=mysqli_fetch_row($rslt);
        echo "$row[0]|$row[1]";
        if ($format=='debug') {echo "\n<!-- $row[0]     $row[1] -->";}
        }
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
