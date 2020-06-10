#!/bin/bash

#add to sources.list contrib and non-free
apt update
apt install xorg neofetch htop git wget chromium openssh-server openbox lightdm sudo unclutter firmware-linux firmware-realtek curl net-tools xdotool hostapd dnsmasq wpasupplicant wireless-tools

sudo usermod -aG sudo oasys

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

nano $HOME/.config/openbox/autostart
###########################
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/'Local State'
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/; s/"exit_type":"[^"]\+"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences

xset dpms force off &

chromium \
    --no-first-run \
    --no-default-browser-check \
    --disable \
    --disable-translate \
    --disable-infobars \
    --disable-suggestions-service \
    --disable-save-password-bubble \
    --disable-session-crashed-bubble \
    --start-maximized \    
    --kiosk "http://localhost:8080" &

sleep 2
xset dpms force on &

#############################


nano /etc/lightdm/lightdm.conf
##############################
[Seat:*]
xserver-command=X -s 0 dpms  # Deshabilitar ahorro de energia
user-session=openbox
autologin-user=oasys


##############################

########################### KIOSKO ###############################


########################### DAEMONS ###############################


nano /etc/systemd/system/oasys-node.service
##############################
[Unit]
Description=oasys UI backend
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=oasys
WorkingDirectory=/opt/oasys/MagicMirror
ExecStart=/usr/bin/node serveronly

[Install]
WantedBy=multi-user.target
###############################


nano /etc/systemd/system/arduino-uart.service
###############################
[Unit]
Description=Conexion Arduino COM-serie
After=network.target oasys-node.service
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=on-failure
RestartSec=1
User=root
ExecStart=/usr/local/bin/com-UART.sh

[Install]
WantedBy=multi-user.target
###############################


nano /etc/systemd/system/display-on.service
###############################
[Unit]
Description=Encender Pantalla
After=network.target arduino-uart.service
StartLimitIntervalSec=0
[Service]
Type=oneshot
RemainAfterExit=true
User=oasys
ExecStartPre=/bin/sleep 2
ExecStart=/usr/local/bin/display-on.sh
ExecStop=/usr/local/bin/display-off.sh

[Install]
WantedBy=multi-user.target
###############################


chown oasys:oasys /usr/local/bin/display-on.sh
chown oasys:oasys /usr/local/bin/display-off.sh
chmod 744 /usr/local/bin/display-on.sh
chmod 744 /usr/local/bin/display-off.sh
chmod 664 /etc/systemd/system/display-on.service

chmod 744 /usr/local/bin/com-UART.sh
chmod 664 /etc/systemd/system/arduino-uart.service

chmod 664 /etc/systemd/system/oasys-node.service


sudo systemctl daemon-reload
sudo systemctl enable oasys-node.service arduino-uart.service display-on.service


nano /usr/local/bin/com-UART.sh
################################
#!/bin/bash

/usr/bin/stty 9600 -F /dev/ttyS0 raw -echo
cat /dev/ttyS0
################################


nano /usr/local/bin/display-on.sh
################################
#!/bin/bash

echo '1'>/dev/ttyS0
exit 0
#################################

nano /usr/local/bin/display-off.sh
################################
#!/bin/bash

echo '0'>/dev/ttyS0
exit 0
#################################


########################### DAEMONS ###############################


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

### Plymouth ###
Check KMS kernel support is enabled
cat /var/log/messages | grep modesetting

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

apt install plymouth plymouth-themes

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

########################### GRUB CONFIG ###############################


########################### ARDUINO ###############################


sudo usermod -aG dialout oasys


########################### ARDUINO ###############################



############################ NOTAS ##################################
Siempre que conectemos por ssh y queremos abrir programa en pantalla fisica
export display=:0

Uso de memoria 359MB
El panel de retroiluminacion cuenta con 94 leds, 20x27

Para refrescar la interfaz:
DISPLAY=:0 xdotool key F5
Ojito con el usuario con el que se ejecuta, y con la sesion con la que se quiere
hacer interaccion, ya que podriamos no tener la autoridad, cosa que no se hace
explicitamente en Debian. MAS INFO --> https://unix.stackexchange.com/questions/118811/why-cant-i-run-gui-apps-from-root-no-protocol-specified
Podemos comprobar la autrodiad con:
xauth list
Arreglo sencillo a la problematica, ejecutar el comando con el usuario que tiene
la autoridad y no cambiarla
sudo -u oasys DISPLAY=:0 xdotool key F5

