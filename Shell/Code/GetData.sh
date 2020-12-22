#!/bin/bash
#Function:get data
#By Sunday


MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$MYDIR/PATH.sh"
source "$MYDIR/Function.sh"


#外部传参，测试项目名称
testSOP=$1

#1080P和4K测试项目的命令
FPS_1=$(cat $commandTextDir/videoFPS.txt)
FPS_2=$(cat $commandTextDir/captureFPS.txt)

##班别
Shfit=$(date "+%H")
Date=$(date "+%m%d_%H%M%S")

#提取Mac主机的名称 Mac-A ==> A
host=$(echo $HOSTNAME | tr '.' '-' | awk -F - '{print $2}')

#外部数据路径
TCName=/Volumes/TCLogs_$host

#服务器路径
DBName=/Volumes/C02DataBase


#环境温度路径
if [[ $host = A ]]; then
	roomAmbient=~/Desktop/roomAmbient
else
	roomAmbient=/Volumes/roomAmbient
fi

#完整的测试项目名称
testCase=${testSOP}_Oven_${host}_${Date}

#转换为大写
AA=$(echo $testSOP | tr [a-z] [A-Z])

#MYSQL需要的变量
USER_1="root"
PASS="thermal"
DBUnitList=/Volumes/C02DataBase/MYSQL_UnitCfg/UnitList_DB.csv
DBUnitList_copy=/Volumes/C02DataBase/MYSQL_UnitCfg/UnitList_DB_copy.csv


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

#FF:unix or FF:dos check
unixFormatCheck=$(od -t x1 $DBUnitList | grep "0d 0a" | head -1)
if [[ -n "$unixFormatCheck" ]]; then
	cat -e $DBUnitList | awk -F ^ '{print $1}' > $DBUnitList_copy
	rm $DBUnitList
	mv $DBUnitList_copy $DBUnitList
fi

#外部数据和环境温度路径检查
if [[ $AA =*POWERCHECK* ]] || [[ $AA =*IR* ]]; then
	:
else
	cd ${TCName}
	if [[ $? -ne 0 ]]; then
		clear
		printf "\e[0;31m"
		echo "外部数据路径连接失败，请检查！"
		printf "\e[0m"
		afplay $AlarmDir/jingbao.mp3 -t 4 &
		errorTip "外部数据路径连接失败，请检查！"
		exit 1
	fi
	cd ${roomAmbient}
	if [[ $? -ne 0 ]]; then
		clear
		printf "\e[0;31m"
		echo "环境数据路径连接失败，请检查！"
		printf "\e[0m"
		afplay $AlarmDir/jingbao.mp3 -t 4 &
		errorTip "环境数据路径连接失败，请检查！"
		exit 1
	fi
fi


#获取机台端口和名称
source "$MYDIR/iPhoneInfo.sh"

#若发现UnitList有新增机台，更新unitbase
cd $iPhoneInfoDir
awk '{print $0}' $DBUnitList UnitList_Script.csv | sort | uniq -u > diffPart.csv
if [[ -s diffPart.csv ]]; then
	while read line; do
		oldIFS=$IFS
		IFS=,
		values=($line)
		values[0]="\"`echo ${values[0]}`\""
		values[1]="\"`echo ${values[1]}`\""
		query=`echo ${values[@]} | tr ' ' ','`
		IFS=$oldIFS
		mysql -u $USER_1 -p$PASS UnitBase << EOF 2>/dev/null
INSERT INTO UnitList VALUES($query);
EOF
	done < diffPart.csv
	echo "成功向数据库写入新增机台Cfg"
	rm UnitList_Script.csv
	cp $DBUnitList ./
	mv $DBUnitList UnitList_Script.csv
fi


#开始获取机台Cfg
getiPhoneCfg $iPhoneName_1 1
getiPhoneCfg $iPhoneName_2 2
getiPhoneCfg $iPhoneName_3 3
getiPhoneCfg $iPhoneName_4 4
getiPhoneCfg $iPhoneName_5 5
getiPhoneCfg $iPhoneName_6 6
getiPhoneCfg $iPhoneName_7 7
getiPhoneCfg $iPhoneName_8 8


