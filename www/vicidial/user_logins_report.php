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
$startMS = microtime();
$report_name='User Logins Report';
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
if (isset($_GET["user"])) {
    $user=$_GET["user"];
} elseif (isset($_POST["user"])) {
    $user=$_POST["user"];
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
$DB=preg_replace("/[^0-9a-zA-Z]/", "", $DB);
$NOW_DATE = date("Y-m-d");
$NOW_TIME = date("Y-m-d H:i:s");
$last_midnight = date("Y-m-d 00:00:00");
$STARTtime = date("U");
$stmt = "SELECT use_non_latin,webroot_writable,outbound_autodial_active,user_territories_active,enable_languages,language_method,allow_shared_dial,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                    $row[0];
    $webroot_writable =                $row[1];
    $SSoutbound_autodial_active =    $row[2];
    $user_territories_active =        $row[3];
    $SSenable_languages =            $row[4];
    $SSlanguage_method =            $row[5];
    $SSallow_shared_dial =            $row[6];
    $SSallow_web_debug =            $row[7];
}
if ($SSallow_web_debug < 1) {
    $DB=0;
}
$submit = preg_replace('/[^-_0-9a-zA-Z]/', '', $submit);
$SUBMIT = preg_replace('/[^-_0-9a-zA-Z]/', '', $SUBMIT);
if ($non_latin < 1) {
    $PHP_AUTH_USER = preg_replace('/[^-_0-9a-zA-Z]/', '', $PHP_AUTH_USER);
    $PHP_AUTH_PW = preg_replace('/[^-_0-9a-zA-Z]/', '', $PHP_AUTH_PW);
    $user = preg_replace('/[^-_0-9a-zA-Z]/', '', $user);
} else {
    $PHP_AUTH_USER = preg_replace('/[^-_0-9\p{L}]/u', '', $PHP_AUTH_USER);
    $PHP_AUTH_PW = preg_replace('/[^-_0-9\p{L}]/u', '', $PHP_AUTH_PW);
    $user = preg_replace('/[^-_0-9\p{L}]/u', '', $user);
}
$stmt="SELECT selected_language,user_group from vicidial_users where user='$PHP_AUTH_USER';";
if ($DB) {
    echo "|$stmt|\n";
}
$rslt=mysql_to_mysqli($stmt, $link);
$sl_ct = mysqli_num_rows($rslt);
if ($sl_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $VUselected_language =        $row[0];
    $LOGuser_group =            $row[1];
}
$auth=0;
$reports_auth=0;
$admin_auth=0;
$auth_message = user_authorization($PHP_AUTH_USER, $PHP_AUTH_PW, '', 1, 0);
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
        $VDdisplayMESSAGE = _QXZ("You are not allowed to view reports");
        Header("Content-type: text/html; charset=utf-8");
        echo "$VDdisplayMESSAGE: |$PHP_AUTH_USER|$auth_message|\n";
        exit;
    }
    if (($reports_auth > 0) and ($admin_auth < 1)) {
        $ADD=999999;
        $reports_only_user=1;
    }
} else {
    $VDdisplayMESSAGE = _QXZ("Login incorrect, please try again");
    if ($auth_message == 'LOCK') {
        $VDdisplayMESSAGE = _QXZ("Too many login attempts, try again in 15 minutes");
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
$stmt="SELECT modify_campaigns,user_group from vicidial_users where user='$PHP_AUTH_USER';";
$rslt=mysql_to_mysqli($stmt, $link);
$row=mysqli_fetch_row($rslt);
$LOGmodify_campaigns =    $row[0];
$LOGuser_group =        $row[1];
if ($LOGmodify_campaigns < 1) {
    Header("Content-type: text/html; charset=utf-8");
    echo _QXZ("You do not have permissions for campaign debugging").": |$PHP_AUTH_USER|\n";
    exit;
}
$stmt="SELECT allowed_campaigns,allowed_reports,admin_viewable_groups,admin_viewable_call_times from vicidial_user_groups where user_group='$LOGuser_group';";
if ($DB) {
    $HTML_text.="|$stmt|\n";
}
$rslt=mysql_to_mysqli($stmt, $link);
$row=mysqli_fetch_row($rslt);
$LOGallowed_campaigns =            $row[0];
$LOGallowed_reports =            $row[1];
$LOGadmin_viewable_groups =        $row[2];
$LOGadmin_viewable_call_times =    $row[3];
$LOGallowed_campaignsSQL='';
$whereLOGallowed_campaignsSQL='';
if ((!preg_match('/\-ALL/i', $LOGallowed_campaigns))) {
    $rawLOGallowed_campaignsSQL = preg_replace("/ -/", '', $LOGallowed_campaigns);
    $rawLOGallowed_campaignsSQL = preg_replace("/ /", "','", $rawLOGallowed_campaignsSQL);
    $LOGallowed_campaignsSQL = "and campaign_id IN('$rawLOGallowed_campaignsSQL')";
    $whereLOGallowed_campaignsSQL = "where campaign_id IN('$rawLOGallowed_campaignsSQL')";
}
$regexLOGallowed_campaigns = " $LOGallowed_campaigns ";
$admin_viewable_groupsALL=0;
$LOGadmin_viewable_groupsSQL='';
$whereLOGadmin_viewable_groupsSQL='';
$valLOGadmin_viewable_groupsSQL='';
$vmLOGadmin_viewable_groupsSQL='';
if ((!preg_match('/\-\-ALL\-\-/i', $LOGadmin_viewable_groups)) and (strlen($LOGadmin_viewable_groups) > 3)) {
    $rawLOGadmin_viewable_groupsSQL = preg_replace("/ -/", '', $LOGadmin_viewable_groups);
    $rawLOGadmin_viewable_groupsSQL = preg_replace("/ /", "','", $rawLOGadmin_viewable_groupsSQL);
    $LOGadmin_viewable_groupsSQL = "and user_group IN('---ALL---','$rawLOGadmin_viewable_groupsSQL')";
    $whereLOGadmin_viewable_groupsSQL = "where user_group IN('---ALL---','$rawLOGadmin_viewable_groupsSQL')";
    $valLOGadmin_viewable_groupsSQL = "and val.user_group IN('---ALL---','$rawLOGadmin_viewable_groupsSQL')";
    $vmLOGadmin_viewable_groupsSQL = "and vm.user_group IN('---ALL---','$rawLOGadmin_viewable_groupsSQL')";
} else {
    $admin_viewable_groupsALL=1;
}
$regexLOGadmin_viewable_groups = " $LOGadmin_viewable_groups ";
if ((!preg_match("/$report_name/", $LOGallowed_reports)) and (!preg_match("/ALL REPORTS/", $LOGallowed_reports))) {
    Header("WWW-Authenticate: Basic realm=\"CONTACT-CENTER-ADMIN\"");
    Header("HTTP/1.0 401 Unauthorized");
    echo "You are not allowed to view this report: |$PHP_AUTH_USER|$report_name|\n";
    exit;
}
$LOGip = getenv("REMOTE_ADDR");
$LOGbrowser = getenv("HTTP_USER_AGENT");
$LOGscript_name = getenv("SCRIPT_NAME");
$LOGserver_name = getenv("SERVER_NAME");
$LOGserver_port = getenv("SERVER_PORT");
$LOGrequest_uri = getenv("REQUEST_URI");
$LOGhttp_referer = getenv("HTTP_REFERER");
$LOGbrowser=preg_replace("/\'|\"|\\\\/", "", $LOGbrowser);
$LOGrequest_uri=preg_replace("/\'|\"|\\\\/", "", $LOGrequest_uri);
$LOGhttp_referer=preg_replace("/\'|\"|\\\\/", "", $LOGhttp_referer);
if (preg_match("/443/i", $LOGserver_port)) {
    $HTTPprotocol = 'https://';
} else {
    $HTTPprotocol = 'http://';
}
if (($LOGserver_port == '80') or ($LOGserver_port == '443')) {
    $LOGserver_port='';
} else {
    $LOGserver_port = ":$LOGserver_port";
}
$LOGfull_url = "$HTTPprotocol$LOGserver_name$LOGserver_port$LOGrequest_uri";
$LOGhostname = php_uname('n');
if (strlen($LOGhostname)<1) {
    $LOGhostname='X';
}
if (strlen($LOGserver_name)<1) {
    $LOGserver_name='X';
}
$stmt="SELECT webserver_id FROM vicidial_webservers where webserver='$LOGserver_name' and hostname='$LOGhostname' LIMIT 1;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($DB) {
    echo "$stmt\n";
}
$webserver_id_ct = mysqli_num_rows($rslt);
if ($webserver_id_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $webserver_id = $row[0];
} else {
    $stmt="INSERT INTO vicidial_webservers (webserver,hostname) values('$LOGserver_name','$LOGhostname');";
    if ($DB) {
        echo "$stmt\n";
    }
    $rslt=mysql_to_mysqli($stmt, $link);
    $affected_rows = mysqli_affected_rows($link);
    $webserver_id = mysqli_insert_id($link);
}
$stmt="INSERT INTO vicidial_report_log set event_date=NOW(), user='$PHP_AUTH_USER', ip_address='$LOGip', report_name='$report_name', browser='$LOGbrowser', referer='$LOGhttp_referer', notes='$LOGserver_name:$LOGserver_port $LOGscript_name', url='$LOGfull_url', webserver='$webserver_id';";
if ($DB) {
    echo "|$stmt|\n";
}
$rslt=mysql_to_mysqli($stmt, $link);
$report_log_id = mysqli_insert_id($link);
if ((strlen($slave_db_server)>5) and (preg_match("/$report_name/", $reports_use_slave_db))) {
    mysqli_close($link);
    $use_slave_server=1;
    $db_source = 'S';
    require("dbconnect_mysqli.php");
    $MAIN.="<!-- Using slave server $slave_db_server $db_source -->\n";
}
$stmt="select user,full_name from vicidial_users $whereLOGadmin_viewable_groupsSQL order by user;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($DB) {
    echo "$stmt\n";
}
$campaigns_to_print = mysqli_num_rows($rslt);
$i=0;
while ($i < $campaigns_to_print) {
    $row=mysqli_fetch_row($rslt);
    $users[$i] =$row[0];
    $full_name[$i] =$row[1];
    $i++;
}
$NWB = "<IMG SRC=\"help.png\" onClick=\"FillAndShowHelpDiv(event, '";
$NWE = "')\" WIDTH=20 HEIGHT=20 BORDER=0 ALT=\"HELP\" ALIGN=TOP>";
?>
<HTML>
<HEAD>
<STYLE type="text/css">
<!--
   .green {color: white; background-color: green}
   .red {color: white; background-color: red}
   .blue {color: white; background-color: blue}
   .purple {color: white; background-color: purple}
