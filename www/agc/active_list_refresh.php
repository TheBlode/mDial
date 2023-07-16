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
$version = '0.0.21';
$build = '220220-0922';
$php_script = 'active_list_refresh.php';
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
if (isset($_GET["ADD"]))                    {$ADD=$_GET["ADD"];}
    elseif (isset($_POST["ADD"]))            {$ADD=$_POST["ADD"];}
if (isset($_GET["order"]))                    {$order=$_GET["order"];}
    elseif (isset($_POST["order"]))            {$order=$_POST["order"];}
if (isset($_GET["bgcolor"]))                {$bgcolor=$_GET["bgcolor"];}
    elseif (isset($_POST["bgcolor"]))        {$bgcolor=$_POST["bgcolor"];}
if (isset($_GET["txtcolor"]))                {$txtcolor=$_GET["txtcolor"];}
    elseif (isset($_POST["txtcolor"]))        {$txtcolor=$_POST["txtcolor"];}
if (isset($_GET["txtsize"]))                {$txtsize=$_GET["txtsize"];}
    elseif (isset($_POST["txtsize"]))        {$txtsize=$_POST["txtsize"];}
if (isset($_GET["selectsize"]))                {$selectsize=$_GET["selectsize"];}
    elseif (isset($_POST["selectsize"]))    {$selectsize=$_POST["selectsize"];}
if (isset($_GET["selectfontsize"]))                {$selectfontsize=$_GET["selectfontsize"];}
    elseif (isset($_POST["selectfontsize"]))    {$selectfontsize=$_POST["selectfontsize"];}
if (isset($_GET["selectedext"]))            {$selectedext=$_GET["selectedext"];}
    elseif (isset($_POST["selectedext"]))    {$selectedext=$_POST["selectedext"];}
if (isset($_GET["selectedtrunk"]))            {$selectedtrunk=$_GET["selectedtrunk"];}
    elseif (isset($_POST["selectedtrunk"]))    {$selectedtrunk=$_POST["selectedtrunk"];}
if (isset($_GET["selectedlocal"]))            {$selectedlocal=$_GET["selectedlocal"];}
    elseif (isset($_POST["selectedlocal"]))    {$selectedlocal=$_POST["selectedlocal"];}
if (isset($_GET["textareaheight"]))                {$textareaheight=$_GET["textareaheight"];}
    elseif (isset($_POST["textareaheight"]))    {$textareaheight=$_POST["textareaheight"];}
if (isset($_GET["textareawidth"]))            {$textareawidth=$_GET["textareawidth"];}
    elseif (isset($_POST["textareawidth"]))    {$textareawidth=$_POST["textareawidth"];}
if (isset($_GET["field_name"]))                {$field_name=$_GET["field_name"];}
    elseif (isset($_POST["field_name"]))    {$field_name=$_POST["field_name"];}
$user=preg_replace("/\'|\"|\\\\|;| /","",$user);
$pass=preg_replace("/\'|\"|\\\\|;| /","",$pass);
if (!isset($ADD))                {$ADD="1";}
if (!isset($order))                {$order='desc';}
if (!isset($format))            {$format="text";}
if (!isset($bgcolor))            {$bgcolor='white';}
if (!isset($txtcolor))            {$txtcolor='black';}
if (!isset($txtsize))            {$txtsize='2';}
if (!isset($selectsize))        {$selectsize='4';}
if (!isset($selectfontsize))    {$selectfontsize='10';}
if (!isset($textareaheight))    {$textareaheight='10';}
if (!isset($textareawidth))        {$textareawidth='20';}
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
if ($SSallow_web_debug < 1) {$DB=0;   $format="text";}
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
$ADD=preg_replace("/[^0-9]/","",$ADD);
$order=preg_replace("/[^0-9a-zA-Z]/","",$order);
$format=preg_replace("/[^0-9a-zA-Z]/","",$format);
$bgcolor=preg_replace("/[^\#0-9a-zA-Z]/","",$bgcolor);
$txtcolor=preg_replace("/[^\#0-9a-zA-Z]/","",$txtcolor);
$txtsize=preg_replace("/[^0-9a-zA-Z]/","",$txtsize);
$selectsize=preg_replace("/[^0-9a-zA-Z]/","",$selectsize);
$selectfontsize=preg_replace("/[^0-9a-zA-Z]/","",$selectfontsize);
$selectedext=preg_replace("/[^ \#\*\:\/\@\.\-\_0-9a-zA-Z]/","",$selectedext);
$selectedtrunk=preg_replace("/[^ \#\*\:\/\@\.\-\_0-9a-zA-Z]/","",$selectedtrunk);
$selectedlocal=preg_replace("/[^ \#\*\:\/\@\.\-\_0-9a-zA-Z]/","",$selectedlocal);
$textareaheight=preg_replace("/[^0-9a-zA-Z]/","",$textareaheight);
$textareawidth=preg_replace("/[^0-9a-zA-Z]/","",$textareawidth);
$field_name=preg_replace("/[^ \#\*\:\/\@\.\-\_0-9a-zA-Z]/","",$field_name);
$session_name = preg_replace('/[^-\.\:\_0-9a-zA-Z]/','',$session_name);
$server_ip = preg_replace('/[^-\.\:\_0-9a-zA-Z]/','',$server_ip);
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
$auth_message = user_authorization($user,$pass,'',0,1,0,0,'active_list_refresh');
if ($auth_message == 'GOOD')
    {$auth=1;}
