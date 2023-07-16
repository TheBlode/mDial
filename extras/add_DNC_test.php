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
$DB=1; 
$phone_numbers = "9998885555\n9998885556\n9998885557";
$HTTPuser = '6666';
$HTTPpass = '1234';
$url = "https://cpdtest.vicihost.com/vicidial/admin.php";
$fields = "ADD=121&campaign_id=SYSTEM_INTERNAL&stage=add&phone_numbers=$phone_numbers";
$curl = curl_init();
curl_setopt_array($curl, array(
    CURLOPT_RETURNTRANSFER => 1,
    CURLOPT_URL => $url,
    CURLOPT_POST => 4,
    CURLOPT_POSTFIELDS => $fields,
    CURLOPT_USERPWD => "$HTTPuser:$HTTPpass",
    CURLOPT_USERAGENT => 'Test-DNC-adder'
));
$resp = curl_exec($curl);
curl_close($curl);
if ($DB > 0)
    {
    echo "URL: $url\n";
    }
echo "$resp\n";
?>
