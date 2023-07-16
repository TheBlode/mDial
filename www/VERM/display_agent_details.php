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
$PHP_AUTH_USER=$_SERVER['PHP_AUTH_USER'];
$PHP_AUTH_PW=$_SERVER['PHP_AUTH_PW'];
$PHP_SELF=$_SERVER['PHP_SELF'];
$PHP_SELF = preg_replace('/\.php.*/i','.php',$PHP_SELF);
require("dbconnect_mysqli.php");
require("functions.php");
require("VERM_options.php");
require("VERM_global_vars.inc");
if (isset($_GET["user"]))            {$user=$_GET["user"];}
    elseif (isset($_POST["user"]))    {$user=$_POST["user"];}
if (isset($_GET["campaign_id"]))            {$campaign_id=$_GET["campaign_id"];}
    elseif (isset($_POST["campaign_id"]))    {$campaign_id=$_POST["campaign_id"];}
if (isset($_GET["users"]))            {$users=$_GET["users"];}
    elseif (isset($_POST["users"]))    {$users=$_POST["users"];}
if (isset($_GET["user_group"]))            {$user_group=$_GET["user_group"];}
    elseif (isset($_POST["user_group"]))    {$user_group=$_POST["user_group"];}
if (isset($_GET["location"]))            {$location=$_GET["location"];}
    elseif (isset($_POST["location"]))    {$location=$_POST["location"];}
if (isset($_GET["status"]))            {$status=$_GET["status"];}
    elseif (isset($_POST["status"]))    {$status=$_POST["status"];}
if (isset($_GET["vicidial_queue_groups"]))            {$vicidial_queue_groups=$_GET["vicidial_queue_groups"];}
    elseif (isset($_POST["vicidial_queue_groups"]))    {$vicidial_queue_groups=$_POST["vicidial_queue_groups"];}
if (isset($_GET["start_datetime"]))            {$start_datetime=$_GET["start_datetime"];}
    elseif (isset($_POST["start_datetime"]))    {$start_datetime=$_POST["start_datetime"];}
if (isset($_GET["end_datetime"]))            {$end_datetime=$_GET["end_datetime"];}
    elseif (isset($_POST["end_datetime"]))    {$end_datetime=$_POST["end_datetime"];}
if (isset($_GET["total_duration_His"]))            {$total_duration_His=$_GET["total_duration_His"];}
    elseif (isset($_POST["total_duration_His"]))    {$total_duration_His=$_POST["total_duration_His"];}
if (isset($_GET["total_pause_His"]))            {$total_pause_His=$_GET["total_pause_His"];}
    elseif (isset($_POST["total_pause_His"]))    {$total_pause_His=$_POST["total_pause_His"];}
if (isset($_GET["total_all_billable_His"]))            {$total_all_billable_His=$_GET["total_all_billable_His"];}
    elseif (isset($_POST["total_all_billable_His"]))    {$total_all_billable_His=$_POST["total_all_billable_His"];}
if (isset($_GET["total_billable_His"]))            {$total_billable_His=$_GET["total_billable_His"];}
    elseif (isset($_POST["total_billable_His"]))    {$total_billable_His=$_POST["total_billable_His"];}
$stmt = "SELECT use_non_latin,outbound_autodial_active,slave_db_server,reports_use_slave_db,enable_languages,language_method,agent_whisper_enabled,report_default_format,enable_pause_code_limits,allow_web_debug,admin_screen_colors,admin_web_directory FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($DB) {echo "$stmt\n";}
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $non_latin =                    $row[0];
    $outbound_autodial_active =        $row[1];
    $slave_db_server =                $row[2];
    $reports_use_slave_db =            $row[3];
    $SSenable_languages =            $row[4];
    $SSlanguage_method =            $row[5];
    $agent_whisper_enabled =        $row[6];
    $SSreport_default_format =        $row[7];
    $SSenable_pause_code_limits =    $row[8];
    $SSallow_web_debug =            $row[9];
    $SSadmin_screen_colors =        $row[10];
    $SSadmin_web_directory =        $row[11];
    }
