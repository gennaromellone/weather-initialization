#!/bin/bash +x

ISCONNECTED=1
PREV_STATE=""

while true; do
    sleep 30

    # Controlla lo stato della connessione VPN
    VPNCON=$(nmcli -f GENERAL.STATE con show id $HOSTNAME | awk '{print $2}')

    if [[ $VPNCON == "activated" ]]; then
        echo "Connected to VPN"
        CURRENT_STATE="VPN"
    elif [[ $VPNCON == "activating" ]]; then
        echo "Not connected! Connecting to VPN"
        CURRENT_STATE="CONNECTING"
    else
        echo "VPN down"
        # Controlla se la connessione LAN è attiva pingando un server esterno
        PINGCON=$(ping -c2 -q -W 3 8.8.8.8 | grep "2 received")
        if [[ $PINGCON != *"2 received"* ]]; then
            echo "Disconnected, trying to reconnect…"
            nmcli con down id $HOSTNAME
            sleep 1s
            nmcli con up id $HOSTNAME
            CURRENT_STATE="DISCONNECTED"
        else
            echo "Connected to LAN!"
            CURRENT_STATE="LAN"
        fi
    fi

    # Verifica se lo stato della connessione è cambiato
    if [[ "$PREV_STATE" != "$CURRENT_STATE" ]]; then
        if [[ "$CURRENT_STATE" == "LAN" || "$CURRENT_STATE" == "DISCONNECTED" ]]; then
            ISCONNECTED=0
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
