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
header ("Content-type: text/html; charset=utf-8");
require("dbconnect_mysqli.php");
require("functions.php");
if (isset($_GET["date"]))                {$date=$_GET["date"];}
    elseif (isset($_POST["date"]))        {$date=$_POST["date"];}
if (isset($_GET["format"]))                {$format=$_GET["format"];}
    elseif (isset($_POST["format"]))    {$format=$_POST["format"];}
if (isset($_GET["DB"]))                    {$DB=$_GET["DB"];}
    elseif (isset($_POST["DB"]))        {$DB=$_POST["DB"];}
$stmt = "SELECT use_non_latin,webroot_writable FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
$ss_conf_ct = mysqli_num_rows($rslt);
if ($ss_conf_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                    $row[0];
    $webroot_writable =                $row[1];
    }
if ($non_latin < 1)
    {
    $date = preg_replace("/'|\"|\\\\|;/","",$date);
    $format = preg_replace("/'|\"|\\\\|;/","",$format);
    }
else
    {
    $date = preg_replace("/'|\"|\\\\|;/","",$date);
    $format = preg_replace("/'|\"|\\\\|;/","",$format);
    }
$date=preg_replace("/\+/",' ',$date);
$record_count=0;
if (strlen($date) > 18)
    {
    $stmt = "SELECT phrase_text FROM www_phrases where insert_date >=\"$date\" order by insert_date;";
    if ($DB > 0) {echo "$stmt\n";}
    $rslt=mysql_to_mysqli($stmt, $link);
    $did_call_ct = mysqli_num_rows($rslt);
    $i=0;
    while ($did_call_ct > $i)
        {
        $row=mysqli_fetch_row($rslt);
        $phrase_text =    $row[0];
        if ($DB > 0) {echo "$i|";}
        echo "$phrase_text\n";
        $i++;
        if ( ($DB > 0) and ($webroot_writable > 0) )
            {
            $fp = fopen ("./www_phrases_recent_log.txt", "a");
            fwrite ($fp, "$i|$date|$phrase_text|$did_call_ct|$stmt\n");
            fclose($fp);
            }
        }
    }
if ($DB > 0) {echo "DONE: |$date|\n";}
?>
