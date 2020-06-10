echo "Identificate como root.. "
su
########################## APT SOURCES ##################################

#add to sources.list contrib and non-free

DEBIAN_RELEASE=`cat /etc/*-release 2> /dev/null | grep PRETTY_NAME | awk -F "=" {'print $2'} | awk -F "(" {'print $2'} | awk -F ")" {'print $1'}`

echo "Writes /etc/apt/sources.list in order to add $DEBIAN_RELEASE non-free repository"

echo "# deb http://deb.debian.org/debian $DEBIAN_RELEASE main" > /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "deb http://deb.debian.org/debian $DEBIAN_RELEASE main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian $DEBIAN_RELEASE main contrib non-free" >> /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "deb http://security.debian.org/ $DEBIAN_RELEASE/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/ $DEBIAN_RELEASE/updates main contrib non-free" >> /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "# $DEBIAN_RELEASE-updates, previously known as "volatile"" >> /etc/apt/sources.list
echo "deb http://deb.debian.org/debian $DEBIAN_RELEASE-updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian $DEBIAN_RELEASE-updates main contrib non-free" >> /etc/apt/sources.list

########################## APT SOURCES ##################################

apt update
apt install xorg neofetch htop git wget chromium openssh-server openbox lightdm sudo unclutter firmware-linux firmware-realtek curl net-tools xdotool hostapd dnsmasq wireless-tools network-manager

sudo usermod -aG sudo oasys
echo "oasys   ALL=(ALL:ALL) ALL" >> /etc/sudoers

########################### NODE AND MM ###############################

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -y nodejs

mkdir /opt/oasys
chown oasys:oasys /opt/oasys
su oasys
cd /opt/oasys
git clone https://github.com/MichMich/MagicMirror
cd MagicMirror/
npm install
cp config/config.js.sample config/config.js

########################### NODE AND MM ###############################

########################### KIOSKO ###############################


mkdir -p $HOME/.config/openbox

cp ./openbox/autostart /home/oasys/.config/openbox/autostart

echo "Hacer los siguientes cambios en la configuración de lightdm: "
echo
echo "##############################
[Seat:*] /
xserver-command=X -s 0 dpms  # Deshabilitar ahorro de energia /
user-session=openbox /
autologin-user=oasys /
/
############################## "
read -p "pulse entrar para editar el fichero"
nano /etc/lightdm/lightdm.conf

########################### KIOSKO ###############################

########################### DAEMONS ###############################
cp ./system/oasys-node.service /etc/systemd/system/
chmod 664 /etc/systemd/system/oasys-node.service


cp ./system/arduino-uart.service /etc/systemd/system/
chmod 664 /etc/systemd/system/arduino-uart.service
chmod 744 /usr/local/bin/com-UART.sh

cp ./system/display-on.service /etc/systemd/system/
chmod 664 /etc/systemd/system/display-on.service

cp ./bin/display-on.sh /usr/local/bin
cp ./bin/display-off.sh /usr/local/bin
chown oasys:oasys /usr/local/bin/display-on.sh
chown oasys:oasys /usr/local/bin/display-off.sh
chmod 744 /usr/local/bin/display-on.sh
chmod 744 /usr/local/bin/display-off.sh



sudo systemctl daemon-reload
sudo systemctl enable oasys-node.service arduino-uart.service display-on.service

########################### DAEMONS ###############################

########################### ARDUINO ###############################
sudo usermod -aG dialout oasys
########################### ARDUINO ###############################

########################### GRUB CONFIG ###############################

nano /etc/default/grub
#############################
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET="true"
GRUB_DISABLE_OS_PROBER="true"
GRUB_BACKGROUND=
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX=""
##############################
sudo update-grub

########################### GRUB CONFIG ###############################
