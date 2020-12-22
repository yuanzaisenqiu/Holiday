#!/bin/bash
#Function:NTP and Reboot unit
#By Sunday


MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$MYDIR/PATH.sh"
source "$MYDIR/Function.sh"

#	$1 == 改boot值
#	$2 == 不重启

#机台不重启
if [[ $2 -eq 1 ]]; then
	#机台改boot值，不重启
	if [[ $1 -eq 1 ]]; then
		cd $SOPDir
		cd Boot
		open boot.txt
		say --voice="ting-ting" 请在三十秒内输入命令并保存 &
		clear
		echo "你有三十秒输入命令并保存，可以输入回车键跳过剩余等待时间!"
		read -t 30 inputComfirm
		if [[ -s boot.txt ]]; then
			bootCMD=$(sed 's/reboot// boot.txt')
		else
			echo "这个文件夹没有boot.txt或者文件为空，请检查!"
			exit 2
		fi
	#机台不改boot值，不重启
	else
		bootCMD=pwd
	fi
#机台会重启
else
	#机台改boot值，并重启
	if [[ $1 -eq 1 ]]; then
		cd $SOPDir
		cd Boot
		open boot.txt
		say --voice="ting-ting" 请在三十秒内输入命令并保存 &
		clear
		echo "你有三十秒输入命令并保存，可以输入回车键跳过剩余等待时间!"
		read -t 30 inputComfirm
		if [[ -s boot.txt ]]; then
			bootCMD=$(cat boot.txt)
		else
			echo "这个文件夹没有boot.txt或者文件为空，请检查!"
			exit 2
		fi
	#不改boot值，重启
	else
		bootCMD=reboot
	fi
fi



source "$MYDIR/iPhoneInfo.sh"

syncTime $sshPort_1 $iPhoneName_1 "$bootCMD"
syncTime $sshPort_2 $iPhoneName_2 "$bootCMD"
syncTime $sshPort_3 $iPhoneName_3 "$bootCMD"
syncTime $sshPort_4 $iPhoneName_4 "$bootCMD"
syncTime $sshPort_5 $iPhoneName_5 "$bootCMD"
syncTime $sshPort_6 $iPhoneName_6 "$bootCMD"
syncTime $sshPort_7 $iPhoneName_7 "$bootCMD"
syncTime $sshPort_8 $iPhoneName_8 "$bootCMD"

cd $AlarmDir
afplay OK.wav