if ($SSallow_web_debug < 1) {$DB=0;}
$NWB = "<IMG SRC=\"help.png\" onClick=\"FillAndShowHelpDiv(event, '";
$NWE = "')\" WIDTH=20 HEIGHT=20 BORDER=0 ALT=\"HELP\" ALIGN=TOP>";
$start_datetime=preg_replace('/[^\s\-0-9\:]/', '', $start_datetime);
$end_datetime=preg_replace('/[^\s\-0-9\:]/', '', $end_datetime);
$total_duration_His=preg_replace('/[^0-9\:]/', '', $total_duration_His);
$total_pause_His=preg_replace('/[^0-9\:]/', '', $total_pause_His);
$total_all_billable_His=preg_replace('/[^0-9\:]/', '', $total_all_billable_His);
$total_billable_His=preg_replace('/[^0-9\:]/', '', $total_billable_His);
if ($non_latin < 1)
    {
    $PHP_AUTH_USER = preg_replace('/[^-_0-9a-zA-Z]/', '', $PHP_AUTH_USER);
    $PHP_AUTH_PW = preg_replace('/[^-_0-9a-zA-Z]/', '', $PHP_AUTH_PW);
    $download_rpt = preg_replace('/[^\._0-9a-zA-Z]/','',$download_rpt);
    $user = preg_replace('/[^\-_0-9a-zA-Z]/','',$user);
    $users = preg_replace('/[^\-_0-9a-zA-Z]/','',$users);
    $user_group = preg_replace('/[^\-_0-9a-zA-Z]/','',$user_group);
    $campaign_id = preg_replace('/[^\-_0-9a-zA-Z]/','',$campaign_id);
    $location = preg_replace('/[^\- \.\,\_0-9a-zA-Z]/','',$location); 
    $status = preg_replace('/[^\- \.\,\_0-9a-zA-Z]/','',$status);
    $vicidial_queue_groups = preg_replace('/[^-_0-9a-zA-Z]/','',$vicidial_queue_groups);
    }
else
    {
    $PHP_AUTH_USER = preg_replace('/[^-_0-9\p{L}]/u', '', $PHP_AUTH_USER);
    $PHP_AUTH_PW = preg_replace('/[^-_0-9\p{L}]/u', '', $PHP_AUTH_PW);
    $download_rpt = preg_replace('/[^\._0-9\p{L}]/u','',$download_rpt);
    $user = preg_replace('/[^-_0-9\p{L}]/u','',$user);
    $users = preg_replace('/[^-_0-9\p{L}]/u','',$users);
    $user_group = preg_replace('/[^-_0-9\p{L}/u','',$user_group);
    $campaign_id = preg_replace('/[^-_0-9\p{L}/u','',$campaign_id);
    $location = preg_replace('/[^- \.\,\_0-9\p{L}]/u','',$location); 
    $status = preg_replace('/[^- \.\,\_0-9\p{L}]/u','',$status);
    $vicidial_queue_groups = preg_replace('/[^-_0-9\p{L}]/u','',$vicidial_queue_groups);
    }
if (!$user || !$start_datetime || !$end_datetime) {echo "Missing information - needs a minimum of: user, start date/time, end date/time"; die;}
function RemoveEmptyArrayStrings($array) 
    {
    if (is_array($array))
        {
        for ($i=0; $i<count($array); $i++)
                {
                if ($array[$i]=="") {unset($array[$i]);}
                }
        }
    return $array;
    }
$where_event_time_sql="where event_time>='$start_datetime' and event_time<='$end_datetime' ";
$where_event_date_sql="where event_date>='$start_datetime' and event_date<='$end_datetime' ";
$vicidial_queue_groups=preg_replace('/[^-_0-9\p{L}]/u','',$vicidial_queue_groups);
$vicidial_queue_groups=RemoveEmptyArrayStrings($vicidial_queue_groups);
if ($vicidial_queue_groups)
    {
    $vqg_stmt="select included_campaigns, included_inbound_groups from vicidial_queue_groups where queue_group='$vicidial_queue_groups'";
    $vqg_rslt=mysql_to_mysqli($vqg_stmt, $link);
    if(mysqli_num_rows($vqg_rslt)>0)
        {
        $vqg_row=mysqli_fetch_array($vqg_rslt);
        $included_campaigns=trim(preg_replace('/\s\-$/', '', $vqg_row["included_campaigns"]));
        $included_campaigns_clause="and campaign_id in ('".preg_replace('/\s/', "', '", $included_campaigns)."')";
        $included_inbound_groups=trim(preg_replace('/\s\-$/', '', $vqg_row["included_inbound_groups"]));
        $included_inbound_groups_clause="and group_id in ('".preg_replace('/\s/', "', '", $included_inbound_groups)."')";
        $where_included_inbound_groups_clause="where group_id in ('".preg_replace('/\s/', "', '", $included_inbound_groups)."')";
        }
    }