if( (strlen($user)<2) or (strlen($pass)<2) or ($auth==0))
    {
    echo _QXZ("Invalid Username/Password").": |$user|$pass|$auth_message|\n";
    exit;
    }
else
    {
    if( (strlen($server_ip)<6) or (!isset($server_ip)) or ( (strlen($session_name)<12) or (!isset($session_name)) ) )
        {
        echo _QXZ("Invalid server_ip").": |$server_ip|  or  Invalid session_name: |$session_name|\n"; #underscore
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
            echo _QXZ("Invalid session_name").": |$session_name|$server_ip|\n"; #underscore
            exit;
            }
        else
            {
            }
        }
    }
if ($format=='table')
    {
    echo "<html>\n";
    echo "<head>\n";
    echo "<!-- VERSION: $version     BUILD: $build    ADD: $ADD   server_ip: $server_ip-->\n";
    echo "<title>List Display: ";
    if ($ADD==1)        {echo _QXZ("Live Extensions");}
    if ($ADD==2)        {echo _QXZ("Busy Extensions");}
    if ($ADD==3)        {echo _QXZ("Outside Lines");}
    if ($ADD==4)        {echo _QXZ("Local Extensions");}
    if ($ADD==5)        {echo _QXZ("Conferences");}
    if ($ADD==99999)    {echo _QXZ("HELP");}
    echo "</title>\n";
    echo "</head>\n";
    echo "<BODY BGCOLOR=white marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>\n";
    }
if ($ADD==1)
    {
    $pt='pt';
    if (!$field_name) {$field_name = 'extension';}
    if ($format=='table') {echo "<TABLE WIDTH=120 BGCOLOR=$bgcolor cellpadding=0 cellspacing=0>\n";}
    if ($format=='menu') {echo "<SELECT SIZE=1 name=\"$field_name\">\n";}
    if ($format=='selectlist') 
        {
        echo "<SELECT SIZE=$selectsize name=\"$field_name\" STYLE=\"font-family : sans-serif; font-size : $selectfontsize$pt\">\n";
        }
    if ($format=='textarea') 
        {
        echo "<TEXTAREA ROWS=$textareaheight COLS=$textareawidth NAME=extension WRAP=off STYLE=\"font-family : sans-serif; font-size : $selectfontsize$pt\">";
        }
    $stmt="SELECT extension,fullname FROM phones where server_ip = '$server_ip' order by extension $order";
        if ($format=='table') {echo "\n<!-- $stmt -->";}
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($rslt) {$phones_to_print = mysqli_num_rows($rslt);}
    $o=0;
    while ($phones_to_print > $o) 
        {
        $row=mysqli_fetch_row($rslt);
        if ($format=='table')
            {
            echo "<TR><TD ALIGN=LEFT NOWRAP><FONT FACE=\"ARIAL,HELVETICA\" COLOR=$txtcolor SIZE=$txtsize>";
            echo "$row[0] - $row[1]";
            echo "</TD></TR>\n";
            }
        if ( ($format=='text') or ($format=='textarea') )
            {
            echo "$row[0] - $row[1]\n";
            }
        if ( ($format=='menu') or ($format=='selectlist') )
            {
            echo "<OPTION ";
            if ($row[0]=="$selectedext") {echo "SELECTED ";}
            echo "VALUE=\"$row[0]\">";
            echo "$row[0] - $row[1]";
            echo "</OPTION>\n";
            }
        $o++;
        }
    if ($format=='table') {echo "</TABLE>\n";}
    if ($format=='menu') {echo "</SELECT>\n";}
    if ($format=='selectlist') {echo "</SELECT>\n";}
    if ($format=='textarea') {echo "</TEXTAREA>\n";}
    }
