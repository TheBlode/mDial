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
require("dbconnect_mysqli.php");
require("functions.php");
$style_array=array("", "italics", "bold italics");
if (isset($_GET["action"]))                            {$action=$_GET["action"];}
    elseif (isset($_POST["action"]))                {$action=$_POST["action"];}
if (isset($_GET["DB"]))                                {$DB=$_GET["DB"];}
    elseif (isset($_POST["DB"]))                    {$DB=$_POST["DB"];}
if (isset($_GET["chat_id"]))                        {$chat_id=$_GET["chat_id"];}
    elseif (isset($_POST["chat_id"]))                {$chat_id=$_POST["chat_id"];}
if (isset($_GET["chat_level"]))                        {$chat_level=$_GET["chat_level"];}
    elseif (isset($_POST["chat_level"]))            {$chat_level=$_POST["chat_level"];}
if (isset($_GET["chat_member_name"]))                {$chat_member_name=$_GET["chat_member_name"];}
    elseif (isset($_POST["chat_member_name"]))        {$chat_member_name=$_POST["chat_member_name"];}
if (isset($_GET["chat_message"]))                    {$chat_message=$_GET["chat_message"];}
    elseif (isset($_POST["chat_message"]))            {$chat_message=$_POST["chat_message"];}
if (isset($_GET["lead_id"]))                        {$lead_id=$_GET["lead_id"];}
    elseif (isset($_POST["lead_id"]))                {$lead_id=$_POST["lead_id"];}
if (isset($_GET["group_id"]))                        {$group_id=$_GET["group_id"];}
    elseif (isset($_POST["group_id"]))                {$group_id=$_POST["group_id"];}
if (isset($_GET["user"]))                            {$user=$_GET["user"];}
    elseif (isset($_POST["user"]))                    {$user=$_POST["user"];}
if (isset($_GET["user_level"]))                        {$user_level=$_GET["user_level"];}
    elseif (isset($_POST["user_level"]))            {$user_level=$_POST["user_level"];}
if (isset($_GET["keepalive"]))                        {$keepalive=$_GET["keepalive"];}
    elseif (isset($_POST["keepalive"]))                {$keepalive=$_POST["keepalive"];}
if (isset($_GET["current_message_count"]))            {$current_message_count=$_GET["current_message_count"];}
    elseif (isset($_POST["current_message_count"]))    {$current_message_count=$_POST["current_message_count"];}
if (isset($_GET["language"]))                        {$language=$_GET["language"];}
    elseif (isset($_POST["language"]))                {$language=$_POST["language"];}
if (isset($_GET["available_agents"]))                {$available_agents=$_GET["available_agents"];}
    elseif (isset($_POST["available_agents"]))        {$available_agents=$_POST["available_agents"];}
if (isset($_GET["show_email"]))                        {$show_email=$_GET["show_email"];}
    elseif (isset($_POST["show_email"]))            {$show_email=$_POST["show_email"];}
$chat_member_name = preg_replace('/[^- \.\,\_0-9a-zA-Z]/',"",$chat_member_name);
if (!$user) {echo "No user, no using."; exit;}
$DB=preg_replace("/[^0-9a-zA-Z]/","",$DB);
$lead_id = preg_replace("/[^0-9]/","",$lead_id);
$chat_id = preg_replace('/[^- \_\.0-9a-zA-Z]/','',$chat_id);
$chat_level = preg_replace('/[^- \_\.0-9a-zA-Z]/','',$chat_level);
$group_id = preg_replace('/[^- \_0-9a-zA-Z]/','',$group_id);
$language = preg_replace('/[^-\_0-9a-zA-Z]/','',$language);
$user = preg_replace("/\'|\"|\\\\|;/","",$user);
$chat_member_name = preg_replace("/\'|\"|\\\\|;/","",$chat_member_name);
$available_agents = preg_replace('/[^-\_0-9a-zA-Z]/','',$available_agents);
$show_email = preg_replace('/[^-\_0-9a-zA-Z]/','',$show_email);
$chat_message = preg_replace('/\|/', '&#124;', $chat_message);
$action = preg_replace('/[^-\_0-9a-zA-Z]/','',$action);
$user_level = preg_replace('/[^-\_0-9a-zA-Z]/','',$user_level);
$keepalive = preg_replace('/[^-\_0-9a-zA-Z]/','',$keepalive);
$current_message_count = preg_replace('/[^-\_0-9a-zA-Z]/','',$current_message_count);
$use_agent_colors=1;
if (file_exists('options.php'))
    {require('options.php');}
