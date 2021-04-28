#!/system/bin/sh

appPath='/sdcard/Download/ipt-backup'
logMsg='/proc/kmsg'
cd "$appPath"

appSys='com.android.development'
appGtrs='com.google.android.backuptransport'
appDl='com.android.providers.downloads'
appPs='com.android.vending'
appGass='com.google.android.googlequicksearchbox'
appYt='com.google.android.youtube'
appGch='com.android.chrome'
appGm='com.google.android.gm'
appGmap='com.google.android.apps.maps'
appGd='com.google.android.apps.docs'
appGtl='com.google.android.apps.translate'
appMsg='com.facebook.orca'
appFb='com.facebook.katana'
appVb='com.viber.voip'
appEnote='com.evernote'
appFf='org.mozilla.firefox'
appZl='com.zing.zalo'
appOvpn='net.openvpn.openvpn'
appVpn='user-vpn'
appTm='com.termux'
appGpa='com.grabtaxi.passenger'
appGdr='com.grabtaxi.driver2'
appFgps='com.incorporateapps.fakegps.fre'

fnAddApp () {
#args "name" "uid" "protocol" "ports" "d-ip"
#args "uid" can be package name or user-username
local apro=""
local aport=""
local adip=""
local auid=""
if [[ "$2" == "user-"* ]]
then
auid="$(sed -E s/^user-// <<< $2)"
id "$auid" &> /dev/null
if [[ $? == "1" ]]
then
auid=""
else
auid=$(id $auid | egrep -o "uid=[0-9]+" | egrep -o "[0-9]+")
fi
elif [[ "$2" != '' ]]
then
auid="$(su -c cmd package list packages -U $2 | egrep -om1 [0-9]+$)"
else
auid="WARNING"
fi
if [[ $3 != '' ]]
then
apro=" -p $3"
fi
if [[ $4 != '' ]]
then
aport=" -m multiport --dports $4"
fi
if [[ $5 != '' ]]
then
adip=" -d $5"
fi
if [[ $auid == '' ]]
then
echo "NOT FOUND \"$1\"."
elif [[ $auid == "WARNING" ]]
then
echo "WARNING!!! NOT ALLOW EMPTY UID."
else
su -c "iptables -S cfw_OUTPUT_ACCEPT" | egrep -o "uid-owner $auid" 1> /dev/null
if [[ $? == "0" ]]
then
echo "$1 ALREADY ADDED. DO NOTHING!!!"
else
su -c "iptables -A cfw_OUTPUT_ACCEPT$apro$aport$adip -m owner --uid-owner $auid -j ACCEPT"
echo "$1 ADDED."
fi
fi
}

mmenu='FIREWALL - IPTABLES CONTROL.
\nEnable / Disable / Block / Reset. (e/di/bl/rs)\n

\nYoutube, OpenVPN, Messenger, VPN. (y/o/m/v)
\nPlay Store, Assistant, Google Services. (s/as/g)\nTermux, Viber, Facebook, Evernote. (tm/vb/fb/en)\nChrome, Firefox, Zalo. (ch/f/zl)
\nGrab, Grab Driver, FakeGPS. (gp/gd/fg)
\n
\n\tAdd new / blacklist rule. (a)
\n\tDelete rule. (d)
\n\tZero counter. (z)
\n\tChange DNS Server. (c)
\n\tBackup / Restore / Remove. (b/r/rm)
\n\tSave to default. (df)
\n\tLogging. (l)
\n\tExit / View table. (blank/t)'
echo $mmenu
while :
do
read mme
case $mme in
"") break ;;

e)
cd "$appPath"
su -c "iptables-restore < ipt-fwe.bak"
su -c "ip6tables-restore < ipt6-fwe.bak"
echo
echo 'FIREWALL ENABLE. What next?'
;;

di)
cd "$appPath"
su -c "iptables-restore < ipt-fwd.bak"
su -c "ip6tables-restore < ipt6-fwd.bak"
echo
echo 'FIREWALL DISABLE. What next?'
;;

bl)
su -c "iptables -F cfw_INPUT_ACCEPT"
su -c "iptables -F cfw_FORWARD_ACCEPT"
su -c "iptables -F cfw_OUTPUT_ACCEPT"
echo
echo 'FIREWALL BLOCKED. What next?'
;;