$atomic_queue_str="";
$atomic_queue_campaigns_str="";
$campaign_id_stmt="select campaign_id, campaign_name from vicidial_campaigns where campaign_id is not null $included_campaigns_clause order by campaign_id"; # $LOGallowed_campaignsSQL, removed for now per Matt's assurances
$campaign_id_rslt=mysql_to_mysqli($campaign_id_stmt, $link);
while($campaign_id_row=mysqli_fetch_array($campaign_id_rslt))
    {
    $atomic_queue_str.=$campaign_id_row["campaign_name"];
    $atomic_queue_str.=" <i>[".$campaign_id_row["campaign_id"]."]</i>,";
    $atomic_queue_campaigns_str.="$campaign_id_row[campaign_id]', '";
    }
if ($atomic_queue_campaigns_str)
    {
    $and_atomic_queue_campaigns_clause="and campaign_id in ('".$atomic_queue_campaigns_str."') ";
    }
$closer_campaigns_stmt="select closer_campaigns from vicidial_campaigns where closer_campaigns is not null $LOGallowed_campaignsSQL"; #  $included_campaigns_clause
$closer_campaigns_rslt=mysql_to_mysqli($closer_campaigns_stmt, $link); 
$allowed_ingroups_array=array();
while ($closer_campaigns_row=mysqli_fetch_array($closer_campaigns_rslt))
    {
    $closer_campaigns_array=explode(" ", trim(preg_replace('/\s\-$/', '', $closer_campaigns_row["closer_campaigns"])));
    for ($i=0; $i<count($closer_campaigns_array); $i++)
        {
        if (!in_array($closer_campaigns_array[$i], $allowed_ingroups_array))
            {
            array_push($allowed_ingroups_array, $closer_campaigns_array[$i]);
            }
        }
    }
$atomic_queue_ingroups_str="";
$ingroups_id_stmt="select group_id, group_name from vicidial_inbound_groups $where_included_inbound_groups_clause"; #where group_id in ('".implode("', '", $allowed_ingroups_array)."') $included_inbound_groups_clause
$ingroups_id_rslt=mysql_to_mysqli($ingroups_id_stmt, $link);
while($ingroups_id_row=mysqli_fetch_array($ingroups_id_rslt))
    {
    $atomic_queue_str.=$ingroups_id_row["group_name"];
    $atomic_queue_str.=" <i>[".$ingroups_id_row["group_id"]."]</i>,";
    $atomic_queue_ingroups_str.="$ingroups_id_row[group_id]', '";
    }
$and_atomic_queue_ingroups_clause="and campaign_id in ('".$atomic_queue_ingroups_str."')";
$atomic_queue_str=preg_replace('/,$/', '', $atomic_queue_str);
if (strlen($atomic_queue_str)==0)
    {
    $atomic_queue_str="NONE";
    }
$vicidial_agent_log_SQL.="$and_atomic_queue_campaigns_clause";
$vicidial_log_SQL.="$and_atomic_queue_campaigns_clause";
$vicidial_closer_log_SQL.="$and_atomic_queue_ingroups_clause";
$vicidial_user_log_SQL.="$and_atomic_queue_campaigns_clause";
if ($user)
    {
    $user=preg_replace('/[^-_0-9\p{L}]/u','',$user);
    $and_user_sql=" and user='$user' ";
    $where_user_sql=" where user='$user' ";
    $vicidial_agent_log_SQL.=$and_user_sql;
    $vicidial_log_SQL.=$and_user_sql;
    $vicidial_closer_log_SQL.=$and_user_sql;
    $vicidial_user_log_SQL.=$and_user_sql;
    }
if ($campaign_id)
    {
    $campaign_id=preg_replace('/[^-_0-9\p{L}]/u','',$campaign_id);
    $and_campaign_id_sql=" and campaign_id='$campaign_id' ";
    $where_campaign_id_sql=" where campaign_id='$campaign_id' ";
    $vicidial_agent_log_SQL.=$and_campaign_id_sql;
    $vicidial_log_SQL.=$and_campaign_id_sql;
    $vicidial_closer_log_SQL.=$and_campaign_id_sql;
    $vicidial_user_log_SQL.=$and_campaign_id_sql;
    }
