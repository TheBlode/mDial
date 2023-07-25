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
header("Content-type: text/html; charset=utf-8");
require_once("dbconnect_mysqli.php");
require("functions.php");
if (file_exists('options.php')) {
    require_once('options.php');
}
$stmt = "SELECT use_non_latin,enable_languages,language_method,default_language,agent_screen_colors,admin_web_directory,agent_script,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($mel > 0) {
    mysql_error_logging($NOW_TIME, $link, $mel, $stmt, '01001', $VD_login, $server_ip, $session_name, $one_mysql_log);
}
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                $row[0];
    $SSenable_languages =        $row[1];
    $SSlanguage_method =        $row[2];
    $default_language =            $row[3];
    $agent_screen_colors =        $row[4];
    $admin_web_directory =        $row[5];
    $SSagent_script =            $row[6];
    $SSallow_web_debug =        $row[7];
}
if ($SSallow_web_debug < 1) {
    $DB=0;
}
$SSmenu_background='015B91';
$SSframe_background='D9E6FE';
$SSstd_row1_background='9BB9FB';
$SSstd_row2_background='B9CBFD';
$SSstd_row3_background='8EBCFD';
$SSstd_row4_background='B6D3FC';
$SSstd_row5_background='A3C3D6';
$SSalt_row1_background='BDFFBD';
$SSalt_row2_background='99FF99';
$SSalt_row3_background='CCFFCC';
if ($agent_screen_colors != 'default') {
    $stmt = "SELECT web_logo,agent_login_background_image FROM vicidial_screen_colors where colors_id='$agent_screen_colors';";
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($mel > 0) {
        mysql_error_logging($NOW_TIME, $link, $mel, $stmt, '01XXX', $VD_login, $server_ip, $session_name, $one_mysql_log);
    }
    if ($DB) {
        echo "$stmt\n";
    }
    $qm_conf_ct = mysqli_num_rows($rslt);
    if ($qm_conf_ct > 0) {
        $row=mysqli_fetch_row($rslt);
        $SSweb_logo = $row[0];
        $SSagent_login_background_image = $row[1];
    }
}
$Mhead_color =    $SSstd_row5_background;
$Mmain_bgcolor = $SSmenu_background;
$Mhead_color =    $SSstd_row5_background;
$selected_logo = "./images/vicidial_admin_web_logo.png";
$logo_new=0;
$logo_old=0;
if (file_exists('../$admin_web_directory/images/vicidial_admin_web_logo.png')) {
    $logo_new++;
}
if (file_exists('vicidial_admin_web_logo.gif')) {
    $logo_old++;
}
if ($SSweb_logo=='default_new') {
    $selected_logo = "./images/vicidial_admin_web_logo.png";
}
if (($SSweb_logo=='default_old') and ($logo_old > 0)) {
    $selected_logo = "../$admin_web_directory/vicidial_admin_web_logo.gif";
}
if (($SSweb_logo!='default_new') and ($SSweb_logo!='default_old')) {
    if (file_exists("../$admin_web_directory/images/vicidial_admin_web_logo$SSweb_logo")) {
        $selected_logo = "../$admin_web_directory/images/vicidial_admin_web_logo$SSweb_logo";
    }
}

if ($web_logo == "default_new") {
    $selected_logo = "./images/vicidial_admin_web_logo.png";
} else if ($web_logo == "default_new") {
    $selected_logo = "./vicidial_admin_web_logo.gif";
}

if ($SSagent_login_background_image == "Random") {
    $temp_array = Array();

    if ($dir_handle = opendir('./images/wallpaper/')) {
        while (false !== ($entry = readdir($dir_handle))) {
            if ($entry != "." && $entry != "..") {
                array_push($temp_array, $entry);
            }
        }

        closedir($dir_handle);
    }

    $random = array_rand($temp_array);
    $SSagent_login_background_image = $temp_array[$random];
}

