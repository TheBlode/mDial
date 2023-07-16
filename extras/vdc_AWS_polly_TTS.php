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
$version = '2.14-1';
$build = '220410-2127';
$api_script = 'AWS_polly';
$startMS = microtime();
require_once("dbconnect_mysqli.php");
require_once("functions.php");
$query_string = getenv("QUERY_STRING");
if (isset($_GET["user"]))            {$user=$_GET["user"];}
    elseif (isset($_POST["user"]))    {$user=$_POST["user"];}
if (isset($_GET["pass"]))            {$pass=$_GET["pass"];}
    elseif (isset($_POST["pass"]))    {$pass=$_POST["pass"];}
if (isset($_GET["message"]))            {$message=$_GET["message"];}
    elseif (isset($_POST["message"]))    {$message=$_POST["message"];}
if (isset($_GET["counter"]))            {$counter=$_GET["counter"];}
    elseif (isset($_POST["counter"]))    {$counter=$_POST["counter"];}
if (isset($_GET["force"]))            {$force=$_GET["force"];}
    elseif (isset($_POST["force"]))    {$force=$_POST["force"];}
if (isset($_GET["voice"]))            {$voice=$_GET["voice"];}
    elseif (isset($_POST["voice"]))    {$voice=$_POST["voice"];}
if (isset($_GET["DB"]))                {$DB=$_GET["DB"];}
    elseif (isset($_POST["DB"]))    {$DB=$_POST["DB"];}
$DB=preg_replace("/[^0-9a-zA-Z]/","",$DB);
$user=preg_replace("/\'|\"|\\\\|;| /","",$user);
$pass=preg_replace("/\'|\"|\\\\|;| /","",$pass);
$stmt = "SELECT use_non_latin,allow_sipsak_messages,enable_languages,language_method,meetme_enter_login_filename,meetme_enter_leave3way_filename,agent_debug_logging,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                        $row[0];
    $allow_sipsak_messages =            $row[1];
    $SSenable_languages =                $row[2];
    $SSlanguage_method =                $row[3];
    $meetme_enter_login_filename =        $row[4];
    $meetme_enter_leave3way_filename =    $row[5];
    $SSagent_debug_logging =            $row[6];
    $SSallow_web_debug =                $row[7];
    }
if ($SSallow_web_debug < 1) {$DB=0;}
header ("Content-type: text/html; charset=utf-8");
header ("Cache-Control: no-cache, must-revalidate");  // HTTP/1.1
header ("Pragma: no-cache");                          // HTTP/1.0
$txt = '.txt';
$StarTtime = date("U");
$NOW_DATE = date("Y-m-d");
$NOW_TIME = date("Y-m-d H:i:s");
$CIDdate = date("mdHis");
$ENTRYdate = date("YmdHis");
$MT[0]='';
$message = preg_replace("/\'|\\\\|;/","",$message);
$counter = preg_replace("/[^0-9]/","",$counter);
$force = preg_replace("/[^0-9]/","",$force);
$voice = preg_replace("/[^-_0-9a-zA-Z]/","",$voice);
if ($non_latin < 1)
    {
    $user=preg_replace("/[^-_0-9a-zA-Z]/","",$user);
    $pass=preg_replace("/[^-_0-9a-zA-Z]/","",$pass);
    }
else
    {
    $user = preg_replace('/[^-_0-9\p{L}]/u','',$user);
    $pass = preg_replace('/[^-\.\+\/\=_0-9\p{L}]/u','',$pass);
    }
$auth=0;
$auth_message = user_authorization($user,$pass,'',0,0,0,0,'AWS_polly');
if ($auth_message == 'GOOD')
    {$auth=1;}
if ( (strlen($user)<2) or (strlen($pass)<2) or ($auth==0) )
    {
    echo _QXZ("Invalid Username/Password:")." |$user|$pass|$auth|$authlive|$auth_message|\n";
    exit;
    }
if (strlen($message) < 1)
    {
    echo "ERROR: invalid message: |$message|\n";
    }
else
    {
    if (strlen($message) < 10)
        {$message = '<speak>this is a test of the AWS Polly text to speech service. Number test, <say-as interpret-as="characters">1234567890</say-as>. Currency test, 987654321 dollars and 98 cents. Done.</speak>';}
    if (strlen($voice) < 1) {$voice = 'Matthew';}
    require_once './polly/aws-autoloader.php';
    $awsAccessKeyId = 'XXXXXXXXXXXXXXXXXXXX';
    $awsSecretKey   = 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY';
    $credentials    = new \Aws\Credentials\Credentials($awsAccessKeyId, $awsSecretKey);
    $client         = new \Aws\Polly\PollyClient([
        'version'     => '2016-06-10',
        'credentials' => $credentials,
        'region'      => 'us-east-1',
    ]);
    $result         = $client->synthesizeSpeech([
        'Engine'       => 'neural',
        'OutputFormat' => 'pcm',
        'SampleRate'   => '8000',
        'Text'         => $message,
        'TextType'     => 'ssml',
        'VoiceId'      => $voice,
    ]);
    $resultData     = $result->get('AudioStream')->getContents();
    //Output file
    $temp_filename = "./polly/generated/".$counter."_TTS.wav";
    $fp = fopen($temp_filename, 'wb');
    $pcm_size = strlen($resultData);
    $size = 36 + $pcm_size;
    $chunk_size = 16;
    $audio_format = 1;
    $channels = 1; //mono
    $sample_rate = 8000; //Hz    #From the AWS Polly documentation: Valid values for pcm are "8000" and "16000" The default value is "16000".
    $bits_per_sample = 16;
    $block_align = $channels * $bits_per_sample / 8;
    $byte_rate = $sample_rate * $channels * $bits_per_sample / 8;
    //RIFF chunk descriptor
    fwrite($fp, 'RIFF');
    fwrite($fp,pack('I', $size));
    fwrite($fp, 'WAVE');
    //fmt sub-chunk
    fwrite($fp, 'fmt ');
    fwrite($fp,pack('I', $chunk_size));
    fwrite($fp,pack('v', $audio_format));
    fwrite($fp,pack('v', $channels));
    fwrite($fp,pack('I', $sample_rate));
    fwrite($fp,pack('I', $byte_rate));
    fwrite($fp,pack('v', $block_align));
    fwrite($fp,pack('v', $bits_per_sample));
    //data sub-chunk
    fwrite($fp, 'data');
    fwrite($fp,pack('i', $pcm_size));
    fwrite($fp, $resultData);
    fclose($fp);
    $endMS = microtime();
    $startMSary = explode(" ",$startMS);
    $endMSary = explode(" ",$endMS);
    $runS = ($endMSary[0] - $startMSary[0]);
    $runM = ($endMSary[1] - $startMSary[1]);
    $TOTALrun = ($runS + $runM);
    echo "SUCCESS|".$counter."_TTS.wav|\n";
    $stmt="INSERT INTO vicidial_api_log set user='polly',agent_user='$user',function='aws_polly',value='TTS',result=\"GOOD\",result_reason='$counter ".$counter."_TTS.wav bytes: $size voice: $voice',source='AWS',data='$message',api_date=NOW(),api_script='$api_script',run_time='$TOTALrun',webserver='',api_url='';";
    $rslt=mysql_to_mysqli($stmt, $link);
    $ALaffected_rows = mysqli_affected_rows($link);
    if ($DB > 0) {echo "LOG: $ALaffected_rows|$stmt|\n";}
    }
exit;
?>