rs)
#IPv4
su -c "iptables -t filter -F"
su -c "iptables -t filter -X"
su -c "iptables -P INPUT DROP"
su -c "iptables -P FORWARD DROP"
su -c "iptables -P OUTPUT DROP"
su -c "iptables -N cfw_FORWARD_ACCEPT"
su -c "iptables -N cfw_FORWARD_BLACKLIST"
su -c "iptables -N cfw_INPUT_ACCEPT"
su -c "iptables -N cfw_INPUT_BLACKLIST"
su -c "iptables -N cfw_OUTPUT_ACCEPT"
su -c "iptables -N cfw_OUTPUT_BLACKLIST"
su -c "iptables -A INPUT -i lo -j ACCEPT"
su -c "iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT"
su -c "iptables -A INPUT -j cfw_INPUT_BLACKLIST"
su -c "iptables -A INPUT -j cfw_INPUT_ACCEPT"
su -c "iptables -A INPUT -j REJECT --reject-with icmp-port-unreachable"
su -c "iptables -A FORWARD -j cfw_FORWARD_BLACKLIST"
su -c "iptables -A FORWARD -j cfw_FORWARD_ACCEPT"
su -c "iptables -A FORWARD -j REJECT --reject-with icmp-port-unreachable"
su -c "iptables -A OUTPUT -o lo -j ACCEPT"
su -c "iptables -A OUTPUT -j cfw_OUTPUT_BLACKLIST"
su -c "iptables -A OUTPUT -j cfw_OUTPUT_ACCEPT"
su -c "iptables -A OUTPUT -j REJECT --reject-with icmp-port-unreachable"
su -c "iptables -A cfw_OUTPUT_ACCEPT -d 9.9.9.9/32 -p udp -m udp --dport 53 -m owner --uid-owner 0 -j ACCEPT"
su -c "iptables -t security -F"
su -c "iptables -t security -X"
su -c "iptables -t security -P INPUT ACCEPT"
su -c "iptables -t security -P FORWARD ACCEPT"
su -c "iptables -t security -P OUTPUT ACCEPT"
su -c "iptables -t raw -F"
su -c "iptables -t raw -X"
su -c "iptables -t raw -P PREROUTING ACCEPT"
su -c "iptables -t raw -P OUTPUT ACCEPT"
su -c "iptables -t raw -N bw_raw_PREROUTING"
su -c "iptables -t raw -A PREROUTING -j bw_raw_PREROUTING"
su -c "iptables -t raw -A bw_raw_PREROUTING -m owner --socket-exists"
su -c "iptables -t nat -F"
su -c "iptables -t nat -X"
su -c "iptables -t nat -P PREROUTING ACCEPT"
su -c "iptables -t nat -P INPUT ACCEPT"
su -c "iptables -t nat -P OUTPUT ACCEPT"
su -c "iptables -t nat -P POSTROUTING ACCEPT"
su -c "iptables -t nat -A OUTPUT -p udp -m udp --dport 53 -m owner --uid-owner 0 -j DNAT --to-destination 9.9.9.9:53"
su -c "iptables -t mangle -F"
su -c "iptables -t mangle -X"
su -c "iptables -t mangle -P PREROUTING ACCEPT"
su -c "iptables -t mangle -P INPUT ACCEPT"
su -c "iptables -t mangle -P FORWARD ACCEPT"
su -c "iptables -t mangle -P OUTPUT ACCEPT"
su -c "iptables -t mangle -P POSTROUTING ACCEPT"
su -c "iptables -t mangle -N routectrl_mangle_INPUT"
su -c "iptables -t mangle -A INPUT -j routectrl_mangle_INPUT"

#IPv6
su -c "ip6tables -t filter -F"
su -c "ip6tables -t filter -X"
su -c "ip6tables -P INPUT DROP"
su -c "ip6tables -P FORWARD DROP"
su -c "ip6tables -P OUTPUT DROP"
su -c "ip6tables -A INPUT -i lo -j ACCEPT"
su -c "ip6tables -A INPUT -j REJECT --reject-with icmp6-port-unreachable"
su -c "ip6tables -A FORWARD -j REJECT --reject-with icmp6-port-unreachable"
su -c "ip6tables -A OUTPUT -o lo -j ACCEPT"
su -c "ip6tables -A OUTPUT -j REJECT --reject-with icmp6-port-unreachable"
su -c "ip6tables -t raw -F"
su -c "ip6tables -t raw -X"
su -c "ip6tables -t raw -P PREROUTING DROP"
su -c "ip6tables -t raw -P OUTPUT DROP"
su -c "ip6tables -t mangle -F"
su -c "ip6tables -t mangle -X"
su -c "ip6tables -t mangle -P PREROUTING DROP"
su -c "ip6tables -t mangle -P INPUT DROP"
su -c "ip6tables -t mangle -P FORWARD DROP"
su -c "ip6tables -t mangle -P OUTPUT DROP"
su -c "ip6tables -t mangle -P POSTROUTING DROP"
su -c "ip6tables -t mangle -N routectrl_mangle_INPUT"
su -c "ip6tables -t mangle -A INPUT -j routectrl_mangle_INPUT"
echo
echo 'FIREWALL RESET. What next?'
;;

