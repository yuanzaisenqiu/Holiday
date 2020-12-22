#!/bin/bash

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


#铃声的路径
cd $MYDIR
cd ..
cd Alarm
AlarmDir=`pwd`


#测试命令txt路径
cd $MYDIR
cd ..
cd SOP
cd Command
CommandDir=`pwd`


#机台信息txt路径
cd $MYDIR
cd Text
cd iPhoneInfo
iPhoneInfoDir=`pwd`


#测试SOP路径
cd $MYDIR
cd ..
cd SOP
SOPDir=`pwd`