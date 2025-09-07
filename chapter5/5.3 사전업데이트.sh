#!/bin/bash

#저장소업데이트
echo 저장소업데이트
sudo apt update
sudo dpkg --configure -a
sudo apt --fix-broken install -y
sudo apt upgrade -y

#커널 변경으로 시스템 리부팅한다 
echo 커널 변경으로 시스템 리부팅한다 
sudo reboot