v) echo
fnAddApp "VPN" "$appVpn"
echo
echo 'Add more rule?'
;;

y) echo
fnAddApp "YOUTUBE" "$appYt" "tcp" "443"
echo
echo 'Add more rule?'
;;

s) echo
fnAddApp "SYSTEM APPS" "$appSys" "tcp"
fnAddApp "DOWNLOADER" "$appDl" "tcp" "443"
fnAddApp "GOOGLE TRANSPORT" "$appGtrs" "tcp" "443"
fnAddApp "PLAY STORE" "$appPs" "tcp" "443"
echo
echo 'Add more rule?'
;;

as) echo
fnAddApp "GOOGLE TRANSPORT" "$appGtrs" "tcp" "443"
fnAddApp "GOOGLE ASSISTANT" "$appGass" "tcp" "443"
fnAddApp "YOUTUBE" "$appYt" "tcp" "443"
fnAddApp "GOOGLE CHROME" "$appGch" "tcp" "443,80"
echo
echo 'Add more rule?'
;;

g) echo
fnAddApp "GOOGLE TRANSPORT" "$appGtrs" "tcp" "443"
fnAddApp "GOOGLE MAIL" "$appGm" "tcp" "443"
fnAddApp "GOOGLE MAP" "$appGmap" "tcp" "443"
fnAddApp "GOOGLE DRIVE" "$appGd" "tcp" "443"
fnAddApp "GOOGLE TRANSLATE" "$appGtl" "tcp" "443"
echo
echo 'Add more rule?'
;;

tm) echo
fnAddApp "TERMUX" "$appTm"
echo
echo 'Add more rule?'
;;

o) echo
fnAddApp "OPENVPN" "$appOvpn"
echo
echo 'Add more rule?'
;;

m) echo
fnAddApp "FACEBOOK MESSENGER" "$appMsg" "tcp" "443"
echo
echo 'Add more rule?'
;;

vb) echo
fnAddApp "VIBER" "$appVb" "tcp" "443"
echo
echo 'Add more rule?'
;;

fb) echo
fnAddApp "FACEBOOK" "$appFb" "tcp" "443"
echo
echo 'Add more rule?'
;;

en) echo
fnAddApp "EVERNOTE" "$appEnote" "tcp" "443"
echo
echo 'Add more rule?'
;;

f) echo
fnAddApp "FIREFOX BROWSER" "$appFf" "tcp" "443,80"
echo
echo 'Add more rule?'
;;

ch) echo
fnAddApp "GOOGLE CHROME" "$appGch" "tcp" "443,80"
echo
echo 'Add more rule?'
;;

zl) echo
fnAddApp "ZALO" "$appZl" "tcp" "443,80"
echo
echo 'Add more rule?'
;;

gp) echo
fnAddApp "GRAB" "$appGpa" "tcp" "443"
echo
echo 'Add more rule?'
;;

gd) echo
fnAddApp "GRAB DRIVER" "$appGdr" "tcp" "443"
echo
echo 'Add more rule?'
;;

fg) echo
fnAddApp "FAKEGPS" "$appFgps" "tcp" "443"
echo
echo 'Add more rule?'
;;


a)
echo
echo 'Add to Accept or Blacklist? (A/b)'
read -r ablistv
if [[ "$ablistv" == 'b' ]]
then
echo 'Adding Blacklist...'
else
echo 'Adding Accept list...'
fi
echo
echo 'Option can be blank to ignore.'
echo 'Enter Protocol:'
read -r prov
echo
echo 'Enter Source / Destination IP:'
read -r dipv
echo
echo 'Enter Port number or Multi Ports with comma:'
read -r portv
echo
echo 'Enter App UID or App name to search UID:'
while :
do
read -r uidv
case $uidv in
*[!0-9]*)
su -c cmd package list packages -U $uidv
;;
*) break ;;
esac
done
echo
echo 'Add conntrack? ESTABLISHED. (e)'
read -r cntv