echo"<HTML><HEAD>\n";
echo"<TITLE>"._QXZ("Welcome Screen")."</TITLE>\n";
echo"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">\n";
echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"../agc/css/style.css\" />\n";
echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"../agc/css/custom.css\" />\n";
// Include Bootstrap for styling
echo "<link rel=\"stylesheet\" href=\"./css/bootstrap.min.css\">";
echo <<<EOF
<style>
body {
EOF;
    echo "background-image: url(\\/vicidial\/images\/wallpaper\/$SSagent_login_background_image);";
echo <<<EOF
    background-size: cover;
}

.login_center {
    border: black solid 0px;
    border-radius: 10px;
    background: white;
    opacity: 0.9;
    width: 37vw;
    position: absolute;
    left: 34%;
    top: 18vh;
}

.login_table {
    border: black solid 0px;
    border-radius: 42px;
    padding: 10px;
    margin: 20px;
}

.black_line_input {
    border-top: solid black 0px;
    border-left: solid black 0px;
    border-right: solid black 0px;
}

@-webkit-keyframes fadeout {
    0% {
        opacity: 0.9;
    }
    100% {
        opacity: 0;
    }
}

@keyframes fadeout {
    0% {
        opacity: 0.9;
    }
    100% {
        opacity: 0;
    }
}

.fadeOut {
    opacity: 0.9;
    -moz-animation   : fadeout 0.8s linear;
    -webkit-animation: fadeout 0.8s linear;
    animation        : fadeout 0.8s linear;
}

@-webkit-keyframes fadein {
    0% {
        opacity: 0;
    }
    100% {
        opacity: 0.9;
    }
}

@keyframes fadein {
    0% {
        opacity: 0;
    }
    100% {
        opacity: 0.9;
    }
}

.fadeIn {
    opacity: 0.9;
    -moz-animation: fadein 0.8s linear;
    -webkit-animation: fadein 0.8s linear;
    animation: fadein 0.8s linear;
}
</style>
EOF;
echo"</HEAD>\n";
echo "<BODY>\n";
echo "<table width=\"100%\"><tr><td></td>\n";
echo "</tr></table>\n";
echo "<br /><div class=\"alert alert-success fadeIn\"><center>👋 " . _QXZ("Welcome to mDial!") . " 💻</div><center>";
echo "<br /><br /><br /><center \"login_center\" class=\"login_center fadeIn\"><table class=\"login_table\" width=\"460px\" cellpadding=\"3\" cellspacing=\"0\"><tr bgcolor=\"white\">";
echo "<td align=\"center\" valign=\"bottom\" bgcolor=\"white\" width=\"170\" colspan=\"3\"><img src=\"$selected_logo\" border=\"0\" height=\"45\" width=\"170\" alt=\"Agent Screen\" /></td>";
echo "</tr>\n";
echo "<tr><td align=\"left\" colspan=\"2\"><font size=\"1\"> &nbsp; </font></td></tr>\n";
echo "<TR><TD ALIGN=CENTER COLSPAN=2><font size=1> &nbsp; </TD></TR>\n";
echo "<TR><TD ALIGN=CENTER COLSPAN=2><font class=\"skb_text\"> <a class=\"btn btn-info btn-block\" href=\"../agc/$SSagent_script\">"._QXZ("Agent Login")."</a> </TD></TR>\n";
echo "<TR><TD ALIGN=CENTER COLSPAN=2><font size=1> &nbsp; </TD></TR>\n";
if ($hide_timeclock_link < 1) {
    echo "<TR><TD ALIGN=CENTER COLSPAN=2><font class=\"skb_text\"> <a class=\"btn btn-info btn-block\" href=\"../agc/timeclock.php?referrer=welcome\"> "._QXZ("Timeclock")."</a> </TD></TR>\n";
}
echo "<TR><TD ALIGN=CENTER COLSPAN=2><font size=1> &nbsp; </TD></TR>\n";
echo "<TR><TD ALIGN=CENTER COLSPAN=2><font class=\"skb_text\"> <a class=\"btn btn-info btn-block\" href=\"../$admin_web_directory/admin.php\">"._QXZ("Administration")."</a> </TD></TR>\n";
echo "<TR><TD ALIGN=CENTER COLSPAN=2><font size=1> &nbsp; </TD></TR>\n";
echo "</table></center>\n";
echo "</form>\n\n";
echo "</BODY>\n\n";
echo "</HTML>\n\n";
exit;
?>
