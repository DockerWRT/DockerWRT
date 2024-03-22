#!/usr/bin/expect

spawn make menuconfig
expect "OpenWrt Configuration"
sleep 1
send "\t\t\t\r"
#interact

expect "Enter"
sleep 1
send "\r"
#interact

expect "No change"
sleep 1
send "\r"
#interact

expect "OpenWrt Configuration"
sleep 1
send "\t\r"
interact
#expect "Ok"
#send "\r"