if [[ "$ablistv" == 'b' ]]; then
ablist="BLACKLIST"
ablistJ="REJECT"
else
ablist="ACCEPT"
ablistJ="ACCEPT"
fi
if [ -z "$prov" ]; then
pro=""
else
pro="-p $prov"
fi
if [ -z "$dipv" ]; then
dip=""
sip=""
else
dip="-d $dipv"
sip="-s $dipv"
fi
if [ -z "$portv" ]; then
dport=""
sport=""
else
dport="-m multiport --dports $portv"
sport="-m multiport --sports $portv"
fi
if [ -z "$uidv" ]; then
uid=""
else
uid="-m owner --uid-owner $uidv"
fi
if [ -z "$cntv" ]; then
cnt=""
elif [ "$cntv" = "e" ]; then
cnt="-m conntrack --ctstate RELATED,ESTABLISHED"
else
cnt="-m conntrack --ctstate $cntv"
fi
echo
echo 'Default Append. Insert or Replace? (A/i/r)'
read -r inrl
case $inrl in
i)
echo
su -c iptables -L -v -n --line-numbers
echo
echo 'Order number? Default 1.'
read -r ordn
if [[ $ordn == '' ]]
then
echo '1'
fi
irule="su -c iptables -I cfw_INPUT_$ablist $ordn $pro $sip $sport $cnt -j $ablistJ"
orule="su -c iptables -I cfw_OUTPUT_$ablist $ordn $pro $dip $dport $uid -j $ablistJ"
;;
r)
echo
su -c iptables -L -v -n --line-numbers
echo
echo 'Order number?'
read -r ordn
irule="su -c iptables -R cfw_INPUT_$ablist $ordn $pro $sip $sport $cnt -j $ablistJ"
orule="su -c iptables -R cfw_OUTPUT_$ablist $ordn $pro $dip $dport $uid -j $ablistJ"
;;
*)
if [[ $inrl == '' ]]; then
echo 'Append'
fi
irule="su -c iptables -A cfw_INPUT_$ablist $pro $sip $sport $cnt -j $ablistJ"
orule="su -c iptables -A cfw_OUTPUT_$ablist $pro $dip $dport $uid -j $ablistJ"
;;
esac
echo
echo 'Add to OUT, IN or both? Back? (O/i/bo/b)'
read -r inout
case $inout in
""|o|O)
$orule
echo
if [ "$inrl" = "i" ]; then
echo "OUTPUT $ablist RULE INSERTED."
elif [ "$inrl" = "r" ]; then
echo "OUTPUT $ablist RULE REPLACE SUCCESSFUL."
else
echo "OUTPUT $ablist RULE ADDED."
fi
;;
i)
$irule
echo
if [ "$inrl" = "i" ]; then
echo "INPUT $ablist RULE INSERTED."
elif [ "$inrl" = "r" ]; then
echo "INPUT $ablist RULE REPLACE SUCCESSFUL."
else
echo "INPUT $ablist RULE ADDED."
fi
;;
bo)
echo
if [ "$inrl" = "i" ]; then
if [[ $ordn == '' || $ordn == 1 ]]
then
$irule
$orule
echo "BOTH $ablist RULE INSERTED."
else
echo "CAN'T INSERT BOTH $ablist RULE. CANCEL!!!"
fi
elif [ "$inrl" = "r" ]; then
echo "CAN'T REPLACE BOTH $ablist RULE. CANCEL!!!"
elif [[ $inrl == 'a' || $inrl == '' ]]; then
$irule
$orule
echo "BOTH $ablist RULE ADDED."
else
echo 'WRONG OPTION!!! (a/i/r)'
fi
;;
*)
echo
echo Nothing added.
;;
esac
echo
echo
echo $mmenu
;;


d)
demenu='Enter option number:
\n
\n\t1. Delete cfw rule.
\n\t2. Delete blacklist rule.
\n\t3. Delete rule.
\n\t4. Flush chains.
\n\t5. Delete chains.
\n\t6. Delete chain fw_dozable.
\n\t7. Go back. (blank)'
echo
echo $demenu
while :
do
read dopt
case $dopt in
1)
echo
su -c "iptables -L -v -n --line-numbers"
echo
echo 'Enter rule number: (Back)'
read -r rulenum
case $rulenum in
"")
echo 'Back to delete menu.'
;;
*[!0-9]*)
echo
echo Accept number only.
;;
*)
echo
echo 'Delete OUT or IN? Back? (O/i/b)'
read -r inout
case $inout in
""|o|O)
su -c "iptables -D cfw_OUTPUT_ACCEPT $rulenum"
if [[ $? == '0' ]]
then
echo
echo 'CFW OUTPUT RULE DELETED.'
fi
;;
i)
su -c "iptables -D cfw_INPUT_ACCEPT $rulenum"
if [[ $? == '0' ]]
then
echo
echo 'CFW INPUT RULE DELETED.'
fi
;;
*)
echo
echo Nothing deleted.
;;
esac
;;
esac
echo
echo $demenu
;;

