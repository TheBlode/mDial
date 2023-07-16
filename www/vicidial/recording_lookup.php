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
$STARTtime = date("U");
$TODAYstart = date("H/i/s 00:00:00");
$linkAST=mysqli_connect("1.1.1.1", "cron", "1234", "asterisk");
$PHP_AUTH_USER=$_SERVER['PHP_AUTH_USER'];
$PHP_AUTH_PW=$_SERVER['PHP_AUTH_PW'];
$PHP_SELF=$_SERVER['PHP_SELF'];
$PHP_SELF = preg_replace('/\.php.*/i','.php',$PHP_SELF);
if (isset($_GET["QUERY_recid"]))                {$QUERY_recid=$_GET["QUERY_recid"];}
    elseif (isset($_POST["QUERY_recid"]))        {$QUERY_recid=$_POST["QUERY_recid"];}
$QUERY_recid = preg_replace("/\<|\>|\'|\"|\\\\|;/","",$QUERY_recid);
$PHP_AUTH_USER = preg_replace("/\<|\>|\'|\"|\\\\|;/","",$PHP_AUTH_USER);
$PHP_AUTH_PW = preg_replace("/\<|\>|\'|\"|\\\\|;/","",$PHP_AUTH_PW);
$web_server = '1.1.1.1';
$US='_';
if( (preg_match("/VDC/i",$PHP_AUTH_USER)) or (preg_match("/VDC/i",$PHP_AUTH_PW)) )
    {
    }
else
    {
    Header("WWW-Authenticate: Basic realm=\"VICI-VERIF\"");
    Header("HTTP/1.0 401 Unauthorized");
    echo "Invalid Username/Password: |$PHP_AUTH_USER|$PHP_AUTH_PW|\n";
    exit;
    }
require("screen_colors.php");
?>
<html>
<head>
<title>Recording ID Lookup: </title>
</head>
<body bgcolor=white>
<?php 
echo "<br><br>\n";
if (strlen($QUERY_recid)<10)
    {
    echo "Please enter a recording ID(customer phone number) below:\n";
    }
else
    {
    $logs_to_print=0;
    echo "<B>searching for: $QUERY_recid</B>\n";
    echo "<PRE>\n";
    $stmt="select recording_id,lead_id,user,filename,location,start_time,length_in_sec from recording_log where filename LIKE \"%$QUERY_recid%\" order by recording_id desc LIMIT 1;";
    $rslt=mysql_to_mysqli($stmt, $linkAST);
    $logs_to_print = mysqli_num_rows($rslt);
    $u=0;
    if ($logs_to_print)
        {
        $row=mysqli_fetch_row($rslt);
        $phone = $QUERY_recid;
        $recording_id = $row[0]; 
        $lead_id =        $row[1]; 
        $user =            $row[2];
        $filename =        $row[3];
        $location =        $row[4];
        $start_time =    $row[5];
        $length_in_sec = $row[6];
        $AUDname =    explode("/",$location);
        $AUDnamect =    (count($AUDname)) - 1;
        preg_replace('/10\.10\.10\.16/i', "10.10.10.16",$AUDname[$AUDnamect]);
        echo "Call Date/Time:        $start_time\n";
        echo "Recording Length:      $length_in_sec\n";
        echo "Phone Number:          $phone\n";
        echo "Recording ID:          $recording_id\n";
        echo "Agent:                 $user\n";
        echo "Unique ID:             $lead_id\n";
        $fileGSM=$AUDname[$AUDnamect];
        $locationGSM=$location;
        $fileGSM = preg_replace('/\.wav/i', ".gsm",$fileGSM);
        if (!preg_match('/gsm/i',$locationGSM))
            {
            $locationGSM = preg_replace('/10\.10\.10\.16/i', "10.10.10.16/GSM",$locationGSM);
            $locationGSM = preg_replace('/\.wav/i', ".gsm",$locationGSM);
            }
        passthru("/usr/local/apache2/htdocs/vicidial/wget --output-document=/usr/local/apache2/htdocs/vicidial/temp/$AUDname[$AUDnamect] $location\n");
        passthru("/usr/local/apache2/htdocs/vicidial/wget --output-document=/usr/local/apache2/htdocs/vicidial/temp/$fileGSM $locationGSM\n");
        echo "Link Uncompressed WAV: <a href=\"./temp/$AUDname[$AUDnamect]\">$AUDname[$AUDnamect]</a>\n";
        echo "Link Compressed GSM:   <a href=\"./temp/$fileGSM\">$fileGSM</a>\n";
        }
    else
        {
        echo "ERROR:        $QUERY_recid\n";
        }
    echo "</PRE>\n";
    }
$ENDtime = date("U");
$RUNtime = ($ENDtime - $STARTtime);
echo "\n\n\n<br><br><br>\n<FORM ACTION=\"$PHP_SELF\" METHOD=GET>\n";
echo "<INPUT TYPE=text name=QUERY_recid size=12 maxlength=10>\n";
echo "<INPUT style='background-color:#$SSbutton_color' type=submit name=submit value='"._QXZ("submit")."'>\n";
echo "</FORM>\n";
echo "\n\n\n<br><br><br>\nscript runtime: $RUNtime seconds";
?>
</body>
</html>
