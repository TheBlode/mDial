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
if (isset($_GET["phone"]))                {$phone=$_GET["phone"];}
    elseif (isset($_POST["phone"]))        {$phone=$_POST["phone"];}
if (isset($_GET["format"]))                {$format=$_GET["format"];}
    elseif (isset($_POST["format"]))    {$format=$_POST["format"];}
if (isset($_GET["auth"]))                {$auth=$_GET["auth"];}
    elseif (isset($_POST["auth"]))        {$auth=$_POST["auth"];}
if (isset($_GET["DB"]))                    {$DB=$_GET["DB"];}
    elseif (isset($_POST["DB"]))        {$DB=$_POST["DB"];}
$DB = preg_replace('/[^0-9]/','',$DB);
$DB=0; # disable $DB, it's not used in this script
$phone = preg_replace("/\<|\>|\'|\"|\\\\|;/","",$phone);
$format = preg_replace("/\<|\>|\'|\"|\\\\|;/","",$format);
$auth = preg_replace("/\<|\>|\'|\"|\\\\|;/","",$auth);
$US='_';
if(preg_match("/VDC1234593JH654398722/i",$auth))
    {$nothing=1;}
else
    {
    echo "auth code: |$auth|\n";
    exit;
    }
$fp = fopen ("/usr/local/apache2/htdocs/vicidial/auth_entries.txt", "w");
$date = date("r");
$ip = getenv("REMOTE_ADDR");
$browser = getenv("HTTP_USER_AGENT");
fwrite ($fp, "AUTH|VDC   |$date|\n");
fclose($fp);
if (strlen($format)<3) {$format='WAV';}
if ( (strlen($phone)<10) or (strlen($phone)>10) ) 
    {
    echo "<html>\n";
    echo "<head>\n";
    echo "<title>Recording ID Lookup: </title>\n";
    echo "</head>\n";
    echo "<body bgcolor=white>\n";
    echo "<br><br>\n";
    echo "You need to use only a 10-digit phone number<BR>\n";
    echo "recording_lookup_DIRECT.php?format=WAV&phone=7275551212&auth=VDC1234593JH654398722\n<BR>";
    exit;
    }
else
    {
    $stmt="select recording_id,filename,location,start_time from recording_log where filename LIKE \"%$phone%\" order by recording_id desc LIMIT 1;";
    $rslt=mysql_to_mysqli($stmt, $linkAST);
    $logs_to_print = mysqli_num_rows($rslt);
    $u=0;
    if ($logs_to_print)
        {
        $row=mysqli_fetch_row($rslt);
        $recording_id = $row[0]; 
        $filename =        $row[1];
        $location =        $row[2];
        $start_time =    $row[3];
        $AUDname =    explode("/",$location);
        $AUDnamect =    (count($AUDname)) - 1;
        preg_replace('/10\.10\.10\.16/i', "10.10.10.16",$AUDname[$AUDnamect]);
        $fileGSM=$AUDname[$AUDnamect];
        $locationGSM=$location;
        $fileGSM = preg_replace('/\.wav/i', ".gsm",$fileGSM);
        if (!preg_match('/gsm/i',$locationGSM))
            {
            $locationGSM = preg_replace('/10\.10\.10\.16/i', "10.10.10.16/GSM",$locationGSM);
            $locationGSM = preg_replace('/\.wav/i', ".gsm",$locationGSM);
            }
        if ($format == 'WAV')
            {
            exec("/usr/local/apache2/htdocs/vicidial/wget --output-document=/usr/local/apache2/htdocs/vicidial/temp/$AUDname[$AUDnamect] $location\n");
            $AUDIOfile = "/usr/local/apache2/htdocs/vicidial/temp/$AUDname[$AUDnamect]";
            $AUDIOfilename = "$AUDname[$AUDnamect]";
            // We'll be outputting a PDF
            header('Content-type: audio/wav');
            // It will be named properly
            header("Content-Disposition: attachment; filename=\"$AUDIOfilename\"");
            // The PDF source is in original.pdf
            readfile($AUDIOfile);
            }
        if ($format == 'GSM')
            {
            passthru("/usr/local/apache2/htdocs/vicidial/wget --output-document=/usr/local/apache2/htdocs/vicidial/temp/$fileGSM $locationGSM\n");
            $AUDIOfile = "/usr/local/apache2/htdocs/vicidial/temp/$fileGSM";
            $AUDIOfilename = "$fileGSM";
            // We'll be outputting a PDF
            header('Content-type: audio/gsm');
            // It will be named properly
            header("Content-Disposition: attachment; filename=\"$AUDIOfilename\"");
            // The PDF source is in original.pdf
            readfile($AUDIOfile);
            }
        }
    else
        {
        echo "ERROR:        $phone|$format\n";
        }
    }
?>
