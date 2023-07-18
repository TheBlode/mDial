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
// Grab API key
if (isset($_REQUEST["openai_api_key"])) {
    $api_key = $_REQUEST["openai_api_key"];
} else {
    echo "Error! No valid API key was passed in.\n";

    // Exit!
    exit;
}

// Grab question
if (isset($_REQUEST["question"])) {
    $question = $_REQUEST["question"];
    $question = preg_replace("/'/", "", $question);
} else {
    echo "Error! No valid question was was passed in.\n";

    // Exit!
    exit;
}

if (strlen($question) > 500) {
    echo "Too many characters!";
    exit;
}
// Construct the API call
$command = <<<EOF
curl https://api.openai.com/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer $api_key" -d '{"model": "gpt-3.5-turbo", "stop": "", "messages": [{"role": "user", "content": "$question"}]}'
EOF;

// Fire off the API call!
exec($command, $output);

// Get reply
preg_match('/content\":\s\"(.+)\"/', $output[10], $matches);

// Save reply
$reply = $matches[1];
$reply = preg_replace('/\\\n/', "", $reply);

// Send reply back to caller
if (!empty($reply)) {
    echo $reply;
} else {
    echo "Error with the OpenAI API. Please contact your administrator.";
}

// Exit!
exit;
?>