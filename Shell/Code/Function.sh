#!/bin/echo Warning:this library should be sourced





#错误提示函数
errorTip()
{
	source "$MYDIR/pashua.sh"
	conf="
	*.title = 错误信息
	txt.type = text
	txt.default = $1
	txt.relx = 80
	db.type = defaultbutton
	db.label = 关闭窗口
	"
	customLocation=''
	pashua_run "$conf" "$customLocation"
}

#######
#input.sh 函数
#######

#同步时间
#exceptSyncTime $sshPort_1 $iPhoneName_1
exceptSyncTime()
{
if [[ $1 = *22 ]];then
NOW=$(date "+%m%d%H%M%Y.%S")
/usr/bin/expect << EOF
spawn ssh -o NoHostAuthenticationForLocalhost=yes -p $1 root@localhost
set timeout 1
expect {
	timeout { send_user "\nSSH aleardy works...";exit 1}
	"password:"
}
send "alpine\r"
expect "root#"
send "date $NOW\r"
expect "#"
send "mount - uw /\r"
expect "#"
send "exit\r"
EOF
echo
echo "########################"
echo "机台:${2}已完成同步时间！"
echo "########################"
sleep 1
fi
}



#把脚本导入到机台，并统计花费的时间
#inputScript() $rsyncPort_1 $iPhoneName_1
inputScript()
{
	if [[ $1 != 0 ]];then
		echo "########################"
		echo "机台信息:${2}"
		echo "开始时间：$(date +%r)"
		startTime=$(date +%s)
		cd ~/Desktop/D??_Script
		RSYNC_PASSWORD=alpine rsync -a * rsync://root@localhost:${1}873/root/var/root
		if [[ $? -ne 0 ]];then
			printf "\e[0;31m"
			echo "导入脚本失败，请检查"
			printf "\e[0m"
			afplay $AlarmDir/jingbao.mp3 -t 4 &
			errorTip "导入脚本失败，请检查"
			exit 1
		fi
		echo "完成的时间:$(date +%r)"
		endTime=$(date +%s)
		let spendTime=endTime-startTime
		echo "花费的时间:${spendTime}秒"
		echo "########################"
		echo
	fi
}


#UI机台初始化设置
#setup $telnetPort_1 $iPhoneName_1 "$setupCMD"
setup()
{
	if [[ $1 != 1 ]];then
		if [[ $2 = [0-9]-[0-9]*[a-z] ]]; then
			setupiPhoneName=$(echo $2 | awk -F '-' '{print $2}')
		elif [[ $2 = [0-9]*[a-z] ]]; then
			setupiPhoneName=$2
		else
			echo "机台初始化设置只接受机台名称为1-20832r、20832r这两种格式，请重新命名！"
			exit 1
		fi
		sleep 1
		ttab -w -t $2 $MYDIR/TelnetSetup $1 $setupiPhoneName
	fi
}


#######
#boot.sh 函数
#######

#同步时间
syncTime()
{
	if [[ $1 = *22 ]];then
		sleep 1
		nowTime=$(date "+%m%d%H%M%Y.%S")
		ttab -w -t $2 $MYDIR/sshNTP $1 $nowTime "$3"
	fi
}




#######
#getData.sh 函数
#######

#获取机台的Thermal Config
getiPhoneCfg()
{
	if [[ -z "$1" ]] || [[ $1 = iPhone* ]]; then
		:
	else
		if [[ $1 = [0-9]-[0-9]*[a-z] ]]; then #case_1:3-20832r
			newiPhoneName=$(echo $1|sed 's/[a-z]//g'|awk -F '-' '{print $2}') #20832
		elif [[ $1 = [0-9]*[a-z] ]]; then #case_2:20832r
			newiPhoneName=$(echo $1|sed 's/[a-z]//g') #20832
		fi
		result="$(mysql -u $USER_1 -p$PASS UnitBase -Bse "SELECT * FROM UnitList WHERE iPhoneName='$newiPhoneName' limit 1" 2>/dev/null)"
		read _ Cfg_$2 <<< "$result"
	fi
}


#video测试获取机台FPS.txt
getFPS()
{
	if [[ $1 = *22 ]];then
		if [[ $5 = *CAPTURE* ]]; then
			sleep 1
			ttab -w -t $2 $MYDIR/sshCommand $1 "$4"
		else
			sleep 1
			ttab -w -t $2 $MYDIR/sshCommand $1 "$3"
		fi
	fi
}


#获取机台诊断信息
getSysdiagnose()
{
	if [[ $1 = *22 ]];then
		sleep 1
		ttab -w -t $2 $MYDIR/sshCommand $1 "$3"
	fi
}


#验证sysdiagnose是否完成
verifySysdiagnoseDone()
{
	if [[ $1 -ne 0 ]]; then
		until [[ -z "$1" ]]; do
			RSYNC_PASSWORD=alpine rsync -a rsync://root@localhost:${1}873/root/var/root/*_OK*.txt ~/Desktop/D??_Logs/AutoGetData 2>/dev/null
			shift
		done
	fi
}


