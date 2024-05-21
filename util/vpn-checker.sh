#!/bin/bash +x

while [ “true” ]
do
	VPNCON=$(nmcli -f GENERAL.STATE con show id $HOSTNAME | awk '{print $2}')
	if [[ $VPNCON != "activated" ]]; then
		echo "Disconnected, trying to reconnect…"
		(sleep 1s && nmcli con up id $HOSTNAME)
  		echo "Restarting AnyDesk"
  		sudo killall anydesk && sudo anydesk --service
	else
		echo "Already connected !"
	fi
	
	echo "Check network connection..."
	PINGCON=$(ping 8.8.8.8 -c2 -q -W 3|grep "2 received")
	if [[ $PINGCON != *2*received* ]];then
		echo "Timeout, trying to reconnect…"
		nmcli con down id $HOSTNAME
		sleep 1s 
		nmcli con up id $HOSTNAME
  		echo "Restarting AnyDesk"
  		sudo killall anydesk && sudo anydesk --service
	else
		echo "Connected!"
	fi
	sleep 60
done