$VUselected_language='';
$stmt = "SELECT use_non_latin,enable_languages,language_method,default_language,chat_url,allow_chats,allow_web_debug FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
        if ($mel > 0) {mysql_error_logging($NOW_TIME,$link,$mel,$stmt,'00XXX',$user,$server_ip,$session_name,$one_mysql_log);}
if ($DB) {echo "$stmt\n";}
$qm_conf_ct = mysqli_num_rows($rslt);
if ($qm_conf_ct > 0)
    {
    $row=mysqli_fetch_row($rslt);
    $non_latin =            $row[0];
    $SSenable_languages =    $row[1];
    $SSlanguage_method =    $row[2];
    $SSdefault_language =    $row[3];
    $chat_url =                $row[4];
    $SSallow_chats =        $row[5];
    $SSallow_web_debug =    $row[6];
    }
$VUselected_language = $SSdefault_language;
if ($SSallow_web_debug < 1) {$DB=0;}
if ($non_latin < 1)
    {
    $user = preg_replace('/[^- \+\_\.0-9a-zA-Z]/','',$user);
    }
else
    {
    $user = preg_replace("/\'|\"|\\\\|;/","",$user);
    }
if (strlen($language) > 1)
    {
    $stmt = "SELECT language_code,language_description FROM vicidial_languages where language_id='$language' and active='Y';";
    $rslt=mysql_to_mysqli($stmt, $link);
            if ($mel > 0) {mysql_error_logging($NOW_TIME,$link,$mel,$stmt,'00XXX',$user,$server_ip,$session_name,$one_mysql_log);}
    if ($DB) {echo "$stmt\n";}
    $lang_good_ct = mysqli_num_rows($rslt);
    if ($lang_good_ct > 0)
        {
        $row=mysqli_fetch_row($rslt);
        $language_code =        $row[0];
        $language_description =    $row[1];
        $VUselected_language = $language;
        }
    }
if ($SSallow_chats < 1)
    {
    header ("Content-type: text/html; charset=utf-8");
    echo _QXZ("Error, chat disabled on this system");
    exit;
    }
