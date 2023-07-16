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
if (file_exists("/etc/astguiclient.conf")) {
    $DBCagc = file("/etc/astguiclient.conf");
    foreach ($DBCagc as $DBCline) {
        $DBCline = preg_replace("/ |>|\n|\r|\t|\#.*|;.*/", "", $DBCline);
        if (preg_match("/^PATHlogs/", $DBCline)) {
            $PATHlogs = $DBCline;
            $PATHlogs = preg_replace("/.*=/", "", $PATHlogs);
        }
        if (preg_match("/^PATHweb/", $DBCline)) {
            $WeBServeRRooT = $DBCline;
            $WeBServeRRooT = preg_replace("/.*=/", "", $WeBServeRRooT);
        }
        if (preg_match("/^VARserver_ip/", $DBCline)) {
            $WEBserver_ip = $DBCline;
            $WEBserver_ip = preg_replace("/.*=/", "", $WEBserver_ip);
        }
        if (preg_match("/^VARDB_server/", $DBCline)) {
            $VARDB_server = $DBCline;
            $VARDB_server = preg_replace("/.*=/", "", $VARDB_server);
        }
        if (preg_match("/^VARDB_database/", $DBCline)) {
            $VARDB_database = $DBCline;
            $VARDB_database = preg_replace("/.*=/", "", $VARDB_database);
        }
        if (preg_match("/^VARDB_user/", $DBCline)) {
            $VARDB_user = $DBCline;
            $VARDB_user = preg_replace("/.*=/", "", $VARDB_user);
        }
        if (preg_match("/^VARDB_pass/", $DBCline)) {
            $VARDB_pass = $DBCline;
            $VARDB_pass = preg_replace("/.*=/", "", $VARDB_pass);
        }
        if (preg_match("/^VARDB_port/", $DBCline)) {
            $VARDB_port = $DBCline;
            $VARDB_port = preg_replace("/.*=/", "", $VARDB_port);
        }
    }
} else {
    $VARDB_server = 'localhost';
    $VARDB_port = '3306';
    $VARDB_user = 'cron';
    $VARDB_pass = '1234';
    $VARDB_database = '1234';
    $WeBServeRRooT = '/usr/local/apache2/htdocs';
}
$link=mysql_connect("$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass");
if (!$link) {
    die('MySQL connect ERROR: ' . mysql_error());
}
mysql_select_db("$VARDB_database");
$local_DEF = 'Local/';
$conf_silent_prefix = '7';
$local_AMP = '@';
$ext_context = 'demo';
$recording_exten = '8309';
$WeBRooTWritablE = '1';
$non_latin = '0';    # set to 1 for UTF rules, overridden by system_settings
$flag_channels=0;
$flag_string = 'VICIast20';
?>
