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

$body_stuff = "";

if (!preg_match("/Animated Background/", $SSagent_login_background_image)) {
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
EOF;
} else {
    $css_filename = "";
    if ($SSagent_login_background_image == "Random Animated Background") {
        $random = rand(1, 10);
        $SSagent_login_background_image = "Animated Background $random";
    }

    if ($SSagent_login_background_image == "Animated Background 1") {
        $body_stuff = "<div class=\"wave\"></div><div class=\"wave\"></div><div class=\"wave\"></div>";
        $css_filename = "./css/animated_bg_1.css";
    } else if ($SSagent_login_background_image == "Animated Background 2") {
        $body_stuff = "<div class=\"main\"><div class=\"d1\"></div> <div class=\"d2\"</div><div class=\"d3\"></div><div class=\"d4\"></div></div>";
        $css_filename = "./css/animated_bg_2.css";
    } else if ($SSagent_login_background_image == "Animated Background 3") {
        $body_stuff = "<div class=\"wrapper\"><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div></div>";
        $css_filename = "./css/animated_bg_3.css";
    } else if ($SSagent_login_background_image == "Animated Background 4") {
        $body_stuff = "<div class=\"context\"></div><div class=\"area\" ><ul class=\"circles\"><li></li><li></li><li></li><li></li><li></li><li></li><li></li><li></li><li></li><li></li></ul></div >";
        $css_filename = "./css/animated_bg_4.css";
    } else if ($SSagent_login_background_image == "Animated Background 5") {
        $body_stuff = "<div class=\"bg\"></div><div class=\"bg bg2\"></div><div class=\"bg bg3\"></div>";
        $css_filename = "./css/animated_bg_5.css";
    } else if ($SSagent_login_background_image == "Animated Background 6") {
        $body_stuff = "<div id=\"bg-wrap\" style=\"width: 100%; height:100vh; position: absolute;\"><svg viewBox=\"0 0 100 100\" preserveAspectRatio=\"xMidYMid slice\"><defs><radialGradient id=\"Gradient1\" cx=\"50%\" cy=\"50%\" fx=\"0.441602%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"34s\" values=\"0%;3%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(255, 0, 255, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(255, 0, 255, 0)\"></stop></radialGradient><radialGradient id=\"Gradient2\" cx=\"50%\" cy=\"50%\" fx=\"2.68147%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"23.5s\" values=\"0%;3%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(255, 255, 0, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(255, 255, 0, 0)\"></stop></radialGradient><radialGradient id=\"Gradient3\" cx=\"50%\" cy=\"50%\" fx=\"0.836536%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"21.5s\" values=\"0%;3%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(0, 255, 255, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(0, 255, 255, 0)\"></stop></radialGradient><radialGradient id=\"Gradient4\" cx=\"50%\" cy=\"50%\" fx=\"4.56417%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"23s\" values=\"0%;5%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(0, 255, 0, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(0, 255, 0, 0)\"></stop></radialGradient><radialGradient id=\"Gradient5\" cx=\"50%\" cy=\"50%\" fx=\"2.65405%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"24.5s\" values=\"0%;5%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(0,0,255, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(0,0,255, 0)\"></stop></radialGradient><radialGradient id=\"Gradient6\" cx=\"50%\" cy=\"50%\" fx=\"0.981338%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"25.5s\" values=\"0%;5%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(255,0,0, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(255,0,0, 0)\"></stop></radialGradient></defs><!--<rect x=\"0\" y=\"0\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient4)\"><animate attributeName=\"x\" dur=\"20s\" values=\"25%;0%;25%\" repeatCount=\"indefinite\" /><animate attributeName=\"y\" dur=\"21s\" values=\"0%;25%;0%\" repeatCount=\"indefinite\" /><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"0 50 50\" to=\"360 50 50\" dur=\"17s\" repeatCount=\"indefinite\"/></rect><rect x=\"0\" y=\"0\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient5)\"><animate attributeName=\"x\" dur=\"23s\" values=\"0%;-25%;0%\" repeatCount=\"indefinite\" /><animate attributeName=\"y\" dur=\"24s\" values=\"25%;-25%;25%\" repeatCount=\"indefinite\" /><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"0 50 50\" to=\"360 50 50\" dur=\"18s\" repeatCount=\"indefinite\"/></rect><rect x=\"0\" y=\"0\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient6)\"><animate attributeName=\"x\" dur=\"25s\" values=\"-25%;0%;-25%\" repeatCount=\"indefinite\" /><animate attributeName=\"y\" dur=\"26s\" values=\"0%;-25%;0%\" repeatCount=\"indefinite\" /><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"360 50 50\" to=\"0 50 50\" dur=\"19s\" repeatCount=\"indefinite\"/></rect>--><rect x=\"13.744%\" y=\"1.18473%\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient1)\" transform=\"rotate(334.41 50 50)\"><animate attributeName=\"x\" dur=\"20s\" values=\"25%;0%;25%\" repeatCount=\"indefinite\"></animate><animate attributeName=\"y\" dur=\"21s\" values=\"0%;25%;0%\" repeatCount=\"indefinite\"></animate><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"0 50 50\" to=\"360 50 50\" dur=\"7s\" repeatCount=\"indefinite\"></animateTransform></rect><rect x=\"-2.17916%\" y=\"35.4267%\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient2)\" transform=\"rotate(255.072 50 50)\"><animate attributeName=\"x\" dur=\"23s\" values=\"-25%;0%;-25%\" repeatCount=\"indefinite\"></animate><animate attributeName=\"y\" dur=\"24s\" values=\"0%;50%;0%\" repeatCount=\"indefinite\"></animate><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"0 50 50\" to=\"360 50 50\" dur=\"12s\" repeatCount=\"indefinite\"></animateTransform></rect><rect x=\"9.00483%\" y=\"14.5733%\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient3)\" transform=\"rotate(139.903 50 50)\"><animate attributeName=\"x\" dur=\"25s\" values=\"0%;25%;0%\" repeatCount=\"indefinite\"></animate><animate attributeName=\"y\" dur=\"12s\" values=\"0%;25%;0%\" repeatCount=\"indefinite\"></animate><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"360 50 50\" to=\"0 50 50\" dur=\"9s\" repeatCount=\"indefinite\"></animateTransform></rect></svg></div>";
    } else if ($SSagent_login_background_image == "Animated Background 7") {
        $body_stuff = "<body><div class=\"glowing\"><span style=\"--i:1;\"></span><span style=\"--i:2;\"></span><span style=\"--i:3;\"></span></div><div class=\"glowing\"><span style=\"--i:1;\"></span><span style=\"--i:2;\"></span><span style=\"--i:3;\"></span></div><div class=\"glowing\"><span style=\"--i:1;\"></span><span style=\"--i:2;\"></span><span style=\"--i:3;\"></span></div><div class=\"glowing\"><span style=\"--i:1;\"></span><span style=\"--i:2;\"></span><span style=\"--i:3;\"></span></div></body>";
        $css_filename = "./css/animated_bg_7.css";
    } else if ($SSagent_login_background_image == "Animated Background 8") {
        $body_stuff ="<div class=\"light x1\"></div><div class=\"light x2\"></div><div class=\"light x3\"></div><div class=\"light x4\"></div><div class=\"light x5\"></div><div class=\"light x6\"></div><div class=\"light x7\"></div><div class=\"light x8\"></div><div class=\"light x9\"></div>";
        $css_filename = "./css/animated_bg_8.css";
    } else if ($SSagent_login_background_image == "Animated Background 9") {
        $body_stuff = "<div id=\"retrobg\"><div id=\"retrobg-sky\"><div id=\"retrobg-stars\"><div class=\"retrobg-star\" style=\"left:  5%; top: 55%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left:  7%; top:  5%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 10%; top: 45%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 12%; top: 35%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 15%; top: 39%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 20%; top: 10%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 35%; top: 50%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 40%; top: 16%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 43%; top: 28%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 45%; top: 30%; transform: scale( 3 );\"></div><div class=\"retrobg-star\" style=\"left: 55%; top: 18%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 60%; top: 23%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 62%; top: 44%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 67%; top: 27%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 75%; top: 10%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 80%; top: 25%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 83%; top: 57%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 90%; top: 29%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 95%; top:  5%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 96%; top: 72%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 98%; top: 70%; transform: scale( 3 );\"></div></div><div id=\"retrobg-sunWrap\"><div id=\"retrobg-sun\"></div></div><div id=\"retrobg-mountains\"><div id=\"retrobg-mountains-left\" class=\"retrobg-mountain\"></div><div id=\"retrobg-mountains-right\" class=\"retrobg-mountain\"></div></div><div id=\"retrobg-cityWrap\"><div id=\"retrobg-city\"><div style=\"left:  4.0%; height: 20%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left:  6.0%; height: 50%; width: 1.5%;\" class=\"retrobg-building\"></div><div style=\"left:  8.0%; height: 25%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 12.0%; height: 30%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 13.0%; height: 55%; width: 3.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 17.0%; height: 20%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 18.5%; height: 70%; width: 1.5%;\" class=\"retrobg-building\"></div><div style=\"left: 20.0%; height: 30%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 21.5%; height: 80%; width: 2.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 25.0%; height: 60%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 28.0%; height: 40%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 30.0%; height: 70%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 35.0%; height: 65%; width: 4.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 38.0%; height: 40%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 42.0%; height: 60%; width: 2.0%;\" class=\"retrobg-building\"></div><div style=\"left: 43.0%; height: 85%; width: 4.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 45.0%; height: 40%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 48.0%; height: 25%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 50.0%; height: 80%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 52.0%; height: 32%; width: 5.0%;\" class=\"retrobg-building\"></div><div style=\"left: 55.0%; height: 55%; width: 3.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 58.0%; height: 45%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 61.0%; height: 90%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 66.0%; height: 99%; width: 4.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 69.0%; height: 30%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 73.5%; height: 90%; width: 2.0%;\" class=\"retrobg-building\"></div><div style=\"left: 72.0%; height: 70%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 75.0%; height: 60%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 80.0%; height: 40%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 83.0%; height: 70%; width: 4.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 87.0%; height: 60%; width: 3.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 93.0%; height: 50%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 91.0%; height: 30%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 94.0%; height: 20%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 98.0%; height: 35%; width: 2.0%;\" class=\"retrobg-building\"></div></div></div></div><div id=\"retrobg-ground\"><div id=\"retrobg-linesWrap\"><div id=\"retrobg-lines\"><div id=\"retrobg-vlines\"><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div></div><div id=\"retrobg-hlines\"><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div></div></div></div><div id=\"retrobg-groundShadow\"></div></div> <div>";
        $css_filename = "./css/animated_bg_9.css";
    } else if ($SSagent_login_background_image == "Animated Background 10") {
        $body_stuff = "<i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>";
        $css_filename = "./css/animated_bg_10.css";
    }

echo"<HTML><HEAD>\n";
echo"<TITLE>"._QXZ("Welcome Screen")."</TITLE>\n";
echo"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">\n";
echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"../agc/css/style.css\" />\n";
echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"../agc/css/custom.css\" />\n";
// Include Bootstrap for styling
echo "<link rel=\"stylesheet\" href=\"./css/bootstrap.min.css\">";

echo <<<EOF
<link rel="stylesheet" href="$css_filename">
<style>
EOF;
}
echo <<<EOF
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
echo $body_stuff;
echo "<table width=\"100%\"><tr><td></td>\n";
echo "</tr></table>\n";
echo "<br /><div class=\"alert alert-success fadeIn\"><center>👋 " . _QXZ("Welcome to mDial!") . " 💻</div><center>";
echo "<br /><br /><br /><center id=\"login_center\" class=\"login_center fadeIn\"><table class=\"login_table\" width=\"460px\" cellpadding=\"3\" cellspacing=\"0\"><tr bgcolor=\"white\">";
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