-->
 </STYLE>
<?php
echo "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">\n";
echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"vicidial_stylesheet.php\">\n";
echo "<script language=\"JavaScript\" src=\"help.js\"></script>\n";
echo "<TITLE>"._QXZ("$report_name")."</TITLE></HEAD><BODY BGCOLOR=WHITE marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>\n";
echo "<div id='HelpDisplayDiv' class='help_info' style='display:none;'></div>";
$short_header=1;
require("admin_header.php");
echo "<b>"._QXZ("$report_name")."</b> $NWB#user_logins_report$NWE\n";
echo "<TABLE CELLPADDING=4 CELLSPACING=0><TR><TD>";
echo "<FORM ACTION=\"$PHP_SELF\" METHOD=GET>\n";
echo "<SELECT SIZE=1 NAME=user>\n";
echo "<option ";
if ($user == '--MOST-RECENT-ACTIVE-TODAY--') {
    echo "selected ";
}
echo "value='--MOST-RECENT-ACTIVE-TODAY--'>"._QXZ("--MOST-RECENT-ACTIVE-TODAY--")."</option>\n";
echo "<option ";
if ($user == '--MOST-RECENT-ACTIVE-ARCHIVE--') {
    echo "selected ";
}
echo "value='--MOST-RECENT-ACTIVE-ARCHIVE--'>"._QXZ("--MOST-RECENT-ACTIVE-ARCHIVE--")."</option>\n";
$o=0;
while ($campaigns_to_print > $o) {
    if ($users[$o] == $user) {
        echo "<option selected value=\"$users[$o]\">$users[$o] - $full_name[$o]</option>\n";
    } else {
        echo "<option value=\"$users[$o]\">$users[$o] - $full_name[$o]</option>\n";
    }
    $o++;
}
echo "</SELECT>\n";
echo "<INPUT TYPE=SUBMIT NAME=SUBMIT VALUE='"._QXZ("SUBMIT")."'>\n";
if (($user != '--MOST-RECENT-ACTIVE-ARCHIVE--') and ($user != '--MOST-RECENT-ACTIVE-TODAY--')) {
    echo " &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <a href=\"./admin.php?ADD=3&user=$user\">"._QXZ("MODIFY")."</a> \n";
}
echo "</FORM>\n\n";
echo "<PRE><FONT SIZE=2>\n\n";
if (!$user) {
    echo "\n\n";
    echo _QXZ("PLEASE SELECT A USER ABOVE AND CLICK SUBMIT")."\n";
} else {
    $multi_user=0;
    $stmt="select vuld.user,vuld.login_day,vuld.last_login_date,vuld.last_ip,vuld.failed_login_attempts_today,vuld.failed_login_count_today,vuld.failed_last_ip_today,vuld.failed_last_type_today from vicidial_user_logins_daily vuld, vicidial_users vm where vuld.user='" . mysqli_real_escape_string($link, $user) . "' and vm.user=vuld.user $vmLOGadmin_viewable_groupsSQL order by login_day desc limit 1000;";
    if ($user == '--MOST-RECENT-ACTIVE-ARCHIVE--') {
        $multi_user=1;
        $stmt="select vuld.user,vuld.login_day,vuld.last_login_date,vuld.last_ip,vuld.failed_login_attempts_today,vuld.failed_login_count_today,vuld.failed_last_ip_today,vuld.failed_last_type_today from vicidial_user_logins_daily vuld, vicidial_users vm where vm.user=vuld.user $vmLOGadmin_viewable_groupsSQL order by login_day desc, last_login_date desc limit 1000;";
    }
    if ($user == '--MOST-RECENT-ACTIVE-TODAY--') {
        $multi_user=1;
        $stmt="select user,'TODAY',last_login_date,last_ip,failed_login_attempts_today,failed_login_count_today,failed_last_ip_today,failed_last_type_today from vicidial_users where last_login_date >= \"$last_midnight\" $LOGadmin_viewable_groupsSQL order by last_login_date desc limit 1000;";
    }
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($DB) {
        echo "$stmt\n";
    }
    $shortages_to_print = mysqli_num_rows($rslt);
    if ($shortages_to_print > 0) {
        echo _QXZ("User Logins Summary").":\n";
        echo "| "._QXZ("USER", 20)." ! "._QXZ("LOG DATE", 10)." ! "._QXZ("LAST LOGIN DATE", 20)." ! "._QXZ("LAST IP", 20)." ! "._QXZ("FAIL ATMPT", 10)." ! "._QXZ("FAIL COUNT", 10)." ! "._QXZ("LAST FAIL IP", 20)." ! "._QXZ("LAST FAIL TYPE", 20)." |\n";
        echo "+----------------------+------------+----------------------+----------------------+------------+------------+----------------------+----------------------+\n";
    }
    $i=0;
    $archive_output='';
    while ($shortages_to_print > $i) {
        $row=mysqli_fetch_row($rslt);
        $archive_output .= "| ".sprintf("%-20s", $row[0])." |";
        $archive_output .= " ".sprintf("%-10s", $row[1])." |";
        $archive_output .= " ".sprintf("%-20s", $row[2])." |";
        $archive_output .= " ".sprintf("%-20s", $row[3])." |";
        $archive_output .= " ".sprintf("%-10s", $row[4])." |";
        $archive_output .= " ".sprintf("%-10s", $row[5])." |";
        $archive_output .= " ".sprintf("%-20s", $row[6])." |";
        $archive_output .= " ".sprintf("%-20s", $row[7])." |\n";
        $i++;
    }
    if ($multi_user < 1) {
        $stmt="select user,'TODAY',last_login_date,last_ip,failed_login_attempts_today,failed_login_count_today,failed_last_ip_today,failed_last_type_today from vicidial_users where user='" . mysqli_real_escape_string($link, $user) . "' and last_login_date >= \"$last_midnight\"  $LOGadmin_viewable_groupsSQL order by last_login_date desc limit 1000;";
        $rslt=mysql_to_mysqli($stmt, $link);
        if ($DB) {
            echo "$stmt\n";
        }
        $shortages_to_print = mysqli_num_rows($rslt);
        $i=0;
        while ($shortages_to_print > $i) {
            $row=mysqli_fetch_row($rslt);
            echo "| ".sprintf("%-20s", $row[0])." |";
            echo " ".sprintf("%-10s", $row[1])." |";
            echo " ".sprintf("%-20s", $row[2])." |";
            echo " ".sprintf("%-20s", $row[3])." |";
            echo " ".sprintf("%-10s", $row[4])." |";
            echo " ".sprintf("%-10s", $row[5])." |";
            echo " ".sprintf("%-20s", $row[6])." |";
            echo " ".sprintf("%-20s", $row[7])." |\n";
            $i++;
        }
    }
    echo $archive_output;
    echo "\n";
}
if ($db_source == 'S') {
    mysqli_close($link);
    $use_slave_server=0;
    $db_source = 'M';
    require("dbconnect_mysqli.php");
}
$endMS = microtime();
$startMSary = explode(" ", $startMS);
$endMSary = explode(" ", $endMS);
$runS = ($endMSary[0] - $startMSary[0]);
$runM = ($endMSary[1] - $startMSary[1]);
$TOTALrun = ($runS + $runM);
$stmt="UPDATE vicidial_report_log set run_time='$TOTALrun' where report_log_id='$report_log_id';";
if ($DB) {
    echo "|$stmt|\n";
}
$rslt=mysql_to_mysqli($stmt, $link);
?>
</PRE>
</TD></TR></TABLE>
</BODY></HTML>