2)
echo
su -c "iptables -L -v -n --line-numbers"
echo
echo 'Enter rule number: (Back)'
read -r rulenum
case $rulenum in
"")
echo 'Back to delete menu.'
;;
*[!0-9]*)
echo
echo Accept number only.
;;
*)
echo
echo 'Delete OUT or IN? Back? (O/i/b)'
read -r inout
case $inout in
""|o|O)
su -c "iptables -D cfw_OUTPUT_BLACKLIST $rulenum"
if [[ $? == '0' ]]
then
echo
echo 'CFW OUTPUT BLACKLIST RULE DELETED.'
fi
;;
i)
su -c "iptables -D cfw_INPUT_BLACKLIST $rulenum"
if [[ $? == '0' ]]
then
echo
echo 'CFW INPUT BLACKLIST RULE DELETED.'
fi
;;
*)
echo
echo Nothing deleted.
;;
esac
;;
esac
echo
echo $demenu
;;

3)
echo
su -c "iptables -L -v -n --line-numbers"
echo
echo 'Enter chain name: (Back)'
read -r chna
case "$chna" in
"")
echo 'Back to delete menu.'
;;
*)
echo
echo 'Enter rule number: (Back)'
read -r rulenum
case $rulenum in
"")
echo 'Back to delete menu.'
;;
*[!0-9]*)
echo
echo Accept number only.
;;
*)
su -c "iptables -D $chna $rulenum"
if [[ $? == '0' ]]
then
echo
echo "$chna $rulenum DELETED."
fi
;;
esac
;;
esac
echo
echo $demenu
;;

4)
echo
su -c "iptables -L -v -n --line-numbers"
echo
echo 'Flush all chains or enter chain name? (a)'
read -r chna
if [[ "$chna" != '' ]]
then
if [[ "$chna" == 'a' ]]
then
chna=""
fi
msg="FLUSH $chna SUCCESSFUL."
su -c "iptables -F $chna"
if [[ "$?" == '0' ]]
then
echo
echo $msg
else
echo
echo 'Select option again.'
fi
else
echo 'Cancel. Please select delete option.'
fi
echo
echo $demenu
;;

5)
echo
su -c "iptables -L -v -n --line-numbers"
echo
echo 'Delete all chains or enter chain name? (a)'
read -r chna
if [[ "$chna" != '' ]]
then
if [[ "$chna" == 'a' ]]
then
su -c "iptables -F"
su -c "iptables -X"
echo
echo "DELETE ALL CHAINS SUCCESSFUL."
else
echo
rulnum=""
mChain=("INPUT" "FORWARD" "OUTPUT")
for i in ${mChain[@]}
do
su -c "iptables -L $i -vn --line-number" | egrep -om1 "^[0-9]+.*$chna" 1> /dev/null
if [[ "$?" == '0' ]]
then
resNum=$(su -c "iptables -L $i -vn --line-number" | egrep -c "^[0-9]+.*$chna")
resLoop=0
while (( $resLoop < $resNum ))
do
rulnum=$(su -c "iptables -L $i -vn --line-number" | egrep -om1 "^[0-9]+.*$chna" | egrep -om1 "^[0-9]+")
mcName="$i"
su -c "iptables -F $chna"
if [[ "$?" == '0' ]]
then
su -c "iptables -D $mcName $rulnum"
echo "$mcName $rulnum: $chna DELETED."
fi
(( ++resLoop ))
done
su -c "iptables -X $chna 2> /dev/null"
fi
done
if [[ "$rulnum"  == '' ]]
then
echo "Not found \"$chna\" chain."
echo 'Select option again.'
fi
fi
else
echo 'Cancel. Please select delete option.'
fi
echo
echo $demenu
;;

6)
echo
chna='fw_dozable'
su -c "iptables -F $chna"
if [[ $? == '0' ]]
then
su -c "iptables -X $chna"
msg="DELETE $chna SUCCESSFUL. What next?"
echo $msg
else
echo
echo 'Select option again.'
fi
;;

7|"")
echo
echo
echo $mmenu
break
;;
*)
echo 'Please select an delete option again.'
;;
esac
done
;;


z)
echo
su -c "iptables -L -v -n --line-numbers"
echo
echo 'Zero all chains or enter chain name? (a)'
read -r chna
if [[ "$chna" != '' ]]
then
if [[ "$chna" == 'a' ]]
then
chna=""
rulnum=""
else
echo 'Rule number?'
read -r rulnum
fi
zeroc="su -c iptables -Z $chna $rulnum"
msg="ZERO COUNTER $chna $rulnum SUCCESSFUL."
$zeroc
if [[ $? == '0' ]]
then
echo
echo $msg
else
echo
echo 'Back to main menu.'
fi
else
echo 'Nothing changed. Back to main menu.'
fi
echo
echo $mmenu
;;