if ($ADD==2)
    {
    if (!$field_name) {$field_name = 'busyext';}
    if ($format=='table') {echo "<TABLE WIDTH=120 BGCOLOR=$bgcolor cellpadding=0 cellspacing=0>\n";}
    if ($format=='menu') {echo "<SELECT SIZE=1 name=\"$field_name\">\n";}
    if ($format=='selectlist') 
        {
        echo "<SELECT SIZE=$selectsize name=\"$field_name\" STYLE=\"font-family : sans-serif; font-size : $selectfontsize$pt\">\n";
        }
    if ($format=='textarea') 
        {
        echo "<TEXTAREA ROWS=$textareaheight COLS=$textareawidth NAME=extension WRAP=off STYLE=\"font-family : sans-serif; font-size : $selectfontsize$pt\">";
        }
    $stmt="SELECT extension FROM live_channels where server_ip = '$server_ip' order by extension $order";
        if ($format=='table') {echo "\n<!-- $stmt -->";}
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($rslt) {$busys_to_print = mysqli_num_rows($rslt);}
    $o=0;
    while ($busys_to_print > $o) 
        {
        $row=mysqli_fetch_row($rslt);
        if ($format=='table')
            {
            echo "<TR><TD ALIGN=LEFT NOWRAP><FONT FACE=\"ARIAL,HELVETICA\" COLOR=$txtcolor SIZE=$txtsize>";
            echo "$row[0]";
            echo "</TD></TR>\n";
            }
        if ( ($format=='text') or ($format=='textarea') )
            {
            echo "$row[0]\n";
            }
        if ( ($format=='menu') or ($format=='selectlist') )
            {
            echo "<OPTION ";
            if ($row[0]=="$selectedext") {echo "SELECTED ";}
            echo "VALUE=\"$row[0]\">";
            echo "$row[0]";
            echo "</OPTION>\n";
            }
        $o++;
        }
    if ($format=='table') {echo "</TABLE>\n";}
    if ($format=='menu') {echo "</SELECT>\n";}
    if ($format=='selectlist') {echo "</SELECT>\n";}
    if ($format=='textarea') {echo "</TEXTAREA>\n";}
    }
if ($ADD==3)
    {
    if (!$field_name) {$field_name = 'trunk';}
    if ($format=='table') {echo "<TABLE WIDTH=120 BGCOLOR=$bgcolor cellpadding=0 cellspacing=0>\n";}
    if ($format=='menu') {echo "<SELECT SIZE=1 name=\"$field_name\">\n";}
    if ($format=='selectlist') 
        {
        echo "<SELECT SIZE=$selectsize name=\"$field_name\" STYLE=\"font-family : sans-serif; font-size : $selectfontsize$pt\">\n";
        }
    if ($format=='textarea') 
        {
        echo "<TEXTAREA ROWS=$textareaheight COLS=$textareawidth NAME=extension WRAP=off STYLE=\"font-family : sans-serif; font-size : $selectfontsize$pt\">";
        }
    $stmt="SELECT channel, extension FROM live_channels where server_ip = '$server_ip' order by channel $order";
        if ($format=='table') {echo "\n<!-- $stmt -->";}
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($rslt) {$busys_to_print = mysqli_num_rows($rslt);}
    $o=0;
    while ($busys_to_print > $o) 
        {
        $row=mysqli_fetch_row($rslt);
        if ($format=='table')
            {
            echo "<TR><TD ALIGN=LEFT NOWRAP><FONT FACE=\"ARIAL,HELVETICA\" COLOR=$txtcolor SIZE=$txtsize>";
            echo "$row[0] - $row[1]";
            echo "</TD></TR>\n";
            }
        if ( ($format=='text') or ($format=='textarea') )
            {
            echo "$row[0] - $row[1]\n";
            }
        if ( ($format=='menu') or ($format=='selectlist') )
            {
            echo "<OPTION ";
            if ($row[0]=="$selectedtrunk") {echo "SELECTED ";}
            echo "VALUE=\"$row[0]\">";
            echo "$row[0] - $row[1]";
            echo "</OPTION>\n";
            }
        $o++;
        }
    if ($format=='table') {echo "</TABLE>\n";}
    if ($format=='menu') {echo "</SELECT>\n";}
    if ($format=='selectlist') {echo "</SELECT>\n";}
    if ($format=='textarea') {echo "</TEXTAREA>\n";}
    }
