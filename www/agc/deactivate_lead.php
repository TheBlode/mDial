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
$api_script = 'deactivate';
$php_script = 'deactivate_lead.php';
require_once("dbconnect_mysqli.php");
require_once("functions.php");
$filedate = date("Ymd");
$filetime = date("H:i:s");
$IP = getenv ("REMOTE_ADDR");
$BR = getenv ("HTTP_USER_AGENT");
$PHP_AUTH_USER=$_SERVER['PHP_AUTH_USER'];
$PHP_AUTH_PW=$_SERVER['PHP_AUTH_PW'];
if (isset($_GET["lead_id"]))                {$lead_id=$_GET["lead_id"];}
    elseif (isset($_POST["lead_id"]))        {$lead_id=$_POST["lead_id"];}
if (isset($_GET["search_field"]))            {$search_field=$_GET["search_field"];}
    elseif (isset($_POST["search_field"]))    {$search_field=$_POST["search_field"];}
if (isset($_GET["campaign_check"]))                {$campaign_check=$_GET["campaign_check"];}
    elseif (isset($_POST["campaign_check"]))    {$campaign_check=$_POST["campaign_check"];}
if (isset($_GET["sale_status"]))            {$sale_status=$_GET["sale_status"];}
    elseif (isset($_POST["sale_status"]))    {$sale_status=$_POST["sale_status"];}
if (isset($_GET["dispo"]))                    {$dispo=$_GET["dispo"];}
    elseif (isset($_POST["dispo"]))            {$dispo=$_POST["dispo"];}
if (isset($_GET["new_status"]))                {$new_status=$_GET["new_status"];}
    elseif (isset($_POST["new_status"]))    {$new_status=$_POST["new_status"];}
if (isset($_GET["user"]))                    {$user=$_GET["user"];}
    elseif (isset($_POST["user"]))            {$user=$_POST["user"];}
if (isset($_GET["pass"]))                    {$pass=$_GET["pass"];}
    elseif (isset($_POST["pass"]))            {$pass=$_POST["pass"];}
if (isset($_GET["DB"]))                        {$DB=$_GET["DB"];}
    elseif (isset($_POST["DB"]))            {$DB=$_POST["DB"];}
if (isset($_GET["log_to_file"]))            {$log_to_file=$_GET["log_to_file"];}
    elseif (isset($_POST["log_to_file"]))    {$log_to_file=$_POST["log_to_file"];}
$DB=preg_replace("/[^0-9a-zA-Z]/","",$DB);
$US = '_';
$TD = '---';
$STARTtime = date("U");
$NOW_TIME = date("Y-m-d H:i:s");
$sale_status = "$TD$sale_status$TD";
$search_value='';
$user = preg_replace("/\'|\"|\\\\|;| /","",$user);
$pass = preg_replace("/\'|\"|\\\\|;| /","",$pass);
if (file_exists('options.php'))
    {
    require_once('options.php');
    }
header ("Content-type: text/html; charset=utf-8");
$stmt = "SELECT use_non_latin,enable_languages,language_method,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
    if ($mel > 0) {mysql_error_logging($NOW_TIME,$link,$mel,$stmt,'02001',$user,$server_ip,$session_name,$one_mysql_log);}
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                $row[0];
    $SSenable_languages =        $row[1];
    $SSlanguage_method =        $row[2];
    $SSallow_web_debug =        $row[3];
    }
if ($SSallow_web_debug < 1) {$DB=0;}
$VUselected_language = '';
$stmt="SELECT selected_language from vicidial_users where user='$user';";
if ($DB) {echo "|$stmt|\n";}
$rslt=mysql_to_mysqli($stmt, $link);
    if ($mel > 0) {mysql_error_logging($NOW_TIME,$link,$mel,$stmt,'00XXX',$user,$server_ip,$session_name,$one_mysql_log);}
$sl_ct = mysqli_num_rows($rslt);
if ($sl_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $VUselected_language =        $row[0];
    }
$search_field = preg_replace("/\'|\"|\\\\|;| /","",$search_field);
$lead_id = preg_replace('/[^0-9]/','',$lead_id);
$log_to_file = preg_replace('/[^-_0-9a-zA-Z]/', '', $log_to_file);
if ($non_latin < 1)
    {
    $user=preg_replace("/[^-_0-9a-zA-Z]/","",$user);
    $pass=preg_replace("/[^-\.\+\/\=_0-9a-zA-Z]/","",$pass);
    $campaign_check = preg_replace('/[^-_0-9a-zA-Z]/','',$campaign_check);
    $new_status = preg_replace('/[^-_0-9a-zA-Z]/','',$new_status);
    $sale_status = preg_replace('/[^-_0-9a-zA-Z]/', '', $sale_status);
    $dispo = preg_replace('/[^-_0-9a-zA-Z]/', '', $dispo);
    }
