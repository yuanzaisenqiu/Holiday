#!/bin/bash
#Function:NTP and Reboot unit
#By Sunday


MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$MYDIR/PATH.sh"
source "$MYDIR/Function.sh"


#提取Mac主机的名称 Mac-A ==> A
host=$(echo $HOSTNAME | tr '.' '-' | awk -F - '{print $2}')

LeakageDir=$(date "+%m%d%H%M%S")

#服务器路径
DBName=/Volumes/C02DataBase

#验证服务器是否连接成功！
cd ${DBName}
if [[ $? -ne 0 ]]; then
	clear
	printf "\e[0;31m"
	echo "服务器连接失败，请检查！"
	printf "\e[0m"
	afplay $AlarmDir/jingbao.mp3 -t 4 &
	errorTip "服务器连接失败，请检查！"
	exit 1
fi


#获取机台端口和名称
source "$MYDIR/iPhoneInfo.sh"


echo '准备获取机台Leakage！'
LeakageCMD=$(cat $CommandDir/leakage.txt)
getLeakage 

getLeakage $syncPort_1 $sshPort_1 $iPhoneName_1 "$LeakageCMD"
getLeakage $syncPort_2 $sshPort_2 $iPhoneName_2 "$LeakageCMD"
getLeakage $syncPort_3 $sshPort_3 $iPhoneName_3 "$LeakageCMD" 
getLeakage $syncPort_4 $sshPort_4 $iPhoneName_4 "$LeakageCMD" 
getLeakage $syncPort_5 $sshPort_5 $iPhoneName_5 "$LeakageCMD"
getLeakage $syncPort_6 $sshPort_6 $iPhoneName_6 "$LeakageCMD"
getLeakage $syncPort_7 $sshPort_7 $iPhoneName_7 "$LeakageCMD"
getLeakage $syncPort_8 $sshPort_8 $iPhoneName_8 "$LeakageCMD"


# 导出Leakage
cd ~/Desktop/D??_Logs
mkdir -p Leakage
cd Leakage
mkdir -p $LeakageDir

echo '准备导出Leakage'
sleep 3
outLeakage $syncPort_1 $iPhoneName_1
outLeakage $syncPort_2 $iPhoneName_2
outLeakage $syncPort_3 $iPhoneName_3
outLeakage $syncPort_4 $iPhoneName_4
outLeakage $syncPort_5 $iPhoneName_5
outLeakage $syncPort_6 $iPhoneName_6
outLeakage $syncPort_7 $iPhoneName_7
outLeakage $syncPort_8 $iPhoneName_8



cd ~/Desktop/D??_Logs/Leakage/$LeakageDir
sort -t' ' -k 2 -o AllUnitInfoSort.csv AllUnitInfo.csv

echo '成功导出leakage'
echo '准备上传到服务器'

cp -a ~/Desktop/D??_Logs/Leakage/$LeakageDir $DBName/Leakage

cd $AlarmDir
afplay OK.wav













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











