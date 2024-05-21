#!/bin/bash

ISCONNECTED=1
PREV_STATE="INIT"

while true; do
    sleep 30

    # Verifica se la connessione è presente con un ping
    PINGCON=$(ping -c2 -q -W 3 8.8.8.8 | grep "2 received")
    if [[ $PINGCON != *"2 received"* ]]; then
        echo "No connection detected, trying to reconnect..."
        nmcli con down id $HOSTNAME
        sleep 1s
        nmcli con up id $HOSTNAME
        CURRENT_STATE="DISCONNECTED"
    else
        echo "Connection detected"
        
        # Verifica lo stato della connessione VPN
        nmcli con up id $HOSTNAME
        VPNCON=$(nmcli -f GENERAL.STATE con show id $HOSTNAME | awk '{print $2}')

        if [[ $VPNCON == "activated" ]]; then
            echo "Connected to VPN"
            CURRENT_STATE="VPN"
        elif [[ $VPNCON == "activating" ]]; then
            echo "Not connected! Connecting to VPN"
            CURRENT_STATE="CONNECTING"
        else
            echo "VPN down, but LAN is connected"
            CURRENT_STATE="LAN"
        fi
    fi

    # Verifica se lo stato della connessione è cambiato, escluso il primo ciclo
    if [[ "$PREV_STATE" != "INIT" && "$PREV_STATE" != "$CURRENT_STATE" ]]; then
        if [[ "$CURRENT_STATE" == "VPN" || "$CURRENT_STATE" == "LAN" || "$CURRENT_STATE" == "DISCONNECTED" ]]; then
            ISCONNECTED=0
        elif [[ "$CURRENT_STATE" == "VPN" ]]; then
            ISCONNECTED=1
            if [[ "$PREV_STATE" == "LAN" ]]; then
                # Attiva la connessione VPN solo se non è già attiva
                if [[ $VPNCON != "activated" ]]; then
                    echo "Activating VPN..."
                    nmcli con up id $HOSTNAME
                fi
            fi
        fi
    fi

    # Riavvia AnyDesk se necessario
    if [[ $ISCONNECTED == 0 ]]; then
        echo "Restarting AnyDesk"
        sudo systemctl restart anydesk
        ISCONNECTED=1
    fi

    # Aggiorna lo stato precedente
    PREV_STATE="$CURRENT_STATE"
done
