#!/usr/bin/expect

set offset [lindex $argv 0]
set command1 [lindex $argv 1]
set password "alpine"
set timeout 10

spawn telnet localhost $offset
expect "login:"
send "root\r"
expect "Password:"
send "$password\r"
expect "#"
send "screen\r"
send "\r"
send "\r"
send "./SetupiPhone.sh $command1\r"
send "\r"
interact

