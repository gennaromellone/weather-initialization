#!/bin/bash +x

while [ “true” ]
do
	sleep 30
	VPNCON=$(nmcli -f GENERAL.STATE con show id $HOSTNAME | awk '{print $2}')



 	if [[ $VPNCON == "activated" ]]; then
		echo "Connected to VPN"
  	elif [[ $VPNCON == "activating" ]]; then
   		echo "Not connected! Connecting to VPN"
     	else
      		echo "VPN down"
	fi


   
	if [[ $VPNCON != "activated" ]]; then
		echo "Disconnected, trying to reconnect…"
		sleep 1s
  		nmcli con up id $HOSTNAME
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
  		sudo systemctl restart anydesk
	else
		echo "Connected!"
	fi
	sleep 30
done
