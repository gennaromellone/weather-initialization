#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo -e "\e[91mPlease launch this script as root user.\e[0m"
    exit 1
fi

if [ -z "$ANYPWD" ]; then
    echo -e "\e[91mPlease set an anydesk password in variable ANYPWD.\e[0m"
    exit 1
fi

echo -e "\e[91m---- INSTALLING PREREQUISITES ----\e[0m"
sudo apt update
sudo apt upgrade -y
sudo apt-get install -y openssh-server make curl


echo -e "\e[91m---- INSTALLING ANYDESK ----\e[0m"
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list
sudo apt update
sudo apt install anydesk -y
echo -e "\e[91mSetting password ...\e[0m"
echo $ANYPWD | sudo anydesk --set-password
sudo cp $HOME/weather-initialization/util/custom.conf /etc/gdm3/custom.conf

echo -e "\e[91mSetting dummy display ...\e[0m"
sudo apt-get install xserver-xorg-video-dummy
sudo cp $HOME/weather-initialization/util/xorg.conf /etc/X11/xorg.conf


echo -e "\e[91m---- INSTALLING DOCKER ----\e[0m"
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER

sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo apt-get install docker-compose -y


echo -e "\e[91m---- INSTALLING SER2NET ----\e[0m"
sudo apt-get install ser2net -y
sudo cp $HOME/weather-initialization/util/ser2net.yaml /etc/ser2net.yaml
echo -e "\e[91mActivating ser2net ...\e[0m"
sudo systemctl restart ser2net.service 


echo -e "\e[91m---- INSTALLING VANTAGE-PUBLISHER ----\e[0m"
cd $HOME
git clone https://github.com/gennaromellone/vantage-publisher
cd vantage-publisher
sudo chmod +x vantage-updater.sh
sudo cp $HOME/weather-initialization/util/vantage-updater.service /etc/systemd/
sudo systemctl enable $HOME/weather-initialization/util/vantage-updater.service
make build
docker-compose up -d


echo -e "\e[91m---- DONE! ----\e[0m"
echo -e "\e[91mPlease reboot the system. (y/n)\e[0m"
read rb


if [ "$rb" = "y" ]; then
    sudo reboot
else
    echo "Something will not work correctly until reboot..."
fi
