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
if (isset($_GET["lead_id"]))                {$lead_id=$_GET["lead_id"];}
    elseif (isset($_POST["lead_id"]))        {$lead_id=$_POST["lead_id"];}
if (isset($_GET["chat_id"]))                {$chat_id=$_GET["chat_id"];}
    elseif (isset($_POST["chat_id"]))        {$chat_id=$_POST["chat_id"];}
if (isset($_GET["group_id"]))                {$chat_group_id=$_GET["group_id"];}
    elseif (isset($_POST["group_id"]))        {$chat_group_id=$_POST["group_id"];}
if (isset($_GET["chat_group_id"]))            {$chat_group_id=$_GET["chat_group_id"];}
    elseif (isset($_POST["chat_group_id"]))    {$chat_group_id=$_POST["chat_group_id"];}
if (isset($_GET["email"]))                    {$email=$_GET["email"];}
    elseif (isset($_POST["email"]))            {$email=$_POST["email"];}
if (isset($_GET["unique_userID"]))            {$unique_userID=$_GET["unique_userID"];}
    elseif (isset($_POST["unique_userID"]))    {$unique_userID=$_POST["unique_userID"];}
if (isset($_GET["language"]))                {$language=$_GET["language"];}
    elseif (isset($_POST["language"]))        {$language=$_POST["language"];}
if (isset($_GET["available_agents"]))            {$available_agents=$_GET["available_agents"];}
    elseif (isset($_POST["available_agents"]))    {$available_agents=$_POST["available_agents"];}
if (isset($_GET["show_email"]))                {$show_email=$_GET["show_email"];}
    elseif (isset($_POST["show_email"]))    {$show_email=$_POST["show_email"];}
$lead_id = preg_replace("/[^0-9]/","",$lead_id);
$chat_id = preg_replace('/[^-\_\.0-9a-zA-Z]/','',$chat_id);
$group_id = preg_replace('/[^-\_0-9\p{L}]/u','',$group_id);
$chat_group_id = preg_replace('/[^-\_0-9\p{L}]/u','',$chat_group_id);
$email = preg_replace('/[^-\.\:\/\@\_0-9\p{L}]/u','',$email);
$unique_userID = preg_replace('/[^-\.\_0-9a-zA-Z]/','',$unique_userID);
$language = preg_replace('/[^-\_0-9a-zA-Z]/','',$language);
$available_agents = preg_replace('/[^-\_0-9a-zA-Z]/','',$available_agents);
$show_email = preg_replace('/[^-\_0-9a-zA-Z]/','',$show_email);
$URL_vars="?user=".urlencode($unique_userID)."&lead_id=".$lead_id."&group_id=".urlencode($chat_group_id)."&chat_id=".$chat_id."&email=".urlencode($email)."&language=".urlencode($language)."&available_agents=".urlencode($available_agents)."&show_email=".urlencode($show_email);
header ("Content-type: text/html; charset=utf-8");
header ("Cache-Control: no-cache, must-revalidate");  // HTTP/1.1
header ("Pragma: no-cache");                          // HTTP/1.0
echo '<?xml version="1.0" encoding="UTF-8"?><html><head><title>Chat</title></head>';
?>
<iframe src="/chat_customer/vicidial_chat_customer_side.php<?php echo $URL_vars; ?>" style="width:640;height:480;background-color:transparent;" scrolling="auto" frameborder="0" allowtransparency="true" id="ViCiDiAlChAtIfRaMe" name="ViCiDiAlChAtIfRaMe"/>
</html>
