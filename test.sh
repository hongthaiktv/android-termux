#!/system/xbin/bash

fn () {
read -r k
if [[ $k =~ [abc] ]]
then
echo True
else
echo False
fi
}
while :
do
fn
done
echo
echo
read -srn1 -p 'Press any key to exit.' key