#创建需要的文件夹
cd ~/Desktop/D??_Logs
mkdir -p AutoGetData
mkdir -p $testCase
mkdir -p $(date +%m%d)


#判断是否取FPS.txt
if [[ $AA = *4K* ]] || [[ $AA = *1080P* ]] || [[ $AA = *CAPTURE* ]]; then
	echo '|-----------正在获取机台FPS-----------|'
	getFPS $sshPort_1 $iPhoneName_1 "$FPS_1" "$FPS_2" $AA
	getFPS $sshPort_2 $iPhoneName_2 "$FPS_1" "$FPS_2" $AA
	getFPS $sshPort_3 $iPhoneName_3 "$FPS_1" "$FPS_2" $AA
	getFPS $sshPort_4 $iPhoneName_4 "$FPS_1" "$FPS_2" $AA
	getFPS $sshPort_5 $iPhoneName_5 "$FPS_1" "$FPS_2" $AA
	getFPS $sshPort_6 $iPhoneName_6 "$FPS_1" "$FPS_2" $AA
	getFPS $sshPort_7 $iPhoneName_7 "$FPS_1" "$FPS_2" $AA
	getFPS $sshPort_8 $iPhoneName_8 "$FPS_1" "$FPS_2" $AA		

	sleep 6
	#开始验证FPS是否全部取完	
	for (( i = 0; i < 20; i++ )); do
		cd ~/Desktop/D??_Logs/AutoGetData
		nowSysdiagnoseDnoeQty=$(find . -maxdepth 1 -name "FPS_OK*.txt" | wc -l)
		if [[ $nowSysdiagnoseDnoeQty -eq $testUnitQuantity ]]; then
			break
		else
			verifySysdiagnoseDone $syncPort_1 $syncPort_2 $syncPort_3 $syncPort_4 $syncPort_5 $syncPort_6 $syncPort_7 $syncPort_8
		fi
		sleep 2
		if [[ $i -ge 6 ]]; then
			clear
			printf "\e[0;31m"
			echo "取机台FPS超时，请检查！"
			printf "\e[0m"
			afplay $AlarmDir/jingbao.mp3 -t 4 &
			rm -rf ~/Desktop/D??_Logs/$testCase
			rm -rf ~/Desktop/D??_Logs/AutoGetData
			errorTip "取机台FPS超时，请检查！"
			exit 1
		fi
	done	
	rm FPS_OK*.txt	
fi

#开始取机台内部数据

#取以前的所有测试数据
if [[ $5 -eq 1 ]]; then
	getPreviousUnitData $syncPort_1 $iPhoneName_1 $testCase unit_1 $AA 
	getPreviousUnitData $syncPort_2 $iPhoneName_2 $testCase unit_2 $AA &
	getPreviousUnitData $syncPort_3 $iPhoneName_3 $testCase unit_3 $AA &
	getPreviousUnitData $syncPort_4 $iPhoneName_4 $testCase unit_4 $AA &
	getPreviousUnitData $syncPort_5 $iPhoneName_5 $testCase unit_5 $AA &
	getPreviousUnitData $syncPort_6 $iPhoneName_6 $testCase unit_6 $AA &
	getPreviousUnitData $syncPort_7 $iPhoneName_7 $testCase unit_7 $AA &
	getPreviousUnitData $syncPort_8 $iPhoneName_8 $testCase unit_8 $AA &
	wait
else
	getUnitData $syncPort_1 ${iPhoneName_1}_${Cfg_1} $testCase unit_1 $AA 
	getUnitData $syncPort_2 ${iPhoneName_2}_${Cfg_2} $testCase unit_2 $AA &
	getUnitData $syncPort_3 ${iPhoneName_3}_${Cfg_3} $testCase unit_3 $AA &
	getUnitData $syncPort_4 ${iPhoneName_4}_${Cfg_4} $testCase unit_4 $AA &
	getUnitData $syncPort_5 ${iPhoneName_5}_${Cfg_5} $testCase unit_5 $AA &
	getUnitData $syncPort_6 ${iPhoneName_6}_${Cfg_6} $testCase unit_6 $AA &
	getUnitData $syncPort_7 ${iPhoneName_7}_${Cfg_7} $testCase unit_7 $AA &
	getUnitData $syncPort_8 ${iPhoneName_8}_${Cfg_8} $testCase unit_8 $AA &
	wait
