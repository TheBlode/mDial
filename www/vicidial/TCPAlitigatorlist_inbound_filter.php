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
require("dbconnect_mysqli.php");
require("functions.php");
if (isset($_GET["phone"])) {
    $phone=$_GET["phone"];
} elseif (isset($_POST["phone"])) {
    $phone=$_POST["phone"];
}
if (isset($_GET["DB"])) {
    $DB=$_GET["DB"];
} elseif (isset($_POST["DB"])) {
    $DB=$_POST["DB"];
}
if (isset($_GET["in_filter_override"])) {
    $in_filter_override=$_GET["in_filter_override"];
} elseif (isset($_POST["in_filter_override"])) {
    $in_filter_override=$_POST["in_filter_override"];
}
if (isset($_GET["in_cache_override"])) {
    $in_cache_override=$_GET["in_cache_override"];
} elseif (isset($_POST["in_cache_override"])) {
    $in_cache_override=$_POST["in_cache_override"];
}
$DB=preg_replace("/[^0-9a-zA-Z]/", "", $DB);
$stmt = "SELECT use_non_latin,webroot_writable,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                $row[0];
    $webroot_writable =            $row[1];
    $SSallow_web_debug =        $row[2];
}
if ($SSallow_web_debug < 1) {
    $DB=0;
}
$in_filter_override=preg_replace('/[^-_0-9a-zA-Z]/', '', $in_filter_override);
$in_cache_override=preg_replace('/[^-_0-9a-zA-Z]/', '', $in_cache_override);
if ($non_latin < 1) {
    $phone=preg_replace('/[^-_0-9a-zA-Z]/', '', $phone);
} else {
    $phone = preg_replace("/'|\"|\\\\|;/", "", $phone);
}
$filter_count=0;
$ENTRYdate = date("mdHis");
$stmt = "SELECT count(*) FROM vicidial_settings_containers where container_id='TCPALITIGATORLIST';";
$rslt=mysql_to_mysqli($stmt, $link);
if ($DB) {
    echo "$stmt\n";
}
$sc_ct = mysqli_num_rows($rslt);
if ($sc_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $SC_count = $row[0];
}
if ($SC_count > 0) {
    $stmt = "SELECT container_entry FROM vicidial_settings_containers where container_id='TCPALITIGATORLIST';";
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($DB) {
        echo "$stmt\n";
    }
    $sc_ct = mysqli_num_rows($rslt);
    if ($sc_ct > 0) {
        $row=mysqli_fetch_row($rslt);
        $container_entry =    $row[0];
        $container_ARY = explode("\n", $container_entry);
        $p=0;
        $scrub_url='';
        $flag_invalid=0;
        $flag_dnc=0;
        $flag_projdnc=0;
        $flag_litigator=0;
        $valid_pull=0;
        $pull_counter=0;
        $container_ct = count($container_ARY);
        while ($p <= $container_ct) {
            $line = $container_ARY[$p];
            $line = preg_replace("/\n|\r|\t|\#.*|;.*/", '', $line);
            if (preg_match("/^TCPALITIGATORLIST_URL/", $line)) {
                $scrub_url = $line;
                $scrub_url = trim(preg_replace("/.*=>/", '', $scrub_url));
            }
            if (preg_match("/^USERNAME/", $line)) {
                $APIusername = $line;
                $APIusername = trim(preg_replace("/.*=>/", '', $APIusername));
            }
            if (preg_match("/^PASSWORD/", $line)) {
                $APIpassword = $line;
                $APIpassword = trim(preg_replace("/.*=>/", '', $APIpassword));
            }
            if (preg_match("/^INBOUND_CACHE/", $line)) {
                $in_cache = $line;
                $in_cache = trim(preg_replace("/.*=>/", '', $in_cache));
            }
            $p++;
        }
        if (strlen($in_filter_override)>5) {
            if ($DB) {
                echo "FILTER OVERRIDE: $in_filter_override|$in_filter\n";
            }
            $in_filter = $in_filter_override;
        }
        if (strlen($in_cache_override)>0) {
            if ($DB) {
                echo "CACHE OVERRIDE: $in_cache_override|$in_cache\n";
            }
            $in_cache = $in_cache_override;
        }
        $scrub_url .= $phone . "/";
        $cache_found=0;
        if ((strlen($in_cache)>0) and ($in_cache > 0)) {
            $stmt = "SELECT full_response,scrub_date FROM vicidial_dnccom_scrub_log where phone_number='$phone' and scrub_date > CONCAT(DATE_ADD(CURDATE(), INTERVAL -$in_cache DAY),' ',CURTIME()) order by scrub_date desc limit 1;";
            $rslt=mysql_to_mysqli($stmt, $link);
            if ($DB) {
                echo "$stmt\n";
            }
            $vdsl_ct = mysqli_num_rows($rslt);
            if ($vdsl_ct > 0) {
                $row=mysqli_fetch_row($rslt);
                $SCUfile_contents =    $row[0];
                $cache_found++;
                if ($DB) {
                    echo "CACHE FOUND: $row[1]|$vdsl_ct|$stmt\n";
                }
            }
        }
        if ($cache_found < 1) {
            while (($valid_pull < 1) and ($pull_counter < 5)) {
                $uniqueid = $ENTRYdate . '.' . $phone;
                $SQL_log = "$scrub_url";
                $SQL_log = preg_replace('/;|\n/', '', $SQL_log);
                $SQL_log = addslashes($SQL_log);
                $stmt = "INSERT INTO vicidial_url_log SET uniqueid='$uniqueid',url_date=NOW(),url_type='TCPAlit',url='$SQL_log',url_response='';";
                if ($DB) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                $url_id = mysqli_insert_id($link);
                $URLstart_sec = date("U");
                if ($DB > 0) {
                    echo "$scrub_url($APIusername:$APIpassword)<BR>\n";
                }
                $curl = curl_init();
                curl_setopt_array($curl, array(
                    CURLOPT_RETURNTRANSFER => 1,
                    CURLOPT_URL => $scrub_url,
                    CURLOPT_POST => 0,
                    CURLOPT_HTTPAUTH => CURLAUTH_BASIC,
                    CURLOPT_USERPWD => "$APIusername:$APIpassword",
                    CURLOPT_SSL_VERIFYPEER => false,
                    CURLOPT_USERAGENT => 'VICIdial inbound DID filter',
                    CURLOPT_VERBOSE => 1
                ));
                $resp = curl_exec($curl);
                $err = curl_errno($curl);
                $errmsg = curl_error($curl);
                $header = curl_getinfo($curl);
                $header_string = implode(">", $header).
                curl_close($curl);
                $header_ct = count($header);
                if ($DB > 0) {
                    echo "OUTPUT: |$resp|<BR>DEBUG: |$err|$errmsg|$header_string($header_ct)|<BR>\n";
                }
                $URLend_sec = date("U");
                $URLdiff_sec = ($URLend_sec - $URLstart_sec);
                if ($resp) {
                    if (is_array($resp)) {
                        $SCUfile_contents = implode("", $resp);
                    } else {
                        $SCUfile_contents = $resp;
                    }
                    $SCUfile_contents = preg_replace("/;|\n/", '', $SCUfile_contents);
                    $SCUfile_contents = addslashes($SCUfile_contents);
                    $valid_pull++;
                } else {
                    $SCUfile_contents = "PHP ERROR: Info=$info_string";
                    if (!preg_match("/\d/", $phone)) {
                        $valid_pull++;
                    }
                }
                $stmt = "UPDATE vicidial_url_log SET response_sec='$URLdiff_sec',url_response='$SCUfile_contents' where url_log_id='$url_id';";
                if ($DB) {
                    echo "$stmt\n";
                }
                $rslt=mysql_to_mysqli($stmt, $link);
                $affected_rows = mysqli_affected_rows($link);
                $pull_counter++;
            }
        }
        if (preg_match("/match/", $SCUfile_contents)) {
            $flag_litigator++;
            $filter_count++;
        }
        if ($cache_found < 1) {
            $stmt = "INSERT INTO vicidial_dnccom_scrub_log SET phone_number='$phone',scrub_date=NOW(),flag_invalid='$flag_invalid',flag_dnc='$flag_dnc',flag_projdnc='$flag_projdnc',flag_litigator='$flag_litigator',full_response='$SCUfile_contents';";
            $rslt=mysql_to_mysqli($stmt, $link);
            $affected_rows = mysqli_affected_rows($link);
            if ($DB) {
                echo "$affected_rows|$stmt\n";
            }
        }
        if ($DB) {
            echo "DEBUG: pulls - $pull_counter\n";
        }
    }
}
echo "$filter_count\n";
?>