/* THIS PAGE IS FOR SPECIFIC AGENTS, NOT NECESSARY TO FILTER FOR THIS
if ($users)
    {
    $users=preg_replace('/[^-_0-9\p{L}]/u','',$users);
    $users=RemoveEmptyArrayStrings($users);
    $users_str=is_array($users) ? implode("', '", $users) : "$users";
    $and_users_sql=" and user in ('$users_str')";
    $where_users_sql=" where user in ('$users_str')";
    $vicidial_agent_log_SQL.=$and_users_sql;
    $vicidial_log_SQL.=$and_users_sql;
    $vicidial_closer_log_SQL.=$and_users_sql;
    }
*/
/* THIS PAGE IS FOR SPECIFIC AGENTS, NOT NECESSARY TO FILTER FOR THIS
if ($location)
    {
    $location=preg_replace('/[^-_0-9\p{L}]/u','',$location);
    $location=RemoveEmptyArrayStrings($location);
    $location_str=is_array($location) ? implode("', '", $location) : "$location";
    $and_location_sql.=" and user_location in ('$location_str')";
    $where_location_sql.=" where user_location in ('$location_str')";
    $user_location_stmt="select user from vicidial_users where user is not null $LOGadmin_viewable_groupsSQL $and_location_sql";
    $user_location_rslt=mysql_to_mysqli($user_location_stmt, $link);
    $users_by_location=array();
    while ($user_location_row=mysqli_fetch_row($user_location_rslt))
        {
        array_push($users_by_location, $user_location_row[0]);
        }
    if ($users)
        {
        array_push($users_by_location, $users);
        }
    $users_by_location_str=implode("', '", $users_by_location);
    $and_users_by_location_sql=" and user in ('$users_by_location_str')";
    $where_users_by_location_sql=" where user in ('$users_by_location_str')";
    $vicidial_agent_log_SQL.=$and_users_by_location_sql;
    $vicidial_log_SQL.=$and_users_by_location_sql;
    $vicidial_closer_log_SQL.=$and_users_by_location_sql;
    }
*/
if ($user_group)
    {
    $user_group=preg_replace('/[^-_0-9\p{L}]/u','',$user_group);
    $user_group=RemoveEmptyArrayStrings($user_group);
    $user_group_str=is_array($user_group) ? implode("', '", $user_group) : "$user_group";
    $and_user_group_sql.=" and user_group in ('$user_group_str') ";
    $where_user_group_sql.=" where user_group in ('$user_group_str') ";
    $vicidial_agent_log_SQL.=$and_user_group_sql;
    $vicidial_log_SQL.=$and_user_group_sql;
    $vicidial_closer_log_SQL.=$and_user_group_sql;
    $vicidial_user_log_SQL.=$and_user_group_sql;
    }
if ($status)
    {
    $status=preg_replace('/[^-_0-9\p{L}]/u','',$status);
    $and_status_sql.=" and status='$status' ";
    $vicidial_agent_log_SQL.=$and_status_sql;
    $vicidial_log_SQL.=$and_status_sql;
    $vicidial_closer_log_SQL.=$and_status_sql;
    }
$vicidial_agent_log_SQL="$where_event_time_sql".$vicidial_agent_log_SQL;
$vicidial_log_SQL="$where_call_date_sql".$vicidial_log_SQL;
$vicidial_closer_log_SQL="$where_call_date_sql".$vicidial_closer_log_SQL;
$vicidial_user_log_SQL="$where_event_date_sql".$vicidial_user_log_SQL;
$sort_char="";
$sort_index="";
$sort_clause=" order by call_date";
$sort_index=preg_replace('/ desc/', '', $sort_answered_details);
if (preg_match('/ desc$/', $sort_answered_details)) 
    {
    $sort_char="&#8595;"; 
    $reverse_link=preg_replace('/ desc$/', '', $sort_answered_details);
    } 
else 
    {
    $sort_char="&#8593;"; 
    $reverse_link=$sort_answered_details." desc";
    }
