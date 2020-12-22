#!/bin/bash
#Function:GUI
#By Sunday


MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$MYDIR/pashua.sh"
source "$MYDIR/PATH.sh"


#GUI元素配置
conf="
# Set window title
*.title = Welcome to Holiday
*.x = 50
*.y = 60


# Add a text field
tf.type = textfield
tf.label = 提取数据SOP输入文本框
tf.default = 直接copy
tf.width = 310


# Define radiobuttons
rb.type = radiobutton
rb.label = 功能
rb.option = 修改命令
rb.option = 导入脚本
rb.option = Leakage
rb.option = 同步时间
rb.option = 懒人一键
rb.option = 提取数据


# 导入脚本可选项
chk1.type = checkbox
chk1.label = UI初始化设置
chk1.x = 82
chk1.y = 123

chk2.type = checkbox
chk2.label = 同步时间
chk2.x = 220
chk2.y = 123


# 同步时间可选项
chk3.type = checkbox
chk3.label = 改Boot值
chk3.x = 82
chk3.y = 86

chk4.type = checkbox
chk4.label = 不重启
chk4.x = 180
chk4.y = 86



#提取数据可选项
chk5.type = checkbox
chk5.label = 35C
chk5.x = 82
chk5.y = 46

chk13.type = checkbox
chk13.label = PreData
chk13.x = 140
chk13.y = 46

chk14.type = checkbox
chk14.label = sysdiagnose
chk14.x = 220
chk14.y = 46

chk6.type = checkbox
chk6.label = 重启机台
chk6.x = 320
chk6.y = 46
chk6.default = 1

chk15.type = checkbox
chk15.label = 不重启不移数据
chk15.x = 220
chk15.y = 26

# 一键操作的可选项
chk9.type = checkbox
chk9.label = 冷却
chk9.x = 82
chk9.y = 66

chk10.type = checkbox
chk10.label = 关机
chk10.x = 140
chk10.y = 66

chk11.type = checkbox
chk11.label = 打开一个root
chk11.x = 220
chk11.y = 66

chk12.type = checkbox
chk12.label = 打开一个root
chk12.x = 320
chk12.y = 66


# Add a cancel button with default label
cb.type = cancelbutton
cb.label = 关闭

db.type = defaultbutton
db.label = 开始
"


if [ -d '/Volumes/Pashua/Pashua.app' ]
then
	# Looks like the Pashua disk image is mounted. Run from there.
	customLocation='/Volumes/Pashua'
else
	# Search for Pashua in the standard locations
	customLocation=''
fi

# Get the icon from the application bundle
locate_pashua "$customLocation"
bundlecontents=$(dirname $(dirname "$pashuapath"))
if [ -e "$bundlecontents/Resources/AppIcon@2.png" ]
then
    conf="$conf
          img.type = image
          img.x = 435
          img.y = 120
          img.maxwidth = 128
          img.tooltip = This is an element of type “image”
          img.path = $bundlecontents/Resources/AppIcon@2.png"
fi

while true; do
  # 检查ios menu是否已经打开
  checkAPP=$(ps -ef | grep "iOS Menu.app" | wc -l)
  if [[ $checkAPP = 1 ]]; then
    open -a "iOS Menu.app"
    sleep 3
  fi
  echo '#################'
  echo 'Open APP GUI'
  echo
  pashua_run "$conf" "$customLocation"
  if [[ $cb = 1 ]]; then
    echo Bye!
    exit 1
  fi
  cd $MYDIR
  case $rb in
    导入脚本 )
      ./InputScript.sh $chk1 $chk2
      # chk1
      # chk2
      ;;
    同步时间 )
      ./ModifyBoot.sh $chk3 $chk4
      # chk3
      # chk4
      ;;
    提取数据 )
      if [[ "$tx" != "直接copy" ]]; then
        if [[ $tx = *.rtf ]]; then
          # 去除.rtf后缀
          tx=${tx%.*}
        fi
        if [[ $chk5 = 1 ]]; then
          tx=$(echo $tx | sed 's/_25C/_35C/g')
          ./GetData.sh $tx $chk6 $chk7 $chk8 $chk13 $chk14 $chk15
          # $tx
          # $chk6
          # $chk8
          # $chk13
          # $chk14
          # $chk15
        else
          ./GetData.sh $tx $chk6 $chk7 $chk8 $chk13 $chk14 $chk15
        fi
      else
        printf "\e[0;31m"
        echo "请在文本框中输入正确的SOP名称"
        printf "\e[0m"
        afplay $AlarmDir/jingbao.mp3 -t 4 &
        exit 1        
      fi
      ;;
    懒人一键 )
      ./LazyBoy.sh $chk9 $chk10 $ch11 $chk12
      ;;
    Leakage )
      ./GetLeakage.sh
      ;;
    修改命令 )
      cd ..
      cd SOP
      open .
      ;;
    * )
      echo '请选择一个功能块执行！'
      sleep 1
      ;;    
  esac
done
echo 




















