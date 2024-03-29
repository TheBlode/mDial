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
require("functions.php");
echo "<title>"._QXZ("ViciDial Welcome")."</title>\n";
echo "</head>\n";
echo "<BODY BGCOLOR=WHITE MARGINHEIGHT=0 MARGINWIDTH=0>\n";
echo "<BR><BR><BR><BR><CENTER><TABLE WIDTH=600 CELLPADDING=0 CELLSPACING=0 BGCOLOR=\"#CCCCCC\"><TR BGCOLOR=WHITE>";
echo "<TD ALIGN=LEFT VALIGN=BOTTOM WIDTH=120><IMG SRC=\"../agc/images/vdc_tab_vicidial.gif\" BORDER=0></TD>";
echo "<TD ALIGN=RIGHT VALIGN=MIDDLE WIDTH=180> Welcome! Bienvenue! &nbsp; </TD>";
echo "<TD ALIGN=LEFT VALIGN=MIDDLE WIDTH=300> Willkommen! Benvenuto! Υποδοχή!</TD>";
echo "</TR>\n";
echo "<TR><TD ALIGN=LEFT COLSPAN=3><font size=1> &nbsp; </TD></TR>\n";
echo "<TR><TD ALIGN=CENTER COLSPAN=2 VALIGN=TOP>\n";
echo "<TABLE WIDTH=300 CELLPADDING=2 CELLSPACING=0 BGCOLOR=\"#CCCCCC\">";
echo "<TR><TD ALIGN=LEFT>";
echo "<font size=3><b> &nbsp; <a href=\"../agc/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/en.gif\" border=0> "._QXZ("English Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_es/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/es.gif\" border=0> "._QXZ("Spanish Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_de/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/de.gif\" border=0> "._QXZ("German Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_it/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/it.gif\" border=0> "._QXZ("Italian Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_el/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/el.gif\" border=0> "._QXZ("Greek Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_fr/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/fr.gif\" border=0> "._QXZ("French Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_br/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/br.gif\" border=0> "._QXZ("Brazillian Portuguese Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_pt/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/pt.gif\" border=0> "._QXZ("Portuguese Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_pl/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/pl.gif\" border=0> "._QXZ("Polish Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_sk/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/sk.gif\" border=0> "._QXZ("Slovak Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_ru/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/ru.gif\" border=0> "._QXZ("Russian Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_nl/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/nl.gif\" border=0> "._QXZ("Dutch Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_tw/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/tw.gif\" border=0> "._QXZ("Chinese(T) Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_se/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/se.gif\" border=0> "._QXZ("Swedish Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_dk/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/dk.gif\" border=0> "._QXZ("Danish Agent Login")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../agc_jp/vicidial.php?relogin=YES&VD_login=6666&VD_campaign=TESTCAMP&phone_login=phone&phone_pass=phone&VD_pass=1234\"><IMG SRC=\"../agc/images/jp.gif\" border=0> "._QXZ("Japanese Agent Login")."</a>";
echo "</TD></TR></TABLE>\n";
echo "</TD><TD VALIGN=TOP>\n";
echo "<TABLE WIDTH=300 CELLPADDING=2 CELLSPACING=0 BGCOLOR=\"#CCCCCC\">";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../vicidial/admin.php\"><IMG SRC=\"../agc/images/en.gif\" border=0> "._QXZ("English Administration")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../vicidial_es/admin.php\"><IMG SRC=\"../agc/images/es.gif\" border=0> "._QXZ("Spanish Administration")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../vicidial_de/admin.php\"><IMG SRC=\"../agc/images/de.gif\" border=0> "._QXZ("German Administration")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../vicidial_it/admin.php\"><IMG SRC=\"../agc/images/it.gif\" border=0> "._QXZ("Italian Administration")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../vicidial_el/admin.php\"><IMG SRC=\"../agc/images/el.gif\" border=0> "._QXZ("Greek Administration")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../vicidial_fr/admin.php\"><IMG SRC=\"../agc/images/fr.gif\" border=0> "._QXZ("French Administration")."</a>";
echo "</TD></TR>\n";
echo "<TR><TD ALIGN=LEFT >";
echo "<font size=3><b> &nbsp; <a href=\"../vicidial_br/admin.php\"><IMG SRC=\"../agc/images/br.gif\" border=0> "._QXZ("Brazilian Portuguese Administration")."</a>";
echo "</TD></TR></TABLE>\n";
echo "<TR><TD ALIGN=LEFT ><font size=1> &nbsp; </TD></TR>\n";
echo "</TABLE>\n";
echo "</FORM>\n\n";
echo "</body>\n\n";
echo "</html>\n\n";
?>
