#!/bin/bash
#Function:NTP and Reboot unit
#By Sunday


MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$MYDIR/PATH.sh"
source "$MYDIR/Function.sh"



# 一键发送冷却指令
# 由于冷却指令过于长，故分两次发送
if [ $1 -eq 1 -a $2 -eq 0 -a $3 -eq 0 -a $4 -eq 0 ]; then
	# 检测cooling.txt是否为空
	cd $SOPDir
	cd CoolingUnit
	open CoolingUnit.txt
	say --voice="ting-ting" 请在三十秒内输入命令并保存 &
	clear
	echo "你有三十秒输入命令并保存，可以输入回车键跳过剩余等待时间!"
	read -t 30 inputComfirm
	if [[ -s CoolingUnit.txt ]]; then
		CMD=$(cat CoolingUnit.txt | sed -n '/CoolingUnit_1/,/CoolingUnit_1/ p' | sed '/CoolingUnit_1/d' | sed '/^$/d') | sed '/^screen/a\
\
\
'
	else
		echo 'CoolingUnit.txt或者文件为空，请检查'
		exit 2
	fi


	source "$MYDIR/iPhoneInfo.sh"

	CoolingUnit $sshPort_1 $iPhoneName_1 "$CMD"
	CoolingUnit $sshPort_2 $iPhoneName_2 "$CMD"
	CoolingUnit $sshPort_3 $iPhoneName_3 "$CMD"
	CoolingUnit $sshPort_4 $iPhoneName_4 "$CMD"
	CoolingUnit $sshPort_5 $iPhoneName_5 "$CMD"
	CoolingUnit $sshPort_6 $iPhoneName_6 "$CMD"
	CoolingUnit $sshPort_7 $iPhoneName_7 "$CMD"
	CoolingUnit $sshPort_8 $iPhoneName_8 "$CMD"

	CMD_1=$(cat CoolingUnit.txt | sed -n '/CoolingUnit_2/,/CoolingUnit_2/ p' | sed '/CoolingUnit_2/d' | sed '/^$/d'))
	if [[ -n "$CMD_1" ]]; then
		sleep 8
		CoolingUnit $sshPort_1 $iPhoneName_1 "$CMD_1"
		CoolingUnit $sshPort_2 $iPhoneName_2 "$CMD_1"
		CoolingUnit $sshPort_3 $iPhoneName_3 "$CMD_1"
		CoolingUnit $sshPort_4 $iPhoneName_4 "$CMD_1"
		CoolingUnit $sshPort_5 $iPhoneName_5 "$CMD_1"
		CoolingUnit $sshPort_6 $iPhoneName_6 "$CMD_1"
		CoolingUnit $sshPort_7 $iPhoneName_7 "$CMD_1"
		CoolingUnit $sshPort_8 $iPhoneName_8 "$CMD_1"		
	fi
	cd $AlarmDir
	afplay OK.wav

# 一键关机
elif [ $1 -eq 0 -a $2 -eq 1 -a $3 -eq 0 -a $4 -eq 0 ]; then
	
	source "$MYDIR/iPhoneInfo.sh"

	haltUnit $sshPort_1 $iPhoneName_1 halt
	haltUnit $sshPort_2 $iPhoneName_2 halt
	haltUnit $sshPort_3 $iPhoneName_3 halt
	haltUnit $sshPort_4 $iPhoneName_4 halt
	haltUnit $sshPort_5 $iPhoneName_5 halt
	haltUnit $sshPort_6 $iPhoneName_6 halt
	haltUnit $sshPort_7 $iPhoneName_7 halt
	haltUnit $sshPort_8 $iPhoneName_8 halt

	cd $AlarmDir
	afplay OK.wav

# 一键打开一个root
elif [ $1 -eq 0 -a $2 -eq 0 -a $3 -eq 1 -a $4 -eq 0 ]; then
	
	source "$MYDIR/iPhoneInfo.sh"

	openOneRoot $sshPort_1 $iPhoneName_1
	openOneRoot $sshPort_2 $iPhoneName_2
	openOneRoot $sshPort_3 $iPhoneName_3
	openOneRoot $sshPort_4 $iPhoneName_4
	openOneRoot $sshPort_5 $iPhoneName_5
	openOneRoot $sshPort_6 $iPhoneName_6
	openOneRoot $sshPort_7 $iPhoneName_7
	openOneRoot $sshPort_8 $iPhoneName_8

	cd $AlarmDir
	afplay OK.wav

# 一键打开两个个root
elif [ $1 -eq 0 -a $2 -eq 0 -a $3 -eq 0 -a $4 -eq 1 ]; then
	
	source "$MYDIR/iPhoneInfo.sh"


	openDoubleRoot $sshPort_1 $iPhoneName_1
	openDoubleRoot $sshPort_2 $iPhoneName_2
	openDoubleRoot $sshPort_3 $iPhoneName_3
	openDoubleRoot $sshPort_4 $iPhoneName_4
	openDoubleRoot $sshPort_5 $iPhoneName_5
	openDoubleRoot $sshPort_6 $iPhoneName_6
	openDoubleRoot $sshPort_7 $iPhoneName_7
	openDoubleRoot $sshPort_8 $iPhoneName_8

	cd $AlarmDir
	afplay OK.wav

else
	echo 'ERROR,懒人一键一次只能勾选一个功能执行！'
	cd $AlarmDir
	afplay jingbao.wav
fi








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











