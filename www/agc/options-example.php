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
$conf_silent_prefix        = '5';    # vicidial_conferences prefix to enter silently and muted for recording
$dtmf_silent_prefix        = '7';    # vicidial_conferences prefix to enter silently
$HKuser_level            = '1';    # minimum vicidial user_level for HotKeys
$campaign_login_list    = '1';    # show drop-down list of campaigns at login    
$manual_dial_preview    = '1';    # allow preview lead option when manual dial
$multi_line_comments    = '1';    # set to 1 to allow multi-line comment box
$user_login_first        = '0';    # set to 1 to have the vicidial_user login before the phone login
$view_scripts            = '1';    # set to 1 to show the SCRIPTS tab
$dispo_check_all_pause    = '0';    # set to 1 to allow for persistent pause after dispo
$callholdstatus            = '1';    # set to 1 to show calls on hold count
$agentcallsstatus        = '0';    # set to 1 to show agent status and call dialed count
   $campagentstatctmax    = '3';    # Number of seconds for campaign call and agent stats
$show_campname_pulldown    = '1';    # set to 1 to show campaign name on login pulldown
$webform_sessionname    = '1';    # set to 1 to include the session_name in webform URL
$local_consult_xfers    = '1';    # set to 1 to send consultative transfers from original server
$clientDST                = '1';    # set to 1 to check for DST on server for agent time
$no_delete_sessions        = '1';    # set to 1 to not delete sessions at logout
$volumecontrol_active    = '1';    # set to 1 to allow agents to alter volume of channels
$ast13_volume_override    = '0';    # set to 1 to allow agent to use volume controls even on Asterisk 13 servers
$PreseT_DiaL_LinKs        = '0';    # set to 1 to show a DIAL link for Dial Presets
$LogiNAJAX                = '1';    # set to 1 to do lookups on campaigns for login
$HidEMonitoRSessionS    = '1';    # set to 1 to hide remote monitoring channels from "session calls"
$hangup_all_non_reserved= '1';    # set to 1 to force hangup all non-reserved channels upon Hangup Customer
$LogouTKicKAlL            = '1';    # set to 1 to hangup all calls in session upon agent logout
$PhonESComPIP            = '1';    # set to 1 to log computer IP to phone if blank, set to 2 to force log each login
$DefaulTAlTDiaL            = '0';    # set to 1 to enable ALT DIAL by default if enabled for the campaign
$AgentAlert_allowed        = '1';    # set to 1 to allow Agent alert option
$disable_blended_checkbox='0';    # set to 1 to disable the BLENDED checkbox from the in-group chooser screen
$hide_timeclock_link    = '0';    # set to 1 to hide the timeclock link on the agent login screen
$conf_check_attempts    = '3';    # number of attempts to try before loosing webserver connection, for bad network setups
$focus_blur_enabled        = '0';    # set to 1 to enable the focus/blur enter key blocking(some IE instances have issues)
$consult_custom_delay    = '2';    # number of seconds to delay consultative transfers when custom fields are active
$mrglock_ig_select_ct    = '4';    # number of seconds to leave in-group select screen open if agent select is disabled
$link_to_grey_version    = '1';    # show link to old grey version of agent screen at login screen, next to timeclock link
$use_agent_colors        = '1';    # agent chat colors
$no_empty_session_warnings=0;    # set to 1 to disable empty session warnings on agent screen
$logged_in_refresh_link = '0';    # set to 1 to allow clickable "Logged in as..." link at top to force Javascript refresh
$webphone_call_seconds    = '0';    # set to 1 or higher to have the agent phone(if set to webphone) called X seconds after login
$user_pass_webform        = '0';    # set to 1 or 2 to return to default of including the 'user'(1) and 'pass'(2) by default in webform URLs
$phone_login_webform    = '0';    # set to 1 or 2 to return to default of including the 'phone_login'(1) and 'phone_pass'(2) by default in webform URLs
$alt_display_enabled    = '0';    # set to 1 to allow the alt_display.php script to be used
$email_attachment_path    = './attachments';    # set to the absolute path from where all of the dispo_send_email.php script attachemnts will be located
$email_header_attach    = '0';    # set to 1 to force blank line after attachments in header. WARNING: Will break on newer versions of PHP
$allow_sendmail_bypass    = '';    # some setups require bypassing PHP's mail() function to send properly, set this to 'sendmail' path: '/usr/sbin/sendmail'
$login_submit_once        = '1';    # set to 0 to remove the "disable the login submit button after submitting" feature
$astguiclient_disabled    = '1';    # set to 0 to allow use of the astguiclient.php script
$dial_override_limit    = '6';    # number of dial-override calls per minute that will lock user account, set to 0 to disable dial_override limit
$dead_logging_version    = '0';    # experimental dead logging enabled, can reverse false DEAD call logging
$TEST_all_statuses        = '0';    # TEST variable allows all statuses in dispo screen
$stretch_dimensions        = '1';    # sets the vicidial screen to the size of the browser window
$BROWSER_HEIGHT            = 500;    # set to the minimum browser height, default=500
$BROWSER_WIDTH            = 770;    # set to the minimum browser width, default=770
$webphone_width            = 460;    # set the webphone frame width
$webphone_height        = 500;    # set the webphone frame height
$webphone_pad            = 0;    # set the table cellpadding for the webphone
$webphone_location        = 'right';    # set the location on the agent screen 'right' or 'bar'
$MAIN_COLOR                = '#CCCCCC';    # old default is E0C2D6
$SCRIPT_COLOR            = '#E6E6E6';    # old default is FFE7D0
$FORM_COLOR                = '#EFEFEF';
$SIDEBAR_COLOR            = '#F6F6F6';
$window_validation        = 0;    # set to 1 to disallow direct logins to vicidial.php
$win_valid_name            = 'subwindow_launch';    # only window name to allow if validation enabled
$INSERT_head_script        = '';    # inserted right above the <script language="Javascript"> line after logging in
$INSERT_head_js            = '';    # inserted after first javascript function
$INSERT_first_onload    = '';    # inserted at the beginning of the first section of the onload function
$INSERT_window_onload    = '';    # inserted at the end of the onload function
$INSERT_agent_events    = '';    # inserted within the agent_events function
$INSERT_before_body_close = '';    # inserted before each BODY close tag
$CORS_allowed_origin        = '';    # if multiple origins allowed, separate them by a pipe (also allows PHP preg syntax)
$CORS_allowed_methods        = '';    # if multiple methods allowed, separate them by a comma 
$CORS_affected_scripts        = '';    # use '--ALL--' for all agc scripts. If multiple(but less than all) scripts affected, separate them by a space 
$CORS_allowed_headers        = '';    # passed in Access-Control-Allow-Headers http response header, 
$CORS_allowed_credentials    = 'N';    # 'Y' or 'N', whether to send credentials to browser or not
$Xframe_options                = 'N';    # Not part of CORS, but can prevent Iframe/embed/etc... use by foreign website, will populate for all affected scripts
$CORS_debug                    = 0;    # 0 = no, 1 = yes (default is no) This will generate a lot of log entries in a CORSdebug_log.txt file
$customer_chat_refresh_seconds    = 1;    # How often (in seconds) to refresh customer ang agent chat window
$manager_chat_refresh_seconds    = 1;    # How often (in seconds) to refresh manager chat window
?>