$sort_answered_details_preg=preg_replace('/ desc$/', '', $sort_answered_details);
echo "<table border=0 width='100%' bgcolor='#FFF'><tr>";
echo "<td align='left'>";
echo "<h2 class='rpt_header'>"._QXZ("Agent Detail").": $user $NWB#VERM_display_agent_details$NWE</h2>";
echo "</td>";
echo "<td align='right'>";
echo "<a onClick='HideAgentDetails()'><h2 class='rpt_header'>[X]</h2></a>";
echo "</td>";
echo "</tr>";
echo "<tr><td colspan='2'>";
echo "<span id='all_agent_details' style='display:block; overflow-y:auto; height: 70vh;'>\n";
echo "<table id=\"rpt_table\">\n";
echo "    <tr>\n";
echo "        <td style=\"width:25vw\">"._QXZ("Total session time").":</th>\n";
echo "        <td style=\"width:75vw\">$total_duration_His</td>\n";
echo "    </tr>\n";
echo "    <tr>\n";
echo "        <td style=\"width:25vw\">"._QXZ("Total pause time").":</td>\n";
echo "        <td style=\"width:75vw\">$total_pause_His</td>\n";
echo "    </tr>\n";
echo "    <tr>\n";
echo "        <td style=\"width:25vw\">"._QXZ("Total billable time (b. pauses + talk + wait + dispo)").":</td>\n";
echo "        <td style=\"width:75vw\">$total_all_billable_His</td>\n";
echo "    </tr>\n";
echo "    <tr>\n";
echo "        <td style=\"width:25vw\">"._QXZ("Total billable pauses").":</td>\n";
echo "        <td style=\"width:75vw\">$total_billable_His</td>\n";
echo "    </tr>\n";
echo "</table>\n";
echo "<hr style='height:2px;border-width:0;color:#ddd;background-color:#ddd;margin-bottom: 2em;'>";
$event_date_clause_apx="";
if (!$overnight_agents)
    {
    $init_start_stmt="select min(event_date) from vicidial_user_log $vicidial_user_log_SQL and event='LOGIN' and user='$user'";
    $init_start_rslt=mysql_to_mysqli($init_start_stmt, $link);
    if (mysqli_num_rows($init_start_rslt)>0)
        {
        $isr_row=mysqli_fetch_row($init_start_rslt);
        $event_date_clause_apx=" and event_date>='$isr_row[0]' ";
        }
    }
