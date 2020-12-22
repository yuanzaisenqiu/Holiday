#!/bin/bash
#Function:NTP and Reboot unit
#By Sunday


MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$MYDIR/PATH.sh"
source "$MYDIR/Function.sh"
source "$MYDIR/iPhoneInfo.sh"



if [[ $2 -eq 1 ]]; then
	clear
	echo '开始同步时间！'
	exceptSyncTime $sshPort_1 $iPhoneName_1
	exceptSyncTime $sshPort_2 $iPhoneName_2
	exceptSyncTime $sshPort_3 $iPhoneName_3
	exceptSyncTime $sshPort_4 $iPhoneName_4
	exceptSyncTime $sshPort_5 $iPhoneName_5
	exceptSyncTime $sshPort_6 $iPhoneName_6
	exceptSyncTime $sshPort_7 $iPhoneName_7
	exceptSyncTime $sshPort_8 $iPhoneName_8
fi

# 复制setupUnit.sh到Script下
cd $MYDIR
cp -a setupiPhone.sh ~/Desktop/D??_Script

clear
echo '开始导入脚本，可能需要一段时间，请等待'
inputScript $rsync_1 $iPhoneName_1
inputScript $rsync_2 $iPhoneName_2
inputScript $rsync_3 $iPhoneName_3
inputScript $rsync_4 $iPhoneName_4
inputScript $rsync_5 $iPhoneName_5
inputScript $rsync_6 $iPhoneName_6
inputScript $rsync_7 $iPhoneName_7
inputScript $rsync_8 $iPhoneName_8


if [[ $1 = 1 ]]; then
	clear
	echo '开始对机台进行初始化设置！'
	setup $telnetPort_1 $iPhoneName_1
	setup $telnetPort_2 $iPhoneName_2
	setup $telnetPort_3 $iPhoneName_3
	setup $telnetPort_4 $iPhoneName_4
	setup $telnetPort_5 $iPhoneName_5
	setup $telnetPort_6 $iPhoneName_6
	setup $telnetPort_7 $iPhoneName_7
	setup $telnetPort_8 $iPhoneName_8
	sleep 70
	exceptSyncTime $sshPort_1 $iPhoneName_1
	exceptSyncTime $sshPort_2 $iPhoneName_2
	exceptSyncTime $sshPort_3 $iPhoneName_3
	exceptSyncTime $sshPort_4 $iPhoneName_4
	exceptSyncTime $sshPort_5 $iPhoneName_5
	exceptSyncTime $sshPort_6 $iPhoneName_6
	exceptSyncTime $sshPort_7 $iPhoneName_7
	exceptSyncTime $sshPort_8 $iPhoneName_8	
fi

cd $AlarmDir
afplay OK.wav











