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
require("dbconnect_mysqli.php");
require("functions.php");
header("Content-type: text/css");
require("screen_colors.php");
?>
div.help_info {position:absolute; top:0; left:0; display:none;}
TABLE.help_td {
        -moz-border-radius: 5px 5px 5px 5px;
        -webkit-border-radius: 5px 5px 5px 5px;
        border-radius: 5px 5px 5px 5px;
        box-shadow: 5px 5px 12px #000000;
        padding: 5px;
        font-family: Arial, Helvetica, sans-serif;
        color: black;
        font-size: 10pt;
        background: #<?php echo $SSframe_background; ?>;
        color: #000000;
        vertical-align: top;
        border:solid 4px #<?php echo $SSmenu_background; ?>
}
.help_bold {
        font-weight:bold;
        font-size: 12pt;
        opacity: 1.0;
}
.panel_td {
    padding: 5px;
    font-family: Arial, Helvetica, sans-serif; 
    color: black; 
    font-size: 12pt; 
    font-weight: bold;
    background: #<?php echo $SSframe_background; ?>;
    color: #000000;
    vertical-align: top;
}
.standard_font_small {
    font-family: "Segoe UI";
    font-size: 9pt; 
}
.standard_font {
    font-family: "Segoe UI";
    font-size: 12pt; 
}
.standard_font_lg {
    font-family: "Segoe UI"; 
    font-size: 14pt; 
    font-weight: bold;
}
h2.rpt_header {
    font-family: "Segoe UI"; 
    font-size: 18pt; 
}
h2.admin_sub_header {
    font-family: "Arial"; 
    font-size: 12pt; 
    color: #<?php echo $SSmenu_background; ?>;
}
h2.admin_header {
    font-family: "Arial"; 
    font-size: 18pt; 
}
    font-family: "Segoe UI";
    font-size: 12pt; 
    border-collapse: collapse;
    width: 100%;
}
    border: 1px solid #ddd;
    padding: 8px;
}
    {
    background-color: #fff;
    padding-top: 12px;
    padding-bottom: 12px;
    background-color: #FFF;
    color: black;
    text-align: right;
    }
  padding-top: 12px;
  padding-bottom: 12px;
  background-color: #FFF;
  color: black;
}
    font-family: "Segoe UI";
    font-size: 12pt; 
    border-collapse: collapse;
    width: 100%;
}
    border: 1px solid #ddd;
    padding: 8px;
}
    {
    border: 0px;
    background-color: #FFF;
    }
    {
    font-weight: bold;
    }
    {
    font-family: "Segoe UI";
    font-size: 8pt; 
    }
    {
    font-family: "Segoe UI";
    font-size: 10pt; 
    }
    font-family: "Segoe UI";
    font-size: 12pt; 
    border-collapse: collapse;
    width: 100%;
}
    border: 1px solid #ddd;
    padding: 4px;
}
    {
    background-color: #fff;
    padding-top: 6px;
    padding-bottom: 6px;
    background-color: #FFF;
    color: black;
    text-align: right;
    }
    {
    border: 0px;
    }
  padding-top: 12px;
  padding-bottom: 12px;
  background-color: #FFF;
  color: black;
}
    {
    font-weight: bold;
    }
    {
    font-family: "Segoe UI";
    font-size: 8pt; 
    }
    {
    font-family: "Segoe UI";
    font-size: 10pt; 
    }
    font-family: "Arial";
    font-size: 12pt; 
    border-collapse: collapse;
    width: 100%;
}
    border: 0px;
    padding: 4px;
}
    {
    background-color: #fff;
    padding-top: 6px;
    padding-bottom: 6px;
    background-color: #FFF;
    color: black;
    text-align: right;
    }
  padding-top: 12px;
  padding-bottom: 12px;
  background-color: #FFF;
  color: black;
}
  font-weight: bold;
  color: red;
}
    {
    width:100%;
    padding:0px;
    margin:0px;
    }
    {
    border-bottom: 2px solid black;
    border-top: 2px solid black;
    background-color: #CCC;
    }
    {
    font-family: "Segoe UI";
    font-size: 12px;
    }
