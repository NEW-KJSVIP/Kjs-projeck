#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
apt update -y && apt upgrade -y && apt install -y wget curl jq at screen

# Mengunduh file setup.sh yang sudah disesuaikan dari repository GitHub
wget -q https://raw.githubusercontent.com/NEW-KJSVIP/Kjs-projeck/main/setup.sh 

# Memberikan izin eksekusi pada file setup.sh
chmod +x setup.sh

# Menjalankan file setup.sh dalam sesi screen untuk instalasi
screen -S install ./setup.sh

Green="\e[92;1m"
RED="\033[1;31m"
YELLOW="\033[33m"
BLUE="\033[36m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
OK="${Green}--->${FONT}"
ERROR="${RED}[ERROR]${FONT}"
GRAY="\e[1;30m"
NC='\e[0m'
red='\e[1;31m'
green='\e[0;32m'
TIME=$(date '+%d %b %Y')
ipsaya=$(wget -qO- ipinfo.io/ip)
TIMES="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
clear
export IP=$(curl -sS icanhazip.com)
clear
clear && clear && clear
clear;clear;clear

echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo -e "\033[96;1m              WELCOME TO SRICPT METSOTRE              \033[0m"
echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo ""
sleep 3

# Mengecek Arsitektur sistem
if [[ $(uname -m | awk '{print $1}') == "x86_64" ]]; then
    echo -e "${OK} Your Architecture Is Supported ( ${green}$(uname -m)${NC} )"
else
    echo -e "${ERROR} Your Architecture Is Not Supported ( ${YELLOW}$(uname -m)${NC} )"
    exit 1
fi

# Mengecek OS yang digunakan
if [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "ubuntu" ]]; then
    echo -e "${OK} Your OS Is Supported ( ${green}$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${NC} )"
elif [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "debian" ]]; then
    echo -e "${OK} Your OS Is Supported ( ${green}$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${NC} )"
else
    echo -e "${ERROR} Your OS Is Not Supported ( ${YELLOW}$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${NC} )"
    exit 1
fi

if [[ $ipsaya == "" ]]; then
    echo -e "${ERROR} IP Address ( ${RED}Not Detected${NC} )"
else
    echo -e "${OK} IP Address ( ${green}$IP${NC} )"
fi

echo ""
read -p "$( echo -e "Press ${GRAY}[ ${NC}${green}Enter${NC} ${GRAY}]${NC} For Starting Installation") "
echo ""
clear

if [ "${EUID}" -ne 0 ]; then
    echo "You need to run this script as root"
    exit 1
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ is not supported"
    exit 1
fi

# Remove unnecessary steps and keep only the needed installation
print_install "Membuat direktori xray"
mkdir -p /etc/xray
curl -s ifconfig.me > /etc/xray/ipvps
touch /etc/xray/domain
mkdir -p /var/log/xray
chown www-data.www-data /var/log/xray
chmod +x /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log

# Install packages
print_install "Menginstall Paket yang Dibutuhkan"
apt install -y zip p7zip-full openvpn speedtest-cli pwgen openssl socat cron bash-completion ntpdate curl jq

# Update the NTP and time zone
timedatectl set-timezone Asia/Jakarta
ntpdate pool.ntp.org

# Install Nginx
nginx_install() {
    print_install "Setup nginx"
    apt-get install nginx -y
}
nginx_install

# Install SSL
pasang_ssl() {
    print_install "Memasang SSL Pada Domain"
    rm -rf /etc/xray/xray.key
    rm -rf /etc/xray/xray.crt
    domain=$(cat /root/domain)
    STOPWEBSERVER=$(lsof -i:80 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
    rm -rf /root/.acme.sh
    mkdir /root/.acme.sh
    systemctl stop $STOPWEBSERVER
    systemctl stop nginx
    curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
    ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    chmod 777 /etc/xray/xray.key
    print_success "SSL Certificate"
}

# Menu and profile setup
menu() {
    print_install "Memasang Menu Packet"
    apt install p7zip-full -y
    wget ${REPO}Cdy/menu.zip
    7z x -pas123@Newbie menu.zip
    chmod +x menu/*
    mv menu/* /usr/local/sbin
    rm -rf menu
    rm -rf menu.zip
    rm -rf /usr/local/sbin/*~
    rm -rf /usr/local/sbin/gz*
    rm -rf /usr/local/sbin/*.bak
    rm -rf /usr/local/sbin/m-noobz
}

# Set the profile
profile() {
    clear
    cat >/root/.profile <<EOF
if [ "$BASH" ]; then
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
mesg n || true
menu
EOF
}

# Final reboot
clear
echo -e ""
echo -e ""
echo -e "\033[96m==========================\033[0m"
echo -e "\033[92m      INSTALL SUCCESS      \033[0m"
echo -e "\033[96m==========================\033[0m"
echo -e ""
sleep 2
clear
echo -e "\033[93;1m Wait in 4 sec...\033[0m"
sleep 4
clear
echo ""
read -p "Press [ Enter ]  TO REBOOT"
clear
reboot