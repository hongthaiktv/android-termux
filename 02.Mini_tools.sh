#!/system/xbin/bash

homeDir='/data/data/com.termux/files/home'
mmenu='Mini tools utilities.\n
\t1. View wifi password.\n
\t2. SSH to router.\n
\t3. Sync Boostnote.\n
\t4. View note.\n'
echo -e $mmenu

while :
do

read -rn1 -p 'Select option: (exit) ' select
echo
echo

case $select in
"") break ;;

1) tsudo cat /data/misc/wifi/WifiConfigStore.xml | egrep -i 'presharedkey|\"ssid"' | egrep -o '\&quot\;.*\&quot\;' | sed s/'\&quot\;'//g
echo
echo -e $mmenu
;;

2) ssh -i .ssh/router_rsa root@192.168.0.1
echo
echo -e $mmenu
;;

3) bash /sdcard/Download/Boostnote/async.sh
echo
echo -e $mmenu
;;

4) notesDir='/sdcard/Download/Boostnote/notes/'
cd $notesDir
while :
do
read -rp 'Keyword: (back) ' keyword
echo
if [[ $keyword == '' ]]
then
cd $homeDir
break
else
IFS_BAK=${IFS}
IFS=$'\n'
notes=( $(egrep -io "title: \".*$keyword.*\"$" *.cson | egrep -ion --color "\".*$keyword.*\"$") )
echo ${notes[@]}
echo ${#notes[@]}
#egrep -ion --color "\".*$keyword.*\"$" <<< $notes
if [[ $? == "0" ]]
then
while :
do
numFd=${#notes[@]}
echo
echo "Found $numFd note(s)."
read -rp 'Enter note order to view: (back) ' fileName
echo
if [[ $fileName == '' ]]
then
break
else
cat $fileName
echo
egrep -i --color "title: \".*$keyword.*\"" *.cson
fi
done
else
echo 'Not match any title. Try again!!!'
echo
fi
fi
done
#IFS=${IFS_BAK}
echo
echo -e $mmenu
;;

*) echo -e 'Wrong option!!!\n'
;;

esac

done