else
    {
    $user = preg_replace('/[^-_0-9\p{L}]/u','',$user);
    $pass = preg_replace('/[^-\.\+\/\=_0-9\p{L}]/u','',$pass);
    $campaign_check = preg_replace('/[^-_0-9\p{L}]/u','',$campaign_check);
    $new_status = preg_replace('/[^-_0-9\p{L}]/u','',$new_status);
    $sale_status = preg_replace('/[^-_0-9\p{L}]/u', '', $sale_status);
    $dispo = preg_replace('/[^-_0-9\p{L}]/u', '', $dispo);
    }
if ($DB>0) {echo "$lead_id|$search_field|$campaign_check|$sale_status|$dispo|$new_status|$user|$pass|$DB|$log_to_file|\n";}
if (preg_match("/$TD$dispo$TD/",$sale_status))
    {
    if ($non_latin < 1)
        {
        $user=preg_replace("/[^-_0-9a-zA-Z]/","",$user);
        }
    $auth=0;
    $auth_message = user_authorization($user,$pass,'',0,0,0,0,'deactivate_lead');
    if ($auth_message == 'GOOD')
        {$auth=1;}
    if( (strlen($user)<2) or (strlen($pass)<2) or ($auth==0))
        {
        echo _QXZ("Invalid Username/Password:")." |$user|$pass|$auth_message|\n";
        exit;
        }
    $stmt = "SELECT $search_field FROM vicidial_list where lead_id='$lead_id';";
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($DB) {echo "$stmt\n";}
    $sv_ct = mysqli_num_rows($rslt);
    if ($sv_ct > 0)
        {
        $row=mysqli_fetch_row($rslt);
        $search_value = $row[0];
        }
    if (strlen($search_value) > 0)
        {
        $stmt="select list_id from vicidial_lists where campaign_id='$campaign_check';";
        $rslt=mysql_to_mysqli($stmt, $link);
        $li_recs = mysqli_num_rows($rslt);
        if ($li_recs > 0)
            {
            $L=0;
            while ($li_recs > $L)
                {
                $row=mysqli_fetch_row($rslt);
                $duplicate_lists .=    "'$row[0]',";
                $L++;
                }
            $duplicate_lists = preg_replace('/,$/','',$duplicate_lists);
            if (strlen($duplicate_lists) < 2) {$duplicate_lists = "''";}
            }
        if (strlen($duplicate_lists) > 4)
            {
            $search_count=0;
            $stmt = "SELECT count(*) FROM vicidial_list where $search_field='$search_value' and list_id IN($duplicate_lists);";
            $rslt=mysql_to_mysqli($stmt, $link);
            if ($DB) {echo "$stmt\n";}
            $sc_ct = mysqli_num_rows($rslt);
            if ($sc_ct > 0)
                {
                $row=mysqli_fetch_row($rslt);
                $search_count = $row[0];
                }
            if ($search_count > 0)
                {
                $stmt="UPDATE vicidial_list SET status='$new_status' where $search_field='$search_value' and list_id IN($duplicate_lists) limit 100;";
                if ($DB) {echo "$stmt\n";}
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                $SQL_log = "$stmt|";
                $SQL_log = preg_replace('/;/','',$SQL_log);
                $SQL_log = addslashes($SQL_log);
                $stmt="INSERT INTO vicidial_api_log set user='$user',agent_user='$user',function='deactivate_lead',value='$lead_id',result='$affected_rows',result_reason='$search_field',source='vdc',data='$SQL_log',api_date='$NOW_TIME',api_script='$api_script';";
                $rslt=mysql_to_mysqli($stmt, $link);
                $MESSAGE = _QXZ("DONE: %1s duplicates found,",0,'',$search_count)." $affected_rows updated to $new_status from $dispo";
                echo "$MESSAGE\n";
                }
            else
                {
                $MESSAGE = _QXZ("DONE: no duplicates found within")." $campaign_check     |$duplicate_lists|";
                echo "$MESSAGE\n";
                }
            }
        else
            {
            $MESSAGE = _QXZ("DONE: no lists in campaign_check")." $campaign_check";
            echo "$MESSAGE\n";
            }
        }
    else
        {
        $MESSAGE = _QXZ("DONE: %1s is empty for lead %2s",0,'',$search_field,$lead_id);
        echo "$MESSAGE\n";
        }
    }
else
    {
    $MESSAGE = _QXZ("DONE: dispo is not a sale status:")." $dispo";
    echo "$MESSAGE\n";
    }
if ($log_to_file > 0)
    {
    $fp = fopen ("./deactivate_lead.txt", "w");
    fwrite ($fp, "$NOW_TIME|\n");
    fclose($fp);
    }
