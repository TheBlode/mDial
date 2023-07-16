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
$webphone_width =    '460';
$webphone_height =    '500';
$webphone_left =    '600';
$webphone_top =        '27';
$webphone_bufw =    '250';
$webphone_bufh =    '1';
$webphone_pad =        '10';
$webphone_clpos =    "<BR>  &nbsp; <a href=\"#\" onclick=\"hideDiv('webphone_content');\">webphone -</a>";
$RS_DB =                0;        # 1=debug on, 0=debug off
$RS_RR =                40;        # refresh rate
$RS_group =                'ALL-ACTIVE';    # selected campaign(s)
$RS_usergroup =            '';        # user group defined
$RS_UGdisplay =            0;        # 0=no, 1=yes
$RS_UidORname =            1;        # 0=id, 1=name
$RS_orderby =            'timeup';
$RS_SERVdisplay =        0;    # 0=no, 1=yes
$RS_CALLSdisplay =        1;    # 0=no, 1=yes
$RS_PHONEdisplay =        0;    # 0=no, 1=yes
$RS_CUSTPHONEdisplay =    0;    # 0=no, 1=yes
$RS_CUSTINFOdisplay =    0;    # 0=no, 1=yes
$RS_CUSTINFOminUL =        9;    # 7-9 (minimum user level to use CUST INFO option)
$RS_PAUSEcodes =        'N';
$RS_with_inbound =        'Y';
$RS_CARRIERstats =        0;    # 0=no, 1=yes
$RS_PRESETstats =        0;    # 0=no, 1=yes
$RS_AGENTtimeSTATS =    0;    # 0=no, 1=yes
$RS_droppedOFtotal =    0;    # 0=no, 1=yes
$RS_logoutLINK =        0;    # 0=no, 1=yes
$RS_parkSTATS =            0;    # 0=no, 1=yes, 2=limited
$RS_SLAinSTATS =        0;    # 0=no, 1=yes, 2=TMA
$RS_ListenBarge =        'MONITOR|BARGE|WHISPER';    # list of listen-related features separated by pipes: "MONITOR|BARGE|WHISPER"
$RS_BargeSwap =            0;    # 0=no, 1=yes   reverse the order of who is called first on barge calls
$RS_agentWAIT =            3;    # 3 or 4
$RS_INcolumnsHIDE =        0;    # 0=no, 1=yes  # whether to hide the 'HOLD' & 'IN-GROUP' columns in the agent detail section
$RS_DIDdesc =            0;    # 0=no, 1=yes  # whether to show a 'DID DESCRIPTION' column in the agent detail section
$RS_report_default_format = '';    # 'TEXT', 'HTML' or '': If set, this will override the System Setting for this report only
$RS_AGENTlatency =        0;    # 0=no, 1=yes, 2=all, 3=day, 4=now
$RS_UGlatencyRESTRICT =    '';    # this can restrict the "LATENCY" features to only be accessible to users in set User Groups: "ADMIN|ADMIN2"
$RS_AGENTstatusTALLY =    '';    # <any valid status>: If set, will look at the number of calls statused by the agent in this status for today
$user_case =            0;        # 1=upper-case, 2-lower-case, 0-no-case-change
$TIME_agenttimedetail = 'H';    # H=hour, M=minute, S=second, HF=force hour
$inventory_allow_realtime = 0;    # allow real-time report generation for inventory report
$api_url_log = 0;                # log non-agent-api calls to the vicidial_url_log
$extended_vl_fields = 0;
$nonselectable_statuses = 0;
$firstlastname_display_user_stats = 0;
$atdr_login_logout_user_link = 0;
$DROPANSWERpercent_adjustment = 0;
$active_only_default_campaigns = 0;
$htmlconvert=1;
$disable_user_group_bulk_change=0;
$graph_canvas_size=600;
$enable_status_mismatch_leadloader_option=0;
$call_export_report_ALTERNATE_2_header="address3\tfirst_name\tlast_name\tphone_number\tstatus_name\tstatus_date\r\n";
$IR_SLA_all_statuses=0;
$audio_store_GSM_allowed=0;
$include_sales_in_TPD_report=0;
$CORS_allowed_origin        = '';    # if multiple origins allowed, separate them by a pipe (also allows PHP preg syntax)
$CORS_allowed_methods        = '';    # if multiple methods allowed, separate them by a comma 
$CORS_affected_scripts        = '';    # If multiple(but less than all) scripts affected, separate them by a space (see CORS_SUPPORT.txt doc for list of files)
$CORS_allowed_headers        = '';    # passed in Access-Control-Allow-Headers http response header, 
$CORS_allowed_credentials    = 'N';    # 'Y' or 'N', whether to send credentials to browser or not
$Xframe_options                = 'N';    # Not part of CORS, but can prevent Iframe/embed/etc... use by foreign website, will populate for all affected scripts
$CORS_debug                    = 0;    # 0 = no, 1 = yes (default is no) This will generate a lot of log entries in a CORSdebug_log.txt file
?>