input.actButton{
    font-family: "Segoe UI";
    font-size: 12px;
    color:#FFFFFF;
    border: none;
    padding: 0px 0px;
    width: 150px;
    height: 36px;
    text-align: center;
    text-decoration: none;
    display: inline-block;    
    background-color:#<?php echo $SSmenu_background; ?>;
}
input.refreshButton{
    font-family: "Segoe UI";
    font-size: 24px;
    color:#FFFFFF;
    border: none;
    padding: 0px 0px;
    width: 50px;
    height: 36px;
    text-align: center;
    text-decoration: none;
    display: inline-block;    
    background-color:#<?php echo $SSmenu_background; ?>;
}
a.header_link:link {
    color: #900;
    text-decoration: none;
}
a.header_link:visited {
    color: #900;
    text-decoration: none;
}
a.header_link:hover {
    color: #66F;
    text-decoration: underline;
    cursor: pointer;
}
a.header_link:active {
    color: #66F;
    text-decoration: underline;
}
a.report_link:link {
    color: #009;
    text-decoration: none;
}
a.report_link {
    color: #009;
    text-decoration: none;
}
a.report_link:visited {
    color: #909;
    text-decoration: none;
}
a.report_link:hover {
    color: #66F;
    text-decoration: underline;
    cursor: pointer;
}
a.report_link:active {
    color: #66F;
    text-decoration: underline;
}
a.popup_link:link {
    color: #900;
    text-decoration: none;
}
a.popup_link {
    color: #900;
    text-decoration: none;
}
a.popup_link:visited {
    color: #900;
    text-decoration: none;
}
a.popup_link:hover {
    color: #F66;
    text-decoration: underline;
    cursor: pointer;
}
a.popup_link:active {
    color: #F66;
    text-decoration: underline;
}
div.details_info {
    position:fixed; 
    background-color: white;
    top: 5vh, 
    left:5vw; 
    display:none; 
    overflow-x: hidden; 
    overflow-y: auto;
    box-shadow: 10px 10px 10px 10px #666;
    border:3px solid;
}
.VERM_form_field {
    font-family: "Segoe UI";
    font-size: 12px;
    margin-bottom: 2px;
    margin-bottom: 2px;
    background-color: #<?php echo $SSalt_row1_background; ?>;
    padding: 5px;
    border: solid 3px #<?php echo $SSmenu_background; ?>;
}
input.VERM_numeric_field
    {
    width:80px
    }
input.transparent_button
    {
    background: none;
    border: 0px;
    padding: 10px 5px;
    display: inline-block;
    }
input.download_button
    {
    background: none;
    border: 0px;
    font-family: "Segoe UI";
    font-size: 12pt; 
    }
input.sort_button
    {
    background: none;
    border: 0px;
    font-family: "Segoe UI";
    font-size: 12pt; 
    font-weight: bold;
    color: #900;
    }
input.download_button:hover 
    {
    background: #F99;
    }
input.sort_button:hover 
    {
    background: #99F;
    }
input.current_report
    {
    font-family: "Arial black";
    font-weight: bold;
    color: #F00;
    }
ul.navigation_list 
    {
    font-family: "Arial";
    font-size: 10pt; 
    float: left; /* float all of this to the right */
    padding-inline: 10px 20px;  /* An absolute length */
    }
ul.navigation_list li
    {
      display: inline-block;
      padding: 15px;
    }
ul.navigation_list li.current_report
    {
    font-family: "Arial black";
    font-weight: bold;
    color: #F00;
    }
button {
  width: 30px;
  height: 38px;
  position: relative;
  left: -5px;
  border: 1px solid #DDE1E4;
  border-left: none;
  background-color: #11E8EA;
  cursor: pointer;
}
datalist {
  display: none;
}
