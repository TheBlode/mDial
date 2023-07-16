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
if (isset($_GET["campaign"])) {
    $campaign=$_GET["campaign"];
} elseif (isset($_POST["campaign"])) {
    $campaign=$_POST["campaign"];
}
if (isset($_GET["lead_id"])) {
    $lead_id=$_GET["lead_id"];
} elseif (isset($_POST["lead_id"])) {
    $lead_id=$_POST["lead_id"];
}
if (isset($_GET["phone_number"])) {
    $phone_number=$_GET["phone_number"];
} elseif (isset($_POST["phone_number"])) {
    $phone_number=$_POST["phone_number"];
}
if (isset($_GET["user"])) {
    $user=$_GET["user"];
} elseif (isset($_POST["user"])) {
    $user=$_POST["user"];
}
if (isset($_GET["session_id"])) {
    $session_id=$_GET["session_id"];
} elseif (isset($_POST["session_id"])) {
    $session_id=$_POST["session_id"];
}
if (isset($_GET["server_ip"])) {
    $server_ip=$_GET["server_ip"];
} elseif (isset($_POST["server_ip"])) {
    $server_ip=$_POST["server_ip"];
}
if (isset($_GET["uniqueid"])) {
    $uniqueid=$_GET["uniqueid"];
} elseif (isset($_POST["uniqueid"])) {
    $uniqueid=$_POST["uniqueid"];
}
if (isset($_GET["vendor_lead_code"])) {
    $vendor_lead_code=$_GET["vendor_lead_code"];
} elseif (isset($_POST["vendor_lead_code"])) {
    $vendor_lead_code=$_POST["vendor_lead_code"];
}
$campaign = preg_replace('/[^-_0-9a-zA-Z]/', '', $campaign);
$phone_number = preg_replace('/[^-_0-9a-zA-Z]/', '', $phone_number);
$lead_id = preg_replace('/[^0-9]/', '', $lead_id);
$session_id = preg_replace('/[^0-9]/', '', $session_id);
$vendor_lead_code = preg_replace("/\||`|&|\'|\"|\\\\|;| /", "", $vendor_lead_code);
$user = preg_replace("/\||`|&|\'|\"|\\\\|;| /", "", $user);
$server_ip = preg_replace('/[^\.0-9]/', '', $server_ip);
$uniqueid = preg_replace('/[^-_\.0-9a-zA-Z]/', '', $uniqueid);
$rec_action = preg_replace('/[^0-9a-zA-Z]/', '', $rec_action);
$recording_channel = preg_replace("/\||`|&|\'|\"|\\\\| /", "", $recording_channel);
?>
<html>
<head>
<title>script multirecording button page</title>
<style type="text/css">
input.red_btn{
   color:#FFFFFF;
   font-size:84%;
   font-weight:bold;
   background-color:#990000;
   border:2px solid;
   border-top-color:#FFCCCC;
   border-left-color:#FFCCCC;
   border-right-color:#660000;
   border-bottom-color:#660000;
}
input.green_btn{
   color:#FFFFFF;
   font-size:84%;
   font-weight:bold;
   background-color:#009900;
   border:2px solid;
   border-top-color:#CCFFCC;
   border-left-color:#CCFFCC;
   border-right-color:#006600;
   border-bottom-color:#006600;
}
</style>
<script language="Javascript">
function RecordingAction(campaign, lead_id, phone_number, user, session_id, server_ip, vendor_lead_code, uniqueid, rec_action, recording_channel) {
    document.getElementById("recording_button_span").innerHTML = "<b><font color='red'><blink>Please wait...</blink></font></b>";
    var xmlhttp=false;
    /*@cc_on @*/
    /*@if (@_jscript_version >= 5)
    // JScript gives us Conditional compilation, we can cope with old IE versions.
    // and security blocked creation of the objects.
     try {
      xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
     } catch (e) {
      try {
       xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (E) {
       xmlhttp = false;
      }
     }
    @end @*/
    if (!xmlhttp && typeof XMLHttpRequest!='undefined')
        {
        xmlhttp = new XMLHttpRequest();
        }
    if (xmlhttp) 
        { 
        if (rec_action=="START") 
            {
            recording_query = "&campaign=" + campaign + "&lead_id=" + lead_id + "&phone_number=" + phone_number + "&user=" + user + "&session_id=" + session_id + "&server_ip=" + server_ip + "&vendor_lead_code=" + vendor_lead_code + "&uniqueid=" + uniqueid + "&rec_action=" + rec_action;
            }
        else 
            {
            recording_query = "&campaign=" + campaign + "&lead_id=" + lead_id + "&phone_number=" + phone_number + "&user=" + user + "&session_id=" + session_id + "&server_ip=" + server_ip + "&vendor_lead_code=" + vendor_lead_code + "&uniqueid=" + uniqueid + "&rec_action=" + rec_action + "&recording_channel=" + recording_channel;
            }
        xmlhttp.open('POST', 'SCRIPT_multirecording_AJAX.php'); 
        xmlhttp.setRequestHeader('Content-Type','application/x-www-form-urlencoded; charset=UTF-8');
        xmlhttp.send(recording_query); 
        xmlhttp.onreadystatechange = function() 
            { 
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) 
                {
                recording_response = null;
                recording_response = xmlhttp.responseText;
            //    alert(recording_query);
            //    alert(xmlhttp.responseText);
                if (recording_response.length>0 && rec_action=="START") 
                    {
                    var recording_response_array=recording_response.split("|");
                    var recording_id=recording_response_array[0];
                    var recording_channel=recording_response_array[1];
                    document.getElementById("recording_button_span").innerHTML = "<input type=\"button\" class=\"red_btn\" value=\"STOP RECORDING\" onclick=\"RecordingAction(<?php echo "'$campaign', '$lead_id', '$phone_number', '$user', '$session_id', '$server_ip', '$vendor_lead_code', '$uniqueid'"; ?>, '"+recording_id+"', '"+recording_channel+"')\" />";
                    }
                else if (recording_response=="HANGUP SUCCESSFUL")
                    {
                    document.getElementById("recording_button_span").innerHTML = "<input type=\"button\" class=\"green_btn\" onClick=\"RecordingAction(<?php echo "'$campaign', '$lead_id', '$phone_number', '$user', '$session_id', '$server_ip', '$vendor_lead_code', '$uniqueid'"; ?>, 'START');\" value=\"START RECORDING\">";
                    }
                }
            }
        delete xmlhttp;
        }
}
</script>
</head>
<body>
<form action="<?php echo $PHP_SELF; ?>" method="post" target="_self">
<center>
<!-- You may put script text here //-->
<span id="recording_button_span">
<input type="button" class="green_btn" onClick="RecordingAction(<?php echo "'$campaign', '$lead_id', '$phone_number', '$user', '$session_id', '$server_ip', '$vendor_lead_code', '$uniqueid'"; ?>, 'START')" value="START RECORDING">
</span>
<!-- You may also put script text here //-->
</center>
</form>
</body>
</html>
</iframe>