fi

moveRawDataCMD='
[[ -s sysdiagnose_OK_${HOSTNAME}.txt ]] && rm sysdiagnose_OK_${HOSTNAME}.txt
[[ -s FPS_OK_${HOSTNAME}.txt ]] && rm FPS_OK_${HOSTNAME}.txt
mkdir -p RawData
cd RawData
lastRawDataTime=$(date "+%m%d_%H%M%S")
mkdir $lastRawDataTime
mv /var/logs/thermal/* ~/RawData/$lastRawDataTime
ggtool -k BRSC
sleep 2
reboot
'

#不执行操作
if [[ $7 -eq 1 ]]; then
	:
else
	#同步时间+重启机台
	sleep 1
	if [[ $2 -eq 1 ]]; then
		syncTime $sshPort_1 $iPhoneName_1 "$moveRawDataCMD"
		syncTime $sshPort_2 $iPhoneName_2 "$moveRawDataCMD"
		syncTime $sshPort_3 $iPhoneName_3 "$moveRawDataCMD"
		syncTime $sshPort_4 $iPhoneName_4 "$moveRawDataCMD"
		syncTime $sshPort_5 $iPhoneName_5 "$moveRawDataCMD"
		syncTime $sshPort_6 $iPhoneName_6 "$moveRawDataCMD"
		syncTime $sshPort_7 $iPhoneName_7 "$moveRawDataCMD"
		syncTime $sshPort_8 $iPhoneName_8 "$moveRawDataCMD"
	#不重启
	else
		moveRawDataCMD=$(echo $moveRawDataCMD | sed 's/reboot/cd/')
		syncTime $sshPort_1 $iPhoneName_1 "$moveRawDataCMD"
		syncTime $sshPort_2 $iPhoneName_2 "$moveRawDataCMD"
		syncTime $sshPort_3 $iPhoneName_3 "$moveRawDataCMD"
		syncTime $sshPort_4 $iPhoneName_4 "$moveRawDataCMD"
		syncTime $sshPort_5 $iPhoneName_5 "$moveRawDataCMD"
		syncTime $sshPort_6 $iPhoneName_6 "$moveRawDataCMD"
		syncTime $sshPort_7 $iPhoneName_7 "$moveRawDataCMD"
		syncTime $sshPort_8 $iPhoneName_8 "$moveRawDataCMD"		
	fi
fi


#开始取外部数据和环境温度
if [[ $AA =*POWERCHECK* ]] || [[ $AA =*IR* ]]; then
	:
else
	echo '|-----------开始取外部数据和环境温度-----------|'
	cd ${TCName}
	ls -Ut | head -1 | while read name;do
		cp -a "$name" ~/Desktop/D??_Logs/$testCase
	done

	cd ${roomAmbient}
	ls -Ut | head -1 | while read name;do
		cp -a "$name" ~/Desktop/D??_Logs/$testCase
	done
fi

#准备上传到服务器
sleep 1
echo '|-----------开始上传到服务器-----------|'
if [[ $Shift -lt 20 ]]; then
	cd ${DBName}
	mkdir -p $(date "+%m%d")
	cp -a ~/Desktop/D??_Logs/$testCase ${DBName}/$(date "+%m%d")
else
	cd ${DBName}
	mkdir -p $(date "+%m%d")N
	cp -a ~/Desktop/D??_Logs/$testCase ${DBName}/$(date "+%m%d")N	
fi


#移动数据到当天的文件夹
mv ~/Desktop/D??_Logs/$testCase  ~/Desktop/D??_Logs/$(date "+%m%d")
rm -rf ~/Desktop/D??_Logs/AutoGetData

echo '|-----------取数据程序执行完毕-----------|'



#随机播放一首音乐提醒用户程序执行完毕
source "$MYDIR/playMusic.sh"