c)
echo
echo 'Current NAT to DNS: '$(su -c "iptables -L OUTPUT -vnt nat" | egrep -o "to:[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")
echo 'Enter new IP DNS server: (Quad9/(b)ack)'
read ipDns
if [[ $ipDns == '' ]]; then
ipDns='9.9.9.9'
msg='DNS changed to Quad9. Add more rule?'
elif [[ $ipDns == 'b' ]]
then
msg='Nothing changed. Add more rule?'
echo
else
msg="DNS changed to $ipDns. Add more rule?"
echo
fi
if [[ $ipDns != 'b' ]]
then
su -c "iptables -t nat -R OUTPUT 1 -p udp --dport 53 -m owner --uid-owner 0 -j DNAT --to-destination $ipDns:53 2> /dev/null"
su -c "iptables -R cfw_OUTPUT_ACCEPT 1 -d $ipDns -p udp --dport 53 -m owner --uid-owner 0 -j ACCEPT 2> /dev/null"
fi
if [[ $? == '0' ]]
then
echo $msg
else
echo "CAN'T REPLACE. TRYING TO INSERT."
su -c "iptables -I cfw_OUTPUT_ACCEPT 1 -d $ipDns -p udp --dport 53 -m owner --uid-owner 0 -j ACCEPT 2> /dev/null"
if [[ $? == '0' ]]
then
echo $msg
else
echo 'Wrong IP address!!! Back to main menu.'
fi
fi
;;


b)
cd "$appPath"
msg=$mmenu
echo
echo 'Enter name or set default. Back? (d/blank)'
read bakn
case $bakn in
"")
msg='Cancel backup. Select option again.'
;;
*)
bakMsg='BACKUP CREATED SUCCESSFUL.'
if [[ $bakn == 'd' ]]; then
bakn='fwe'
bakMsg='SET DEFAULT FIREWALL RULE.'
su -c "ip6tables-save > ipt6-$bakn.bak"
fi
su -c "iptables-save > ipt-$bakn.bak"
echo
ls -1 *.bak
echo
echo $bakMsg
;;
esac
echo
echo $msg
;;


r)
cd "$appPath"
echo
ls -1 *.bak
echo
echo 'Enter restore name. Back? (blank)'
while :
do
read restn
case $restn in
"")
echo 'Cancel restore. Select option again.'
break
;;
*)
file="nfound"
for search in *.bak
do
if [ "$search" = "$restn" -a "$restn" != "*" ]; then
file="found"
break
fi
done
if [ "$file" = "found" ]; then
su -c "iptables-restore < $restn"
echo
echo 'RESTORE SUCCESSFUL.'
break
else
echo
echo "File $restn not found."
fi
;;
esac
done
echo
echo
echo $mmenu
;;


rm)
cd "$appPath"
echo
ls -1 *.bak
echo
echo 'Enter file name. Back? (blank)'
while :
do
read filen
case $filen in
"")
echo 'Cancel remove. Select option again.'
break
;;
*)
su -c "rm $filen 2> /dev/null"
if [[ $? == "1" ]]; then
echo
echo "File $filen not found."
else
echo
ls -1 *.bak
echo
echo "FILE $filen REMOVED."
break
fi
;;
esac
done
echo
echo
echo $mmenu
;;


df)
cd "$appPath"
bakn='fwe'
bakMsg='SET DEFAULT FIREWALL RULE.'
su -c "ip6tables-save > ipt6-$bakn.bak"
su -c "iptables-save > ipt-$bakn.bak"
echo
echo "$bakMsg"
echo 'Add more rule?'
;;


t)
echo
echo 'IPv4 -- Table filter'
echo
su -c "iptables -L -v -n --line-numbers"
tmenu='Table name? Back? Exit? (1-8/blank/e)\n\tIPv4\t\t\tIPv6
\n1. security\t\t6. raw
\n2. raw\t\t\t7. mangle
\n3. nat\t\t\t8. filter
\n4. mangle
\n5. filter'
while :
do
echo
echo $tmenu
read -rn1 tbn
echo
ipt="iptables"
iptn="IPv4"
case $tbn in
1) tbn="security" ;;
2) tbn="raw" ;;
3) tbn="nat" ;;
4) tbn="mangle" ;;
5) tbn="filter" ;;
6) tbn="raw" ipt="ip6tables" iptn="IPv6" ;;
7) tbn="mangle" ipt="ip6tables" iptn="IPv6" ;;
8) tbn="filter" ipt="ip6tables" iptn="IPv6" ;;
e) exit ;;
*)
echo
echo 'Back to Main menu.'
break ;;
esac
echo
echo "$iptn -- Table $tbn"
echo
ript="su -c $ipt -t $tbn -L -v -n --line-numbers"
$ript
echo
done
echo
echo
echo $mmenu
;;


