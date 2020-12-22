#!/bin/bash




MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$MYDIR/PATH.sh"
source "$MYDIR/Function.sh"

cd $iPhoneInfoDir
usbterm -list | awk '{print $4}' >UDID.txt
testUnitQuantity=$(cat UDID.txt | wc -l | sed -e 's/^[ \t]*//')
errorCheck=$(cat UDID.txt | grep "opening")
if [[ $errorCheck = "opening" ]]; then
	let testUnitQuantity=testUnitQuantity-1
fi



if [[ $testUnitQuantity = 0 ]]; then
	clear
	printf "\e[0;31m"
	echo "找不到设备，请检查"
	printf "\e[0m"
	afplay $AlarmDir/jingbao.mp3 -t 4 &
	errorTip "找不到设备，请检查"
	exit 1	
fi

say --voice="ting-ting" ${testUnitQuantity}台苹果 &
sort -t' ' -k 1 -o UDIDSort.txt UDID.txt

cat ~/.ssh/config > allList.txt

while read line;do
	grep $(echo $line | awk '{print $1') allList.txt
done < UDID.txt > whatineed.txt
sort -t' ' -k 3 -o whatineed_sort.txt whatineed.txt

M=1
while read line;do
	read _ _ iPhoneName_$M sshPort_$M <<< "$line"
	let M++
done < whatineed_sort.txt

let telnetPort_1=sshPort_1-1
let telnetPort_2=sshPort_2-1
let telnetPort_3=sshPort_3-1
let telnetPort_4=sshPort_4-1
let telnetPort_5=sshPort_5-1
let telnetPort_6=sshPort_6-1
let telnetPort_7=sshPort_7-1
let telnetPort_8=sshPort_8-1

let syncPort_1=(sshPort_1-22)/1000
let syncPort_2=(sshPort_2-22)/1000
let syncPort_3=(sshPort_3-22)/1000
let syncPort_4=(sshPort_4-22)/1000
let syncPort_5=(sshPort_5-22)/1000
let syncPort_6=(sshPort_6-22)/1000
let syncPort_7=(sshPort_7-22)/1000
let syncPort_8=(sshPort_8-22)/1000


printf "\e[0;32m"
echo "------------------------"
echo "此次获取的机台数量为：${testUnitQuantity}"
echo "------------------------"
printf "\e[0m"
sleep 3