#获取机台测试信息函数
getUnitData()
{
	if [[ $1 -ne 0 ]]; then
		cd ~/Desktop/D??_Logs/AutoGetData
		mkdir -p ${4}	#mkdir -p unit_1
		RSYNC_PASSWORD=alpine rsync -a rsync://root@localhost:${1}873/root/var/logs/thermal ~/Desktop/D??_Logs/AutoGetData/${4} 2>/dev/null
		if [[ $? -eq 0 ]]; then
			cd ${4}
			mkdir ${2}	#mkdir 5-6973b
			mkdir Tmp
			cd thermal
			if [[ $5 = *NOICARUS* ]]; then
				find . -maxdepth 1 type f | while read name;do
					mv "$name" ~/Desktop/D??_Logs/AutoGetData/${4}/${2}
				done
			else
				#mv thermal下的all files 到Tmp文件夹下
				find . -maxdepth 1 type f | while read name;do
					mv "$name" ~/Desktop/D??_Logs/AutoGetData/${4}/Tmp
				done
				#按时间排序所有文件夹，取出最新的那个
				ls -rt|tail -1|while read name;do
					mv "$name" ~/Desktop/D??_Logs/AutoGetData/${4}/${2}
				done
				#把Tmp下的文件移动到RawData下
				cd ..
				cd Tmp
				[[ $(ls|wc -l) -ne 0 ]] && mv *  ~/Desktop/D??_Logs/AutoGetData/${4}/${2}/D*/RawData
			fi
		else
			printf "\e[;31m"
			echo "取数据失败，可能是端口中断，请检查！"
			printf "\e[0m"
			cd ..
			rm -rf AutoGetData
			rm -rf ${3}
			afplay $AlarmDir/jingbao.mp3 -t 4 &
			errorTip "取数据失败，可能是端口中断，请检查！"
			exit 1
		fi
	fi
}


#获取以前所有的测试数据
getPreviousUnitData()
{
	if [[ $1 -ne 0 ]]; then
		cd ~/Desktop/D??_Logs/AutoGetData
		mkdir -p ${2}
		RSYNC_PASSWORD=alpine rsync -a rsync://root@localhost:${1}873/root/var/root/RawData ~/Desktop/D??_Logs/AutoGetData/${2} 2>/dev/null
		if [[ $? -eq 0 ]]; then
			mv ${2} ~/Desktop/D??_Logs/${3}
		else
			printf "\e[;31m"
			echo "取数据失败，可能是端口中断，请检查！"
			printf "\e[0m"
			cd ..
			rm -rf AutoGetData
			rm -rf ${3}
			afplay $AlarmDir/jingbao.mp3 -t 4 &
			errorTip "取数据失败，可能是端口中断，请检查！"
			exit 1
		fi
	fi
}


#######
#LazyBoy.sh 函数
#######


#懒人一键发送冷却指令
coolingUnit()
{
	if [[ $1 = *22 ]];then
		sleep 1
		ttab -w -t $2 $MYDIR/sshCommand $1 "$3"
	fi
}

#懒人一键关机
haltUnit()
{
	if [[ $1 = *22 ]];then
		sleep 1
		ttab -w -t $2 $MYDIR/sshCommand $1 "$3"
	fi	
}

#懒人一键打开机台一个root窗口
openOneRoot()
{
	if [[ $1 = *22 ]];then
		sleep 1
		ttab -w -t $2 $MYDIR/sshRoot $1 
	fi
}

#懒人一键打开机台两个root窗口
openDoubleRoot()
{
	if [[ $1 = *22 ]];then
		sleep 1
		ttab -w -t $2 $MYDIR/sshRoot $1 && ttab -t $2 $MYDIR/sshRoot $1
	fi	
}


#getLeakage.sh
getLeakage()
{
	if [[ $1 != 0 ]]; then
		#判断机台名称
		if [[ $3 = [0-9]-[0-9]*[a-z] ]] || [[ $3 = [0-9]*[a-z] ]]; then
			:
		else
			clear
			echo "机台初始化设置只接受机台名称为1-20832r、20832r这两种格式，请重新命名！"
			afplay $AlarmDir/jingbao.mp3 -t 4 &
			errorTip "机台初始化设置只接受机台名称为1-20832r、20832r这两种格式，请重新命名！"
			exit 1
		fi
		cd ~/Desktop/D??_Script/
		RSYNC_PASSWORD=alpine rsync -a getDieInfo* rsync://root@localhost:${1}873/root/var/root/ || {
			clear
			printf "\e[0;31m"
			echo "导入脚本失败，请检查"
			printf "\e[0m"
			afplay $AlarmDir/jingbao.mp3 -t 4 &
			errorTip "导入脚本失败，请检查"
			exit 1
		}
		ttab -w -t $2 $MYDIR/sshCommand $1 "$4"
	fi
}


outLeakage()
{

	echo 111
	
}