l)
while :
do
lmenu='Add log all or drop packet? (a/d)
\n\tCustom log. (c)
\n\tView log. (v)
\n\tGo back. (blank)
\n\tExit. (e)'
echo
echo $lmenu
read lopt
case $lopt in
a)
echo
echo 'Log All packet or by UID or IP? (a/u/i)'
read aopt
case $aopt in
a)
su -c "iptables -I OUTPUT -j LOG --log-prefix '[IPT OUT] ------------------ ' --log-level 4 --log-uid"
su -c "iptables -I INPUT -j LOG --log-prefix '[IPT IN] ------------------ ' --log-level 4 --log-uid"
echo
echo ALL PACKAGES LOG ADDED.
;;
u)
echo
echo 'Enter App UID or App name to search UID.'
while :
do
read auid
case $auid in
"") 
echo 'Nothing added.'
break
;;
*[!0-9]*)
su -c "cmd package list packages -U $auid"
;;
*)
su -c "iptables -I OUTPUT -m owner --uid-owner $auid -j LOG --log-prefix '[IPT OUT] ------------------ ' --log-level 4 --log-uid"
su -c "iptables -I INPUT -m owner --uid-owner $auid -j LOG --log-prefix '[IPT IN] ------------------ ' --log-level 4 --log-uid"
echo
echo ALL PACKAGES LOG ADDED.
break
;;
esac
done
;;
i)
echo
echo Enter destination IP.
read dip
su -c "iptables -I OUTPUT -d $dip -j LOG --log-prefix '[IPT OUT] ------------------ ' --log-level 4 --log-uid"
su -c "iptables -I INPUT -s $dip -j LOG --log-prefix '[IPT IN] ------------------ ' --log-level 4 --log-uid"
echo
echo ALL PACKAGES LOG ADDED.
;;
*)
echo
echo Nothing added.
;;
esac
;;

d)
echo
echo 'Log Drop All packet or by UID or IP? (a/u/i)'
read dopt
case $dopt in
a)
su -c "iptables -A cfw_OUTPUT_ACCEPT -j LOG --log-prefix '[IPT OUT] ------------------ ' --log-level 4 --log-uid"
su -c "iptables -A cfw_INPUT_ACCEPT -j LOG --log-prefix '[IPT IN] ------------------ ' --log-level 4 --log-uid"
echo
echo DROP PACKAGES LOG ADDED.
;;
u)
echo
echo 'Enter App UID or App name to search UID.'
while :
do
read auid
case $auid in
"") 
echo 'Nothing added.'
break
;;
*[!0-9]*)
su -c "cmd package list packages -U $auid"
;;
*)
su -c "iptables -A cfw_OUTPUT_ACCEPT -m owner --uid-owner $auid -j LOG --log-prefix '[IPT OUT] ------------------ ' --log-level 4 --log-uid"
su -c "iptables -A cfw_INPUT_ACCEPT -m owner --uid-owner $auid -j LOG --log-prefix '[IPT IN] ------------------ ' --log-level 4 --log-uid"
echo
echo DROP PACKAGES LOG ADDED.
break
;;
esac
done
;;
i)
echo
echo Enter destination IP.
read dip
su -c "iptables -A cfw_OUTPUT_ACCEPT -d $dip -j LOG --log-prefix '[IPT OUT] ------------------ ' --log-level 4 --log-uid"
su -c "iptables -A cfw_INPUT_ACCEPT -s $dip -j LOG --log-prefix '[IPT IN] ------------------ ' --log-level 4 --log-uid"
echo
echo DROP PACKAGES LOG ADDED.
;;
*)
echo
echo Nothing added.
;;
esac
;;

"")
echo
echo
echo $mmenu
break ;;

e) exit ;;

c)
echo
echo Option can be blank to ignore.
echo Enter Protocol?
read prov
echo
echo Enter Destination IP?
read dipv
echo
echo Enter Port number or Multi Ports with comma?
read portv
echo
echo Enter App UID or App name to search UID.
while :
do
read uidv
case $uidv in
*[!0-9]*)
su -c cmd package list packages -U $uidv
;;
*) break ;;
esac
done
echo
echo 'Add conntrack? ESTABLISHED. (e)'
read cntv