if ($action=="send_message" && $chat_id) {
    $live_stmt="SELECT status from vicidial_live_chats where chat_id='$chat_id'";
    $live_rslt=mysql_to_mysqli($live_stmt, $link);
    if ($user && $chat_message && $chat_id && mysqli_num_rows($live_rslt)>0) {
        $live_row=mysqli_fetch_row($live_rslt);
        $status=$live_row[0];
        if ($status=="WAITING") {
            echo _QXZ("Chat is waiting for an agent").": $chat_id";
        } else {
            if ($status=="LIVE") {
                $active_stmt="SELECT * from vicidial_chat_participants where chat_id='$chat_id' and chat_member='$user'";
                $active_rslt=mysql_to_mysqli($active_stmt, $link);
                if (mysqli_num_rows($active_rslt)>0) {
                    $ins_stmt="INSERT IGNORE INTO vicidial_chat_log(chat_id, message, poster, chat_member_name, chat_level) VALUES('$chat_id', '".mysqli_real_escape_string($link, $chat_message)."', '$user', '".mysqli_real_escape_string($link, $chat_member_name)."', '$chat_level')";
                    $ins_rslt=mysql_to_mysqli($ins_stmt, $link);
                    if (mysqli_affected_rows($link)<1) {
                        echo "<font class='chat_title alert'>"._QXZ("SYSTEM ERROR")."</font><BR/>\n";
                    }
                }
            } else {
                echo "<font class='chat_title alert'>"._QXZ("SYSTEM ERROR")."</font><BR/>\n";
            }
        }
    } else if (mysqli_num_rows($rslt)==0) {
        echo _QXZ("Chat has been closed").": $chat_id";
    }
}
if ($action=="leave_chat" && $user && $chat_id) { 
    if (!$chat_member_name) {$chat_member_name="Customer";}
    $del_stmt2="DELETE from vicidial_chat_participants where chat_id='$chat_id' and chat_member='$user'";
    $del_rslt2=mysql_to_mysqli($del_stmt2, $link);
    $deleted_participants=mysqli_affected_rows($link);
    if ($deleted_participants>0) {
        $stmt="SELECT lead_id, status, chat_creator from vicidial_live_chats where chat_id='$chat_id'"; # and status='WAITING' and chat_creator='NONE'
        $rslt=mysql_to_mysqli($stmt, $link);
        if (mysqli_num_rows($rslt)>0) {
            $row=mysqli_fetch_row($rslt);
            $lead_id=$row[0];
            $chat_status=$row[1];
            $chat_creator=$row[2];
            if ($chat_status=="WAITING" && $chat_creator=="NONE") {
                $upd_stmt="UPDATE vicidial_list set status='CDROP' where lead_id='$lead_id'";
                $upd_rslt=mysql_to_mysqli($upd_stmt, $link);
                $ins_stmt="INSERT IGNORE INTO vicidial_chat_archive SELECT chat_id, chat_start_time, 'DROP', chat_creator, group_id, lead_id, transferring_agent, user_direct, user_direct_group_id From vicidial_live_chats where chat_id='$chat_id'";
                $ins_rslt=mysql_to_mysqli($ins_stmt, $link);
                $del_stmt="DELETE from vicidial_live_chats where chat_id='$chat_id'";
                $del_rslt=mysql_to_mysqli($del_stmt, $link);
                $archive_log_stmt="insert ignore into vicidial_chat_log_archive select * from vicidial_chat_log where chat_id='$chat_id'";
                $archive_log_rslt=mysql_to_mysqli($archive_log_stmt, $link);
                $del_log_stmt="delete from vicidial_chat_log where chat_id='$chat_id'";
                $del_log_rslt=mysql_to_mysqli($del_log_stmt, $link);
            } else {
                $ins_alert_stmt="INSERT INTO vicidial_chat_log(poster, chat_member_name, message_time, message, chat_id, chat_level) SELECT '$chat_creator', full_name, now(), '$chat_member_name has left chat', '$chat_id', '1' from vicidial_users where user='$chat_creator'";
                $ins_alert_rslt=mysql_to_mysqli($ins_alert_stmt, $link);
            }
        } 
    }
}
if ($action=="update_chat_window" && $chat_id) {
    $status_stmt="SELECT status, chat_creator, transferring_agent from vicidial_live_chats where chat_id='$chat_id'";
    $status_rslt=mysql_to_mysqli($status_stmt, $link);
    if (mysqli_num_rows($status_rslt)==0) {
        echo "Error|";
        $stmt="SELECT * from vicidial_chat_log_archive where chat_id='$chat_id' order by message_time asc";
        $rslt=mysql_to_mysqli($stmt, $link);
        $chat_members=array();
        while ($row=mysqli_fetch_row($rslt)) {
            if (!in_array("$row[4]", $chat_members)) {
                array_push($chat_members, "$row[4]");
            }
        }
        $chat_color_stmt="select menu_background, frame_background, std_row1_background, std_row2_background, std_row3_background, std_row4_background, std_row5_background, web_logo from vicidial_inbound_groups vig, vicidial_screen_colors v where vig.group_id='$group_id' and vig.customer_chat_screen_colors=v.colors_id and length(frame_background)=6 and length(menu_background)=6 limit 1;";
        $color_rslt=mysql_to_mysqli($chat_color_stmt, $link);
        $web_logo=""; $filepath="vicidial/images";
        if(mysqli_num_rows($color_rslt)>0 && $use_agent_colors>0) {
            $color_row=mysqli_fetch_array($color_rslt);
            $color_array=array("#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000");
            $chat_background_array=array("#$color_row[std_row1_background]", "#$color_row[std_row2_background]", "#$color_row[std_row3_background]", "#$color_row[std_row4_background]", "#$color_row[std_row5_background]", "#$color_row[frame_background]", "#$color_row[menu_background]"); 
        } else {
            $color_array=array("#FF0000", "#0000FF", "#009900", "#990099", "#009999", "#666600", "#999999");
            $chat_background_array=array("#FFCCCC", "#CCCCFF", "#CCFFCC", "#FFCCFF", "#CCFFFF", "#CCCC99", "#CCCCCC"); 
        }
        $chat_status="<font color='#900'>INACTIVE</font>";
        echo "$chat_status|";
        if (!$user_level || $user_level==0) {$user_level_clause=" and chat_level='0' ";} else {$user_level_clause="";}
        $stmt="SELECT * from vicidial_chat_log_archive where chat_id='$chat_id' $user_level_clause order by message_time asc";
        $rslt=mysql_to_mysqli($stmt, $link);
        while ($row=mysqli_fetch_row($rslt)) {
            $chat_color_key=array_search("$row[4]", $chat_members);
            $row[2]=preg_replace('/\n/', '<BR/>', $row[2]);    
            echo "<li bgcolor='$chat_background_array[$chat_color_key]'><font color='$color_array[$chat_color_key]' class='chat_message bold'>$row[5]</font> <font class='chat_timestamp bold'>($row[3])</font> - <font class='chat_message ".$style_array[$row[6]]."'>$row[2]</font></li>\n";
        }
    } else {
        $status_row=mysqli_fetch_row($status_rslt);
        if ($user && $keepalive) {
            $upd_stmt="UPDATE vicidial_chat_participants set ping_date=now() where chat_member='$user' and chat_id='$chat_id'";
            $upd_rslt=mysql_to_mysqli($upd_stmt, $link);
        }
        if ($status_row[0]=="LIVE" || ($status_row[0]=="WAITING" && $status_row[2]!="")) {
            $live_stmt="SELECT * from vicidial_live_chats vlc, vicidial_chat_participants vcp where vlc.chat_id='$chat_id' and (status='LIVE' or (status='WAITING' and transferring_agent is not null)) and vlc.chat_id=vcp.chat_id and vcp.chat_member='$user'";
            $live_rslt=mysql_to_mysqli($live_stmt, $link);
            if (mysqli_num_rows($live_rslt)>0) {
                $chat_color_stmt="select menu_background, frame_background, std_row1_background, std_row2_background, std_row3_background, std_row4_background, std_row5_background, web_logo from vicidial_inbound_groups vig, vicidial_screen_colors v where vig.group_id='$group_id' and vig.customer_chat_screen_colors=v.colors_id and length(frame_background)=6 and length(menu_background)=6 limit 1;";
                $color_rslt=mysql_to_mysqli($chat_color_stmt, $link);
                if(mysqli_num_rows($color_rslt)>0 && $use_agent_colors>0) {
                    $color_row=mysqli_fetch_array($color_rslt);
                    $color_array=array("#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000");
                    $chat_background_array=array("#$color_row[std_row1_background]", "#$color_row[std_row2_background]", "#$color_row[std_row3_background]", "#$color_row[std_row4_background]", "#$color_row[std_row5_background]", "#$color_row[frame_background]", "#$color_row[menu_background]"); 
                } else {
                    $color_array=array("#FF0000", "#0000FF", "#009900", "#990099", "#009999", "#666600", "#999999");
                    $chat_background_array=array("#FFCCCC", "#CCCCFF", "#CCFFCC", "#FFCCFF", "#CCFFFF", "#CCCC99", "#CCCCCC"); 
                }
                $chat_status="<font color='#090'>ACTIVE</font>";
                echo "$chat_status|";
                $stmt="SELECT * from vicidial_chat_log where chat_id='$chat_id' order by message_time asc";
                $rslt=mysql_to_mysqli($stmt, $link);
                $chat_members=array();
                while ($row=mysqli_fetch_row($rslt)) {
                    if (!in_array("$row[4]", $chat_members)) {
                        array_push($chat_members, "$row[4]");
                    }
                }
                if (!$user_level || $user_level==0) {$user_level_clause=" and chat_level='0' ";} else {$user_level_clause="";}
                $stmt="SELECT * from vicidial_chat_log where chat_id='$chat_id' $user_level_clause order by message_time asc";
                echo "<table border='0' cellpadding='3' width='100%'>\n";
                $rslt=mysql_to_mysqli($stmt, $link);
                while ($row=mysqli_fetch_row($rslt)) {
                    $chat_color_key=array_search("$row[4]", $chat_members);
                    $row[2]=preg_replace('/\n/', '<BR/>', $row[2]);    
                    echo "<tr><td bgcolor='$chat_background_array[$chat_color_key]'><li><font color='$color_array[$chat_color_key]' class='chat_message bold'>$row[5]</font> <font class='chat_timestamp bold'>($row[3])</font> - <font class='chat_message ".$style_array[$row[6]]."'>$row[2]</font></li></td></tr>\n";
                }
                echo "</table>\n";
                if ($status_row[0]=="WAITING" && $status_row[2]!="") {
                    echo "<BR><font class='chat_message bold'>"._QXZ("Currently being transferred, waiting for agent...")."</font><BR/>\n";
                }
                $current_messages=mysqli_num_rows($rslt);
                echo "<input type='hidden' id='current_message_count' name='current_message_count' value='$current_messages'>\n";
            } else {    
                $chat_status="<font color='#900'>INACTIVE</font>";
                echo "$chat_status|";
                $live_stmt="SELECT * from vicidial_live_chats vlc, vicidial_chat_participants vcp where vlc.chat_id='$chat_id' and (status='LIVE' or (status='WAITING' and transferring_agent is not null)) and vlc.chat_id=vcp.chat_id and vcp.chat_member='$user'";
                $live_rslt=mysql_to_mysqli($live_stmt, $link);
                if (mysqli_num_rows($live_rslt)>0) {
                    $chat_color_stmt="select menu_background, frame_background, std_row1_background, std_row2_background, std_row3_background, std_row4_background, std_row5_background, web_logo from vicidial_inbound_groups vig, vicidial_screen_colors v where vig.group_id='$group_id' and vig.customer_chat_screen_colors=v.colors_id and length(frame_background)=6 and length(menu_background)=6 limit 1;";
                    $color_rslt=mysql_to_mysqli($chat_color_stmt, $link);
                    if(mysqli_num_rows($color_rslt)>0 && $use_agent_colors>0) {
                        $color_row=mysqli_fetch_array($color_rslt);
                        $color_array=array("#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000");
                        $chat_background_array=array("#$color_row[std_row1_background]", "#$color_row[std_row2_background]", "#$color_row[std_row3_background]", "#$color_row[std_row4_background]", "#$color_row[std_row5_background]", "#$color_row[frame_background]", "#$color_row[menu_background]"); 
                    } else {
                        $color_array=array("#FF0000", "#0000FF", "#009900", "#990099", "#009999", "#666600", "#999999");
                        $chat_background_array=array("#FFCCCC", "#CCCCFF", "#CCFFCC", "#FFCCFF", "#CCFFFF", "#CCCC99", "#CCCCCC"); 
                    }
                }
                $stmt="SELECT * from vicidial_chat_log where chat_id='$chat_id' order by message_time asc";
                $rslt=mysql_to_mysqli($stmt, $link);
                $chat_members=array();
                while ($row=mysqli_fetch_row($rslt)) {
                    if (!in_array("$row[4]", $chat_members)) {
                        array_push($chat_members, "$row[4]");
                    }
                }
                if (!$user_level || $user_level==0) {$user_level_clause=" and chat_level='0' ";} else {$user_level_clause="";}
                $stmt="SELECT * from vicidial_chat_log where chat_id='$chat_id' $user_level_clause order by message_time asc";
                echo "<table border='0' cellpadding='3' width='100%'>\n";
                $rslt=mysql_to_mysqli($stmt, $link);
                while ($row=mysqli_fetch_row($rslt)) {
                    $chat_color_key=array_search("$row[4]", $chat_members);
                    $row[2]=preg_replace('/\n/', '<BR/>', $row[2]);    
                    echo "<tr><td bgcolor='$chat_background_array[$chat_color_key]'><li><font color='$color_array[$chat_color_key]' class='chat_message bold'>$row[5]</font> <font class='chat_timestamp bold'>($row[3])</font> - <font class='chat_message ".$style_array[$row[6]]."'>$row[2]</font></li></td></tr>\n";
                }
                echo "</table>\n";
            }
        } else {
            if ($status_row[1]=="NONE") {
                $chat_status="<font color='#990'>"._QXZ("WAITING")."</font>";
                echo "$chat_status|";
                $chat_count_stmt="SELECT chat_id from vicidial_live_chats vlc, vicidial_inbound_groups vig where vlc.status='WAITING' and (vlc.group_id='$group_id' or (vlc.group_id='AGENTDIRECT_CHAT')) and (transferring_agent is null or transferring_agent!='$user') and vlc.group_id=vig.group_id order by queue_priority desc, chat_id asc";
                $chat_count_rslt=mysql_to_mysqli($chat_count_stmt, $link);
                $people_ahead_of_you=0;
                while($chat_count_row=mysqli_fetch_row($chat_count_rslt)) {
                    if ($chat_count_row[0]!=$chat_id) {
                        $people_ahead_of_you++;
                    } else {
                        break;
                    }
                }
                if ($people_ahead_of_you>0) {
                    echo "<font class='chat_title bold'>"._QXZ("There are")." <font color='#FF0000'>$people_ahead_of_you</font> "._QXZ("customer(s) in chat queue ahead of you")."</font>";
                } else {
                    echo "<font class='chat_title bold' color='#FF0000'>"._QXZ("You are the next customer in line")."</font>";
                }        
            } else {
                echo "<font class='chat_title alert'>"._QXZ("SYSTEM ERROR")."</font><BR/>\n";
            }
        }
    }
}
?>
