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
$version = '2.14-17';
$build = '220223-0808';
$MT[0]='';
require("dbconnect_mysqli.php");
require("functions.php");
$PHP_SELF=$_SERVER['PHP_SELF'];
$PHP_SELF = preg_replace('/\.php.*/i', '.php', $PHP_SELF);
if (isset($_GET["action"])) {
    $action=$_GET["action"];
} elseif (isset($_POST["action"])) {
    $action=$_POST["action"];
}
if (isset($_GET["DB"])) {
    $DB=$_GET["DB"];
} elseif (isset($_POST["DB"])) {
    $DB=$_POST["DB"];
}
if (isset($_GET["territory"])) {
    $territory=$_GET["territory"];
} elseif (isset($_POST["territory"])) {
    $territory=$_POST["territory"];
}
if (isset($_GET["territory_description"])) {
    $territory_description=$_GET["territory_description"];
} elseif (isset($_POST["territory_description"])) {
    $territory_description=$_POST["territory_description"];
}
if (isset($_GET["user"])) {
    $user=$_GET["user"];
} elseif (isset($_POST["user"])) {
    $user=$_POST["user"];
}
if (isset($_GET["level"])) {
    $level=$_GET["level"];
} elseif (isset($_POST["level"])) {
    $level=$_POST["level"];
}
if (isset($_GET["accountid"])) {
    $accountid=$_GET["accountid"];
} elseif (isset($_POST["accountid"])) {
    $accountid=$_POST["accountid"];
}
if (isset($_GET["batch"])) {
    $batch=$_GET["batch"];
} elseif (isset($_POST["batch"])) {
    $batch=$_POST["batch"];
}
if (isset($_GET["vl_owner"])) {
    $vl_owner=$_GET["vl_owner"];
} elseif (isset($_POST["vl_owner"])) {
    $vl_owner=$_POST["vl_owner"];
}
if (isset($_GET["SUBMIT"])) {
    $SUBMIT=$_GET["SUBMIT"];
} elseif (isset($_POST["SUBMIT"])) {
    $SUBMIT=$_POST["SUBMIT"];
}
$DB=preg_replace("/[^0-9a-zA-Z]/", "", $DB);
header("Content-type: text/html; charset=utf-8");
header("Cache-Control: no-cache, must-revalidate");  // HTTP/1.1
header("Pragma: no-cache");                          // HTTP/1.0
$stmt = "SELECT use_non_latin,user_territories_active,enable_vtiger_integration,outbound_autodial_active,vtiger_server_ip,vtiger_dbname,vtiger_login,vtiger_pass,vtiger_url,enable_languages,language_method,qc_features_active,user_new_lead_limit,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
$ss_conf_ct = mysqli_num_rows($rslt);
if ($ss_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                        $row[0];
    $user_territories_active =            $row[1];
    $enable_vtiger_integration =        $row[2];
    $SSoutbound_autodial_active =        $row[3];
    $vtiger_server_ip    =                $row[4];
    $vtiger_dbname =                    $row[5];
    $vtiger_login =                        $row[6];
    $vtiger_pass =                        $row[7];
    $vtiger_url =                        $row[8];
    $SSenable_languages =                $row[9];
    $SSlanguage_method =                $row[10];
    $SSqc_features_active =                $row[11];
    $SSuser_new_lead_limit =            $row[12];
    $SSallow_web_debug =                $row[13];
}
if ($SSallow_web_debug < 1) {
    $DB=0;
}
if ($user_territories_active < 1) {
    echo _QXZ("ERROR: User Territories are not active on this system")."\n";
    exit;
}
$DB = preg_replace('/[^0-9]/', '', $DB);
$action = preg_replace('/[^\_0-9a-zA-Z]/', '', $action);
$level = preg_replace('/[^\_A-Z]/', '', $level);
$batch = preg_replace('/[^-_0-9a-zA-Z]/', '', $batch);
$SUBMIT = preg_replace('/[^-_0-9a-zA-Z]/', '', $SUBMIT);
$vl_owner = preg_replace('/[^-_0-9a-zA-Z]/', '', $vl_owner);
if ($non_latin < 1) {
    $user = preg_replace('/[^-\_0-9a-zA-Z]/', '', $user);
    $territory = preg_replace('/[^-\_0-9a-zA-Z]/', '', $territory);
    $territory_description = preg_replace('/[^- \_\.\,0-9a-zA-Z]/', '', $territory_description);
    $old_territory = preg_replace('/[^-\_0-9a-zA-Z]/', '', $old_territory);
    $old_user = preg_replace('/[^-\_0-9a-zA-Z]/', '', $old_user);
    $accountid = preg_replace('/[^-\_0-9a-zA-Z]/', '', $accountid);
} else {
    $user = preg_replace('/[^-_0-9\p{L}]/u', "", $user);
    $territory = preg_replace('/[^-\_0-9\p{L}]/u', '', $territory);
    $territory_description = preg_replace('/[^- \_\.\,0-9\p{L}]/u', '', $territory_description);
    $old_territory = preg_replace('/[^-\_0-9\p{L}]/u', '', $old_territory);
    $old_user = preg_replace('/[^-\_0-9\p{L}]/u', '', $old_user);
    $accountid = preg_replace('/[^-\_0-9\p{L}]/u', '', $accountid);
}
if (preg_match("/YES/i", $batch)) {
    $USER='batch';
    $PASS='batch';
} else {
    $USER=$_SERVER['PHP_AUTH_USER'];
    $PASS=$_SERVER['PHP_AUTH_PW'];
    if ($non_latin < 1) {
        $USER = preg_replace('/[^-_0-9a-zA-Z]/', '', $USER);
        $PASS = preg_replace('/[^-_0-9a-zA-Z]/', '', $PASS);
    } else {
        $USER = preg_replace('/[^-_0-9\p{L}]/u', '', $USER);
        $PASS = preg_replace('/[^-_0-9\p{L}]/u', '', $PASS);
    }
}
$stmt="SELECT selected_language,qc_enabled from vicidial_users where user='$USER';";
if ($DB) {
    echo "|$stmt|\n";
}
$rslt=mysql_to_mysqli($stmt, $link);
$sl_ct = mysqli_num_rows($rslt);
if ($sl_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $VUselected_language =        $row[0];
    $qc_auth =                    $row[1];
}
$auth=0;
$modify_users_auth=0;
$auth_message = user_authorization($USER, $PASS, '', 1, 0);
if ($auth_message == 'GOOD') {
    $auth=1;
}
$stmt="SELECT count(*) from vicidial_users where user='$USER' and user_level > 7 and modify_users='1'";
if ($DB) {
    echo "|$stmt|\n";
}
$rslt=mysql_to_mysqli($stmt, $link);
$row=mysqli_fetch_row($rslt);
$modify_users_auth=$row[0];
if((strlen($USER)<2) or (strlen($PASS)<2) or (!$auth) or (!$modify_users_auth)) {
    Header("WWW-Authenticate: Basic realm=\"CONTACT-CENTER-ADMIN\"");
    Header("HTTP/1.0 401 Unauthorized");
    echo "Invalid Username/Password: |$USER|$PASS|$auth_message|\n";
    exit;
}
if ($enable_vtiger_integration > 0) {
    $linkV=mysqli_connect("$vtiger_server_ip", "$vtiger_login", "$vtiger_pass", "$vtiger_dbname");
    if (!$linkV) {
        die("Could not connect: $vtiger_server_ip|$vtiger_dbname|$vtiger_login|$vtiger_pass" . mysqli_connect_error());
    }
}
if (strlen($action) < 1) {
    $action = 'LIST_ALL_TERRITORIES';
}
?>
<html>
<head>
<link rel="stylesheet" type="text/css" href="vicidial_stylesheet.php">
<script language="JavaScript" src="help.js"></script>
<div id='HelpDisplayDiv' class='help_info' style='display:none;'></div>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">
<!-- VERSION: <?php echo $version ?>     BUILD: <?php echo $build ?> -->
<title><?php echo _QXZ("ADMINISTRATION: User Territories"); ?>
<?php
if (($action == "CHANGE_TERRITORY_OWNER_ACCOUNT") and ($enable_vtiger_integration > 0)) {
    echo "</TITLE></HEAD><BODY BGCOLOR=white>\n";
    echo "<TABLE><TR><TD>\n";
    echo "<FONT FACE=\"ARIAL,HELVETICA\" COLOR=BLACK SIZE=2>";
    echo "<br>"._QXZ("Vtiger Change Territory Owner")."<form action=$PHP_SELF method=POST>\n";
    echo "<input type=hidden name=action value=PROCESS_CHANGE_TERRITORY_OWNER_ACCOUNT>\n";
    echo "<center><TABLE width=$section_width cellspacing=3>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Account ID").": </td><td align=left><input type=text name=accountid value=\"$accountid\"></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("New Owner").": </td><td align=left><select size=1 name=user>\n";
    $stmt="SELECT user,full_name from vicidial_users where active='Y' order by user";
    $rslt=mysql_to_mysqli($stmt, $link);
    $users_to_print = mysqli_num_rows($rslt);
    $users_list='';
    $o=0;
    while ($users_to_print > $o) {
        $rowx=mysqli_fetch_row($rslt);
        $users_list .= "<option value=\"$rowx[0]\">$rowx[0] - $rowx[1]</option>\n";
        $o++;
    }
    echo "$users_list";
    echo "</select></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Update ViciDial List Owner").": </td><td align=left><select size=1 name=vl_owner>\n";
    echo "<option value='YES' SELECTED>"._QXZ("YES")."</option>\n";
    echo "<option value='NO'>"._QXZ("NO")."</option>\n";
    echo "</select></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=center colspan=2><input style='background-color:#$SSbutton_color' type=submit name=SUBMIT value='"._QXZ("SUBMIT")."'></td></tr>\n";
    echo "</TABLE></center>\n";
    exit;
}
if (($action == "PROCESS_CHANGE_TERRITORY_OWNER_ACCOUNT") and ($enable_vtiger_integration > 0)) {
    echo "</TITLE></HEAD><BODY BGCOLOR=white>\n";
    if ((strlen($accountid)<1) or (strlen($user)<1)) {
        echo _QXZ("ERROR: Account ID and User must be filled in")."<BR>\n";
    } else {
        if (preg_match("/YES/i", $batch)) {
            $AID_lookupSQL = "website='$accountid'";
        } else {
            $AID_lookupSQL = "accountid='$accountid'";
        }
        $stmtV="SELECT tickersymbol,accountid from vtiger_account where $AID_lookupSQL;";
        $rsltV=mysql_to_mysqli($stmtV, $linkV);
        if ($DB) {
            echo "$stmtV\n";
        }
        $vat_ct = mysqli_num_rows($rsltV);
        if ($vat_ct > 0) {
            $row=mysqli_fetch_row($rsltV);
            $territory =        $row[0];
            $accountid =        $row[1];
            $stmt="SELECT count(*) from vicidial_user_territories where territory='$territory' and user='$user';";
            $rslt=mysql_to_mysqli($stmt, $link);
            $row=mysqli_fetch_row($rslt);
            if ($row[0] < 1) {
                $stmt="INSERT INTO vicidial_user_territories SET territory='$territory',user='$user',level='STANDARD_AGENT';";
                $rslt=mysql_to_mysqli($stmt, $link);
                echo "NOTICE: Had to add user territory: $user $territory<BR>\n";
                $SQL_log = "$stmt|$stmtB|";
                $SQL_log = preg_replace('/;/', '', $SQL_log);
                $SQL_log = addslashes($SQL_log);
                $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$USER', ip_address='$ip', event_section='TERRITORIES', event_type='ADD', record_id='$territory', event_code='ADMIN ADD USER TERRITORY', event_sql=\"$SQL_log\", event_notes='';";
                if ($DB) {
                    echo "|$stmt|\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
            }
            $stmtV="SELECT id from vtiger_users where user_name='$user';";
            $rsltV=mysql_to_mysqli($stmtV, $linkV);
            if ($DB) {
                echo "$stmtV\n";
            }
            $vtu_ct = mysqli_num_rows($rsltV);
            if ($vtu_ct > 0) {
                $row=mysqli_fetch_row($rsltV);
                $user_id =        $row[0];
                $stmt="UPDATE vtiger_crmentity SET smownerid='$user_id',smcreatorid='$user_id',modifiedby='$user_id' where crmid='$accountid';";
                $rsltV=mysql_to_mysqli($stmt, $linkV);
                $changed = mysqli_affected_rows($linkV);
                $stmtB="UPDATE vtiger_tracker SET user_id='$user_id' where item_id='$accountid';";
                $rsltV=mysql_to_mysqli($stmtB, $linkV);
                if (($vl_owner == 'YES') and ($accountid > 0)) {
                    $stmtB="UPDATE vicidial_list SET owner='$user' where vendor_lead_code='$accountid';";
                    $rsltV=mysql_to_mysqli($stmtB, $link);
                }
                echo _QXZ("Vtiger Territory Owner Changed").": $user $territory<BR>\n";
                echo _QXZ("Records Changed").": $changed<BR>\n";
                $SQL_log = "$stmt|$stmtB|";
                $SQL_log = preg_replace('/;/', '', $SQL_log);
                $SQL_log = addslashes($SQL_log);
                $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$USER', ip_address='$ip', event_section='VTIGER', event_type='MODIFY', record_id='$accountid', event_code='VTIGER MODIFY TERRITORY OWNER ACCOUNT', event_sql=\"$SQL_log\", event_notes='';";
                if ($DB) {
                    echo "|$stmt|\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
            }
        }
    }
    exit;
}
$ADD =                    '0';
$hh =                    'users';
$sh =                    'territory';
$LOGast_admin_access =    '1';
$ADMIN =                'admin.php';
$page_width='770';
$section_width='750';
$header_font_size='3';
$subheader_font_size='2';
$subcamp_font_size='2';
$header_selected_bold='<b>';
$header_nonselected_bold='';
$users_color =        '#FFFF99';
$users_font =        'BLACK';
$users_color =        '#E6E6E6';
$subcamp_color =    '#C6C6C6';
require("admin_header.php");
$colspan='3';
?>
<TABLE WIDTH=<?php echo $page_width ?> BGCOLOR=#E6E6E6 cellpadding=2 cellspacing=0>
<TR BGCOLOR=#E6E6E6>
<TD ALIGN=LEFT><FONT FACE="ARIAL,HELVETICA" SIZE=2><B> &nbsp; <a href="<?php echo "$PHP_SELF" ?>"><?php echo _QXZ("List Territories"); ?></a></TD>
<TD ALIGN=RIGHT><FONT FACE="ARIAL,HELVETICA" SIZE=2><B> &nbsp; <a href="<?php echo "$PHP_SELF" ?>?action=ADD_TERRITORY"><?php echo _QXZ("Add Territory"); ?></a></TD>
<TD ALIGN=RIGHT><FONT FACE="ARIAL,HELVETICA" SIZE=2><B> &nbsp; <a href="<?php echo "$PHP_SELF" ?>?action=ADD_USER_TERRITORY"><?php echo _QXZ("Add User Territory"); ?></a></TD>
<?php
if ($enable_vtiger_integration > 0) { ?>
<TD ALIGN=RIGHT><FONT FACE="ARIAL,HELVETICA" SIZE=2><B> &nbsp; <a href="<?php echo "$PHP_SELF" ?>?action=CHANGE_TERRITORY_OWNER"><?php echo _QXZ("Change Vtiger Territory Owner"); ?></a></TD>
<?php
    $colspan='4';
} ?>
</TR>
<?php
echo "<TR BGCOLOR=\"#$SSframe_background\"><TD ALIGN=LEFT COLSPAN=$colspan><FONT FACE=\"ARIAL,HELVETICA\" COLOR=BLACK SIZE=3><B> &nbsp; \n";
$STARTtime = date("U");
$TODAY = date("Y-m-d");
$NOW_TIME = date("Y-m-d H:i:s");
$FILE_datetime = $STARTtime;
$ip = getenv("REMOTE_ADDR");
$date = date("r");
$browser = getenv("HTTP_USER_AGENT");
$script_name = getenv("SCRIPT_NAME");
$server_name = getenv("SERVER_NAME");
$server_port = getenv("SERVER_PORT");
if (preg_match("/443/i", $server_port)) {
    $HTTPprotocol = 'https://';
} else {
    $HTTPprotocol = 'http://';
}
$admDIR = "$HTTPprotocol$server_name:$server_port$script_name";
$admDIR = preg_replace('/user_territories\.php/i', '', $admDIR);
$admSCR = 'admin.php';
$NWB = "<IMG SRC=\"help.png\" onClick=\"FillAndShowHelpDiv(event, '";
$NWE = "')\" WIDTH=20 HEIGHT=20 BORDER=0 ALT=\"HELP\" ALIGN=TOP>";
$secX = date("U");
$pulldate0 = "$year-$mon-$mday $hour:$min:$sec";
if (($action == "CHANGE_TERRITORY_OWNER") and ($enable_vtiger_integration > 0)) {
    echo "<TABLE><TR><TD>\n";
    echo "<FONT FACE=\"ARIAL,HELVETICA\" COLOR=BLACK SIZE=2>";
    echo "<br>"._QXZ("Vtiger Change Territory Owner")."<form action=$PHP_SELF method=POST>\n";
    echo "<input type=hidden name=action value=PROCESS_CHANGE_TERRITORY_OWNER>\n";
    echo "<center><TABLE width=$section_width cellspacing=3>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Territory").": </td><td align=left><select size=1 name=territory>\n";
    $stmt="SELECT territory,territory_description from vicidial_territories order by territory";
    $rslt=mysql_to_mysqli($stmt, $link);
    $territories_to_print = mysqli_num_rows($rslt);
    $territories_list='';
    $o=0;
    while ($territories_to_print > $o) {
        $rowx=mysqli_fetch_row($rslt);
        $territories_list .= "<option value=\"$rowx[0]\">$rowx[0] - $rowx[1]</option>\n";
        $o++;
    }
    echo "$territories_list";
    echo "</select></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("New Owner").": </td><td align=left><select size=1 name=user>\n";
    $stmt="SELECT user,full_name from vicidial_users where active='Y' order by user";
    $rslt=mysql_to_mysqli($stmt, $link);
    $users_to_print = mysqli_num_rows($rslt);
    $users_list='';
    $o=0;
    while ($users_to_print > $o) {
        $rowx=mysqli_fetch_row($rslt);
        $users_list .= "<option value=\"$rowx[0]\">$rowx[0] - $rowx[1]</option>\n";
        $o++;
    }
    echo "$users_list";
    echo "</select></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Update ViciDial List Owner").": </td><td align=left><select size=1 name=vl_owner>\n";
    echo "<option value='YES' SELECTED>"._QXZ("YES")."</option>\n";
    echo "<option value='NO'>"._QXZ("NO")."</option>\n";
    echo "</select></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=center colspan=2><input style='background-color:#$SSbutton_color' type=submit name=SUBMIT value='"._QXZ("SUBMIT")."'></td></tr>\n";
    echo "</TABLE></center>\n";
}
if (($action == "PROCESS_CHANGE_TERRITORY_OWNER") and ($enable_vtiger_integration > 0)) {
    if ((strlen($territory)<1) or (strlen($user)<1)) {
        echo _QXZ("ERROR: Territory and User must be filled in")."<BR>\n";
    } else {
        $stmt="SELECT count(*) from vicidial_user_territories where territory='$territory' and user='$user';";
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        if ($row[0] < 1) {
            $stmt="INSERT INTO vicidial_user_territories SET territory='$territory',user='$user',level='TOP_AGENT';";
            $rslt=mysql_to_mysqli($stmt, $link);
            $stmtB="UPDATE vicidial_user_territories SET level='STANDARD_AGENT' where territory='$territory' and user!='$user' and level='TOP_AGENT';";
            $rslt=mysql_to_mysqli($stmtB, $link);
            echo _QXZ("NOTICE: Had to add user territory").": $user $territory<BR>\n";
            $SQL_log = "$stmt|$stmtB|";
            $SQL_log = preg_replace('/;/', '', $SQL_log);
            $SQL_log = addslashes($SQL_log);
            $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$USER', ip_address='$ip', event_section='TERRITORIES', event_type='ADD', record_id='$territory', event_code='ADMIN ADD USER TERRITORY', event_sql=\"$SQL_log\", event_notes='';";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
        }
        $stmtV="SELECT id from vtiger_users where user_name='$user';";
        $rsltV=mysql_to_mysqli($stmtV, $linkV);
        if ($DB) {
            echo "$stmtV\n";
        }
        $vtu_ct = mysqli_num_rows($rsltV);
        if ($vtu_ct > 0) {
            $row=mysqli_fetch_row($rsltV);
            $user_id =        $row[0];
            $stmtV="SELECT accountid from vtiger_account where tickersymbol='$territory';";
            $rsltV=mysql_to_mysqli($stmtV, $linkV);
            if ($DB) {
                echo "$stmtV\n";
            }
            $vat_ct = mysqli_num_rows($rsltV);
            $account_ids[0]='';
            $p=0;
            while ($vat_ct > $p) {
                $row=mysqli_fetch_row($rsltV);
                $account_ids[$p] =        $row[0];
                $p++;
            }
            $p=0;
            while ($vat_ct > $p) {
                $stmt="UPDATE vtiger_crmentity SET smownerid='$user_id',smcreatorid='$user_id',modifiedby='$user_id' where crmid='$account_ids[$p]';";
                $rsltV=mysql_to_mysqli($stmt, $linkV);
                $changedX = mysqli_affected_rows($linkV);
                if ($DB) {
                    echo "$stmt|$changedX\n";
                }
                $changed = ($changed + $changedX);
                $stmtV="select activityid from vtiger_seactivityrel where crmid='$account_ids[$p]';";
                $rsltV=mysql_to_mysqli($stmtV, $linkV);
                if ($DB) {
                    echo "$stmtV\n";
                }
                $vact_ct = mysqli_num_rows($rsltV);
                $activity_ids[0]='';
                $r=0;
                while ($vact_ct > $r) {
                    $row=mysqli_fetch_row($rsltV);
                    $activity_ids[$r] =        $row[0];
                    $r++;
                }
                $r=0;
                while ($vact_ct > $r) {
                    $stmt="UPDATE vtiger_crmentity SET smownerid='$user_id' where crmid='$activity_ids[$r]';";
                    $rsltV=mysql_to_mysqli($stmt, $linkV);
                    $AchangedX = mysqli_affected_rows($linkV);
                    if ($DB) {
                        echo "$stmt|$AchangedX\n";
                    }
                    $Achanged = ($Achanged + $AchangedX);
                    $r++;
                }
                if (($vl_owner == 'YES') and ($account_ids[$p] > 0)) {
                    $stmtB="UPDATE vicidial_list SET owner='$user' where vendor_lead_code='$account_ids[$p]';";
                    $rslt=mysql_to_mysqli($stmtB, $link);
                    $VchangedX = mysqli_affected_rows($link);
                    if ($DB) {
                        echo "$stmtB|$VchangedX\n";
                    }
                    $Vchanged = ($Vchanged + $VchangedX);
                }
                $p++;
            }
            $stmt="UPDATE vtiger_crmentity SET smownerid='$user_id',smcreatorid='$user_id',modifiedby='$user_id' where crmid IN(SELECT accountid from vtiger_account where tickersymbol='$territory');";
            $rsltV=mysql_to_mysqli($stmt, $linkV);
            $Cchanged = mysqli_affected_rows($linkV);
            if ($DB) {
                echo "$stmt|$Cchanged\n";
            }
            $stmtB="UPDATE vtiger_tracker vt, vtiger_account va SET user_id='$user_id' where vt.item_id=va.accountid and va.tickersymbol='$territory';";
            $rsltV=mysql_to_mysqli($stmtB, $linkV);
            echo _QXZ("Vtiger Territory Owner Changed").": $user $territory &nbsp; &nbsp; &nbsp; "._QXZ("Records Changed").": $changed - $Achanged - $Cchanged - $Vchanged<BR>\n";
            $SQL_log = "$stmt|$stmtB|";
            $SQL_log = preg_replace('/;/', '', $SQL_log);
            $SQL_log = addslashes($SQL_log);
            $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$USER', ip_address='$ip', event_section='VTIGER', event_type='MODIFY', record_id='$territory', event_code='VTIGER MODIFY TERRITORY OWNER', event_sql=\"$SQL_log\", event_notes='';";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
        }
    }
    $action = "MODIFY_TERRITORY";
}
if ($action == "ADD_USER_TERRITORY") {
    echo "<TABLE><TR><TD>\n";
    echo "<FONT FACE=\"ARIAL,HELVETICA\" COLOR=BLACK SIZE=2>";
    echo "<br>"._QXZ("Add User Territory")."<form action=$PHP_SELF method=POST>\n";
    echo "<input type=hidden name=action value=PROCESS_ADD_USER_TERRITORY>\n";
    echo "<center><TABLE width=$section_width cellspacing=3>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Agent").": </td><td align=left><select size=1 name=user>\n";
    $stmt="SELECT user,full_name from vicidial_users where active='Y' order by user";
    $rslt=mysql_to_mysqli($stmt, $link);
    $users_to_print = mysqli_num_rows($rslt);
    $users_list='';
    $o=0;
    while ($users_to_print > $o) {
        $rowx=mysqli_fetch_row($rslt);
        $users_list .= "<option value=\"$rowx[0]\">$rowx[0] - $rowx[1]</option>\n";
        $o++;
    }
    echo "$users_list";
    echo "</select></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Territory").": </td><td align=left><select size=1 name=territory>\n";
    $stmt="SELECT territory,territory_description from vicidial_territories order by territory";
    $rslt=mysql_to_mysqli($stmt, $link);
    $territories_to_print = mysqli_num_rows($rslt);
    $territories_list='';
    $o=0;
    while ($territories_to_print > $o) {
        $rowx=mysqli_fetch_row($rslt);
        $territories_list .= "<option value=\"$rowx[0]\">$rowx[0] - $rowx[1]</option>\n";
        $o++;
    }
    echo "$territories_list";
    echo "</select></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Level").": </td><td align=left><select size=1 name=level><option value='TOP_AGENT'>"._QXZ("TOP_AGENT")."</option><option value='STANDARD_AGENT'>"._QXZ("STANDARD_AGENT")."</option><option value='BOTTOM_AGENT'>"._QXZ("BOTTOM_AGENT")."</option></select></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=center colspan=2><input style='background-color:#$SSbutton_color' type=submit name=SUBMIT value='"._QXZ("SUBMIT")."'></td></tr>\n";
    echo "</TABLE></center>\n";
}
if ($action == "PROCESS_ADD_USER_TERRITORY") {
    if ((strlen($territory)<1) or (strlen($user)<1) or (strlen($level)<1)) {
        echo _QXZ("ERROR: Territory, User and Level must be filled in")."<BR>\n";
    } else {
        $stmt="SELECT count(*) from vicidial_user_territories where territory='$territory' and user='$user';";
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        if ($row[0] > 0) {
            echo _QXZ("ERROR: this territory user is already in the system")."<BR>\n";
        } else {
            $stmt="INSERT INTO vicidial_user_territories SET territory='$territory',user='$user',level='$level';";
            $rslt=mysql_to_mysqli($stmt, $link);
            if ($level == "TOP_AGENT") {
                $stmtB="UPDATE vicidial_user_territories SET level='STANDARD_AGENT' where territory='$territory' and user!='$user' and level='TOP_AGENT';";
                $rslt=mysql_to_mysqli($stmtB, $link);
            }
            echo _QXZ("User Territory Added").": $user $territory<BR>\n";
            $SQL_log = "$stmt|$stmtB|";
            $SQL_log = preg_replace('/;/', '', $SQL_log);
            $SQL_log = addslashes($SQL_log);
            $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$USER', ip_address='$ip', event_section='TERRITORIES', event_type='ADD', record_id='$territory', event_code='ADMIN ADD USER TERRITORY', event_sql=\"$SQL_log\", event_notes='';";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
        }
    }
    $action = "MODIFY_TERRITORY";
}
if ($action == "PROCESS_MODIFY_USER_TERRITORY") {
    if ((strlen($territory)<1) or (strlen($user)<1) or (strlen($level)<1)) {
        echo _QXZ("ERROR: Territory, User and Level must be filled in")."<BR>\n";
    } else {
        $stmt="SELECT count(*) from vicidial_user_territories where territory='$territory' and user='$user';";
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        if ($row[0] < 0) {
            echo _QXZ("ERROR: this territory user is not in the system")."<BR>\n";
        } else {
            $stmt="UPDATE vicidial_user_territories SET level='$level' where territory='$territory' and user='$user';";
            $rslt=mysql_to_mysqli($stmt, $link);
            if ($level == "TOP_AGENT") {
                $stmtB="UPDATE vicidial_user_territories SET level='STANDARD_AGENT' where territory='$territory' and user!='$user' and level='TOP_AGENT';";
                $rslt=mysql_to_mysqli($stmtB, $link);
            }
            echo _QXZ("User Territory Modified").": $user $territory<BR>\n";
            $SQL_log = "$stmt|$stmtB|";
            $SQL_log = preg_replace('/;/', '', $SQL_log);
            $SQL_log = addslashes($SQL_log);
            $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$USER', ip_address='$ip', event_section='TERRITORIES', event_type='MODIFY', record_id='$territory', event_code='ADMIN MODIFY USER TERRITORY', event_sql=\"$SQL_log\", event_notes='';";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
        }
    }
    $action = "MODIFY_TERRITORY";
}
if ($action == "DELETE_USER_TERRITORY") {
    if ((strlen($territory)<1) or (strlen($user)<1)) {
        echo _QXZ("ERROR: Territory and User must be filled in")."<BR>\n";
    } else {
        $stmt="SELECT count(*) from vicidial_user_territories where territory='$territory' and user='$user';";
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        if ($row[0] < 0) {
            echo _QXZ("ERROR: this territory user is not in the system")."<BR>\n";
        } else {
            $stmt="DELETE from vicidial_user_territories where territory='$territory' and user='$user';";
            $rslt=mysql_to_mysqli($stmt, $link);
            echo _QXZ("User Territory Deleted").": $user $territory<BR>\n";
            $SQL_log = "$stmt|$stmtB|";
            $SQL_log = preg_replace('/;/', '', $SQL_log);
            $SQL_log = addslashes($SQL_log);
            $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$USER', ip_address='$ip', event_section='TERRITORIES', event_type='DELETE', record_id='$territory', event_code='ADMIN DELETE USER TERRITORY', event_sql=\"$SQL_log\", event_notes='';";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
        }
    }
    $action = "MODIFY_TERRITORY";
}
if ($action == "ADD_TERRITORY") {
    echo "<TABLE><TR><TD>\n";
    echo "<FONT FACE=\"ARIAL,HELVETICA\" COLOR=BLACK SIZE=2>";
    echo "<br>"._QXZ("Add Territory")."<form action=$PHP_SELF method=POST>\n";
    echo "<input type=hidden name=action value=PROCESS_ADD_TERRITORY>\n";
    echo "<center><TABLE width=$section_width cellspacing=3>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Territory").": </td><td align=left><input type=text name=territory size=30 maxlength=100></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Territory Description").": </td><td align=left><input type=text name=territory_description size=50 maxlength=255></td></tr>\n";
    echo "<tr bgcolor=#$SSstd_row4_background><td align=center colspan=2><input style='background-color:#$SSbutton_color' type=submit name=SUBMIT value='"._QXZ("SUBMIT")."'></td></tr>\n";
    echo "</TABLE></center>\n";
}
if ($action == "PROCESS_ADD_TERRITORY") {
    if ((strlen($territory)<1) or (strlen($territory_description)<1)) {
        echo _QXZ("ERROR: Territory and Territory Description must be filled in")."<BR>\n";
    } else {
        $stmt="SELECT count(*) from vicidial_territories where territory='$territory';";
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        if ($row[0] > 0) {
            echo _QXZ("ERROR: there is already a territory in the system with this name")."<BR>\n";
        } else {
            $stmt="INSERT INTO vicidial_territories SET territory='$territory',territory_description='$territory_description';";
            $rslt=mysql_to_mysqli($stmt, $link);
            echo "Territory Added: $territory<BR>\n";
            $SQL_log = "$stmt|";
            $SQL_log = preg_replace('/;/', '', $SQL_log);
            $SQL_log = addslashes($SQL_log);
            $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$USER', ip_address='$ip', event_section='TERRITORIES', event_type='ADD', record_id='$territory', event_code='ADMIN ADD TERRITORY', event_sql=\"$SQL_log\", event_notes='';";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
        }
    }
    $action = "LIST_ALL_TERRITORIES";
}
if ($action == "DELETE_TERRITORY") {
    if (strlen($territory)<1) {
        echo _QXZ("ERROR: Territory must be filled in")."<BR>\n";
    } else {
        $stmt="SELECT count(*) from vicidial_territories where territory='$territory';";
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        if ($row[0] < 0) {
            echo _QXZ("ERROR: This territory is not in the system with this name")."<BR>\n";
        } else {
            $stmt="DELETE from vicidial_territories where territory='$territory';";
            $rslt=mysql_to_mysqli($stmt, $link);
            echo "Territory Deleted: $territory<BR>\n";
            $SQL_log = "$stmt|";
            $SQL_log = preg_replace('/;/', '', $SQL_log);
            $SQL_log = addslashes($SQL_log);
            $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$USER', ip_address='$ip', event_section='TERRITORIES', event_type='DELETE', record_id='$territory', event_code='ADMIN DELETE TERRITORY', event_sql=\"$SQL_log\", event_notes='';";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
        }
    }
    $action = "LIST_ALL_TERRITORIES";
}
if ($action == "PROCESS_MODIFY_TERRITORY") {
    if ((strlen($territory)<1) or (strlen($territory_description)<1)) {
        echo _QXZ("ERROR: Territory and Territory Description must be filled in")."<BR>\n";
    } else {
        $stmt="SELECT count(*) from vicidial_territories where territory='$territory';";
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        if ($row[0] < 1) {
            echo _QXZ("ERROR: This territory is not in the system with this name")."<BR>\n";
        } else {
            $stmt="UPDATE vicidial_territories SET territory_description='$territory_description' where territory='$territory';";
            $rslt=mysql_to_mysqli($stmt, $link);
            echo _QXZ("Territory Modified").": $territory<BR>\n";
            $SQL_log = "$stmt|";
            $SQL_log = preg_replace('/;/', '', $SQL_log);
            $SQL_log = addslashes($SQL_log);
            $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$USER', ip_address='$ip', event_section='TERRITORIES', event_type='MODIFY', record_id='$territory', event_code='ADMIN MODIFY TERRITORY', event_sql=\"$SQL_log\", event_notes='';";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
        }
    }
    $action = "MODIFY_TERRITORY";
}
if ($action == "MODIFY_TERRITORY") {
    $stmt="SELECT territory,territory_description from vicidial_territories where territory='$territory';";
    $rslt=mysql_to_mysqli($stmt, $link);
    $territories_to_print = mysqli_num_rows($rslt);
    if ($territories_to_print > 0) {
        $rowx=mysqli_fetch_row($rslt);
        echo "<TABLE><TR><TD>\n";
        echo "<FONT FACE=\"ARIAL,HELVETICA\" COLOR=BLACK SIZE=2>";
        echo "<br>"._QXZ("Modify Territory")."<form action=$PHP_SELF method=POST>\n";
        echo "<input type=hidden name=action value=PROCESS_MODIFY_TERRITORY>\n";
        echo "<input type=hidden name=territory value=\"$territory\">\n";
        echo "<center><TABLE width=$section_width cellspacing=3>\n";
        echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Territory").": </td><td align=left><B>$rowx[0]</B></td></tr>\n";
        echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Territory Description").": </td><td align=left><input type=text name=territory_description size=50 maxlength=255 value=\"$rowx[1]\"></td></tr>\n";
        $stmt = "SELECT count(*) FROM vicidial_user_territories where territory='$territory';";
        $rslt=mysql_to_mysqli($stmt, $link);
        if ($DB) {
            echo "$stmt\n";
        }
        $vut_ct = mysqli_num_rows($rslt);
        if ($vut_ct > 0) {
            $row=mysqli_fetch_row($rslt);
            $user_count =            $row[0];
        }
        echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Agents").": </td><td align=left><B>$user_count</B></td></tr>";
        $owner_count=0;
        $stmt = "SELECT count(*) FROM vicidial_list where owner='$territory';";
        $rslt=mysql_to_mysqli($stmt, $link);
        if ($DB) {
            echo "$stmt\n";
        }
        $VLo_ct = mysqli_num_rows($rslt);
        if ($VLo_ct > 0) {
            $row=mysqli_fetch_row($rslt);
            $owner_count =            $row[0];
        }
        echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Accounts").": </td><td align=left><B>$owner_count</B></td></tr>";
        if ($enable_vtiger_integration > 0) {
            $stmtV = "SELECT count(*) FROM vtiger_account where tickersymbol='$territory';";
            $rsltV=mysql_to_mysqli($stmtV, $linkV);
            if ($DB) {
                echo "$stmtV\n";
            }
            $vta_ct = mysqli_num_rows($rsltV);
            if ($vta_ct > 0) {
                $row=mysqli_fetch_row($rsltV);
                $vtiger_count =            $row[0];
            }
            echo "<tr bgcolor=#$SSstd_row4_background><td align=right>"._QXZ("Vtiger Accounts").": </td><td align=left><B>$vtiger_count</B></td></tr>";
        }
        echo "<tr bgcolor=#$SSstd_row4_background><td align=center colspan=2><input style='background-color:#$SSbutton_color' type=submit name=SUBMIT value='"._QXZ("SUBMIT")."'></form></td></tr>\n";
        echo "</TABLE></center>\n";
        echo "<BR><BR>\n";
        echo "<TABLE CELLPADDING=3 CELLSPACING=1 WIDTH=600><TR><TD COLSPAN=5><FONT FACE=\"ARIAL,HELVETICA\" COLOR=BLACK SIZE=2>"._QXZ("Users in this Territory").":</TD></TR>\n";
        $stmt="SELECT vut.user,level,full_name from vicidial_user_territories vut,vicidial_users vu where vut.territory='$territory' and vut.user=vu.user order by vu.user;";
        $rslt=mysql_to_mysqli($stmt, $link);
        $territories_to_print = mysqli_num_rows($rslt);
        $o=0;
        while ($territories_to_print > $o) {
            $rowx=mysqli_fetch_row($rslt);
            $Tuser[$o] =        $rowx[0];
            $Tlevel[$o] =        $rowx[1];
            $Tfull_name[$o] =    $rowx[2];
            $o++;
        }
        $o=0;
        while ($territories_to_print > $o) {
            $rowx=mysqli_fetch_row($rslt);
            $p++;
            if (preg_match("/1$|3$|5$|7$|9$/i", $p)) {
                $bgcolor='bgcolor="#'. $SSstd_row2_background .'"';
            } else {
                $bgcolor='bgcolor="#'. $SSstd_row1_background .'"';
            }
            echo "<TR $bgcolor><TD><font size=1>$p</TD>";
            echo "<TD><a href=\"admin.php?ADD=3&user=$Tuser[$o]\">$Tuser[$o]</a></TD>";
            echo "<TD>$Tfull_name[$o]</TD>";
            if ($enable_vtiger_integration > 0) {
                $stmtV="SELECT id from vtiger_users where user_name='$Tuser[$o]';";
                $rsltV=mysql_to_mysqli($stmtV, $linkV);
                if ($DB) {
                    echo "$stmtV\n";
                }
                $vtu_ct = mysqli_num_rows($rsltV);
                if ($vtu_ct > 0) {
                    $row=mysqli_fetch_row($rsltV);
                    $user_id =        $row[0];
                    $stmtV = "SELECT count(*) FROM vtiger_account where tickersymbol='$territory' and accountid IN(SELECT crmid from vtiger_crmentity where smownerid='$user_id');";
                    $rsltV=mysql_to_mysqli($stmtV, $linkV);
                    if ($DB) {
                        echo "$stmtV\n";
                    }
                    $vca_ct = mysqli_num_rows($rsltV);
                    if ($vca_ct > 0) {
                        $row=mysqli_fetch_row($rsltV);
                        echo "<TD>VT Accounts: $row[0]</TD>";
                    }
                }
            }
            echo "<TD>";
            echo "<form action=$PHP_SELF method=POST>";
            echo "<input type=hidden name=action value=PROCESS_MODIFY_USER_TERRITORY>";
            echo "<input type=hidden name=territory value=\"$territory\">";
            echo "<input type=hidden name=user value=\"$Tuser[$o]\">";
            echo "<select size=1 name=level><option SELECTED>$Tlevel[$o]</option><option value='TOP_AGENT'>"._QXZ("TOP_AGENT")."</option><option value='STANDARD_AGENT'>"._QXZ("STANDARD_AGENT")."</option><option value='BOTTOM_AGENT'>"._QXZ("BOTTOM_AGENT")."</option></select> ";
            echo "<input style='background-color:#$SSbutton_color' type=submit name=SUBMIT value='"._QXZ("SUBMIT")."'>";
            echo "</form>";
            echo "</TD>";
            echo "<TD><a href=\"$PHP_SELF?action=DELETE_USER_TERRITORY&territory=$territory&user=$Tuser[$o]\">"._QXZ("DELETE")."</a></TD>";
            echo "</TR>\n";
            $o++;
        }
        echo "</TABLE>\n";
        echo "<BR><BR><BR>\n";
        echo "<a href=\"$PHP_SELF?action=DELETE_TERRITORY&territory=$territory\">"._QXZ("Delete This Territory")."</a>\n";
        echo "<BR><BR>\n";
    } else {
        echo _QXZ("ERROR: Territory not found").": $territory<BR>\n";
    }
}
if ($action == "LIST_ALL_TERRITORIES") {
    echo "<TABLE><TR><TD>\n";
    echo "<FONT FACE=\"ARIAL,HELVETICA\" COLOR=BLACK SIZE=2>";
    echo "<br>"._QXZ("List All Territories").":\n";
    echo "<center><TABLE width=$section_width cellspacing=0 cellpadding=1>\n";
    echo "<TR BGCOLOR=BLACK>";
    echo "<TD><B><FONT FACE=\"Arial,Helvetica\" size=1 color=white>#</B></TD>";
    echo "<TD><B><FONT FACE=\"Arial,Helvetica\" size=1 color=white>"._QXZ("ID")."</B></TD>";
    echo "<TD><B><FONT FACE=\"Arial,Helvetica\" size=1 color=white>"._QXZ("TERRITORY")."</B></TD>";
    echo "<TD><B><FONT FACE=\"Arial,Helvetica\" size=1 color=white>"._QXZ("DESCRIPTION")."</B></TD>\n";
    echo "<TD><B><FONT FACE=\"Arial,Helvetica\" size=1 color=white>"._QXZ("AGENTS")."</TD>\n";
    echo "<TD><B><FONT FACE=\"Arial,Helvetica\" size=1 color=white>"._QXZ("ACCOUNTS")."</TD>\n";
    if ($enable_vtiger_integration > 0) {
        echo "<TD><B><FONT FACE=\"Arial,Helvetica\" size=1 color=white>"._QXZ("VT ACCOUNTS")."</TD>\n";
    }
    echo "</TR>\n";
    $stmt = "SELECT territory_id,territory,territory_description FROM vicidial_territories order by territory;";
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($DB) {
        echo "$stmt\n";
    }
    $vt_ct = mysqli_num_rows($rslt);
    $i=0;
    while ($vt_ct > $i) {
        $row=mysqli_fetch_row($rslt);
        $Lterritory_id[$i] =            $row[0];
        $Lterritory[$i] =                $row[1];
        $Lterritory_description[$i] =    $row[2];
        $i++;
    }
    $i=0;
    while ($vt_ct > $i) {
        $stmt = "SELECT count(*) FROM vicidial_user_territories where territory='$Lterritory[$i]';";
        $rslt=mysql_to_mysqli($stmt, $link);
        if ($DB) {
            echo "$stmt\n";
        }
        $vut_ct = mysqli_num_rows($rslt);
        if ($vut_ct > 0) {
            $row=mysqli_fetch_row($rslt);
            $Lterritory_count[$i] =            $row[0];
        }
        $stmt = "SELECT count(*) FROM vicidial_list where owner='$Lterritory[$i]';";
        $rslt=mysql_to_mysqli($stmt, $link);
        if ($DB) {
            echo "$stmt\n";
        }
        $VLo_ct = mysqli_num_rows($rslt);
        if ($VLo_ct > 0) {
            $row=mysqli_fetch_row($rslt);
            $Lterritory_owner_count[$i] =    $row[0];
        }
        if ($enable_vtiger_integration > 0) {
            $stmtV = "SELECT count(*) FROM vtiger_account where tickersymbol='$Lterritory[$i]';";
            $rsltV=mysql_to_mysqli($stmtV, $linkV);
            if ($DB) {
                echo "$stmtV\n";
            }
            $va_ct = mysqli_num_rows($rsltV);
            if ($va_ct > 0) {
                $row=mysqli_fetch_row($rsltV);
                $Lvtiger_count[$i] =            $row[0];
            }
        }
        if (preg_match("/1$|3$|5$|7$|9$/i", $i)) {
            $bgcolor='class="records_list_x"';
        } else {
            $bgcolor='class="records_list_y"';
        }
        echo "<tr $bgcolor";
        if ($SSadmin_row_click > 0) {
            echo " onclick=\"window.document.location='$PHP_SELF?action=MODIFY_TERRITORY&territory=$Lterritory[$i]'\"";
        } echo "><td><font size=1>$i</td>";
        echo "<td><font size=1> $Lterritory_id[$i] </td>";
        echo "<td> <a href=\"$PHP_SELF?action=MODIFY_TERRITORY&territory=$Lterritory[$i]\"><font size=1 color=black>$Lterritory[$i]</a></td>";
        echo "<td><font size=1> $Lterritory_description[$i]</td>";
        echo "<td><font size=1> $Lterritory_count[$i]</td>";
        echo "<td><font size=1> $Lterritory_owner_count[$i]</td>";
        if ($enable_vtiger_integration > 0) {
            echo "<td><font size=1> $Lvtiger_count[$i]</td>";
        }
        echo "</tr>\n";
        $i++;
    }
    echo "</TABLE><BR><BR>\n";
    echo "\n";
    echo "</center>\n";
}
?>
<BR><font size=1><?php echo _QXZ("User Territories"); ?> &nbsp; &nbsp; <?php echo _QXZ("VERSION"); ?>: <?php echo $version ?> &nbsp; &nbsp; <?php echo _QXZ("BUILD"); ?>: <?php echo $build ?> &nbsp; &nbsp; </td></tr>
</TD></TR></TABLE>