if [ -z "$prov" ]; then
pro=""
else
pro="-p $prov"
fi
if [ -z "$dipv" ]; then
dip=""
sip=""
else
dip="-d $dipv"
sip="-s $dipv"
fi
if [ -z "$portv" ]; then
dport=""
sport=""
else
dport="-m multiport --dports $portv"
sport="-m multiport --sports $portv"
fi
if [ -z "$uidv" ]; then
uid=""
else
uid="-m owner --uid-owner $uidv"
fi
if [ -z "$cntv" ]; then
cnt=""
elif [ "$cntv" = "e" ]; then
cnt="-m conntrack --ctstate RELATED,ESTABLISHED"
else
cnt="-m conntrack --ctstate $cntv"
fi
echo
echo 'Default Insert. Append or Replace? (blank/a/r)'
read inrl
case $inrl in
a)
irule="su -c iptables -A INPUT $pro $sip $sport $uid $cnt -j LOG --log-prefix '[IPT IN] ------------------ ' --log-level 4 --log-uid"
orule="su -c iptables -A OUTPUT $pro $dip $dport $uid -j LOG --log-prefix '[IPT OUT] ------------------ ' --log-level 4 --log-uid"
;;
r)
echo
su -c iptables -L -v -n --line-numbers
echo
echo 'Order number?'
read ordn
irule="su -c iptables -R INPUT $ordn $pro $sip $sport $uid $cnt -j LOG --log-prefix '[IPT IN] ------------------ ' --log-level 4 --log-uid"
orule="su -c iptables -R OUTPUT $ordn $pro $dip $dport $uid -j LOG --log-prefix '[IPT OUT] ------------------ ' --log-level 4 --log-uid"
;;
*)
echo
su -c iptables -L -v -n --line-numbers
echo
echo 'Order number? Default 1.'
read ordn
if [[ $ordn == '' ]]
then
echo '1'
fi
irule="su -c iptables -I INPUT $ordn $pro $sip $sport $uid $cnt -j LOG --log-prefix '[IPT IN] ------------------ ' --log-level 4 --log-uid"
orule="su -c iptables -I OUTPUT $ordn $pro $dip $dport $uid -j LOG --log-prefix '[IPT OUT] ------------------ ' --log-level 4 --log-uid"
;;
esac
echo
echo 'Add to OUT, IN or both? Back? (blank/i/bo/b)'
read inout
case $inout in
""|o)
$orule
echo
if [ "$inrl" = "a" ]; then
echo 'OUTPUT LOG RULE ADDED.'
elif [ "$inrl" = "r" ]; then
echo 'OUTPUT LOG RULE REPLACE SUCCESSFUL.'
else
echo 'OUTPUT LOG RULE INSERTED.'
fi
;;
i)
$irule
echo
if [ "$inrl" = "a" ]; then
echo 'INPUT LOG RULE ADDED.'
elif [ "$inrl" = "r" ]; then
echo 'INPUT LOG RULE REPLACE SUCCESSFUL.'
else
echo 'INPUT LOG RULE INSERTED.'
fi
;;
bo)
echo
if [[ $inrl == 'i' || $inrl == '' ]]; then
if [[ $ordn == '' || $ordn == 1 ]]
then
$irule
$orule
echo 'BOTH LOG RULE INSERTED.'
else
echo 'BOTH RULE ORDER NOT MATCH. CANCEL!!!'
fi
elif [ "$inrl" = "r" ]; then
echo 'CANNOT REPLACE BOTH RULE. CANCEL!!!'
elif [ "$inrl" = "a" ]; then
$irule
$orule
echo 'BOTH LOG RULE ADDED.'
else
echo 'WRONG OPTION!!! (i/a/r)'
fi
;;
*)
echo
echo Nothing added.
;;
esac
;;

v)
while :
do
echo
echo 'View IN, OUT or BOTH? Back? (i/o/b/blank)'
echo 'Tip: While logging press Ctrl+C to stop.'
read inout
case $inout in
i|o|b)
shino=""
shinon="BOTH"
if [ "$inout" = "i" ]; then
shino="IN" shinon="INPUT"
elif [ "$inout" = "o" ]; then
shino="OUT" shinon="OUTPUT"
fi
echo
echo "LOGGING $shinon CHAIN."
echo
su -c "fgrep --color \"IPT $shino\" $logMsg"
echo
echo
echo 'Back to view log again or Exit? (blank/e)'
echo 'Enter UID number to view packet name.'
while :
do
read puid
case $puid in
e) exit ;;
"") break ;;
*[!0-9]*)
echo 'Accept UID number only!'
;;
*)
su -c cmd package list packages -U --uid $puid
;;
esac
done
;;
"") break ;;
*)
echo
echo 'Please select view option again.'
;;
esac
done
;;

*)
echo Please select an log option again.
;;
esac
done
;;


*)
echo 'Please select menu option again.'
;;
esac
done


echo
su -c iptables -L -v -n --line-numbers
echo
echo
echo "Press any key to exit!"
read -rn1 key