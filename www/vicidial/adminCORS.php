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
$NOW_TIME = date("Y-m-d H:i:s");
if (strlen($php_script) < 1) {
    $donothing=1;
} else {
    $CORS_origin = $_SERVER['HTTP_ORIGIN']; # The client browser origin server
    $CORS_method = isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']) ? $_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD'] : $_SERVER['REQUEST_METHOD']; # Either the requested HTTP method or the current one
    $CORS_affected_scripts = " $CORS_affected_scripts "; # surround with spaces for preg match below
    if ($CORS_debug > 0) {
        $fp = fopen("./CORSdebug_log.txt", "a");
        fwrite($fp, "$NOW_TIME CORS-Debug 1: BEGIN - |$CORS_allowed_origin($CORS_origin)|$CORS_allowed_methods($CORS_method)|$CORS_affected_scripts($php_script)|$CORS_allowed_credentials|$CORS_allowed_headers|$Xframe_options|$CORS_debug|\n");
        fclose($fp);
    }
    if ((strlen($CORS_allowed_origin) < 1) or (strlen($CORS_allowed_methods) < 1) or (strlen($CORS_affected_scripts) < 1)) {
        if ($CORS_debug > 0) {
            $fp = fopen("./CORSdebug_log.txt", "a");
            fwrite($fp, "$NOW_TIME CORS-Debug 2: variable not set - |$CORS_allowed_origin|$CORS_allowed_methods|$CORS_affected_scripts|\n");
            fclose($fp);
        }
    } else {
        if (preg_match('/ ' . $php_script . ' /i', $CORS_affected_scripts)) {
            if ((($CORS_allowed_origin == '*') or (stripos($CORS_allowed_origin, $CORS_origin) !== false) or (preg_match('/' . $CORS_allowed_origin . '/i', $CORS_origin))) and (preg_match('/' . $CORS_method . '/i', $CORS_allowed_methods))) {
                header('Access-Control-Allow-Origin: ' . $CORS_origin);
                header('Access-Control-Allow-Methods: ' . $CORS_allowed_methods);
                if (strlen($CORS_allowed_headers) > 0) {
                    header('Access-Control-Allow-Headers: ' . $CORS_allowed_headers);
                }
                if ($CORS_allowed_credentials == 'Y') {
                    header('Access-Control-Allow-Credentials: true');
                }
                if ($CORS_debug > 0) {
                    $fp = fopen("./CORSdebug_log.txt", "a");
                    fwrite($fp, "$NOW_TIME CORS-Debug 3: MATCHES found - |$CORS_allowed_origin($CORS_origin)|$CORS_allowed_methods($CORS_method)|$php_script\n");
                    fclose($fp);
                }
            } else {
                if ($CORS_debug > 0) {
                    $fp = fopen("./CORSdebug_log.txt", "a");
                    fwrite($fp, "$NOW_TIME CORS-Debug 4: NO MATCH origin or method - |$CORS_allowed_origin($CORS_origin)|$CORS_allowed_methods($CORS_method)|$php_script\n");
                    fclose($fp);
                }
            }
            if ((strcasecmp($_SERVER['REQUEST_METHOD'], 'OPTIONS') == 0) and (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))) {
                flush();
                die();
            }
        } else {
            if ($CORS_debug > 0) {
                $fp = fopen("./CORSdebug_log.txt", "a");
                fwrite($fp, "$NOW_TIME CORS-Debug 5: NO AFFECT script - |$CORS_affected_scripts|$php_script|\n");
                fclose($fp);
            }
        }
        if (($Xframe_options == 'SAMEORIGIN') or ($Xframe_options == 'DENY')) {
            header('X-Frame-Options: ' . $Xframe_options);
            if ($CORS_debug > 0) {
                $fp = fopen("./CORSdebug_log.txt", "a");
                fwrite($fp, "$NOW_TIME CORS-Debug 6: X-frame-Options sent - |$Xframe_options|$php_script\n");
                fclose($fp);
            }
        }
    }
}
?>