$session_stmt="select * from vicidial_user_log $vicidial_user_log_SQL $event_date_clause_apx and event in ('LOGIN', 'LOGOUT', 'TIMEOUTLOGOUT') and user='$user' order by event_date asc";
if ($DB) {$HTML_output.="<B>$session_stmt</B>";}
$session_rslt=mysql_to_mysqli($session_stmt, $link);
$prev_date="";
$start_event_date="";
$row_no=0; $agent_logged_in=0;
$agent_sessions_array=array();
while ($session_row=mysqli_fetch_array($session_rslt))
    {
    $original_session_start_date="$start_datetime";
    $original_session_cutoff_date=substr($start_datetime, 10)." 00:00:00";
    $original_session_cutoff_eod=substr($start_datetime, 10)." 23:59:59";
    $user=$session_row["user"];
    $campaign_id=$session_row["campaign_id"];
    $extension=$session_row["extension"];
    $event=$session_row["event"];
    $event_epoch=$session_row["event_epoch"];
    $event_time=$session_row["event_date"];
    $event_date=substr($event_time, 0, 10);
    if (!$prev_date) {$prev_date=$event_date;}
    if ($event_date!=$TODAY)
        {
        $event_date_eod="$event_date 23:59:59";
        }
    else
        {
        $event_date_eod="$event_date $NOW_TIME";
        }
    if ($row_no==0)
        {
        $override_login=0;
        $previous_interval_stmt="select * from vicidial_user_log where user='$user' $and_vicidial_user_log_SQL and event_date<='$original_session_start_date' and event_date>='$original_session_cutoff_date' and event in ('LOGIN', 'LOGOUT', 'TIMEOUTLOGOUT') order by user, event_date desc limit 1";
        $previous_interval_rslt=mysql_to_mysqli($previous_interval_stmt, $link);
        if (mysqli_num_rows($previous_interval_rslt)>0)
            {
            $previous_interval_row=mysqli_fetch_array($previous_interval_rslt);
            if ($previous_interval_row["event"]=="LOGIN")
                {
                $override_login=1;
                $login_notes="PRIOR LOGIN";
                }
            else
                {
                $next_interval_stmt="select * from vicidial_user_log where user='$user' $and_vicidial_user_log_SQL and event_date>='$original_session_start_date' and event_date<='$original_session_cutoff_eod' and event in ('LOGIN', 'LOGOUT', 'TIMEOUTLOGOUT') order by user, event_date desc limit 1";
                $next_interval_rslt=mysql_to_mysqli($next_interval_stmt, $link);
                if (mysqli_num_rows($next_interval_rslt)>0)
                    {
                    $next_interval_row=mysqli_fetch_array($next_interval_rslt);
                    if (preg_match('/LOGOUT/', $next_interval_row["event"]))
                        {
                        $override_login=1;
                        $login_notes="DOUBLE LOGOUT";
                        }
                    }
                }
            if ($override_login==1)
                {
                $start_event_date=$original_session_start_date;
                $start_epoch_stmt="select unix_timestamp('$start_event_date')";
                $start_epoch_rslt=mysql_to_mysqli($start_epoch_stmt, $link);
                $start_epoch_row=mysqli_fetch_row($start_epoch_rslt);
                $override_event_epoch=$start_epoch_row[0];
                $agent_sessions_array["$start_event_date"]["start_hour"]=$override_event_epoch;
                $agent_sessions_array["$start_event_date"]["extension"]=$extension;
                $agent_sessions_array["$start_event_date"]["login_notes"]=$login_notes;
                $agent_logged_in=1;
                }
            }
        }
    $row_no++; # Keeps from doing an override check
    if ($event=="LOGIN")
        {
        if ($agent_logged_in!=0)
            {
            unset($agent_sessions_array["$start_event_date"]);
            $agent_logged_in=0;
            }
        if ($agent_logged_in==0)
            {
            $start_event_date=$event_time;
            $agent_sessions_array["$start_event_date"]["user_group"]=$user_group;
            $agent_sessions_array["$start_event_date"]["start_hour"]=$event_epoch;
            $agent_sessions_array["$start_event_date"]["extension"]=$extension;
            $agent_sessions_array["$start_event_date"]["server_ip"]=$server_ip;
            }
        $agent_logged_in=1;
        }
    if (preg_match('/LOGOUT/', $event)) #  && $agent_logged_in==1, removed this due to back to back logouts (see user 105110 for 2022-01-10)
        {
        if ($agent_logged_in==1)
            {
            $agent_sessions_array["$start_event_date"]["end_hour"]=$event_epoch;
            $agent_sessions_array["$start_event_date"]["end_date"]=$event_time;
            $agent_sessions_array["$start_event_date"]["duration"]=($agent_sessions_array["$start_event_date"]["end_hour"]-$agent_sessions_array["$start_event_date"]["start_hour"]);
            $agent_sessions_array["$start_event_date"]["notes"]="NORMAL LOGOUT";
            }
        else
            {
            $agent_sessions_array["$start_event_date"]["notes"]="REPEAT LOGOUT";
            }
        $agent_logged_in=0;
        }
    $override_login=0;
    $prev_date=$event_date;
    $prev_event=$event;
    $prev_campaign_id=$campaign_id;
    }
$TODAY=date("Y-m-d");
$NOW_TIME=date("H:i:s");
if($agent_logged_in)
    { 
    if ($event_date!=$TODAY)
        {
        $event_date_eod="$event_date 23:59:59";
        $notes="EOD LOGOUT";
        }
    else
        {
        $event_date_eod="$event_date $NOW_TIME";
        $notes="STILL LOGGED IN";
        }
    $eod_epoch_stmt="select unix_timestamp('$start_event_date'), unix_timestamp('$event_date_eod')";
    $eod_epoch_rslt=mysql_to_mysqli($eod_epoch_stmt, $link);
    $eod_epoch_row=mysqli_fetch_row($eod_epoch_rslt);
    $agent_sessions_array["$start_event_date"]["start_hour"]=$eod_epoch_row[0];
    $agent_sessions_array["$start_event_date"]["end_hour"]=$eod_epoch_row[1];
    $agent_sessions_array["$start_event_date"]["end_date"]=$event_date_eod;
    $agent_sessions_array["$start_event_date"]["duration"]=($agent_sessions_array["$start_event_date"]["end_hour"]-$agent_sessions_array["$start_event_date"]["start_hour"]);
    $agent_sessions_array["$start_event_date"]["notes"]=$notes;
    $agent_logged_in=0;
    }
