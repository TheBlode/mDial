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
$version = '2.14-22';
$build = '220921-1702';
$php_script = 'timeclock.php';
$StarTtimE = date("U");
$NOW_TIME = date("Y-m-d H:i:s");
$last_action_date = $NOW_TIME;
$US='_';
$CL=':';
$AT='@';
$DS='-';
$date = date("r");
$ip = getenv("REMOTE_ADDR");
$browser = getenv("HTTP_USER_AGENT");
$script_name = getenv("SCRIPT_NAME");
$server_name = getenv("SERVER_NAME");
$server_port = getenv("SERVER_PORT");
if (preg_match("/443/i", $server_port)) {
    $HTTPprotocol = 'https://';
} else {
    $HTTPprotocol = 'http://';
}
if (($server_port == '80') or ($server_port == '443')) {
    $server_port='';
} else {
    $server_port = "$CL$server_port";
}
$agcPAGE = "$HTTPprotocol$server_name$server_port$script_name";
$agcDIR = preg_replace('/timeclock\.php/i', '', $agcPAGE);
if (isset($_GET["DB"])) {
    $DB=$_GET["DB"];
} elseif (isset($_POST["DB"])) {
    $DB=$_POST["DB"];
}
if (isset($_GET["phone_login"])) {
    $phone_login=$_GET["phone_login"];
} elseif (isset($_POST["phone_login"])) {
    $phone_login=$_POST["phone_login"];
}
if (isset($_GET["phone_pass"])) {
    $phone_pass=$_GET["phone_pass"];
} elseif (isset($_POST["phone_pass"])) {
    $phone_pass=$_POST["phone_pass"];
}
if (isset($_GET["VD_login"])) {
    $VD_login=$_GET["VD_login"];
} elseif (isset($_POST["VD_login"])) {
    $VD_login=$_POST["VD_login"];
}
if (isset($_GET["VD_pass"])) {
    $VD_pass=$_GET["VD_pass"];
} elseif (isset($_POST["VD_pass"])) {
    $VD_pass=$_POST["VD_pass"];
}
if (isset($_GET["VD_campaign"])) {
    $VD_campaign=$_GET["VD_campaign"];
} elseif (isset($_POST["VD_campaign"])) {
    $VD_campaign=$_POST["VD_campaign"];
}
if (isset($_GET["stage"])) {
    $stage=$_GET["stage"];
} elseif (isset($_POST["stage"])) {
    $stage=$_POST["stage"];
}
if (isset($_GET["commit"])) {
    $commit=$_GET["commit"];
} elseif (isset($_POST["commit"])) {
    $commit=$_POST["commit"];
}
if (isset($_GET["referrer"])) {
    $referrer=$_GET["referrer"];
} elseif (isset($_POST["referrer"])) {
    $referrer=$_POST["referrer"];
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
if (strlen($VD_login)<1) {
    $VD_login = $user;
}
if (!isset($phone_login)) {
    if (isset($_GET["pl"])) {
        $phone_login=$_GET["pl"];
    } elseif (isset($_POST["pl"])) {
        $phone_login=$_POST["pl"];
    }
}
if (!isset($phone_pass)) {
    if (isset($_GET["pp"])) {
        $phone_pass=$_GET["pp"];
    } elseif (isset($_POST["pp"])) {
        $phone_pass=$_POST["pp"];
    }
}
$DB=preg_replace("/[^0-9a-z]/", "", $DB);
$VD_login=preg_replace("/\'|\"|\\\\|;| /", "", $VD_login);
$VD_pass=preg_replace("/\'|\"|\\\\|;| /", "", $VD_pass);
$user=preg_replace("/\'|\"|\\\\|;| /", "", $user);
$pass=preg_replace("/\'|\"|\\\\|;| /", "", $pass);
require_once("dbconnect_mysqli.php");
require_once("functions.php");
if (file_exists('options.php')) {
    require_once('options.php');
}
$stmt = "SELECT use_non_latin,admin_home_url,admin_web_directory,enable_languages,language_method,default_language,agent_screen_colors,agent_script,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($mel > 0) {
    mysql_error_logging($NOW_TIME, $link, $mel, $stmt, '00XXX', $VD_login, $server_ip, $session_name, $one_mysql_log);
}
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $non_latin =            $row[0];
    $welcomeURL =            $row[1];
    $admin_web_directory =    $row[2];
    $SSenable_languages =    $row[3];
    $SSlanguage_method =    $row[4];
    $SSdefault_language =    $row[5];
    $agent_screen_colors =    $row[6];
    $SSagent_script =        $row[7];
    $SSallow_web_debug =    $row[8];
}
if ($SSallow_web_debug < 1) {
    $DB=0;
}
$VUselected_language = '';
$stmt="SELECT user,selected_language from vicidial_users where user='$VD_login';";
if ($DB) {
    echo "|$stmt|\n";
}
$rslt=mysql_to_mysqli($stmt, $link);
if ($mel > 0) {
    mysql_error_logging($NOW_TIME, $link, $mel, $stmt, '00XXX', $VD_login, $server_ip, $session_name, $one_mysql_log);
}
$sl_ct = mysqli_num_rows($rslt);
if ($sl_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $VUuser =                $row[0];
    $VUselected_language =    $row[1];
}
if (strlen($VUselected_language) < 1) {
    $VUselected_language = $SSdefault_language;
}
$user=preg_replace("/\'|\"|\\\\|;| /", "", $user);
$pass=preg_replace("/\'|\"|\\\\|;| /", "", $pass);
$phone_login=preg_replace("/\'|\"|\\\\|;| /", "", $phone_login);
$phone_pass=preg_replace("/\'|\"|\\\\|;| /", "", $phone_pass);
$stage=preg_replace("/[^0-9a-zA-Z]/", "", $stage);
$commit=preg_replace("/[^0-9a-zA-Z]/", "", $commit);
$referrer=preg_replace("/[^0-9a-zA-Z]/", "", $referrer);
if ($non_latin < 1) {
    $user=preg_replace("/[^-_0-9a-zA-Z]/", "", $user);
    $pass=preg_replace("/[^-\.\+\/\=_0-9a-zA-Z]/", "", $pass);
    $VD_login=preg_replace("/[^-_0-9a-zA-Z]/", "", $VD_login);
    $VD_pass=preg_replace("/[^-_0-9a-zA-Z]/", "", $VD_pass);
    $VD_campaign=preg_replace("/[^-_0-9a-zA-Z]/", "", $VD_campaign);
    $phone_login=preg_replace("/[^\,0-9a-zA-Z]/", "", $phone_login);
    $phone_pass=preg_replace("/[^-_0-9a-zA-Z]/", "", $phone_pass);
} else {
    $user=preg_replace("/[^-_0-9\p{L}]/u", "", $user);
    $pass = preg_replace('/[^-\.\+\/\=_0-9\p{L}]/u', '', $pass);
    $VD_login=preg_replace("/[^-_0-9\p{L}]/u", "", $VD_login);
    $VD_pass=preg_replace("/[^-_0-9\p{L}]/u", "", $VD_pass);
    $VD_campaign=preg_replace("/[^-_0-9\p{L}]/u", "", $VD_campaign);
    $phone_login=preg_replace("/[^\,0-9\p{L}]/u", "", $phone_login);
    $phone_pass=preg_replace("/[^-_0-9\p{L}]/u", "", $phone_pass);
}
header("Content-type: text/html; charset=utf-8");
header("Cache-Control: no-cache, must-revalidate");  // HTTP/1.1
header("Pragma: no-cache");                          // HTTP/1.0
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

