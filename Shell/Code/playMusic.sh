#!/bin/bash
#Function:随机播放一首音乐

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$MYDIR/PATH.sh"


#如果家目录有music，随机播放一首音乐；如果没有，则播放音乐
cd ~/thermalTestMusic 2>/dev/null || {
	afplay $AlarmDir/OK.wav
	exit 2
}


musicQuantity=$(ls|wc-l)
let divisor=32767/musicQuantity

Num=$RANDOM		#[0,32767]
let Num=Num/divisor
echo $Num
afplay ${Num}*.* -t 15 &