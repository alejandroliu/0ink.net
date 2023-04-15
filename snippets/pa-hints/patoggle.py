#!/bin/sh
wallpanel="http://192.168.101.58:2971"

req='{
	"speak": "¡Aló mundo"
     }'

req='{
	"url": "https://www.yahoo.com/"
     }'
req='{
	"url": "intent:#Intent;launchFlags=0x10000000;component=com.google.android.calendar/com.android.calendar.AllInOneActivity;end"
     }'
req='{
	"url": "intent:#Intent;launchFlags=0x10000000;component=com.google.android.deskclock/com.google.android.deskclock.DeskClockApplication;end"
     }'


curl \
	-s \
	--location \
	--request POST "$wallpanel/api/command" \
	--header 'Content-Type: application/json;charset=UTF-8' \
	--data-raw "$req" | jq .