if ($DB) {print_r($agent_sessions_array);}
echo "<table id=\"details_table\">\n";
echo "<tr>\n";
echo "<th>"._QXZ("Agent")."</th>\n";
echo "<th>"._QXZ("Ext.")."</th>\n";
echo "<th>"._QXZ("Duration")."</th>\n";
echo "<th>"._QXZ("On pause")."</th>\n";
echo "<th>"._QXZ("Overlapping")."</th>\n";
echo "<th>"._QXZ("Activity")."</th>\n";
echo "<th> </th>\n";
echo "<th>"._QXZ("Start hour")."</th>\n";
echo "<th>"._QXZ("End hour")."</th>\n";
echo "</tr>\n";
foreach ($agent_sessions_array as $session_start_date => $session)
    {
    echo "<tr>\n";
    echo "<td class='small_text'>".$fullname_info["$user"]."</td>\n";
    echo "<td class='small_text'>".$session["extension"]."</td>\n";
    echo "<td class='small_text'>".sprintf('%02d', floor($session["duration"]/3600)).gmdate(":i:s", $session["duration"])."</td>\n";
    echo "<td class='small_text'>&nbsp;</td>\n";
    echo "<td class='small_text'>0:00</td>\n";
    echo "<td class='small_text'>-</td>\n";
    echo "<td class='small_text'> </td>\n";
    echo "<td class='small_text'>".$session_start_date."</td>\n";
    echo "<td class='small_text'>".$session["end_date"]."</td>\n";
    echo "</tr>\n";
    $agent_log_stmt="select sec_to_time(pause_sec) as pause_sec_fmt, event_time, event_time+INTERVAL pause_sec SECOND as end_time, if(sub_status is null or sub_status='BLANK', '-', sub_status) as pause_code, campaign_id from vicidial_agent_log where event_time>='$session_start_date' and event_time<='".$session["end_date"]."' and user='$user' order by event_time asc";
    $agent_log_rslt=mysql_to_mysqli($agent_log_stmt, $link);
    while ($agent_log_row=mysqli_fetch_array($agent_log_rslt))
        {
        $campaign_id=$agent_log_row["campaign_id"];
        $bp="N"; $pp="N";
        if (in_array($agent_log_row["pause_code"], $billable_pause_codes["$campaign_id"]) || in_array($agent_log_row["pause_code"], $billable_pause_codes["SYSTEM"]))
            {
            $is_billable="Yes"; $bp="";
            }
        if (!in_array($agent_log_row["pause_code"], $payable_pause_codes["$campaign_id"]) && in_array($agent_log_row["pause_code"], $payable_pause_codes["SYSTEM"]))
            {
            $pp="";
            }
        $billable_code=$bp."B".$pp."P";
        $pause_name_key=$campaign_id."-".$agent_log_row["pause_code"];
        echo "<tr>\n";
        echo "<td class='small_text'>&nbsp;</td>\n";
        echo "<td class='small_text'>&nbsp;</td>\n";
        echo "<td class='small_text'>&nbsp;</td>\n";
        echo "<td class='small_text'>".$agent_log_row["pause_sec_fmt"]."</td>\n";
        echo "<td class='small_text'>0:00</td>\n";
        echo "<td class='small_text'>".$pause_code_names["$pause_name_key"]."</td>\n";
        echo "<td class='small_text'>$billable_code</td>\n";
        echo "<td class='small_text'>".$agent_log_row["event_time"]."</td>\n";
        echo "<td class='small_text'>".$agent_log_row["end_time"]."</td>\n";
        echo "</tr>\n";
        }
    echo "<tr>\n";
    echo "<td class='small_text'>".$fullname_info["$user"]."</td>\n";
    echo "<td class='small_text'>".$session["extension"]."</td>\n";
    echo "<td class='small_text'>".sprintf('%02d', floor($session["duration"]/3600)).gmdate(":i:s", $session["duration"])."</td>\n";
    echo "<td class='small_text'>&nbsp;</td>\n";
    echo "<td class='small_text'>&nbsp;</td>\n";
    echo "<td class='small_text'>"._QXZ("Logout")."</td>\n";
    echo "<td class='small_text'>-</td>\n";
    echo "<td class='small_text'>".$session_start_date."</td>\n";
    echo "<td class='small_text'>".$session["end_date"]."</td>\n";
    echo "</tr>\n";
    echo "<tr>\n";
    echo "<td colspan='9'>&nbsp;</td>\n";
    echo "</tr>\n";
    }
echo "</table>";
echo "</span>\n";
echo "</td></tr></table>";
?>
