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
require("dbconnect_mysqli.php");
require("functions.php");
$PHP_AUTH_USER=$_SERVER['PHP_AUTH_USER'];
$PHP_AUTH_PW=$_SERVER['PHP_AUTH_PW'];
$PHP_SELF=$_SERVER['PHP_SELF'];
$PHP_SELF = preg_replace('/\.php.*/i', '.php', $PHP_SELF);
$US = '_';
$STARTtime = date("U");
$TODAY = date("Y-m-d");
$NOW_TIME = date("Y-m-d H:i:s");
$REC_TIME = date("Ymd-His");
$FILE_datetime = $STARTtime;
$parked_time = $STARTtime;
$stmt = "SELECT enable_vtiger_integration,vtiger_server_ip,vtiger_dbname,vtiger_login,vtiger_pass,vtiger_url FROM system_settings;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($DB) {
    echo "$stmt\n";
}
$ss_conf_ct = mysqli_num_rows($rslt);
if ($ss_conf_ct > 0) {
    $row=mysqli_fetch_row($rslt);
    $enable_vtiger_integration =    $row[0];
    $vtiger_server_ip    =            $row[1];
    $vtiger_dbname =                $row[2];
    $vtiger_login =                    $row[3];
    $vtiger_pass =                    $row[4];
    $vtiger_url =                    $row[5];
}
echo "<html>\n";
echo "<head>\n";
echo "<title>VICIDIAL Vtiger user synchronization utility</title>\n";
echo "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">\n";
if ($enable_vtiger_integration < 1) {
    echo "<B>ERROR! - Vtiger integration is disabled in the VICIDIAL system_settings";
    exit;
}
$stmt="SELECT user_group,group_name FROM vicidial_user_groups;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($DB) {
    echo "$stmt\n";
}
$VD_groups_ct = mysqli_num_rows($rslt);
$i=0;
while ($i < $VD_groups_ct) {
    $row=mysqli_fetch_row($rslt);
    $UGid[$i] =        $row[0];
    $UGname[$i] =    $row[1];
    $i++;
}
$stmt="SELECT user,pass,full_name,user_level,active,user_group FROM vicidial_users;";
$rslt=mysql_to_mysqli($stmt, $link);
if ($DB) {
    echo "$stmt\n";
}
$VD_users_ct = mysqli_num_rows($rslt);
$i=0;
while ($i < $VD_users_ct) {
    $row=mysqli_fetch_row($rslt);
    $user[$i] =            $row[0];
    $pass[$i] =            $row[1];
    $full_name[$i] =    $row[2];
    while (strlen($full_name[$i])>30) {
        $full_name[$i] = preg_replace('/.$/i', '', $full_name[$i]);
    }
    $user_level[$i] =    $row[3];
    $active[$i] =        $row[4];
    $user_group[$i] =    $row[5];
    $i++;
}
$linkV=mysqli_connect("$vtiger_server_ip", "$vtiger_login", "$vtiger_pass", "$vtiger_dbname");
if (!$linkV) {
    die("Could not connect: $vtiger_server_ip|$vtiger_dbname|$vtiger_login|$vtiger_pass" . mysqli_connect_error());
}
echo "Connected successfully\n<BR>\n";
$i=0;
while ($i < $VD_groups_ct) {
    $VTgroup_name =            $UGid[$i];
    $VTgroup_description =    $UGname[$i];
    $stmt="SELECT count(*) from vtiger_groups where groupname='$VTgroup_name';";
    $rslt=mysql_to_mysqli($stmt, $linkV);
    if ($DB) {
        echo "$stmt\n";
    }
    if (!$rslt) {
        die('Could not execute: ' . mysqli_error());
    }
    $row=mysqli_fetch_row($rslt);
    $group_found_count = $row[0];
    if ($group_found_count > 0) {
        $stmt="SELECT groupid from vtiger_groups where groupname='$VTgroup_name';";
        $rslt=mysql_to_mysqli($stmt, $linkV);
        if ($DB) {
            echo "$stmt\n";
        }
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        $row=mysqli_fetch_row($rslt);
        $groupid = $row[0];
        $VTugID[$i] = $groupid;
        $stmtA = "UPDATE vtiger_groups SET description='$VTgroup_description' where groupid='$groupid';";
        if ($DB) {
            echo "|$stmtA|\n";
        }
        $rslt=mysql_to_mysqli($stmtA, $linkV);
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        echo "GROUP- $VTgroup_name: $groupid<BR>\n";
        echo "<BR>\n";
    } else {
        $stmt="SELECT id from vtiger_users_seq;";
        if ($DB) {
            echo "$stmt\n";
        }
        $rslt=mysql_to_mysqli($stmt, $linkV);
        $row=mysqli_fetch_row($rslt);
        $groupid = ($row[0] + 1);
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        $VTugID[$i] = $groupid;
        $stmt="UPDATE vtiger_users_seq SET id = '$groupid';";
        if ($DB) {
            echo "$stmt\n";
        }
        $rslt=mysql_to_mysqli($stmt, $linkV);
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        $stmtA = "INSERT INTO vtiger_groups SET groupid='$groupid',groupname='$VTgroup_name',description='$VTgroup_description';";
        if ($DB) {
            echo "|$stmtA|\n";
        }
        $rslt=mysql_to_mysqli($stmtA, $linkV);
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        echo "GROUP- $VTgroup_name: $groupid<BR>\n";
        echo "<BR>\n";
    }
    $i++;
}
$i=0;
while ($i < $VD_users_ct) {
    $user_name =        $user[$i];
    $VUgroup =            $user_group[$i];
    $user_password =    $pass[$i];
    $last_name =        $full_name[$i];
    $is_admin =            'off';
    $roleid =            'H5';
    $status =            'Active';
    $groupid =            '1';
    if ($user_level[$i] >= 7) {
        $roleid = 'H4';
    }
    if ($user_level[$i] >= 8) {
        $roleid = 'H3';
    }
    if ($user_level[$i] >= 9) {
        $roleid = 'H2';
    }
    if ($user_level[$i] >= 9) {
        $is_admin = 'on';
    }
    if (preg_match('/N/', $active[$i])) {
        $status = 'Inactive';
    }
    $salt = substr($user_name, 0, 2);
    $salt = '$1$' . $salt . '$';
    $encrypted_password = crypt($user_password, $salt);
    $i++;
    $stmt = "SELECT vtiger_role FROM vtiger_vicidial_roles where user_level='$user_level';";
    $rslt=mysql_to_mysqli($stmt, $link);
    if ($DB) {
        echo "$stmt\n";
    }
    $vvr_ct = mysqli_num_rows($rslt);
    if ($vvr_ct > 0) {
        $row=mysqli_fetch_row($rslt);
        $roleid =    $row[0];
    }
    $j=0;
    $all_VICIDIAL_groups_SQL='';
    while ($j < $VD_groups_ct) {
        if ((preg_match("/$UGid[$j]/i", $VUgroup)) and ((strlen($UGid[$j]))==(strlen($VUgroup)))) {
            $groupid =                $VTugID[$j];
            $VTgroup_name =            $UGid[$j];
            $VTgroup_description =    $UGname[$j];
        } else {
            $all_VICIDIAL_groups_SQL .= "'$VTugID[$j]',";
        }
        $j++;
    }
    $all_VICIDIAL_groups_SQL = preg_replace("/.$/", '', $all_VICIDIAL_groups_SQL);
    $stmt="SELECT count(*) from vtiger_users where user_name='$user_name';";
    $rslt=mysql_to_mysqli($stmt, $linkV);
    if ($DB) {
        echo "$stmt\n";
    }
    if (!$rslt) {
        die('Could not execute: ' . mysqli_error());
    }
    $row=mysqli_fetch_row($rslt);
    $found_count = $row[0];
    if ($found_count > 0) {
        $stmt="SELECT id from vtiger_users where user_name='$user_name';";
        $rslt=mysql_to_mysqli($stmt, $linkV);
        if ($DB) {
            echo "$stmt\n";
        }
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        $row=mysqli_fetch_row($rslt);
        $userid = $row[0];
        $stmt="SELECT count(*) from vtiger_users2group WHERE userid='$userid' and groupid='$groupid';";
        $rslt=mysql_to_mysqli($stmt, $linkV);
        if ($DB) {
            echo "$stmt\n";
        }
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        $row=mysqli_fetch_row($rslt);
        $usergroupcount = $row[0];
        $stmtA = "UPDATE vtiger_users SET user_password='$encrypted_password',last_name='$last_name',is_admin='$is_admin',status='$status' where id='$userid';";
        if ($DB) {
            echo "|$stmtA|\n";
        }
        $rslt=mysql_to_mysqli($stmtA, $linkV);
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        $stmtB = "UPDATE vtiger_user2role SET roleid='$roleid' where userid='$userid';";
        if ($DB) {
            echo "|$stmtB|\n";
        }
        $rslt=mysql_to_mysqli($stmtB, $linkV);
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        if ($usergroupcount < 1) {
            $stmtC = "DELETE FROM vtiger_users2group WHERE userid='$userid' and groupid IN($all_VICIDIAL_groups_SQL);";
            if ($DB) {
                echo "|$stmtC|\n";
            }
            $rslt=mysql_to_mysqli($stmtC, $linkV);
            if (!$rslt) {
                die('Could not execute: ' . mysqli_error());
            }
            $stmtD = "INSERT INTO vtiger_users2group SET userid='$userid',groupid='$groupid';";
            if ($DB) {
                echo "|$stmtC|\n";
            }
            $rslt=mysql_to_mysqli($stmtD, $linkV);
            if (!$rslt) {
                die('Could not execute: ' . mysqli_error());
            }
        } else {
            $stmtC='';
        }
        echo "$user_name: $userid<BR>\n";
        echo "$stmtA<BR>\n";
        echo "$stmtB<BR>\n";
        echo "$stmtC<BR>\n";
        echo "$stmtD<BR>\n";
        echo "<BR>\n";
    } else {
        $stmtA = "INSERT INTO vtiger_users SET user_name='$user_name',user_password='$encrypted_password',last_name='$last_name',is_admin='$is_admin',status='$status',date_format='yyyy-mm-dd',first_name='',reports_to_id='',description='',title='',department='',phone_home='',phone_mobile='',phone_work='',phone_other='',phone_fax='',email1='',email2='',yahoo_id='',signature='',address_street='',address_city='',address_state='',address_country='',address_postalcode='',user_preferences='',imagename='';";
        if ($DB) {
            echo "|$stmtA|\n";
        }
        $rslt=mysql_to_mysqli($stmtA, $linkV);
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        $userid = mysqli_insert_id($linkV);
        $stmtB = "INSERT INTO vtiger_user2role SET userid='$userid',roleid='$roleid';";
        if ($DB) {
            echo "|$stmtB|\n";
        }
        $rslt=mysql_to_mysqli($stmtB, $linkV);
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        $stmtC = "INSERT INTO vtiger_users2group SET userid='$userid',groupid='$groupid';";
        if ($DB) {
            echo "|$stmtC|\n";
        }
        $rslt=mysql_to_mysqli($stmtC, $linkV);
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        $stmtD = "UPDATE vtiger_users_seq SET id='$userid';";
        if ($DB) {
            echo "|$stmtD|\n";
        }
        $rslt=mysql_to_mysqli($stmtD, $linkV);
        if (!$rslt) {
            die('Could not execute: ' . mysqli_error());
        }
        echo "$user_name:<BR>\n";
        echo "$stmtA<BR>\n";
        echo "$stmtB<BR>\n";
        echo "$stmtC<BR>\n";
        echo "$stmtD<BR>\n";
        echo "<BR>\n";
    }
}
echo "DONE\n";
exit;