De la misma forma tras hacer un poco de debugging podemos levantar y bajar el servidor node de una manera más sencilla en pruebas
sudo -u oasys DISPLAY=:0 npm start


nano /opt/oasys/MagicMirror/config/config.js [CONFIGURACION BASICA]
#########################################
        address: "0.0.0.0", // Address to listen on, can be:
        port: 8080,
        ipWhitelist: ["127.0.0.1","10.0.0.0/31","192.168.1.0/24"], // Set [] to allow all IP addresses
        useHttps: false,                // Support HTTPS or not, default "false" will use HTTP
        httpsPrivateKey: "",    // HTTPS private key path, only require when useHttps is true
        httpsCertificate: "",   // HTTPS Certificate path, only require when useHttps is true
        language: "es",
        timeFormat: 24,
        units: "metric",
########################################


Ejemplo de uso de la api REST que provee el modulo MMM-remote:
curl -X GET "http://192.168.1.30:8080/api/module/alert/showalert?message=Hello&timer=10000&apiKey=keymuysegura"



50 mA 5V ---> 0.25W
5A 5V ----> 25W
10W ---> 40 LED aprox

En total tenemos 94 LED


############################ NOTAS ##################################


########################### WIFI-HOTSPOT ###############################

ip addr add 10.0.0.0/31 dev wlx0007324cad42             # IP temporal para el hotspot

nano /etc/hostapd/hostapd.conf
#############################
interface=wlx0007324cad42
ssid=Oasys
hw_mode=g
channel=0
ieee80211d=1
country_code=ES
ieee80211n=1
ieee80211ac=1
wmm_enabled=1

auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK WPA-PSK-SHA256
rsn_pairwise=CCMP
wpa_passphrase=12345678
#############################

nano /etc/dnsmasq.conf
############################
domain=local
interface=wlx0007324cad42
no-resolv
dhcp-range=10.0.0.0,10.0.0.1,255.255.255.254,5m
dhcp-option=3,1.2.3.4
############################


systemctl restart dnsmasq
systemctl unmask hostapd
systemctl restart hostapd


#Cuando acabemos de introducir los datos para conectarse a la red wifi existente, paramos los servicios y deshabilitamos los servicios
nano /usr/local/bin/first-run_end.sh
###########################
systemctl stop dnsmasq
systemctl stop hostapd
systemctl disable dnsmasq
systemctl disable hostapd
#Antes de reiniciar, hacer las configuraciones pertinentes para conectarnos a la otra red.
reboot
##########################


########################### WIFI-HOTSPOT ###############################

########################### CONEXION A RED WIFI EXISTENTE ###############################


##########################

ip link set wlx0007324cad42 up
sudo iwlist wlx0007324cad42 scan # | grep -i ssid
sudo wpa_passphrase nombreRed contrasena > /etc/wpa_supplicant/wpa_supplicant.conf

nano /etc/wpa_supplicant/wpa_supplicant.conf
###############################

###############################

########################### CONEXION A RED WIFI EXISTENTE ###############################

############################ MODULOS ##################################

cd /opt/oasys/MagicMirror/modules


git pullhttps://github.com/Jopyth/MMM-Remote-Control.git
cd MMM-Remote-Control
git show-branch
git checkout develop
git pull
npm install

nano /opt/oasys/MagicMirror/config/config.js
####################################
{
    module: 'MMM-Remote-Control',
    // uncomment the following line to show the URL of the remote control on the mirror
    position: 'bottom_left',
    // you can hide this module afterwards from the remote control itself
    config: {
                    customCommand: {},  // Optional, See "Using Custom Commands" below
                    customMenu: "custom_menu.json", // Optional, See "Custom Menu Items" below
                    showModuleApiMenu: true, // Optional, Enable the Module Controls menu
                    apiKey: "keymuysegura",         // Optional, See API/README.md for details
            }
},

###################################



############################ MODULOS ##################################
