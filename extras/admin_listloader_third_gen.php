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
$version = '2.14-49';
$build = '170409-1534';
require("dbconnect_mysqli.php");
require("functions.php");
$US='_';
$PHP_AUTH_USER=$_SERVER['PHP_AUTH_USER'];
$PHP_AUTH_PW=$_SERVER['PHP_AUTH_PW'];
$PHP_SELF=$_SERVER['PHP_SELF'];
$leadfile=$_FILES["leadfile"];
$LF_orig = $_FILES['leadfile']['name'];
$LF_path = $_FILES['leadfile']['tmp_name'];
if (isset($_GET["submit_file"])) {
    $submit_file=$_GET["submit_file"];
} elseif (isset($_POST["submit_file"])) {
    $submit_file=$_POST["submit_file"];
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
if (isset($_GET["leadfile_name"])) {
    $leadfile_name=$_GET["leadfile_name"];
} elseif (isset($_POST["leadfile_name"])) {
    $leadfile_name=$_POST["leadfile_name"];
}
if (isset($_FILES["leadfile"])) {
    $leadfile_name=$_FILES["leadfile"]['name'];
}
if (isset($_GET["file_layout"])) {
    $file_layout=$_GET["file_layout"];
} elseif (isset($_POST["file_layout"])) {
    $file_layout=$_POST["file_layout"];
}
if (isset($_GET["OK_to_process"])) {
    $OK_to_process=$_GET["OK_to_process"];
} elseif (isset($_POST["OK_to_process"])) {
    $OK_to_process=$_POST["OK_to_process"];
}
if (isset($_GET["vendor_lead_code_field"])) {
    $vendor_lead_code_field=$_GET["vendor_lead_code_field"];
} elseif (isset($_POST["vendor_lead_code_field"])) {
    $vendor_lead_code_field=$_POST["vendor_lead_code_field"];
}
if (isset($_GET["source_id_field"])) {
    $source_id_field=$_GET["source_id_field"];
} elseif (isset($_POST["source_id_field"])) {
    $source_id_field=$_POST["source_id_field"];
}
if (isset($_GET["list_id_field"])) {
    $list_id_field=$_GET["list_id_field"];
} elseif (isset($_POST["list_id_field"])) {
    $list_id_field=$_POST["list_id_field"];
}
if (isset($_GET["phone_code_field"])) {
    $phone_code_field=$_GET["phone_code_field"];
} elseif (isset($_POST["phone_code_field"])) {
    $phone_code_field=$_POST["phone_code_field"];
}
if (isset($_GET["phone_number_field"])) {
    $phone_number_field=$_GET["phone_number_field"];
} elseif (isset($_POST["phone_number_field"])) {
    $phone_number_field=$_POST["phone_number_field"];
}
if (isset($_GET["title_field"])) {
    $title_field=$_GET["title_field"];
} elseif (isset($_POST["title_field"])) {
    $title_field=$_POST["title_field"];
}
if (isset($_GET["first_name_field"])) {
    $first_name_field=$_GET["first_name_field"];
} elseif (isset($_POST["first_name_field"])) {
    $first_name_field=$_POST["first_name_field"];
}
if (isset($_GET["middle_initial_field"])) {
    $middle_initial_field=$_GET["middle_initial_field"];
} elseif (isset($_POST["middle_initial_field"])) {
    $middle_initial_field=$_POST["middle_initial_field"];
}
if (isset($_GET["last_name_field"])) {
    $last_name_field=$_GET["last_name_field"];
} elseif (isset($_POST["last_name_field"])) {
    $last_name_field=$_POST["last_name_field"];
}
if (isset($_GET["address1_field"])) {
    $address1_field=$_GET["address1_field"];
} elseif (isset($_POST["address1_field"])) {
    $address1_field=$_POST["address1_field"];
}
if (isset($_GET["address2_field"])) {
    $address2_field=$_GET["address2_field"];
} elseif (isset($_POST["address2_field"])) {
    $address2_field=$_POST["address2_field"];
}
if (isset($_GET["address3_field"])) {
    $address3_field=$_GET["address3_field"];
} elseif (isset($_POST["address3_field"])) {
    $address3_field=$_POST["address3_field"];
}
if (isset($_GET["city_field"])) {
    $city_field=$_GET["city_field"];
} elseif (isset($_POST["city_field"])) {
    $city_field=$_POST["city_field"];
}
if (isset($_GET["state_field"])) {
    $state_field=$_GET["state_field"];
} elseif (isset($_POST["state_field"])) {
    $state_field=$_POST["state_field"];
}
if (isset($_GET["province_field"])) {
    $province_field=$_GET["province_field"];
} elseif (isset($_POST["province_field"])) {
    $province_field=$_POST["province_field"];
}
if (isset($_GET["postal_code_field"])) {
    $postal_code_field=$_GET["postal_code_field"];
} elseif (isset($_POST["postal_code_field"])) {
    $postal_code_field=$_POST["postal_code_field"];
}
if (isset($_GET["country_code_field"])) {
    $country_code_field=$_GET["country_code_field"];
} elseif (isset($_POST["country_code_field"])) {
    $country_code_field=$_POST["country_code_field"];
}
if (isset($_GET["gender_field"])) {
    $gender_field=$_GET["gender_field"];
} elseif (isset($_POST["gender_field"])) {
    $gender_field=$_POST["gender_field"];
}
if (isset($_GET["date_of_birth_field"])) {
    $date_of_birth_field=$_GET["date_of_birth_field"];
} elseif (isset($_POST["date_of_birth_field"])) {
    $date_of_birth_field=$_POST["date_of_birth_field"];
}
if (isset($_GET["alt_phone_field"])) {
    $alt_phone_field=$_GET["alt_phone_field"];
} elseif (isset($_POST["alt_phone_field"])) {
    $alt_phone_field=$_POST["alt_phone_field"];
}
if (isset($_GET["email_field"])) {
    $email_field=$_GET["email_field"];
} elseif (isset($_POST["email_field"])) {
    $email_field=$_POST["email_field"];
}
if (isset($_GET["security_phrase_field"])) {
    $security_phrase_field=$_GET["security_phrase_field"];
} elseif (isset($_POST["security_phrase_field"])) {
    $security_phrase_field=$_POST["security_phrase_field"];
}
if (isset($_GET["comments_field"])) {
    $comments_field=$_GET["comments_field"];
} elseif (isset($_POST["comments_field"])) {
    $comments_field=$_POST["comments_field"];
}
if (isset($_GET["rank_field"])) {
    $rank_field=$_GET["rank_field"];
} elseif (isset($_POST["rank_field"])) {
    $rank_field=$_POST["rank_field"];
}
if (isset($_GET["owner_field"])) {
    $owner_field=$_GET["owner_field"];
} elseif (isset($_POST["owner_field"])) {
    $owner_field=$_POST["owner_field"];
}
if (isset($_GET["list_id_override"])) {
    $list_id_override=$_GET["list_id_override"];
} elseif (isset($_POST["list_id_override"])) {
    $list_id_override=$_POST["list_id_override"];
}
$list_id_override = (preg_replace("/\D/", "", $list_id_override));
if (isset($_GET["lead_file"])) {
    $lead_file=$_GET["lead_file"];
} elseif (isset($_POST["lead_file"])) {
    $lead_file=$_POST["lead_file"];
}
if (isset($_GET["dupcheck"])) {
    $dupcheck=$_GET["dupcheck"];
} elseif (isset($_POST["dupcheck"])) {
    $dupcheck=$_POST["dupcheck"];
}
if (isset($_GET["postalgmt"])) {
    $postalgmt=$_GET["postalgmt"];
} elseif (isset($_POST["postalgmt"])) {
    $postalgmt=$_POST["postalgmt"];
}
if (isset($_GET["phone_code_override"])) {
    $phone_code_override=$_GET["phone_code_override"];
} elseif (isset($_POST["phone_code_override"])) {
    $phone_code_override=$_POST["phone_code_override"];
}
$phone_code_override = (preg_replace("/\D/", "", $phone_code_override));
if (isset($_GET["DB"])) {
    $DB=$_GET["DB"];
} elseif (isset($_POST["DB"])) {
    $DB=$_POST["DB"];
}
if (isset($_GET["usacan_check"])) {
    $usacan_check=$_GET["usacan_check"];
} elseif (isset($_POST["usacan_check"])) {
    $usacan_check=$_POST["usacan_check"];
}
if ($list_id_override == "in_file") {
    $list_id_override = "";
}
if ($phone_code_override == "in_file") {
    $phone_code_override = "";
}
$field_regx = "['\"`\\;]";
$vicidial_list_fields = '|lead_id|vendor_lead_code|source_id|list_id|gmt_offset_now|called_since_last_reset|phone_code|phone_number|title|first_name|middle_initial|last_name|address1|address2|address3|city|state|province|postal_code|country_code|gender|date_of_birth|alt_phone|email|security_phrase|comments|called_count|last_local_call_time|rank|owner|entry_list_id|';
$stmt = "SELECT use_non_latin,admin_web_directory,custom_fields_enabled,webroot_writable FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($DB) {
    echo "$stmt\n";
}
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                $row[0];
    $admin_web_directory =        $row[1];
    $custom_fields_enabled =    $row[2];
    $webroot_writable =            $row[3];
}
if ($non_latin < 1) {
    $PHP_AUTH_USER = preg_replace('/[^0-9a-zA-Z]/', '', $PHP_AUTH_USER);
    $PHP_AUTH_PW = preg_replace('/[^0-9a-zA-Z]/', '', $PHP_AUTH_PW);
} else {
    $PHP_AUTH_PW = preg_replace("/'|\"|\\\\|;/", "", $PHP_AUTH_PW);
    $PHP_AUTH_USER = preg_replace("/'|\"|\\\\|;/", "", $PHP_AUTH_USER);
}
$list_id_override = preg_replace('/[^0-9]/', '', $list_id_override);
$STARTtime = date("U");
$TODAY = date("Y-m-d");
$NOW_TIME = date("Y-m-d H:i:s");
$FILE_datetime = $STARTtime;
$date = date("r");
$ip = getenv("REMOTE_ADDR");
$browser = getenv("HTTP_USER_AGENT");
$auth=0;
$auth_message = user_authorization($PHP_AUTH_USER, $PHP_AUTH_PW, '', 1, 0);
if ($auth_message == 'GOOD') {
    $auth=1;
}
if ($auth < 1) {
    $VDdisplayMESSAGE = "Login incorrect, please try again";
    if ($auth_message == 'LOCK') {
        $VDdisplayMESSAGE = "Too many login attempts, try again in 15 minutes";
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
$stmt="SELECT load_leads,user_group from vicidial_users where user='$PHP_AUTH_USER';";
$rslt=mysql_to_mysqli($stmt, $link);
$row=mysqli_fetch_row($rslt);
$LOGload_leads =    $row[0];
$LOGuser_group =    $row[1];
if ($LOGload_leads < 1) {
    Header("Content-type: text/html; charset=utf-8");
    echo "You do not have permissions to load leads\n";
    exit;
}
if (preg_match("/;|:|\/|\^|\[|\]|\"|\'|\*/", $LF_orig)) {
    echo "ERROR: Invalid File Name: $LF_orig\n";
    exit;
}
$stmt="SELECT allowed_campaigns,allowed_reports,admin_viewable_groups,admin_viewable_call_times from vicidial_user_groups where user_group='$LOGuser_group';";
if ($DB) {
    echo "|$stmt|\n";
}
$rslt=mysql_to_mysqli($stmt, $link);
$row=mysqli_fetch_row($rslt);
$LOGallowed_campaigns =            $row[0];
$LOGallowed_reports =            $row[1];
$LOGadmin_viewable_groups =        $row[2];
$LOGadmin_viewable_call_times =    $row[3];
$camp_lists='';
$LOGallowed_campaignsSQL='';
$whereLOGallowed_campaignsSQL='';
if (!preg_match('/\-ALL/i', $LOGallowed_campaigns)) {
    $rawLOGallowed_campaignsSQL = preg_replace("/ -/", '', $LOGallowed_campaigns);
    $rawLOGallowed_campaignsSQL = preg_replace("/ /", "','", $rawLOGallowed_campaignsSQL);
    $LOGallowed_campaignsSQL = "and campaign_id IN('$rawLOGallowed_campaignsSQL')";
    $whereLOGallowed_campaignsSQL = "where campaign_id IN('$rawLOGallowed_campaignsSQL')";
}
$regexLOGallowed_campaigns = " $LOGallowed_campaigns ";
$script_name = getenv("SCRIPT_NAME");
$server_name = getenv("SERVER_NAME");
$server_port = getenv("SERVER_PORT");
if (preg_match("/443/i", $server_port)) {
    $HTTPprotocol = 'https://';
} else {
    $HTTPprotocol = 'http://';
}
$admDIR = "$HTTPprotocol$server_name$script_name";
$admDIR = preg_replace('/admin_listloader_third_gen\.php/i', '', $admDIR);
$admSCR = 'admin.php';
$NWB = " &nbsp; <a href=\"javascript:openNewWindow('help.php?ADD=99999";
$NWE = "')\"><IMG SRC=\"help.gif\" WIDTH=20 HEIGHT=20 BORDER=0 ALT=\"HELP\" ALIGN=TOP></A>";
$secX = date("U");
$hour = date("H");
$min = date("i");
$sec = date("s");
$mon = date("m");
$mday = date("d");
$year = date("Y");
$isdst = date("I");
$Shour = date("H");
$Smin = date("i");
$Ssec = date("s");
$Smon = date("m");
$Smday = date("d");
$Syear = date("Y");
$pulldate0 = "$year-$mon-$mday $hour:$min:$sec";
$inSD = $pulldate0;
$dsec = ((($hour * 3600) + ($min * 60)) + $sec);
$stmt="SELECT local_gmt FROM servers where server_ip = '$server_ip';";
$rslt=mysql_to_mysqli($stmt, $link);
$gmt_recs = mysqli_num_rows($rslt);
if ($gmt_recs > 0) {
    $row=mysqli_fetch_row($rslt);
    $DBSERVER_GMT        =        "$row[0]";
    if (strlen($DBSERVER_GMT)>0) {
        $SERVER_GMT = $DBSERVER_GMT;
    }
    if ($isdst) {
        $SERVER_GMT++;
    }
} else {
    $SERVER_GMT = date("O");
    $SERVER_GMT = preg_replace('/\+/i', '', $SERVER_GMT);
    $SERVER_GMT = ($SERVER_GMT + 0);
    $SERVER_GMT = ($SERVER_GMT / 100);
}
$LOCAL_GMT_OFF = $SERVER_GMT;
$LOCAL_GMT_OFF_STD = $SERVER_GMT;
echo "<html>\n";
echo "<head>\n";
echo "<!-- VERSION: $version     BUILD: $build -->\n";
echo "<!-- SEED TIME  $secX:   $year-$mon-$mday $hour:$min:$sec  LOCAL GMT OFFSET NOW: $LOCAL_GMT_OFF  DST: $isdst -->\n";
function macfontfix($fontsize)
{
    $browser = getenv("HTTP_USER_AGENT");
    $pctype = explode("(", $browser);
    if (preg_match('/Mac/', $pctype[1])) {
        /* Browser is a Mac.  If not Netscape 6, raise fonts */
        $blownbrowser = explode('/', $browser);
        $ver = explode(' ', $blownbrowser[1]);
        $ver = $ver[0];
        if ($ver >= 5.0) {
            return $fontsize;
        } else {
            return ($fontsize+2);
        }
    } else {
        return $fontsize;
    }    /* Browser is not a Mac - don't touch fonts */
}
echo "<style type=\"text/css\">\n
<!--\n
.title {  font-family: Arial, Helvetica, sans-serif; font-size: ".macfontfix(18)."pt}\n
.standard {  font-family: Arial, Helvetica, sans-serif; font-size: ".macfontfix(10)."pt}\n
.small_standard {  font-family: Arial, Helvetica, sans-serif; font-size: ".macfontfix(8)."pt}\n
.tiny_standard {  font-family: Arial, Helvetica, sans-serif; font-size: ".macfontfix(6)."pt}\n
.standard_bold {  font-family: Arial, Helvetica, sans-serif; font-size: ".macfontfix(10)."pt; font-weight: bold}\n
.standard_header {  font-family: Arial, Helvetica, sans-serif; font-size: ".macfontfix(14)."pt; font-weight: bold}\n
.standard_bold_highlight {  font-family: Arial, Helvetica, sans-serif; font-size: ".macfontfix(10)."pt; font-weight: bold; color: white; BACKGROUND-COLOR: black}\n
.standard_bold_blue_highlight {  font-family: Arial, Helvetica, sans-serif; font-size: 10pt; font-weight: bold; BACKGROUND-COLOR: blue}\n
A.employee_standard {  font-family: garamond, sans-serif; font-size: ".macfontfix(10)."pt; font-style: normal; font-variant: normal; font-weight: bold; text-decoration: none}\n
.employee_standard {  font-family: garamond, sans-serif; font-size: ".macfontfix(10)."pt; font-weight: bold}\n
.employee_title {  font-family: Garamond, sans-serif; font-size: ".macfontfix(14)."pt; font-weight: bold}\n
\\\\-->\n
</style>\n";
?>
<script language="JavaScript1.2">
function openNewWindow(url) 
    {
    window.open (url,"",'width=700,height=300,scrollbars=yes,menubar=yes,address=yes');
    }
function ShowProgress(good, bad, total, dup, inv, post) 
    {
    parent.lead_count.document.open();
    parent.lead_count.document.write('<html><body><table border=0 width=200 cellpadding=10 cellspacing=0 align=center valign=top><tr bgcolor="#000000"><th colspan=2><font face="arial, helvetica" size=3 color=white>Current file status:</font></th></tr><tr bgcolor="#009900"><td align=right><font face="arial, helvetica" size=2 color=white><B>Good:</B></font></td><td align=left><font face="arial, helvetica" size=2 color=white><B>'+good+'</B></font></td></tr><tr bgcolor="#990000"><td align=right><font face="arial, helvetica" size=2 color=white><B>Bad:</B></font></td><td align=left><font face="arial, helvetica" size=2 color=white><B>'+bad+'</B></font></td></tr><tr bgcolor="#000099"><td align=right><font face="arial, helvetica" size=2 color=white><B>Total:</B></font></td><td align=left><font face="arial, helvetica" size=2 color=white><B>'+total+'</B></font></td></tr><tr bgcolor="#009900"><td align=right><font face="arial, helvetica" size=2 color=white><B> &nbsp; </B></font></td><td align=left><font face="arial, helvetica" size=2 color=white><B> &nbsp; </B></font></td></tr><tr bgcolor="#009900"><td align=right><font face="arial, helvetica" size=2 color=white><B>Duplicate:</B></font></td><td align=left><font face="arial, helvetica" size=2 color=white><B>'+dup+'</B></font></td></tr></tr><tr bgcolor="#009900"><td align=right><font face="arial, helvetica" size=2 color=white><B>Invalid:</B></font></td><td align=left><font face="arial, helvetica" size=2 color=white><B>'+inv+'</B></font></td></tr><tr bgcolor="#009900"><td align=right><font face="arial, helvetica" size=2 color=white><B>Postal Match:</B></font></td><td align=left><font face="arial, helvetica" size=2 color=white><B>'+post+'</B></font></td></tr></table><body></html>');
    parent.lead_count.document.close();
    }
function ParseFileName() 
    {
    if (!document.forms[0].OK_to_process) 
        {    
        var endstr=document.forms[0].leadfile.value.lastIndexOf('\\');
        if (endstr>-1) 
            {
            endstr++;
            var filename=document.forms[0].leadfile.value.substring(endstr);
            document.forms[0].leadfile_name.value=filename;
            }
        }
    }
</script>
<title>ADMINISTRATION: Lead Loader</title>
</head>
<BODY BGCOLOR=WHITE marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>
<?php
$short_header=1;
require("admin_header.php");
echo "<TABLE CELLPADDING=4 CELLSPACING=0><TR><TD>";
if ((!$OK_to_process) or (($leadfile) and ($file_layout!="standard"))) {
    ?>
    <form action=<?php echo $PHP_SELF ?> method=post onSubmit="ParseFileName()" enctype="multipart/form-data">
    <input type=hidden name='leadfile_name' value="<?php echo $leadfile_name ?>">
    <input type=hidden name='DB' value="<?php echo $DB ?>">
    <?php
    if ($file_layout!="custom") {
        ?>
        <table align=center width="700" border=0 cellpadding=5 cellspacing=0 bgcolor=#D9E6FE>
          <tr>
            <td align=right width="35%"><B><font face="arial, helvetica" size=2>Load leads from this file:</font></B></td>
            <td align=left width="65%"><input type=file name="leadfile" value="<?php echo $leadfile ?>"> <?php echo "$NWB#vicidial_list_loader$NWE"; ?></td>
          </tr>
          <tr>
            <td align=right width="25%"><font face="arial, helvetica" size=2>List ID Override: </font></td>
            <td align=left width="75%"><font face="arial, helvetica" size=1>
            <select name='list_id_override'>
            <option value='in_file' selected='yes'>Load from Lead File</option>
            <?php
            $stmt="SELECT list_id, list_name from vicidial_lists $whereLOGallowed_campaignsSQL order by list_id;";
        $rslt=mysql_to_mysqli($stmt, $link);
        $num_rows = mysqli_num_rows($rslt);
        $count=0;
        while ($num_rows > $count) {
            $row = mysqli_fetch_row($rslt);
            echo "<option value=\'$row[0]\'>$row[0] - $row[1]</option>\n";
            $count++;
        }
        ?>
            </select>
            </font></td>
          </tr>
          <tr>
            <td align=right width="25%"><font face="arial, helvetica" size=2>Phone Code Override: </font></td>
            <td align=left width="75%"><font face="arial, helvetica" size=1>
            <select name='phone_code_override'>
                        <option value='in_file' selected='yes'>Load from Lead File</option>
            <?php
        $stmt="select distinct country_code, country from vicidial_phone_codes;";
        $rslt=mysql_to_mysqli($stmt, $link);
        $num_rows = mysqli_num_rows($rslt);
        $count=0;
        while ($num_rows > $count) {
            $row = mysqli_fetch_row($rslt);
            echo "<option value=\'$row[0]\'>$row[0] - $row[1]</option>\n";
            $count++;
        }
        ?>
            </select>
            </font></td>
          </tr>
          <tr>
            <td align=right><B><font face="arial, helvetica" size=2>File layout to use:</font></B></td>
            <td align=left><font face="arial, helvetica" size=2><input type=radio name="file_layout" value="standard" checked>Standard Format&nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name="file_layout" value="custom">Custom layout</td>
          </tr>
          <tr>
            <td align=right width="25%"><font face="arial, helvetica" size=2>Lead Duplicate Check: </font></td>
            <td align=left width="75%"><font face="arial, helvetica" size=1><select size=1 name=dupcheck>
            <option selected value="NONE">NO DUPLICATE CHECK</option>
            <option value="DUPLIST">CHECK FOR DUPLICATES BY PHONE IN LIST ID</option>
            <option value="DUPCAMP">CHECK FOR DUPLICATES BY PHONE IN ALL CAMPAIGN LISTS</option>
            <option value="DUPSYS">CHECK FOR DUPLICATES BY PHONE IN ENTIRE SYSTEM</option>
            <option value="DUPTITLEALTPHONELIST">CHECK FOR DUPLICATES BY TITLE/ALT-PHONE IN LIST ID</option>
            <option value="DUPTITLEALTPHONESYS">CHECK FOR DUPLICATES BY TITLE/ALT-PHONE IN ENTIRE SYSTEM</option>
            </select></td>
          </tr>
          <tr>
            <td align=right width="25%"><font face="arial, helvetica" size=2>USA-Canada Check: </font></td>
            <td align=left width="75%"><font face="arial, helvetica" size=1><select size=1 name=usacan_check>
            <option selected value="NONE">NO USACAN VALID CHECK</option>
            <option value="PREFIX">CHECK FOR VALID PREFIX</option>
            <option value="AREACODE">CHECK FOR VALID AREACODE</option>
            <option value="PREFIX_AREACODE">CHECK FOR VALID PREFIX and AREACODE</option>
            </select></td>
          </tr>
          <tr>
            <td align=right width="25%"><font face="arial, helvetica" size=2>Lead Time Zone Lookup: </font></td>
            <td align=left width="75%"><font face="arial, helvetica" size=1><select size=1 name=postalgmt><option selected value="AREA">COUNTRY CODE AND AREA CODE ONLY</option><option value="POSTAL">POSTAL CODE FIRST</option><option value="TZCODE">OWNER TIME ZONE CODE FIRST</option></select></td>
          </tr>
        <tr>
            <td align=center colspan=2><input type=submit value="SUBMIT" name='submit_file'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=button onClick="javascript:document.location='admin_listloader_third_gen.php'" value="START OVER" name='reload_page'></td>
          </tr>
          <tr><td align=left><font size=1> &nbsp; &nbsp; &nbsp; &nbsp; <a href="admin.php?ADD=100" target="_parent">BACK TO ADMIN</a> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font></td><td align=right><font size=1>LIST LOADER 3rd Gen- &nbsp; &nbsp; VERSION: <?php echo $version ?> &nbsp; &nbsp; BUILD: <?php echo $build ?> &nbsp; &nbsp; </td></tr>
        </table>
        <?php
    }
} else {
    ?>
    <table align=center width="700" border=0 cellpadding=5 cellspacing=0 bgcolor=#D9E6FE>
    <tr>
    <td align=right width="35%"><B><font face="arial, helvetica" size=2>Lead file:</font></B></td>
    <td align=left width="75%"><font face="arial, helvetica" size=2><?php echo $leadfile_name ?></font></td>
    </tr>
    <tr>
    <td align=right width="35%"><B><font face="arial, helvetica" size=2>List ID Override:</font></B></td>
    <td align=left width="75%"><font face="arial, helvetica" size=2><?php echo $list_id_override ?></font></td>
    </tr>
    <tr>
    <td align=right width="35%"><B><font face="arial, helvetica" size=2>Phone Code Override:</font></B></td>
    <td align=left width="75%"><font face="arial, helvetica" size=2><?php echo $phone_code_override ?></font></td>
    </tr>
    <tr>
    <td align=right width="35%"><B><font face="arial, helvetica" size=2>USA-Canada Check:</font></B></td>
    <td align=left width="75%"><font face="arial, helvetica" size=2><?php echo $usacan_check ?></font></td>
    </tr>
    <tr>
    <td align=right width="35%"><B><font face="arial, helvetica" size=2>Lead Duplicate Check:</font></B></td>
    <td align=left width="75%"><font face="arial, helvetica" size=2><?php echo $dupcheck ?></font></td>
    </tr>
    <tr>
    <td align=right width="35%"><B><font face="arial, helvetica" size=2>Lead Time Zone Lookup:</font></B></td>
    <td align=left width="75%"><font face="arial, helvetica" size=2><?php echo $postalgmt ?></font></td>
    </tr>
    <tr>
    <td align=center colspan=2><B><font face="arial, helvetica" size=2>
    <form action=<?php echo $PHP_SELF ?> method=post onSubmit="ParseFileName()" enctype="multipart/form-data">
    <input type=hidden name='leadfile_name' value="<?php echo $leadfile_name ?>">
    <input type=hidden name='DB' value="<?php echo $DB ?>">
    <a href="admin_listloader_third_gen.php">Load Another Lead File</a> &nbsp; &nbsp; &nbsp; &nbsp;</font></B> <font size=1>VERSION: <?php echo $version ?> &nbsp; &nbsp; BUILD: <?php echo $build ?>
    </font></td>
    </tr></table>
    <BR><BR><BR><BR>
    <?php
}
if ($OK_to_process) {
    print "<script language='JavaScript1.2'>document.forms[0].leadfile.disabled=true;document.forms[0].list_id_override.disabled=true;document.forms[0].phone_code_override.disabled=true; document.forms[0].submit_file.disabled=true; document.forms[0].reload_page.disabled=true;</script>";
    flush();
    $total=0;
    $good=0;
    $bad=0;
    $dup=0;
    $post=0;
    $phone_list='';
    $file=fopen("$lead_file", "r");
    if ($webroot_writable > 0) {
        $stmt_file=fopen("listloader_stmts.txt", "w");
    }
    $buffer=fgets($file, 4096);
    $tab_count=substr_count($buffer, "\t");
    $pipe_count=substr_count($buffer, "|");
    if ($tab_count>$pipe_count) {
        $delimiter="\t";
        $delim_name="tab";
    } else {
        $delimiter="|";
        $delim_name="pipe";
    }
    $field_check=explode($delimiter, $buffer);
    if (count($field_check)>=2) {
        flush();
        $file=fopen("$lead_file", "r");
        print "<center><font face='arial, helvetica' size=3 color='#009900'><B>Processing file...\n";
        if (strlen($list_id_override)>0) {
            print "<BR><BR>LIST ID OVERRIDE FOR THIS FILE: $list_id_override<BR><BR>";
        }
        if (strlen($phone_code_override)>0) {
            print "<BR><BR>PHONE CODE OVERRIDE FOR THIS FILE: $phone_code_override<BR><BR>";
        }
        if ($custom_fields_enabled > 0) {
            $tablecount_to_print=0;
            $fieldscount_to_print=0;
            $fields_to_print=0;
            $stmt="SHOW TABLES LIKE \"custom_$list_id_override\";";
            if ($DB>0) {
                echo "$stmt\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
            $tablecount_to_print = mysqli_num_rows($rslt);
            if ($tablecount_to_print > 0) {
                $stmt="SELECT count(*) from vicidial_lists_fields where list_id='$list_id_override';";
                if ($DB>0) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $fieldscount_to_print = mysqli_num_rows($rslt);
                if ($fieldscount_to_print > 0) {
                    $stmt="SELECT field_label,field_type from vicidial_lists_fields where list_id='$list_id_override' order by field_rank,field_order,field_label;";
                    if ($DB>0) {
                        echo "$stmt\n";
                    }
                    $rslt=mysql_to_mysqli($stmt, $link);
                    $fields_to_print = mysqli_num_rows($rslt);
                    $fields_list='';
                    $o=0;
                    while ($fields_to_print > $o) {
                        $rowx=mysqli_fetch_row($rslt);
                        $A_field_label[$o] =    $rowx[0];
                        $A_field_type[$o] =        $rowx[1];
                        $A_field_value[$o] =    '';
                        $o++;
                    }
                }
            }
        }
        while (!feof($file)) {
            $record++;
            $buffer=rtrim(fgets($file, 4096));
            $buffer=stripslashes($buffer);
            if (strlen($buffer)>0) {
                $row=explode($delimiter, preg_replace('/[\'\"]/i', '', $buffer));
                $pulldate=date("Y-m-d H:i:s");
                $entry_date =            "$pulldate";
                $modify_date =            "";
                $status =                "NEW";
                $user ="";
                $vendor_lead_code =        $row[$vendor_lead_code_field];
                $source_code =            $row[$source_id_field];
                $source_id=$source_code;
                $list_id =                $row[$list_id_field];
                $gmt_offset =            '0';
                $called_since_last_reset='N';
                $phone_code =            preg_replace('/[^0-9]/i', '', $row[$phone_code_field]);
                $phone_number =            preg_replace('/[^0-9]/i', '', $row[$phone_number_field]);
                $title =                $row[$title_field];
                $first_name =            $row[$first_name_field];
                $middle_initial =        $row[$middle_initial_field];
                $last_name =            $row[$last_name_field];
                $address1 =                $row[$address1_field];
                $address2 =                $row[$address2_field];
                $address3 =                $row[$address3_field];
                $city =$row[$city_field];
                $state =                $row[$state_field];
                $province =                $row[$province_field];
                $postal_code =            $row[$postal_code_field];
                $country_code =            $row[$country_code_field];
                $gender =                $row[$gender_field];
                $date_of_birth =        $row[$date_of_birth_field];
                $alt_phone =            preg_replace('/[^0-9]/i', '', $row[$alt_phone_field]);
                $email =                $row[$email_field];
                $security_phrase =        $row[$security_phrase_field];
                $comments =                trim($row[$comments_field]);
                $rank =                    $row[$rank_field];
                $owner =                $row[$owner_field];
                $vendor_lead_code =        preg_replace("/$field_regx/i", "", $vendor_lead_code);
                $source_code =            preg_replace("/$field_regx/i", "", $source_code);
                $source_id =             preg_replace("/$field_regx/i", "", $source_id);
                $list_id =                preg_replace("/$field_regx/i", "", $list_id);
                $phone_code =            preg_replace("/$field_regx/i", "", $phone_code);
                $phone_number =            preg_replace("/$field_regx/i", "", $phone_number);
                $title =                preg_replace("/$field_regx/i", "", $title);
                $first_name =            preg_replace("/$field_regx/i", "", $first_name);
                $middle_initial =        preg_replace("/$field_regx/i", "", $middle_initial);
                $last_name =            preg_replace("/$field_regx/i", "", $last_name);
                $address1 =                preg_replace("/$field_regx/i", "", $address1);
                $address2 =                preg_replace("/$field_regx/i", "", $address2);
                $address3 =                preg_replace("/$field_regx/i", "", $address3);
                $city =                    preg_replace("/$field_regx/i", "", $city);
                $state =                preg_replace("/$field_regx/i", "", $state);
                $province =                preg_replace("/$field_regx/i", "", $province);
                $postal_code =            preg_replace("/$field_regx/i", "", $postal_code);
                $country_code =            preg_replace("/$field_regx/i", "", $country_code);
                $gender =                preg_replace("/$field_regx/i", "", $gender);
                $date_of_birth =        preg_replace("/$field_regx/i", "", $date_of_birth);
                $alt_phone =            preg_replace("/$field_regx/i", "", $alt_phone);
                $email =                preg_replace("/$field_regx/i", "", $email);
                $security_phrase =        preg_replace("/$field_regx/i", "", $security_phrase);
                $comments =                preg_replace("/$field_regx/i", "", $comments);
                $rank =                    preg_replace("/$field_regx/i", "", $rank);
                $owner =                preg_replace("/$field_regx/i", "", $owner);
                $USarea =             substr($phone_number, 0, 3);
                if (strlen($list_id_override)>0) {
                    $list_id = $list_id_override;
                }
                if (strlen($phone_code_override)>0) {
                    $phone_code = $phone_code_override;
                }
                $custom_SQL='';
                if ($custom_fields_enabled > 0) {
                    if ($tablecount_to_print > 0) {
                        if ($fieldscount_to_print > 0) {
                            $o=0;
                            while ($fields_to_print > $o) {
                                $A_field_value[$o] =    '';
                                $field_name_id = $A_field_label[$o] . "_field";
                                if (($A_field_type[$o]!='DISPLAY') and ($A_field_type[$o]!='SCRIPT')) {
                                    if (!preg_match("/\|$A_field_label[$o]\|/", $vicidial_list_fields)) {
                                        if (isset($_GET["$field_name_id"])) {
                                            $form_field_value=$_GET["$field_name_id"];
                                        } elseif (isset($_POST["$field_name_id"])) {
                                            $form_field_value=$_POST["$field_name_id"];
                                        }
                                        if ($form_field_value >= 0) {
                                            $A_field_value[$o] =    $row[$form_field_value];
                                            $A_field_value[$o] =    preg_replace("/$field_regx/i", "", $A_field_value[$o]);
                                            $custom_SQL .= "$A_field_label[$o]='$A_field_value[$o]',";
                                        }
                                    }
                                }
                                $o++;
                            }
                        }
                    }
                }
                $custom_SQL = preg_replace("/,$/", "", $custom_SQL);
                if (preg_match("/DUPCAMP/i", $dupcheck)) {
                    $dup_lead=0;
                    $dup_lists='';
                    $stmt="select campaign_id from vicidial_lists where list_id='$list_id';";
                    $rslt=mysql_to_mysqli($stmt, $link);
                    $ci_recs = mysqli_num_rows($rslt);
                    if ($ci_recs > 0) {
                        $row=mysqli_fetch_row($rslt);
                        $dup_camp =            $row[0];
                        $stmt="select list_id from vicidial_lists where campaign_id='$dup_camp';";
                        $rslt=mysql_to_mysqli($stmt, $link);
                        $li_recs = mysqli_num_rows($rslt);
                        if ($li_recs > 0) {
                            $L=0;
                            while ($li_recs > $L) {
                                $row=mysqli_fetch_row($rslt);
                                $dup_lists .=    "'$row[0]',";
                                $L++;
                            }
                            $dup_lists = preg_replace('/,$/i', '', $dup_lists);
                            $stmt="select list_id from vicidial_list where phone_number='$phone_number' and list_id IN($dup_lists) limit 1;";
                            $rslt=mysql_to_mysqli($stmt, $link);
                            $pc_recs = mysqli_num_rows($rslt);
                            if ($pc_recs > 0) {
                                $dup_lead=1;
                                $row=mysqli_fetch_row($rslt);
                                $dup_lead_list =    $row[0];
                            }
                            if ($dup_lead < 1) {
                                if (preg_match("/$phone_number$US$list_id/i", $phone_list)) {
                                    $dup_lead++;
                                    $dup++;
                                }
                            }
                        }
                    }
                }
                if (preg_match("/DUPSYS/i", $dupcheck)) {
                    $dup_lead=0;
                    $stmt="select list_id from vicidial_list where phone_number='$phone_number';";
                    $rslt=mysql_to_mysqli($stmt, $link);
                    $pc_recs = mysqli_num_rows($rslt);
                    if ($pc_recs > 0) {
                        $dup_lead=1;
                        $row=mysqli_fetch_row($rslt);
                        $dup_lead_list =    $row[0];
                    }
                    if ($dup_lead < 1) {
                        if (preg_match("/$phone_number$US$list_id/i", $phone_list)) {
                            $dup_lead++;
                            $dup++;
                        }
                    }
                }
                if (preg_match("/DUPLIST/i", $dupcheck)) {
                    $dup_lead=0;
                    $stmt="select count(*) from vicidial_list where phone_number='$phone_number' and list_id='$list_id';";
                    $rslt=mysql_to_mysqli($stmt, $link);
                    $pc_recs = mysqli_num_rows($rslt);
                    if ($pc_recs > 0) {
                        $row=mysqli_fetch_row($rslt);
                        $dup_lead =            $row[0];
                        $dup_lead_list =    $list_id;
                    }
                    if ($dup_lead < 1) {
                        if (preg_match("/$phone_number$US$list_id/i", $phone_list)) {
                            $dup_lead++;
                            $dup++;
                        }
                    }
                }
                if (preg_match("/DUPTITLEALTPHONELIST/i", $dupcheck)) {
                    $dup_lead=0;
                    $stmt="select count(*) from vicidial_list where title='$title' and alt_phone='$alt_phone' and list_id='$list_id';";
                    $rslt=mysql_to_mysqli($stmt, $link);
                    $pc_recs = mysqli_num_rows($rslt);
                    if ($pc_recs > 0) {
                        $row=mysqli_fetch_row($rslt);
                        $dup_lead =            $row[0];
                        $dup_lead_list =    $list_id;
                    }
                    if ($dup_lead < 1) {
                        if (preg_match("/$alt_phone$title$US$list_id/i", $phone_list)) {
                            $dup_lead++;
                            $dup++;
                        }
                    }
                }
                if (preg_match("/DUPTITLEALTPHONESYS/i", $dupcheck)) {
                    $dup_lead=0;
                    $stmt="select list_id from vicidial_list where title='$title' and alt_phone='$alt_phone';";
                    $rslt=mysql_to_mysqli($stmt, $link);
                    $pc_recs = mysqli_num_rows($rslt);
                    if ($pc_recs > 0) {
                        $dup_lead=1;
                        $row=mysqli_fetch_row($rslt);
                        $dup_lead_list =    $row[0];
                    }
                    if ($dup_lead < 1) {
                        if (preg_match("/$alt_phone$title$US$list_id/i", $phone_list)) {
                            $dup_lead++;
                            $dup++;
                        }
                    }
                }
                $valid_number=1;
                if ((strlen($phone_number)<6) || (strlen($phone_number)>16)) {
                    $valid_number=0;
                    $invalid_reason = "INVALID PHONE NUMBER LENGTH";
                }
                if ((preg_match("/PREFIX/", $usacan_check)) and ($valid_number > 0)) {
                    $USprefix =     substr($phone_number, 3, 1);
                    if ($DB>0) {
                        echo "DEBUG: usacan prefix check - $USprefix|$phone_number\n";
                    }
                    if ($USprefix < 2) {
                        $valid_number=0;
                        $invalid_reason = "INVALID PHONE NUMBER PREFIX";
                    }
                }
                if ((preg_match("/AREACODE/", $usacan_check)) and ($valid_number > 0)) {
                    $phone_areacode = substr($phone_number, 0, 3);
                    $stmt = "select count(*) from vicidial_phone_codes where areacode='$phone_areacode' and country_code='1';";
                    if ($DB>0) {
                        echo "DEBUG: usacan areacode query - $stmt\n";
                    }
                    $rslt=mysql_to_mysqli($stmt, $link);
                    $row=mysqli_fetch_row($rslt);
                    $valid_number=$row[0];
                    if ($valid_number < 1) {
                        $invalid_reason = "INVALID PHONE NUMBER AREACODE";
                    }
                }
                if (($valid_number>0) and ($dup_lead<1) and ($list_id >= 100)) {
                    if (strlen($phone_code)<1) {
                        $phone_code = '1';
                    }
                    if (preg_match("/TITLEALTPHONE/i", $dupcheck)) {
                        $phone_list .= "$alt_phone$title$US$list_id|";
                    } else {
                        $phone_list .= "$phone_number$US$list_id|";
                    }
                    $gmt_offset = lookup_gmt($phone_code, $USarea, $state, $LOCAL_GMT_OFF_STD, $Shour, $Smin, $Ssec, $Smon, $Smday, $Syear, $postalgmt, $postal_code, $owner);
                    if (strlen($custom_SQL)>3) {
                        $stmtZ = "INSERT INTO vicidial_list (lead_id,entry_date,modify_date,status,user,vendor_lead_code,source_id,list_id,gmt_offset_now,called_since_last_reset,phone_code,phone_number,title,first_name,middle_initial,last_name,address1,address2,address3,city,state,province,postal_code,country_code,gender,date_of_birth,alt_phone,email,security_phrase,comments,called_count,last_local_call_time,rank,owner,entry_list_id) values('','$entry_date','$modify_date','$status','$user','$vendor_lead_code','$source_id','$list_id','$gmt_offset','$called_since_last_reset','$phone_code','$phone_number','$title','$first_name','$middle_initial','$last_name','$address1','$address2','$address3','$city','$state','$province','$postal_code','$country_code','$gender','$date_of_birth','$alt_phone','$email','$security_phrase','$comments',0,'2008-01-01 00:00:00','$rank','$owner','$list_id');";
                        $rslt=mysql_to_mysqli($stmtZ, $link);
                        $affected_rows = mysqli_affected_rows($link);
                        $lead_id = mysqli_insert_id($link);
                        if ($DB > 0) {
                            echo "<!-- $affected_rows|$lead_id|$stmtZ -->";
                        }
                        if ($webroot_writable > 0) {
                            fwrite($stmt_file, $stmtZ."\r\n");
                        }
                        $multistmt='';
                        $custom_SQL_query = "INSERT INTO custom_$list_id_override SET lead_id='$lead_id',$custom_SQL;";
                        $rslt=mysql_to_mysqli($custom_SQL_query, $link);
                        $affected_rows = mysqli_affected_rows($link);
                        if ($DB > 0) {
                            echo "<!-- $affected_rows|$custom_SQL_query -->";
                        }
                    } else {
                        if ($multi_insert_counter > 8) {
                            $stmtZ = "INSERT INTO vicidial_list (lead_id,entry_date,modify_date,status,user,vendor_lead_code,source_id,list_id,gmt_offset_now,called_since_last_reset,phone_code,phone_number,title,first_name,middle_initial,last_name,address1,address2,address3,city,state,province,postal_code,country_code,gender,date_of_birth,alt_phone,email,security_phrase,comments,called_count,last_local_call_time,rank,owner,entry_list_id) values$multistmt('','$entry_date','$modify_date','$status','$user','$vendor_lead_code','$source_id','$list_id','$gmt_offset','$called_since_last_reset','$phone_code','$phone_number','$title','$first_name','$middle_initial','$last_name','$address1','$address2','$address3','$city','$state','$province','$postal_code','$country_code','$gender','$date_of_birth','$alt_phone','$email','$security_phrase','$comments',0,'2008-01-01 00:00:00','$rank','$owner','0');";
                            $rslt=mysql_to_mysqli($stmtZ, $link);
                            if ($webroot_writable > 0) {
                                fwrite($stmt_file, $stmtZ."\r\n");
                            }
                            $multistmt='';
                            $multi_insert_counter=0;
                        } else {
                            $multistmt .= "('','$entry_date','$modify_date','$status','$user','$vendor_lead_code','$source_id','$list_id','$gmt_offset','$called_since_last_reset','$phone_code','$phone_number','$title','$first_name','$middle_initial','$last_name','$address1','$address2','$address3','$city','$state','$province','$postal_code','$country_code','$gender','$date_of_birth','$alt_phone','$email','$security_phrase','$comments',0,'2008-01-01 00:00:00','$rank','$owner','0'),";
                            $multi_insert_counter++;
                        }
                    }
                    $good++;
                } else {
                    if ($bad < 1000000) {
                        if ($list_id < 100) {
                            print "<BR></b><font size=1 color=red>record $total BAD- PHONE: $phone_number ROW: |$row[0]| INVALID LIST ID</font><b>\n";
                        } else {
                            if ($valid_number < 1) {
                                print "<BR></b><font size=1 color=red>record $total BAD- PHONE: $phone_number ROW: |$row[0]| INV: $phone_number</font><b>\n";
                            } else {
                                print "<BR></b><font size=1 color=red>record $total BAD- PHONE: $phone_number ROW: |$row[0]| DUP: $dup_lead  $dup_lead_list</font><b>\n";
                            }
                        }
                    }
                    $bad++;
                }
                $total++;
                if ($total%100==0) {
                    print "<script language='JavaScript1.2'>ShowProgress($good, $bad, $total, $dup, $inv, $post)</script>";
                    usleep(1000);
                    flush();
                }
            }
        }
        if ($multi_insert_counter!=0) {
            $stmtZ = "INSERT INTO vicidial_list (lead_id,entry_date,modify_date,status,user,vendor_lead_code,source_id,list_id,gmt_offset_now,called_since_last_reset,phone_code,phone_number,title,first_name,middle_initial,last_name,address1,address2,address3,city,state,province,postal_code,country_code,gender,date_of_birth,alt_phone,email,security_phrase,comments,called_count,last_local_call_time,rank,owner,entry_list_id) values".substr($multistmt, 0, -1).";";
            mysql_to_mysqli($stmtZ, $link);
            if ($webroot_writable > 0) {
                fwrite($stmt_file, $stmtZ."\r\n");
            }
        }
        $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$PHP_AUTH_USER', ip_address='$ip', event_section='LISTS', event_type='LOAD', record_id='$list_id_override', event_code='ADMIN LOAD LIST CUSTOM', event_sql='', event_notes='File Name: $leadfile_name, GOOD: $good, BAD: $bad, TOTAL: $total';";
        if ($DB) {
            echo "|$stmt|\n";
        }
        $rslt=mysql_to_mysqli($stmt, $link);
        print "<BR><BR>Done</B> GOOD: $good &nbsp; &nbsp; &nbsp; BAD: $bad &nbsp; &nbsp; &nbsp; TOTAL: $total</font></center>";
    } else {
        print "<center><font face='arial, helvetica' size=3 color='#990000'><B>ERROR: The file does not have the required number of fields to process it.</B></font></center>";
    }
}
if (($leadfile) && ($LF_path)) {
    $total=0;
    $good=0;
    $bad=0;
    $dup=0;
    $post=0;
    $phone_list='';
    $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$PHP_AUTH_USER', ip_address='$ip', event_section='LISTS', event_type='LOAD', record_id='$list_id_override', event_code='ADMIN LOAD LIST', event_sql='', event_notes='File Name: $leadfile_name';";
    if ($DB) {
        echo "|$stmt|\n";
    }
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($file_layout=="standard") {
        print "<script language='JavaScript1.2'>document.forms[0].leadfile.disabled=true; document.forms[0].submit_file.disabled=true; document.forms[0].reload_page.disabled=true;</script>";
        flush();
        $delim_set=0;
        if (preg_match("/\.csv$|\.xls$|\.xlsx$|\.ods$|\.sxc$/i", $leadfile_name)) {
            $leadfile_name = preg_replace('/[^-\.\_0-9a-zA-Z]/', '_', $leadfile_name);
            copy($LF_path, "/tmp/$leadfile_name");
            $new_filename = preg_replace("/\.csv$|\.xls$|\.xlsx$|\.ods$|\.sxc$/i", '.txt', $leadfile_name);
            $convert_command = "$WeBServeRRooT/$admin_web_directory/sheet2tab.pl /tmp/$leadfile_name /tmp/$new_filename";
            passthru("$convert_command");
            $lead_file = "/tmp/$new_filename";
            if ($DB > 0) {
                echo "|$convert_command|";
            }
            if (preg_match("/\.csv$/i", $leadfile_name)) {
                $delim_name="CSV: Comma Separated Values";
            }
            if (preg_match("/\.xls$/i", $leadfile_name)) {
                $delim_name="XLS: MS Excel 2000-XP";
            }
            if (preg_match("/\.xlsx$/i", $leadfile_name)) {
                $delim_name="XLSX: MS Excel 2007+";
            }
            if (preg_match("/\.ods$/i", $leadfile_name)) {
                $delim_name="ODS: OpenOffice.org OpenDocument Spreadsheet";
            }
            if (preg_match("/\.sxc$/i", $leadfile_name)) {
                $delim_name="SXC: OpenOffice.org First Spreadsheet";
            }
            $delim_set=1;
        } else {
            copy($LF_path, "/tmp/vicidial_temp_file.txt");
            $lead_file = "/tmp/vicidial_temp_file.txt";
        }
        $file=fopen("$lead_file", "r");
        if ($webroot_writable > 0) {
            $stmt_file=fopen("$WeBServeRRooT/$admin_web_directory/listloader_stmts.txt", "w");
        }
        $buffer=fgets($file, 4096);
        $tab_count=substr_count($buffer, "\t");
        $pipe_count=substr_count($buffer, "|");
        if ($delim_set < 1) {
            if ($tab_count>$pipe_count) {
                $delim_name="tab-delimited";
            } else {
                $delim_name="pipe-delimited";
            }
        }
        if ($tab_count>$pipe_count) {
            $delimiter="\t";
        } else {
            $delimiter="|";
        }
        $field_check=explode($delimiter, $buffer);
        if (count($field_check)>=2) {
            flush();
            $file=fopen("$lead_file", "r");
            $total=0;
            $good=0;
            $bad=0;
            $dup=0;
            $post=0;
            $phone_list='';
            print "<center><font face='arial, helvetica' size=3 color='#009900'><B>Processing $delim_name file... ($tab_count|$pipe_count)\n";
            if (strlen($list_id_override)>0) {
                print "<BR><BR>LIST ID OVERRIDE FOR THIS FILE: $list_id_override<BR><BR>";
            }
            if (strlen($phone_code_override)>0) {
                print "<BR><BR>PHONE CODE OVERRIDE FOR THIS FILE: $phone_code_override<BR><BR>\n";
            }
            while (!feof($file)) {
                $record++;
                $buffer=rtrim(fgets($file, 4096));
                $buffer=stripslashes($buffer);
                if (strlen($buffer)>0) {
                    $row=explode($delimiter, preg_replace('/[\'\"]/i', '', $buffer));
                    $pulldate=date("Y-m-d H:i:s");
                    $entry_date =            "$pulldate";
                    $modify_date =            "";
                    $status =                "NEW";
                    $user ="";
                    $vendor_lead_code =        $row[0];
                    $source_code =            $row[1];
                    $source_id=$source_code;
                    $list_id =                $row[2];
                    $gmt_offset =            '0';
                    $called_since_last_reset='N';
                    $phone_code =            preg_replace('/[^0-9]/i', '', $row[3]);
                    $phone_number =            preg_replace('/[^0-9]/i', '', $row[4]);
                    $title =                $row[5];
                    $first_name =            $row[6];
                    $middle_initial =        $row[7];
                    $last_name =            $row[8];
                    $address1 =                $row[9];
                    $address2 =                $row[10];
                    $address3 =                $row[11];
                    $city =$row[12];
                    $state =                $row[13];
                    $province =                $row[14];
                    $postal_code =            $row[15];
                    $country_code =            $row[16];
                    $gender =                $row[17];
                    $date_of_birth =        $row[18];
                    $alt_phone =            preg_replace('/[^0-9]/i', '', $row[19]);
                    $email =                $row[20];
                    $security_phrase =        $row[21];
                    $comments =                trim($row[22]);
                    $rank =                    $row[23];
                    $owner =                $row[24];
                    $vendor_lead_code =        preg_replace("/$field_regx/i", "", $vendor_lead_code);
                    $source_code =            preg_replace("/$field_regx/i", "", $source_code);
                    $source_id =             preg_replace("/$field_regx/i", "", $source_id);
                    $list_id =                preg_replace("/$field_regx/i", "", $list_id);
                    $phone_code =            preg_replace("/$field_regx/i", "", $phone_code);
                    $phone_number =            preg_replace("/$field_regx/i", "", $phone_number);
                    $title =                preg_replace("/$field_regx/i", "", $title);
                    $first_name =            preg_replace("/$field_regx/i", "", $first_name);
                    $middle_initial =        preg_replace("/$field_regx/i", "", $middle_initial);
                    $last_name =            preg_replace("/$field_regx/i", "", $last_name);
                    $address1 =                preg_replace("/$field_regx/i", "", $address1);
                    $address2 =                preg_replace("/$field_regx/i", "", $address2);
                    $address3 =                preg_replace("/$field_regx/i", "", $address3);
                    $city =                    preg_replace("/$field_regx/i", "", $city);
                    $state =                preg_replace("/$field_regx/i", "", $state);
                    $province =                preg_replace("/$field_regx/i", "", $province);
                    $postal_code =            preg_replace("/$field_regx/i", "", $postal_code);
                    $country_code =            preg_replace("/$field_regx/i", "", $country_code);
                    $gender =                preg_replace("/$field_regx/i", "", $gender);
                    $date_of_birth =        preg_replace("/$field_regx/i", "", $date_of_birth);
                    $alt_phone =            preg_replace("/$field_regx/i", "", $alt_phone);
                    $email =                preg_replace("/$field_regx/i", "", $email);
                    $security_phrase =        preg_replace("/$field_regx/i", "", $security_phrase);
                    $comments =                preg_replace("/$field_regx/i", "", $comments);
                    $rank =                    preg_replace("/$field_regx/i", "", $rank);
                    $owner =                preg_replace("/$field_regx/i", "", $owner);
                    $USarea =             substr($phone_number, 0, 3);
                    if (strlen($list_id_override)>0) {
                        $list_id = $list_id_override;
                    }
                    if (strlen($phone_code_override)>0) {
                        $phone_code = $phone_code_override;
                    }
                    if (preg_match("/DUPCAMP/i", $dupcheck)) {
                        $dup_lead=0;
                        $dup_lists='';
                        $stmt="select campaign_id from vicidial_lists where list_id='$list_id';";
                        $rslt=mysql_to_mysqli($stmt, $link);
                        $ci_recs = mysqli_num_rows($rslt);
                        if ($ci_recs > 0) {
                            $row=mysqli_fetch_row($rslt);
                            $dup_camp =            $row[0];
                            $stmt="select list_id from vicidial_lists where campaign_id='$dup_camp';";
                            $rslt=mysql_to_mysqli($stmt, $link);
                            $li_recs = mysqli_num_rows($rslt);
                            if ($li_recs > 0) {
                                $L=0;
                                while ($li_recs > $L) {
                                    $row=mysqli_fetch_row($rslt);
                                    $dup_lists .=    "'$row[0]',";
                                    $L++;
                                }
                                $dup_lists = preg_replace('/,$/i', '', $dup_lists);
                                $stmt="select list_id from vicidial_list where phone_number='$phone_number' and list_id IN($dup_lists) limit 1;";
                                $rslt=mysql_to_mysqli($stmt, $link);
                                $pc_recs = mysqli_num_rows($rslt);
                                if ($pc_recs > 0) {
                                    $dup_lead=1;
                                    $row=mysqli_fetch_row($rslt);
                                    $dup_lead_list =    $row[0];
                                }
                                if ($dup_lead < 1) {
                                    if (preg_match("/$phone_number$US$list_id/i", $phone_list)) {
                                        $dup_lead++;
                                        $dup++;
                                    }
                                }
                            }
                        }
                    }
                    if (preg_match("/DUPSYS/i", $dupcheck)) {
                        $dup_lead=0;
                        $stmt="select list_id from vicidial_list where phone_number='$phone_number';";
                        $rslt=mysql_to_mysqli($stmt, $link);
                        $pc_recs = mysqli_num_rows($rslt);
                        if ($pc_recs > 0) {
                            $dup_lead=1;
                            $row=mysqli_fetch_row($rslt);
                            $dup_lead_list =    $row[0];
                        }
                        if ($dup_lead < 1) {
                            if (preg_match("/$phone_number$US$list_id/i", $phone_list)) {
                                $dup_lead++;
                                $dup++;
                            }
                        }
                    }
                    if (preg_match("/DUPLIST/i", $dupcheck)) {
                        $dup_lead=0;
                        $stmt="select count(*) from vicidial_list where phone_number='$phone_number' and list_id='$list_id';";
                        $rslt=mysql_to_mysqli($stmt, $link);
                        $pc_recs = mysqli_num_rows($rslt);
                        if ($pc_recs > 0) {
                            $row=mysqli_fetch_row($rslt);
                            $dup_lead =            $row[0];
                        }
                        if ($dup_lead < 1) {
                            if (preg_match("/$phone_number$US$list_id/i", $phone_list)) {
                                $dup_lead++;
                                $dup++;
                            }
                        }
                    }
                    if (preg_match("/DUPTITLEALTPHONELIST/i", $dupcheck)) {
                        $dup_lead=0;
                        $stmt="select count(*) from vicidial_list where title='$title' and alt_phone='$alt_phone' and list_id='$list_id';";
                        $rslt=mysql_to_mysqli($stmt, $link);
                        $pc_recs = mysqli_num_rows($rslt);
                        if ($pc_recs > 0) {
                            $row=mysqli_fetch_row($rslt);
                            $dup_lead =            $row[0];
                            $dup_lead_list =    $list_id;
                        }
                        if ($dup_lead < 1) {
                            if (preg_match("/$alt_phone$title$US$list_id/i", $phone_list)) {
                                $dup_lead++;
                                $dup++;
                            }
                        }
                    }
                    if (preg_match("/DUPTITLEALTPHONESYS/i", $dupcheck)) {
                        $dup_lead=0;
                        $stmt="select list_id from vicidial_list where title='$title' and alt_phone='$alt_phone';";
                        $rslt=mysql_to_mysqli($stmt, $link);
                        $pc_recs = mysqli_num_rows($rslt);
                        if ($pc_recs > 0) {
                            $dup_lead=1;
                            $row=mysqli_fetch_row($rslt);
                            $dup_lead_list =    $row[0];
                        }
                        if ($dup_lead < 1) {
                            if (preg_match("/$alt_phone$title$US$list_id/i", $phone_list)) {
                                $dup_lead++;
                                $dup++;
                            }
                        }
                    }
                    $valid_number=1;
                    if ((strlen($phone_number)<6) || (strlen($phone_number)>16)) {
                        $valid_number=0;
                        $invalid_reason = "INVALID PHONE NUMBER LENGTH";
                    }
                    if ((preg_match("/PREFIX/", $usacan_check)) and ($valid_number > 0)) {
                        $USprefix =     substr($phone_number, 3, 1);
                        if ($DB>0) {
                            echo "DEBUG: usacan prefix check - $USprefix|$phone_number\n";
                        }
                        if ($USprefix < 2) {
                            $valid_number=0;
                            $invalid_reason = "INVALID PHONE NUMBER PREFIX";
                        }
                    }
                    if ((preg_match("/AREACODE/", $usacan_check)) and ($valid_number > 0)) {
                        $phone_areacode = substr($phone_number, 0, 3);
                        $stmt = "select count(*) from vicidial_phone_codes where areacode='$phone_areacode' and country_code='1';";
                        if ($DB>0) {
                            echo "DEBUG: usacan areacode query - $stmt\n";
                        }
                        $rslt=mysql_to_mysqli($stmt, $link);
                        $row=mysqli_fetch_row($rslt);
                        $valid_number=$row[0];
                        if ($valid_number < 1) {
                            $invalid_reason = "INVALID PHONE NUMBER AREACODE";
                        }
                    }
                    if (($valid_number>0) and ($dup_lead<1) and ($list_id >= 100)) {
                        if (strlen($phone_code)<1) {
                            $phone_code = '1';
                        }
                        if (preg_match("/TITLEALTPHONE/i", $dupcheck)) {
                            $phone_list .= "$alt_phone$title$US$list_id|";
                        } else {
                            $phone_list .= "$phone_number$US$list_id|";
                        }
                        $gmt_offset = lookup_gmt($phone_code, $USarea, $state, $LOCAL_GMT_OFF_STD, $Shour, $Smin, $Ssec, $Smon, $Smday, $Syear, $postalgmt, $postal_code, $owner);
                        if ($multi_insert_counter > 8) {
                            $stmtZ = "INSERT INTO vicidial_list (lead_id,entry_date,modify_date,status,user,vendor_lead_code,source_id,list_id,gmt_offset_now,called_since_last_reset,phone_code,phone_number,title,first_name,middle_initial,last_name,address1,address2,address3,city,state,province,postal_code,country_code,gender,date_of_birth,alt_phone,email,security_phrase,comments,called_count,last_local_call_time,rank,owner,entry_list_id) values$multistmt('','$entry_date','$modify_date','$status','$user','$vendor_lead_code','$source_id','$list_id','$gmt_offset','$called_since_last_reset','$phone_code','$phone_number','$title','$first_name','$middle_initial','$last_name','$address1','$address2','$address3','$city','$state','$province','$postal_code','$country_code','$gender','$date_of_birth','$alt_phone','$email','$security_phrase','$comments',0,'2008-01-01 00:00:00','$rank','$owner','0');";
                            $rslt=mysql_to_mysqli($stmtZ, $link);
                            if ($webroot_writable > 0) {
                                fwrite($stmt_file, $stmtZ."\r\n");
                            }
                            $multistmt='';
                            $multi_insert_counter=0;
                        } else {
                            $multistmt .= "('','$entry_date','$modify_date','$status','$user','$vendor_lead_code','$source_id','$list_id','$gmt_offset','$called_since_last_reset','$phone_code','$phone_number','$title','$first_name','$middle_initial','$last_name','$address1','$address2','$address3','$city','$state','$province','$postal_code','$country_code','$gender','$date_of_birth','$alt_phone','$email','$security_phrase','$comments',0,'2008-01-01 00:00:00','$rank','$owner','0'),";
                            $multi_insert_counter++;
                        }
                        $good++;
                    } else {
                        if ($bad < 1000000) {
                            if ($list_id < 100) {
                                print "<BR></b><font size=1 color=red>record $total BAD- PHONE: $phone_number ROW: |$row[0]| INVALID LIST ID</font><b>\n";
                            } else {
                                if ($valid_number < 1) {
                                    print "<BR></b><font size=1 color=red>record $total BAD- PHONE: $phone_number ROW: |$row[0]| INV: $phone_number</font><b>\n";
                                } else {
                                    print "<BR></b><font size=1 color=red>record $total BAD- PHONE: $phone_number ROW: |$row[0]| DUP: $dup_lead  $dup_lead_list</font><b>\n";
                                }
                            }
                        }
                        $bad++;
                    }
                    $total++;
                    if ($total%100==0) {
                        print "<script language='JavaScript1.2'>ShowProgress($good, $bad, $total, $dup, $inv, $post)</script>";
                        usleep(1000);
                        flush();
                    }
                }
            }
            if ($multi_insert_counter!=0) {
                $stmtZ = "INSERT INTO vicidial_list (lead_id,entry_date,modify_date,status,user,vendor_lead_code,source_id,list_id,gmt_offset_now,called_since_last_reset,phone_code,phone_number,title,first_name,middle_initial,last_name,address1,address2,address3,city,state,province,postal_code,country_code,gender,date_of_birth,alt_phone,email,security_phrase,comments,called_count,last_local_call_time,rank,owner,entry_list_id) values".substr($multistmt, 0, -1).";";
                mysql_to_mysqli($stmtZ, $link);
                if ($webroot_writable > 0) {
                    fwrite($stmt_file, $stmtZ."\r\n");
                }
            }
            $stmt="INSERT INTO vicidial_admin_log set event_date='$NOW_TIME', user='$PHP_AUTH_USER', ip_address='$ip', event_section='LISTS', event_type='LOAD', record_id='$list_id_override', event_code='ADMIN LOAD LIST STANDARD', event_sql='', event_notes='File Name: $leadfile_name, GOOD: $good, BAD: $bad, TOTAL: $total';";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
            print "<BR><BR>Done</B> GOOD: $good &nbsp; &nbsp; &nbsp; BAD: $bad &nbsp; &nbsp; &nbsp; TOTAL: $total</font></center>";
        } else {
            print "<center><font face='arial, helvetica' size=3 color='#990000'><B>ERROR: The file does not have the required number of fields to process it.</B></font></center>";
        }
    } else {
        print "<script language='JavaScript1.2'>document.forms[0].leadfile.disabled=true; document.forms[0].submit_file.disabled=true; document.forms[0].reload_page.disabled=true;</script><HR>";
        flush();
        print "<table border=0 cellpadding=3 cellspacing=0 width=700 align=center>\r\n";
        print "  <tr bgcolor='#330099'>\r\n";
        print "    <th align=right><font class='standard' color='white'>VICIDIAL Column</font></th>\r\n";
        print "    <th><font class='standard' color='white'>File data</font></th>\r\n";
        print "  </tr>\r\n";
        $fields_stmt = "SELECT vendor_lead_code, source_id, list_id, phone_code, phone_number, title, first_name, middle_initial, last_name, address1, address2, address3, city, state, province, postal_code, country_code, gender, date_of_birth, alt_phone, email, security_phrase, comments, rank, owner from vicidial_list limit 1";
        if ($custom_fields_enabled > 0) {
            $stmt="SHOW TABLES LIKE \"custom_$list_id_override\";";
            if ($DB>0) {
                echo "$stmt\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
            $tablecount_to_print = mysqli_num_rows($rslt);
            if ($tablecount_to_print > 0) {
                $stmt="SELECT count(*) from vicidial_lists_fields where list_id='$list_id_override';";
                if ($DB>0) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $fieldscount_to_print = mysqli_num_rows($rslt);
                if ($fieldscount_to_print > 0) {
                    $rowx=mysqli_fetch_row($rslt);
                    $custom_records_count =    $rowx[0];
                    $custom_SQL='';
                    $stmt="SELECT field_id,field_label,field_name,field_description,field_rank,field_help,field_type,field_options,field_size,field_max,field_default,field_cost,field_required,multi_position,name_position,field_order from vicidial_lists_fields where list_id='$list_id_override' order by field_rank,field_order,field_label;";
                    if ($DB>0) {
                        echo "$stmt\n";
                    }
                    $rslt=mysql_to_mysqli($stmt, $link);
                    $fields_to_print = mysqli_num_rows($rslt);
                    $fields_list='';
                    $o=0;
                    while ($fields_to_print > $o) {
                        $rowx=mysqli_fetch_row($rslt);
                        $A_field_label[$o] =    $rowx[1];
                        $A_field_type[$o] =        $rowx[6];
                        if ($DB>0) {
                            echo "$A_field_label[$o]|$A_field_type[$o]\n";
                        }
                        if (($A_field_type[$o]!='DISPLAY') and ($A_field_type[$o]!='SCRIPT')) {
                            if (!preg_match("/\|$A_field_label[$o]\|/", $vicidial_list_fields)) {
                                $custom_SQL .= ",$A_field_label[$o]";
                            }
                        }
                        $o++;
                    }
                    $fields_stmt = "SELECT vendor_lead_code, source_id, list_id, phone_code, phone_number, title, first_name, middle_initial, last_name, address1, address2, address3, city, state, province, postal_code, country_code, gender, date_of_birth, alt_phone, email, security_phrase, comments, rank, owner $custom_SQL from vicidial_list, custom_$list_id_override limit 1";
                }
            }
        }
        $rslt=mysql_to_mysqli("$fields_stmt", $link);
        $delim_set=0;
        if (preg_match("/\.csv$|\.xls$|\.xlsx$|\.ods$|\.sxc$/i", $leadfile_name)) {
            $leadfile_name = preg_replace('/[^-\.\_0-9a-zA-Z]/', '_', $leadfile_name);
            copy($LF_path, "/tmp/$leadfile_name");
            $new_filename = preg_replace("/\.csv$|\.xls$|\.xlsx$|\.ods$|\.sxc$/i", '.txt', $leadfile_name);
            $convert_command = "$WeBServeRRooT/$admin_web_directory/sheet2tab.pl /tmp/$leadfile_name /tmp/$new_filename";
            passthru("$convert_command");
            $lead_file = "/tmp/$new_filename";
            if ($DB > 0) {
                echo "|$convert_command|";
            }
            if (preg_match("/\.csv$/i", $leadfile_name)) {
                $delim_name="CSV: Comma Separated Values";
            }
            if (preg_match("/\.xls$/i", $leadfile_name)) {
                $delim_name="XLS: MS Excel 2000-XP";
            }
            if (preg_match("/\.xlsx$/i", $leadfile_name)) {
                $delim_name="XLSX: MS Excel 2007+";
            }
            if (preg_match("/\.ods$/i", $leadfile_name)) {
                $delim_name="ODS: OpenOffice.org OpenDocument Spreadsheet";
            }
            if (preg_match("/\.sxc$/i", $leadfile_name)) {
                $delim_name="SXC: OpenOffice.org First Spreadsheet";
            }
            $delim_set=1;
        } else {
            copy($LF_path, "/tmp/vicidial_temp_file.txt");
            $lead_file = "/tmp/vicidial_temp_file.txt";
        }
        $file=fopen("$lead_file", "r");
        if ($webroot_writable > 0) {
            $stmt_file=fopen("$WeBServeRRooT/$admin_web_directory/listloader_stmts.txt", "w");
        }
        $buffer=fgets($file, 4096);
        $tab_count=substr_count($buffer, "\t");
        $pipe_count=substr_count($buffer, "|");
        if ($delim_set < 1) {
            if ($tab_count>$pipe_count) {
                $delim_name="tab-delimited";
            } else {
                $delim_name="pipe-delimited";
            }
        }
        if ($tab_count>$pipe_count) {
            $delimiter="\t";
        } else {
            $delimiter="|";
        }
        $field_check=explode($delimiter, $buffer);
        flush();
        $file=fopen("$lead_file", "r");
        print "<center><font face='arial, helvetica' size=3 color='#009900'><B>Processing $delim_name file...\n";
        if (strlen($list_id_override)>0) {
            print "<BR><BR>LIST ID OVERRIDE FOR THIS FILE: $list_id_override<BR><BR>";
        }
        if (strlen($phone_code_override)>0) {
            print "<BR><BR>PHONE CODE OVERRIDE FOR THIS FILE: $phone_code_override<BR><BR>";
        }
        $buffer=rtrim(fgets($file, 4096));
        $buffer=stripslashes($buffer);
        $row=explode($delimiter, preg_replace('/[\'\"]/i', '', $buffer));
        while ($fieldinfo=mysqli_fetch_field($rslt)) {
            $rslt_field_name=$fieldinfo->name;
            if (($rslt_field_name=="list_id" and $list_id_override!="") or ($rslt_field_name=="phone_code" and $phone_code_override!="")) {
                print "<!-- skipping " . $rslt_field_name . " -->\n";
            } else {
                print "  <tr bgcolor=#D9E6FE>\r\n";
                print "    <td align=right><font class=standard>".strtoupper(preg_replace('/_/i', ' ', $rslt_field_name)).": </font></td>\r\n";
                print "    <td align=center><select name='".$rslt_field_name."_field'>\r\n";
                print "     <option value='-1'>(none)</option>\r\n";
                for ($j=0; $j<count($row); $j++) {
                    preg_replace('/\"/i', '', $row[$j]);
                    print "     <option value='$j'>\"$row[$j]\"</option>\r\n";
                }
                print "    </select></td>\r\n";
                print "  </tr>\r\n";
            }
        }
        print "  <tr bgcolor='#330099'>\r\n";
        print "  <input type=hidden name=dupcheck value=\"$dupcheck\">\r\n";
        print "  <input type=hidden name=usacan_check value=\"$usacan_check\">\r\n";
        print "  <input type=hidden name=postalgmt value=\"$postalgmt\">\r\n";
        print "  <input type=hidden name=lead_file value=\"$lead_file\">\r\n";
        print "  <input type=hidden name=list_id_override value=\"$list_id_override\">\r\n";
        print "  <input type=hidden name=phone_code_override value=\"$phone_code_override\">\r\n";
        print "    <th colspan=2><input type=submit name='OK_to_process' value='OK TO PROCESS'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=button onClick=\"javascript:document.location='admin_listloader_third_gen.php'\" value=\"START OVER\" name='reload_page'></th>\r\n";
        print "  </tr>\r\n";
        print "</table>\r\n";
        print "<script language='JavaScript1.2'>document.forms[0].leadfile.disabled=false; document.forms[0].submit_file.disabled=false; document.forms[0].reload_page.disabled=false;</script>";
    }
}
?>
</form>
</body>
</html>