$body_stuff = "";

if (!preg_match("/Animated Background/", $SSagent_login_background_image)) {
    if ($SSagent_login_background_image == "Random") {
        $temp_array = Array();

        if ($dir_handle = opendir('../vicidial/images/wallpaper/')) {
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
        $css_filename = "../vicidial/css/animated_bg_1.css";
    } else if ($SSagent_login_background_image == "Animated Background 2") {
        $body_stuff = "<div class=\"main\"><div class=\"d1\"></div> <div class=\"d2\"</div><div class=\"d3\"></div><div class=\"d4\"></div></div>";
        $css_filename = "../vicidialcss/animated_bg_2.css";
    } else if ($SSagent_login_background_image == "Animated Background 3") {
        $body_stuff = "<div class=\"wrapper\"><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div><div><span class=\"dot\"></span></div></div>";
        $css_filename = "../vicidial/css/animated_bg_3.css";
    } else if ($SSagent_login_background_image == "Animated Background 4") {
        $body_stuff = "<div class=\"context\"></div><div class=\"area\" ><ul class=\"circles\"><li></li><li></li><li></li><li></li><li></li><li></li><li></li><li></li><li></li><li></li></ul></div >";
        $css_filename = "../vicidial/css/animated_bg_4.css";
    } else if ($SSagent_login_background_image == "Animated Background 5") {
        $body_stuff = "<div class=\"bg\"></div><div class=\"bg bg2\"></div><div class=\"bg bg3\"></div>";
        $css_filename = "../vicidial/css/animated_bg_5.css";
    } else if ($SSagent_login_background_image == "Animated Background 6") {
        $body_stuff = "<div id=\"bg-wrap\" style=\"width: 100%; height:100vh; position: absolute;\"><svg viewBox=\"0 0 100 100\" preserveAspectRatio=\"xMidYMid slice\"><defs><radialGradient id=\"Gradient1\" cx=\"50%\" cy=\"50%\" fx=\"0.441602%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"34s\" values=\"0%;3%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(255, 0, 255, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(255, 0, 255, 0)\"></stop></radialGradient><radialGradient id=\"Gradient2\" cx=\"50%\" cy=\"50%\" fx=\"2.68147%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"23.5s\" values=\"0%;3%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(255, 255, 0, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(255, 255, 0, 0)\"></stop></radialGradient><radialGradient id=\"Gradient3\" cx=\"50%\" cy=\"50%\" fx=\"0.836536%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"21.5s\" values=\"0%;3%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(0, 255, 255, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(0, 255, 255, 0)\"></stop></radialGradient><radialGradient id=\"Gradient4\" cx=\"50%\" cy=\"50%\" fx=\"4.56417%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"23s\" values=\"0%;5%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(0, 255, 0, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(0, 255, 0, 0)\"></stop></radialGradient><radialGradient id=\"Gradient5\" cx=\"50%\" cy=\"50%\" fx=\"2.65405%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"24.5s\" values=\"0%;5%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(0,0,255, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(0,0,255, 0)\"></stop></radialGradient><radialGradient id=\"Gradient6\" cx=\"50%\" cy=\"50%\" fx=\"0.981338%\" fy=\"50%\" r=\".5\"><animate attributeName=\"fx\" dur=\"25.5s\" values=\"0%;5%;0%\" repeatCount=\"indefinite\"></animate><stop offset=\"0%\" stop-color=\"rgba(255,0,0, 1)\"></stop><stop offset=\"100%\" stop-color=\"rgba(255,0,0, 0)\"></stop></radialGradient></defs><!--<rect x=\"0\" y=\"0\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient4)\"><animate attributeName=\"x\" dur=\"20s\" values=\"25%;0%;25%\" repeatCount=\"indefinite\" /><animate attributeName=\"y\" dur=\"21s\" values=\"0%;25%;0%\" repeatCount=\"indefinite\" /><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"0 50 50\" to=\"360 50 50\" dur=\"17s\" repeatCount=\"indefinite\"/></rect><rect x=\"0\" y=\"0\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient5)\"><animate attributeName=\"x\" dur=\"23s\" values=\"0%;-25%;0%\" repeatCount=\"indefinite\" /><animate attributeName=\"y\" dur=\"24s\" values=\"25%;-25%;25%\" repeatCount=\"indefinite\" /><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"0 50 50\" to=\"360 50 50\" dur=\"18s\" repeatCount=\"indefinite\"/></rect><rect x=\"0\" y=\"0\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient6)\"><animate attributeName=\"x\" dur=\"25s\" values=\"-25%;0%;-25%\" repeatCount=\"indefinite\" /><animate attributeName=\"y\" dur=\"26s\" values=\"0%;-25%;0%\" repeatCount=\"indefinite\" /><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"360 50 50\" to=\"0 50 50\" dur=\"19s\" repeatCount=\"indefinite\"/></rect>--><rect x=\"13.744%\" y=\"1.18473%\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient1)\" transform=\"rotate(334.41 50 50)\"><animate attributeName=\"x\" dur=\"20s\" values=\"25%;0%;25%\" repeatCount=\"indefinite\"></animate><animate attributeName=\"y\" dur=\"21s\" values=\"0%;25%;0%\" repeatCount=\"indefinite\"></animate><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"0 50 50\" to=\"360 50 50\" dur=\"7s\" repeatCount=\"indefinite\"></animateTransform></rect><rect x=\"-2.17916%\" y=\"35.4267%\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient2)\" transform=\"rotate(255.072 50 50)\"><animate attributeName=\"x\" dur=\"23s\" values=\"-25%;0%;-25%\" repeatCount=\"indefinite\"></animate><animate attributeName=\"y\" dur=\"24s\" values=\"0%;50%;0%\" repeatCount=\"indefinite\"></animate><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"0 50 50\" to=\"360 50 50\" dur=\"12s\" repeatCount=\"indefinite\"></animateTransform></rect><rect x=\"9.00483%\" y=\"14.5733%\" width=\"100%\" height=\"100%\" fill=\"url(#Gradient3)\" transform=\"rotate(139.903 50 50)\"><animate attributeName=\"x\" dur=\"25s\" values=\"0%;25%;0%\" repeatCount=\"indefinite\"></animate><animate attributeName=\"y\" dur=\"12s\" values=\"0%;25%;0%\" repeatCount=\"indefinite\"></animate><animateTransform attributeName=\"transform\" type=\"rotate\" from=\"360 50 50\" to=\"0 50 50\" dur=\"9s\" repeatCount=\"indefinite\"></animateTransform></rect></svg></div>";
    } else if ($SSagent_login_background_image == "Animated Background 7") {
        $body_stuff = "<body><div class=\"glowing\"><span style=\"--i:1;\"></span><span style=\"--i:2;\"></span><span style=\"--i:3;\"></span></div><div class=\"glowing\"><span style=\"--i:1;\"></span><span style=\"--i:2;\"></span><span style=\"--i:3;\"></span></div><div class=\"glowing\"><span style=\"--i:1;\"></span><span style=\"--i:2;\"></span><span style=\"--i:3;\"></span></div><div class=\"glowing\"><span style=\"--i:1;\"></span><span style=\"--i:2;\"></span><span style=\"--i:3;\"></span></div></body>";
        $css_filename = "./css/animated_bg_7.css";
    } else if ($SSagent_login_background_image == "Animated Background 8") {
        $body_stuff ="<div class=\"light x1\"></div><div class=\"light x2\"></div><div class=\"light x3\"></div><div class=\"light x4\"></div><div class=\"light x5\"></div><div class=\"light x6\"></div><div class=\"light x7\"></div><div class=\"light x8\"></div><div class=\"light x9\"></div>";
        $css_filename = "../vicidial/css/animated_bg_8.css";
    } else if ($SSagent_login_background_image == "Animated Background 9") {
        $body_stuff = "<div id=\"retrobg\"><div id=\"retrobg-sky\"><div id=\"retrobg-stars\"><div class=\"retrobg-star\" style=\"left:  5%; top: 55%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left:  7%; top:  5%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 10%; top: 45%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 12%; top: 35%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 15%; top: 39%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 20%; top: 10%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 35%; top: 50%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 40%; top: 16%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 43%; top: 28%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 45%; top: 30%; transform: scale( 3 );\"></div><div class=\"retrobg-star\" style=\"left: 55%; top: 18%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 60%; top: 23%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 62%; top: 44%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 67%; top: 27%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 75%; top: 10%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 80%; top: 25%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 83%; top: 57%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 90%; top: 29%; transform: scale( 2 );\"></div><div class=\"retrobg-star\" style=\"left: 95%; top:  5%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 96%; top: 72%; transform: scale( 1 );\"></div><div class=\"retrobg-star\" style=\"left: 98%; top: 70%; transform: scale( 3 );\"></div></div><div id=\"retrobg-sunWrap\"><div id=\"retrobg-sun\"></div></div><div id=\"retrobg-mountains\"><div id=\"retrobg-mountains-left\" class=\"retrobg-mountain\"></div><div id=\"retrobg-mountains-right\" class=\"retrobg-mountain\"></div></div><div id=\"retrobg-cityWrap\"><div id=\"retrobg-city\"><div style=\"left:  4.0%; height: 20%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left:  6.0%; height: 50%; width: 1.5%;\" class=\"retrobg-building\"></div><div style=\"left:  8.0%; height: 25%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 12.0%; height: 30%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 13.0%; height: 55%; width: 3.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 17.0%; height: 20%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 18.5%; height: 70%; width: 1.5%;\" class=\"retrobg-building\"></div><div style=\"left: 20.0%; height: 30%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 21.5%; height: 80%; width: 2.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 25.0%; height: 60%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 28.0%; height: 40%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 30.0%; height: 70%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 35.0%; height: 65%; width: 4.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 38.0%; height: 40%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 42.0%; height: 60%; width: 2.0%;\" class=\"retrobg-building\"></div><div style=\"left: 43.0%; height: 85%; width: 4.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 45.0%; height: 40%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 48.0%; height: 25%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 50.0%; height: 80%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 52.0%; height: 32%; width: 5.0%;\" class=\"retrobg-building\"></div><div style=\"left: 55.0%; height: 55%; width: 3.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 58.0%; height: 45%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 61.0%; height: 90%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 66.0%; height: 99%; width: 4.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 69.0%; height: 30%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 73.5%; height: 90%; width: 2.0%;\" class=\"retrobg-building\"></div><div style=\"left: 72.0%; height: 70%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 75.0%; height: 60%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 80.0%; height: 40%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 83.0%; height: 70%; width: 4.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 87.0%; height: 60%; width: 3.0%;\" class=\"retrobg-building retrobg-antenna\"></div><div style=\"left: 93.0%; height: 50%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 91.0%; height: 30%; width: 4.0%;\" class=\"retrobg-building\"></div><div style=\"left: 94.0%; height: 20%; width: 3.0%;\" class=\"retrobg-building\"></div><div style=\"left: 98.0%; height: 35%; width: 2.0%;\" class=\"retrobg-building\"></div></div></div></div><div id=\"retrobg-ground\"><div id=\"retrobg-linesWrap\"><div id=\"retrobg-lines\"><div id=\"retrobg-vlines\"><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div><div class=\"retrobg-vline\"></div></div><div id=\"retrobg-hlines\"><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div><div class=\"retrobg-hline\"></div></div></div></div><div id=\"retrobg-groundShadow\"></div></div> <div>";
        $css_filename = "../vicidial/css/animated_bg_9.css";
    } else if ($SSagent_login_background_image == "Animated Background 10") {
        $body_stuff = "<i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>";
        $css_filename = "../vicidial/css/animated_bg_10.css";
    }

echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"../agc/css/style.css\" />\n";
echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"../agc/css/custom.css\" />\n";
// Include Bootstrap for styling
echo "<link rel=\"stylesheet\" href=\"./css/bootstrap.min.css\">";

echo <<<EOF
<link rel="stylesheet" href="$css_filename">
<style>
body {
    background: transparent;
}
</style>
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
    top: 22vh;
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

#togglePassword {
    margin-left: 31vw;
    cursor: pointer;
    position: relative;
    top: -26px;
}
</style>
EOF;
$INSERT_before_body_close = <<<EOF
<script>
    const togglePassword = document.querySelector("#togglePassword");
    const password = document.querySelector("#password");

    togglePassword.addEventListener("click", function () {
        // toggle the type attribute
        const type = password.getAttribute("type") === "password" ? "text" : "password";
        password.setAttribute("type", type);

        // toggle the icon
        this.classList.toggle("bi-eye");
    });
</script>
EOF;
if (($stage == 'login') or ($stage == 'logout')) {
    $valid_user=0;
    $auth_message = user_authorization($user, $pass, '', 1, 0, 0, 0, 'timeclock');
    if ($auth_message == 'GOOD') {
        $valid_user=1;
    }
    if($valid_user>0) {
        if ($user != "$VUuser") {
            $valid_user=0;
            print "<!-- case check $user|$VD_login|$VUuser:   |$valid_user| -->\n";
        }
    }
    print "<!-- vicidial_users active count for $user:   |$valid_user| -->\n";
    if ($valid_user < 1) {
        $VDdisplayMESSAGE = _QXZ("The user and password you entered are not active in the system<BR>Please try again:");
        if ($auth_message == 'LOCK') {
            $VDdisplayMESSAGE = _QXZ("Too many login attempts, try again in 15 minutes")."<br />";
        }
        if ($auth_message == 'ERRNETWORK') {
            $VDdisplayMESSAGE = _QXZ("Too many network errors, please contact your administrator")."<br />";
        }
        if ($auth_message == 'ERRSERVERS') {
            $VDdisplayMESSAGE = _QXZ("No available servers, please contact your administrator")."<br />";
        }
        if ($auth_message == 'ERRPHONES') {
            $VDdisplayMESSAGE = _QXZ("No available phones, please contact your administrator")."<br />";
        }
        if ($auth_message == 'ERRDUPLICATE') {
            $VDdisplayMESSAGE = _QXZ("You are already logged in, please log out of your other session first")."<br />";
        }
        if ($auth_message == 'ERRAGENTS') {
            $VDdisplayMESSAGE = _QXZ("Too many agents logged in, please contact your administrator")."<br />";
        }
        if ($auth_message == 'ERRCAMPAGENTS') {
            $VDdisplayMESSAGE = _QXZ("Too many agents logged in to this campaign, please contact your manager")."<br />";
        }
        if ($auth_message == 'ERRCASE') {
            $VDdisplayMESSAGE = _QXZ("Login incorrect, user names are case sensitive")."<br />";
        }
        if ($auth_message == 'IPBLOCK') {
            $VDdisplayMESSAGE = _QXZ("Your IP Address is not allowed").": $ip<br />";
        }
        echo"<HTML><HEAD>\n";
        echo"<TITLE>"._QXZ("Agent Timeclock")."</TITLE>\n";
        echo"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">\n";
        echo"</HEAD>\n";
        echo "<body>";
        echo $body_stuff;
        echo "<FORM  NAME=vicidial_form ID=vicidial_form ACTION=\"$agcPAGE\" METHOD=POST>\n";
        echo "<INPUT TYPE=HIDDEN NAME=referrer VALUE=\"$referrer\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=stage VALUE=\"login\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=DB VALUE=\"$DB\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=phone_login VALUE=\"$phone_login\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=phone_pass VALUE=\"$phone_pass\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=VD_login VALUE=\"$VD_login\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=VD_pass VALUE=\"$VD_pass\">\n";
        echo "<CENTER>";
        echo "<table width=\"100%\"><tr><td></td>\n";
        echo "</tr></table>\n";
        if (!empty($VDdisplayMESSAGE)) {
            echo "<br /><div class=\"alert alert-warning fadeIn\"><center>⚠ $VDdisplayMESSAGE</div><center>";
        } else {
            echo "<br /><div class=\"alert alert-success fadeIn\"><center>👋 " . _QXZ("Welcome to mDial Timeclock!") . " ⏱</div><center>";
        }
        echo "<br /><br /><br /><center id=\"login_center\" class=\"login_center fadeIn\"><table class=\"login_table\" width=\"460px\" cellpadding=\"3\" cellspacing=\"0\"><tr bgcolor=\"white\">";
        echo "<td colspan=\"2\" align=\"center\" valign=\"bottom\" width=\"170\"><img src=\"$selected_logo\" border=\"0\" height=\"45\" width=\"170\" alt=\"Agent Screen\" /></td>";
        echo "</tr>\n";
        echo "<tr><td align=\"left\" colspan=\"2\"><font size=\"1\"> &nbsp; </font></td></tr>\n";
        echo "<TR><TD ALIGN=CENTER><font class=\"skb_text\">"._QXZ("User Login").": </TD></TR>";
        echo "<TR><TD ALIGN=CENTER><INPUT TYPE=TEXT NAME=user class=\"form-control\" SIZE=10 MAXLENGTH=20 VALUE=\"$VD_login\"></TD></TR>\n";
        echo "<TR><TD ALIGN=CENTER><font class=\"skb_text\">"._QXZ("User Password:")."  </TD></TR>";
        echo "<TR><TD ALIGN=LEFT><INPUT TYPE=PASSWORD NAME=pass id=\"password\" class=\"form-control\" SIZE=10 MAXLENGTH=20 VALUE=''><i class=\"bi-eye-slash\" id=\"togglePassword\"><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" class=\"bi-eye-fill\" viewBox=\"0 0 16 16\"><path d=\"M10.5 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z\"/><path d=\"M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8zm8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z\"/></svg></i></TD></TR>\n";
        echo "<TR><TD ALIGN=CENTER COLSPAN=2><br /><INPUT class=\"btn btn-info\" TYPE=SUBMIT NAME=SUBMIT VALUE="._QXZ("SUBMIT")."> &nbsp; </TD></TR>\n";
        echo "<TR><TD ALIGN=CENTER COLSPAN=2><font class=\"body_tiny\"><BR>"._QXZ("VERSION:")." $version &nbsp; &nbsp; &nbsp; "._QXZ("BUILD:")." $build</TD></TR>\n";
        echo "</TABLE>\n";
        echo "</FORM>\n\n";
        echo $INSERT_before_body_close;
        echo "</body>\n\n";
        echo "</html>\n\n";
        exit;
    } else {
        $stmt="SELECT full_name,user_group from vicidial_users where user='$user' and active='Y';";
        if ($DB) {
            echo "|$stmt|\n";
        }
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        $full_name =    $row[0];
        $user_group =    $row[1];
        print "<!-- vicidial_users name and group for $user:   |$full_name|$user_group| -->\n";
        $stmt="SELECT count(*) from vicidial_timeclock_status where user='$user';";
        if ($DB) {
            echo "|$stmt|\n";
        }
        $rslt=mysql_to_mysqli($stmt, $link);
        $row=mysqli_fetch_row($rslt);
        $vts_count =    $row[0];
        $last_action_sec=99;
        if ($vts_count > 0) {
            $stmt="SELECT status,event_epoch from vicidial_timeclock_status where user='$user';";
            if ($DB) {
                echo "|$stmt|\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
            $row=mysqli_fetch_row($rslt);
            $status =        $row[0];
            $event_epoch =    $row[1];
            $last_action_date = date("Y-m-d H:i:s", $event_epoch);
            $last_action_sec = ($StarTtimE - $event_epoch);
            if ($last_action_sec > 0) {
                $totTIME_H = ($last_action_sec / 3600);
                $totTIME_H_int = round($totTIME_H, 2);
                $totTIME_H_int = intval("$totTIME_H");
                $totTIME_M = ($totTIME_H - $totTIME_H_int);
                $totTIME_M = ($totTIME_M * 60);
                $totTIME_M_int = round($totTIME_M, 2);
                $totTIME_M_int = intval("$totTIME_M");
                $totTIME_S = ($totTIME_M - $totTIME_M_int);
                $totTIME_S = ($totTIME_S * 60);
                $totTIME_S = round($totTIME_S, 0);
                if (strlen($totTIME_H_int) < 1) {
                    $totTIME_H_int = "0";
                }
                if ($totTIME_M_int < 10) {
                    $totTIME_M_int = "0$totTIME_M_int";
                }
                if ($totTIME_S < 10) {
                    $totTIME_S = "0$totTIME_S";
                }
                $totTIME_HMS = "$totTIME_H_int:$totTIME_M_int:$totTIME_S";
            } else {
                $totTIME_HMS='0:00:00';
            }
            print "<!-- vicidial_timeclock_status previous status for $user:   |$status|$event_epoch|$last_action_sec| -->\n";
        } else {
            $stmt="INSERT INTO vicidial_timeclock_status set status='START', user='$user', user_group='$user_group', event_epoch='$StarTtimE', ip_address='$ip';";
            if ($DB) {
                echo "$stmt\n";
            }
            $rslt=mysql_to_mysqli($stmt, $link);
            $status='START';
            $totTIME_HMS='0:00:00';
            $affected_rows = mysqli_affected_rows($link);
            print "<!-- NEW vicidial_timeclock_status record inserted for $user:   |$affected_rows| -->\n";
        }
        if (($last_action_sec < 30) and ($status != 'START')) {
            $VDdisplayMESSAGE = _QXZ("You cannot log in or out within 30 seconds of your last login or logout");
            echo"<HTML><HEAD>\n";
            echo"<TITLE>Agent Timeclock</TITLE>\n";
            echo"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">\n";
            echo"</HEAD>\n";
            echo "<body>";
            echo $body_stuff;
            echo "<FORM  NAME=vicidial_form ID=vicidial_form ACTION=\"$agcPAGE\" METHOD=POST>\n";
            echo "<INPUT TYPE=HIDDEN NAME=stage VALUE=\"login\">\n";
            echo "<INPUT TYPE=HIDDEN NAME=referrer VALUE=\"$referrer\">\n";
            echo "<INPUT TYPE=HIDDEN NAME=DB VALUE=\"$DB\">\n";
            echo "<INPUT TYPE=HIDDEN NAME=phone_login VALUE=\"$phone_login\">\n";
            echo "<INPUT TYPE=HIDDEN NAME=phone_pass VALUE=\"$phone_pass\">\n";
            echo "<INPUT TYPE=HIDDEN NAME=VD_login VALUE=\"$VD_login\">\n";
            echo "<INPUT TYPE=HIDDEN NAME=VD_pass VALUE=\"$VD_pass\">\n";
            echo "<CENTER>";
            echo "<table width=\"100%\"><tr><td></td>\n";
            echo "</tr></table>\n";
            if (!empty($VDdisplayMESSAGE)) {
                echo "<br /><div class=\"alert alert-warning fadeIn\"><center>⚠ $VDdisplayMESSAGE</div><center><br />";
            } else {
                echo "<br /><div class=\"alert alert-success fadeIn\"><center>👋 " . _QXZ("Welcome to mDial Timeclock!") . " ⏱</div><center>";
            }
            echo "<br /><br /><br /><center id=\"login_center\" class=\"login_center fadeIn\"><table class=\"login_table\" width=\"460px\" cellpadding=\"3\" cellspacing=\"0\"><tr bgcolor=\"white\">";
            echo "<td colspan=\"2\" align=\"center\" valign=\"bottom\" width=\"170\"><img src=\"$selected_logo\" border=\"0\" height=\"45\" width=\"170\" alt=\"Agent Screen\" /></td>";
            echo "</tr>\n";
            echo "<tr><td align=\"left\" colspan=\"2\"><font size=\"1\"> &nbsp; </font></td></tr>\n";
            echo "<TR><TD ALIGN=CENTER><font class=\"skb_text\">"._QXZ("User Login").": </TD></TR>";
            echo "<TR><TD ALIGN=CENTER><INPUT TYPE=TEXT NAME=user class=\"form-control\" SIZE=10 MAXLENGTH=20 VALUE=\"$VD_login\"></TD></TR>\n";
            echo "<TR><TD ALIGN=CENTER><font class=\"skb_text\">"._QXZ("User Password:")."  </TD></TR>";
            echo "<TR><TD ALIGN=LEFT><INPUT TYPE=PASSWORD NAME=pass id=\"password\" class=\"form-control\" SIZE=10 MAXLENGTH=20 VALUE=''><i class=\"bi-eye-slash\" id=\"togglePassword\"><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" class=\"bi-eye-fill\" viewBox=\"0 0 16 16\"><path d=\"M10.5 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z\"/><path d=\"M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8zm8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z\"/></svg></i></TD></TR>\n";
            echo "<TR><TD ALIGN=CENTER COLSPAN=2><br /><INPUT class=\"btn btn-info\" TYPE=SUBMIT NAME=SUBMIT VALUE=\""._QXZ("SUBMIT")."\"> &nbsp; </TD></TR>\n";
            echo "<TR><TD ALIGN=CENTER COLSPAN=2><font class=\"body_tiny\"><BR>"._QXZ("VERSION:")." $version &nbsp; &nbsp; &nbsp; "._QXZ("BUILD:")." $build</TD></TR>\n";
            echo "</TABLE>\n";
            echo "</FORM>\n\n";
            echo $INSERT_before_body_close;
            echo "</body>\n\n";
            echo "</html>\n\n";
            exit;
        }
        if ($commit == 'YES') {
            if ((($status=='AUTOLOGOUT') or ($status=='START') or ($status=='LOGOUT') or ($status=='TIMEOUTLOGOUT')) and ($stage=='login')) {
                $VDdisplayMESSAGE = _QXZ("You have now logged-in");
                $LOGtimeMESSAGE = _QXZ("You logged in at")." $NOW_TIME";
                $stmt="INSERT INTO vicidial_timeclock_log set event='LOGIN', user='$user', user_group='$user_group', event_epoch='$StarTtimE', ip_address='$ip', event_date='$NOW_TIME';";
                if ($DB) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                $timeclock_id = mysqli_insert_id($link);
                print "<!-- NEW vicidial_timeclock_log record inserted for $user:   |$affected_rows|$timeclock_id| -->\n";
                $stmt="UPDATE vicidial_timeclock_status set status='LOGIN', user_group='$user_group', event_epoch='$StarTtimE', ip_address='$ip' where user='$user';";
                if ($DB) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                print "<!-- vicidial_timeclock_status record updated for $user:   |$affected_rows| -->\n";
                $stmt="INSERT INTO vicidial_timeclock_audit_log set timeclock_id='$timeclock_id', event='LOGIN', user='$user', user_group='$user_group', event_epoch='$StarTtimE', ip_address='$ip', event_date='$NOW_TIME';";
                if ($DB) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                print "<!-- NEW vicidial_timeclock_audit_log record inserted for $user:   |$affected_rows| -->\n";
            }
            if (($status=='LOGIN') and ($stage=='logout')) {
                $VDdisplayMESSAGE = _QXZ("You have now logged-out");
                $LOGtimeMESSAGE = _QXZ("You logged out at")." $NOW_TIME<BR>"._QXZ("Amount of time you were logged-in:")." $totTIME_HMS";
                $stmt="INSERT INTO vicidial_timeclock_log set event='LOGOUT', user='$user', user_group='$user_group', event_epoch='$StarTtimE', ip_address='$ip', login_sec='$last_action_sec', event_date='$NOW_TIME';";
                if ($DB) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                $timeclock_id = mysqli_insert_id($link);
                print "<!-- NEW vicidial_timeclock_log record inserted for $user:   |$affected_rows|$timeclock_id| -->\n";
                $stmt="UPDATE vicidial_timeclock_log set login_sec='$last_action_sec',tcid_link='$timeclock_id' where event='LOGIN' and user='$user' order by timeclock_id desc limit 1;";
                if ($DB) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                print "<!-- vicidial_timeclock_log record updated for $user:   |$affected_rows| -->\n";
                $stmt="UPDATE vicidial_timeclock_status set status='LOGOUT', user_group='$user_group', event_epoch='$StarTtimE', ip_address='$ip' where user='$user';";
                if ($DB) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                print "<!-- vicidial_timeclock_status record updated for $user:   |$affected_rows| -->\n";
                $stmt="INSERT INTO vicidial_timeclock_audit_log set timeclock_id='$timeclock_id', event='LOGOUT', user='$user', user_group='$user_group', event_epoch='$StarTtimE', ip_address='$ip', login_sec='$last_action_sec', event_date='$NOW_TIME';";
                if ($DB) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                print "<!-- NEW vicidial_timeclock_audit_log record inserted for $user:   |$affected_rows| -->\n";
                $stmt="UPDATE vicidial_timeclock_audit_log set login_sec='$last_action_sec',tcid_link='$timeclock_id' where event='LOGIN' and user='$user' order by timeclock_id desc limit 1;";
                if ($DB) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                print "<!-- vicidial_timeclock_audit_log record updated for $user:   |$affected_rows| -->\n";
            }
            if (((($status=='AUTOLOGOUT') or ($status=='START') or ($status=='LOGOUT') or ($status=='TIMEOUTLOGOUT')) and ($stage=='logout')) or (($status=='LOGIN') and ($stage=='login'))) {
                echo "<br /><div class=\"alert alert-warning fadeIn\"><center>⚠ " . _QXZ("ERROR: timeclock log entry already made:")." $status | $stage<br /><br /><a href=\"timeclock.php\" class=\"btn btn-info\">Login Again?</a></div><center>";
                exit;
            }
            $BACKlink='';
            if ($referrer=='agent') {
                $BACKlink = "<A class=\"btn btn-info\" HREF=\"./$SSagent_script?pl=$phone_login&pp=$phone_pass&VD_login=$user\"><font class=\"sd_text\">"._QXZ("BACK to Agent Login Screen")."</font></A>";
            }
            if ($referrer=='admin') {
                $BACKlink = "<A class=\"btn btn-info\" HREF=\"/$admin_web_directory/admin.php\"><font class=\"sd_text\">"._QXZ("BACK to Administration")."</font></A>";
            }
            if (($referrer=='welcome') or (strlen($BACKlink) < 10)) {
                $BACKlink = "<A class=\"btn btn-info\" HREF=\"$welcomeURL\"><font class=\"sd_text\">"._QXZ("BACK to Welcome Screen")."</font></A>";
            }
            echo"<HTML><HEAD>\n";
            echo"<TITLE>"._QXZ("Agent Timeclock")."</TITLE>\n";
            echo"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">\n";
            echo"</HEAD>\n";
            echo "<body>";
            echo $body_stuff;
            echo "<CENTER>";
            echo "<table width=\"100%\"><tr><td></td>\n";
            echo "</tr></table>\n";
            echo "<br /><br /><br /><center id=\"login_center\" class=\"login_center fadeIn\"><table class=\"login_table\" width=\"460px\" cellpadding=\"3\" cellspacing=\"0\"><tr bgcolor=\"white\">";
            echo "<td colspan=\"2\" align=\"center\" valign=\"bottom\" width=\"170\"><img src=\"$selected_logo\" border=\"0\" height=\"45\" width=\"170\" alt=\"Agent Screen\" /></td>";
            echo "</tr>\n";
            echo "<tr><td align=\"left\" colspan=\"2\"><font size=\"1\"> &nbsp; </font></td></tr>\n";
            echo "<TR><TD ALIGN=CENTER COLSPAN=2><font size=3><font class=\"skb_text\"> $LOGtimeMESSAGE<hr /></font></TD></TR>\n";
            echo "<TR><TD ALIGN=CENTER COLSPAN=2><B> $BACKlink <BR>&nbsp; </B></TD></TR>\n";
            echo "<TR><TD ALIGN=CENTER COLSPAN=2><font class=\"body_tiny\"><BR>"._QXZ("VERSION:")." $version &nbsp; &nbsp; &nbsp; "._QXZ("BUILD:")." $build</TD></TR>\n";
            echo "</TABLE>\n";
            echo "</body>\n\n";
            echo "</html>\n\n";
            exit;
        }
        if (($status=='AUTOLOGOUT') or ($status=='START') or ($status=='LOGOUT') or ($status=='TIMEOUTLOGOUT')) {
            $VDdisplayMESSAGE = _QXZ("Time since you were last logged-in:")." $totTIME_HMS";
            $log_action = 'login';
            $button_name = _QXZ("LOGIN");
            ;
            $LOGtimeMESSAGE = _QXZ("You last logged-out at:")." $last_action_date<hr />"._QXZ("Click LOGIN below to log-in");
        }
        if ($status=='LOGIN') {
            $VDdisplayMESSAGE = _QXZ("Amount of time you have been logged-in:")." $totTIME_HMS";
            $log_action = 'logout';
            $button_name = _QXZ("LOGOUT");
            $LOGtimeMESSAGE = _QXZ("You logged-in at:")." $last_action_date<BR><hr />"._QXZ("Amount of time you have been logged-in:")." $totTIME_HMS<hr />"._QXZ("Click LOGOUT below to log-out");
        }
        echo"<HTML><HEAD>\n";
        echo"<TITLE>"._QXZ("Agent Timeclock")."</TITLE>\n";
        echo"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">\n";
        echo"</HEAD>\n";
        echo "<body>";
        echo $body_stuff;
        echo "<FORM  NAME=vicidial_form ID=vicidial_form ACTION=\"$agcPAGE\" METHOD=POST>\n";
        echo "<INPUT TYPE=HIDDEN NAME=stage VALUE=\"$log_action\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=commit VALUE=\"YES\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=referrer VALUE=\"$referrer\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=DB VALUE=\"$DB\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=phone_login VALUE=\"$phone_login\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=phone_pass VALUE=\"$phone_pass\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=VD_login VALUE=\"$VD_login\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=VD_pass VALUE=\"$VD_pass\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=user VALUE=\"$user\">\n";
        echo "<INPUT TYPE=HIDDEN NAME=pass VALUE=\"$pass\">\n";
        echo "<CENTER>";
        echo "<table width=\"100%\"><tr><td></td>\n";
        echo "</tr></table>\n";
        echo "<br /><br /><br /><center id=\"login_center\" class=\"login_center fadeIn\"><table class=\"login_table\" width=\"460px\" cellpadding=\"3\" cellspacing=\"0\"><tr bgcolor=\"white\">";
        echo "<td colspan=\"2\" align=\"center\" valign=\"bottom\" width=\"170\"><img src=\"$selected_logo\" border=\"0\" height=\"45\" width=\"170\" alt=\"Agent Screen\" /></td>";
        echo "</tr>\n";
        echo "<tr><td align=\"left\" colspan=\"2\"><font size=\"1\"> &nbsp; </font></td></tr>\n";
        echo "<TR><TD ALIGN=CENTER COLSPAN=2><font size=3><font class=\"skb_text\">$LOGtimeMESSAGE<hr /></font></TD></TR>\n";
        echo "<TR><TD ALIGN=CENTER COLSPAN=2><INPUT class=\"btn btn-info\" TYPE=SUBMIT NAME=\"$button_name\" VALUE=\"$button_name\"> &nbsp; </TD></TR>\n";
        echo "<TR><TD ALIGN=center COLSPAN=2><font size=1><BR>"._QXZ("VERSION:")." $version &nbsp; &nbsp; &nbsp; "._QXZ("BUILD:")." $build</TD></TR>\n";
        echo "</TABLE>\n";
        echo "</FORM>\n\n";
        echo "</body>\n\n";
        echo "</html>\n\n";
        exit;
    }
} else {
    echo"<HTML><HEAD>\n";
    echo"<TITLE>"._QXZ("Agent Timeclock")."</TITLE>\n";
    echo"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">\n";
    echo"</HEAD>\n";
    echo "<body>";
    echo $body_stuff;
    echo "<FORM  NAME=vicidial_form ID=vicidial_form ACTION=\"$agcPAGE\" METHOD=POST>\n";
    echo "<INPUT TYPE=HIDDEN NAME=stage VALUE=\"login\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=referrer VALUE=\"$referrer\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=DB VALUE=\"$DB\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=phone_login VALUE=\"$phone_login\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=phone_pass VALUE=\"$phone_pass\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=VD_login VALUE=\"$VD_login\">\n";
    echo "<INPUT TYPE=HIDDEN NAME=VD_pass VALUE=\"$VD_pass\">\n";
    echo "<CENTER>";
    echo "<table width=\"100%\"><tr><td></td>\n";
    echo "</tr></table>\n";
    if (!empty($VDdisplayMESSAGE)) {
        echo "<br /><div class=\"alert alert-warning fadeIn\"><center>⚠ $VDdisplayMESSAGE</div><center>";
    } else {
        echo "<br /><div class=\"alert alert-success fadeIn\"><center>👋 " . _QXZ("Welcome to mDial Timeclock!") . " ⏱</div><center>";
    }
    echo "<br /><br /><br /><center id=\"login_center\" class=\"login_center fadeIn\"><table class=\"login_table\" width=\"460px\" cellpadding=\"3\" cellspacing=\"0\"><tr bgcolor=\"white\">";
    echo "<td colspan=\"2\" align=\"center\" valign=\"bottom\" width=\"170\"><img src=\"$selected_logo\" border=\"0\" height=\"45\" width=\"170\" alt=\"Agent Screen\" /></td>";
    echo "</tr>\n";
    echo "<tr><td align=\"left\" colspan=\"2\"><font size=\"1\"> &nbsp; </font></td></tr>\n";
    echo "<TR><TD ALIGN=CENTER><font class=\"skb_text\">"._QXZ("User Login").": </TD></TR>";
    echo "<TR><TD ALIGN=CENTER><INPUT TYPE=TEXT NAME=user class=\"form-control\" SIZE=10 MAXLENGTH=20 VALUE=\"$VD_login\"></TD></TR>\n";
    echo "<TR><TD ALIGN=CENTER><font class=\"skb_text\">"._QXZ("User Password:")."  </TD></TR>";
    echo "<TR><TD ALIGN=LEFT><INPUT TYPE=PASSWORD NAME=pass id=\"password\" class=\"form-control\" SIZE=10 MAXLENGTH=20 VALUE=''><i class=\"bi-eye-slash\" id=\"togglePassword\"><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" class=\"bi-eye-fill\" viewBox=\"0 0 16 16\"><path d=\"M10.5 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z\"/><path d=\"M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8zm8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z\"/></svg></i></TD></TR>\n";
    echo "<TR><TD ALIGN=CENTER COLSPAN=2><br /><INPUT class=\"btn btn-info\" TYPE=SUBMIT NAME=SUBMIT VALUE="._QXZ("SUBMIT")."> &nbsp; </TD></TR>\n";
    echo "<TR><TD ALIGN=CENTER COLSPAN=2><font class=\"body_tiny\"><BR>"._QXZ("VERSION:")." $version &nbsp; &nbsp; &nbsp; "._QXZ("BUILD:")." $build</TD></TR>\n";
    echo "</TABLE>\n";
    echo "</FORM>\n\n";
    echo $INSERT_before_body_close;
    echo "</body>\n\n";
    echo "</html>\n\n";
}
exit;
?>