if ($ADD==4)
    {
    if (!$field_name) {$field_name = 'local';}
    if ($format=='table') {echo "<TABLE WIDTH=120 BGCOLOR=$bgcolor cellpadding=0 cellspacing=0>\n";}
    if ($format=='menu') {echo "<SELECT SIZE=1 name=\"$field_name\">\n";}
    if ($format=='selectlist') 
        {
        echo "<SELECT SIZE=$selectsize name=\"$field_name\" STYLE=\"font-family : sans-serif; font-size : $selectfontsize$pt\">\n";
        }
    if ($format=='textarea') 
        {
        echo "<TEXTAREA ROWS=$textareaheight COLS=$textareawidth NAME=extension WRAP=off STYLE=\"font-family : sans-serif; font-size : $selectfontsize$pt\">";
        }
    $stmt="SELECT channel, extension FROM live_sip_channels where server_ip = '$server_ip' order by channel $order";
        if ($format=='table') {echo "\n<!-- $stmt -->";}
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($rslt) {$busys_to_print = mysqli_num_rows($rslt);}
    $o=0;
    while ($busys_to_print > $o) 
        {
        $row=mysqli_fetch_row($rslt);
        if ($format=='table')
            {
            echo "<TR><TD ALIGN=LEFT NOWRAP><FONT FACE=\"ARIAL,HELVETICA\" COLOR=$txtcolor SIZE=$txtsize>";
            echo "$row[0] - $row[1]";
            echo "</TD></TR>\n";
            }
        if ( ($format=='text') or ($format=='textarea') )
            {
            echo "$row[0] - $row[1]\n";
            }
        if ( ($format=='menu') or ($format=='selectlist') )
            {
            echo "<OPTION ";
            if ($row[0]=="$selectedlocal") {echo "SELECTED ";}
            echo "VALUE=\"$row[0]\">";
            echo "$row[0] - $row[1]";
            echo "</OPTION>\n";
            }
        $o++;
        }
    if ($format=='table') {echo "</TABLE>\n";}
    if ($format=='menu') {echo "</SELECT>\n";}
    if ($format=='selectlist') {echo "</SELECT>\n";}
    if ($format=='textarea') {echo "</TEXTAREA>\n";}
    }
if ($ADD==5)
    {
    $pt='pt';
    if (!$field_name) {$field_name = 'conferences';}
    if ($format=='table') {echo "<TABLE WIDTH=120 BGCOLOR=$bgcolor cellpadding=0 cellspacing=0>\n";}
    if ($format=='menu') {echo "<SELECT SIZE=1 name=\"$field_name\">\n";}
    if ($format=='selectlist') 
        {
        echo "<SELECT SIZE=$selectsize name=\"$field_name\" STYLE=\"font-family : sans-serif; font-size : $selectfontsize$pt\">\n";
        }
    if ($format=='textarea') 
        {
        echo "<TEXTAREA ROWS=$textareaheight COLS=$textareawidth NAME=extension WRAP=off STYLE=\"font-family : sans-serif; font-size : $selectfontsize$pt\">";
        }
    $stmt="SELECT conf_exten,extension FROM conferences where server_ip = '$server_ip' order by conf_exten $order";
        if ($format=='table') {echo "\n<!-- $stmt -->";}
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($rslt) {$phones_to_print = mysqli_num_rows($rslt);}
    $o=0;
    while ($phones_to_print > $o) 
        {
        $row=mysqli_fetch_row($rslt);
        if ($format=='table')
            {
            echo "<TR><TD ALIGN=LEFT NOWRAP><FONT FACE=\"ARIAL,HELVETICA\" COLOR=$txtcolor SIZE=$txtsize>";
            echo "$row[0] - $row[1]";
            echo "</TD></TR>\n";
            }
        if ( ($format=='text') or ($format=='textarea') )
            {
            echo "$row[0] - $row[1]\n";
            }
        if ( ($format=='menu') or ($format=='selectlist') )
            {
            echo "<OPTION ";
            if ($row[0]=="$selectedext") {echo "SELECTED ";}
            echo "VALUE=\"$row[0]\">";
            echo "$row[0] - $row[1]";
            echo "</OPTION>\n";
            }
        $o++;
        }
    if ($format=='table') {echo "</TABLE>\n";}
    if ($format=='menu') {echo "</SELECT>\n";}
    if ($format=='selectlist') {echo "</SELECT>\n";}
    if ($format=='textarea') {echo "</TEXTAREA>\n";}
    }
$ENDtime = date("U");
$RUNtime = ($ENDtime - $StarTtime);
if ($format=='table') {echo "\n<!-- script runtime: $RUNtime seconds -->";}
if ($format=='table') {echo "\n</body>\n</html>\n";}
if ($SSagent_debug_logging > 0) {vicidial_ajax_log($NOW_TIME,$startMS,$link,$ACTION,$php_script,$user,$stage,$lead_id,$session_name,$stmt);}
exit; 
?>
