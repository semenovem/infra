Предполагается, что сеть с IP адресами 10.10.0.0/24 основная, а Raspberry Pi управляет сетью для беспроводных клиентов 192.168.4.0/24

sudo apt install hostapd
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

sudo apt install dnsmasq
sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

Настройка маршрутизатора
Raspberry Pi поднимет отдельную одиночную беспроводную сеть и будет управлять ей. А также маршрутизировать трафик между клиентами беспроводной сети и клиентами основной Ethernet сети и роутером.

Для беспроводной сети на Raspberry Pi запущен DHCP сервер, для работы которого требуется присвоить беспроводному интерфейсу (wlan0) статический IP адрес

Присваиваем статический IP адрес (192.168.4.1) точке доступа:

sudo vim /etc/dhcpcd.conf
В конец файла добавьте следующие строки:

interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
Настройка маршрутизации и IP маскарадинга
В этом разделе рассмотрим вопрос доступа беспроводных устройств из вспомогательной сети, организованной Raspberry Pi, к компьютерам основной Ethernet-сети и интернету.

Для включения маршрутизации добавим в конфиг /etc/sysctl.d/routed-ap.conf строку:

# Enable IPv4 routing
net.ipv4.ip_forward=1
Активация маршрутизации откроет участникам сети 192.168.4.0/24 доступ к основной сети и доступ в Интернет через основной роутер. Raspberry Pi может подменять IP адреса участников беспроводной сети своим IP адресом в основной сети, используя правило "маскарада" в своём файерволе, чтобы разрешить сетевой трафик между участниками беспроводной сети и Интернетом без изменения настроек роутера.

Основной роутер будет воспринимать весь трафик от клиентов беспроводной сети, как трафик от Raspberry Pi
Весь входящий трафик будет поступать на Raspberry Pi и перенаправляться клиенту беспроводной сети
Добавляем новое правило в файервол Raspberry Pi:

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
Сохраняем правило при помощи netfilter-persistent, чтобы оно не сбросилось при перезагрузке.

sudo netfilter-persistent save
Настройки файервола хранятся здесь - /etc/iptables/. Не забывайте использовать netfilter-persistent при внесении изменений в правила файервола.

Настройка DHCP и DNS для беспроводной сети
Службы DHCP и DNS предоставляются пакетом dnsmasq. В стандартном конфиге dnsmasq содержатся примеры всех возможных настроек, нам нужны только некоторые, поэтому проще создать конфиг с нуля. На всякий случай сохраняем старый конфиг и создаём новый с таким же именем:

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo nano /etc/dnsmasq.conf
Прописываем настройки в конфиг:

interface=wlan0 # Listening interface
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
# Pool of IP addresses served via DHCP
domain=wlan     # Local wireless DNS domain
address=/gw.wlan/192.168.4.1
# Alias for this router
Raspberry Pi будет выделять клиентам IP-адреса в диапазоне 192.168.4.2-192.168.4.20

Клиенты могут обращаться к RaspberryPi по доменному имени gw.wlan

В разных странах действуют свои телекоммуникационные правила и разрешённые для радиопередачи диапазоны. Операционная система Linux помогает пользователям выполнять эти правила

В операционной системе Raspberry Pi OS работа беспроводной сети в диапазоне 5GHz запрещена до тех пор, пока пользователь не внесёт в настройках двухбуквенный код страны (RU для России).

Настройка ПО
Чтобы убедиться, что работа Wi-Fi не заблокирована выполните команду

sudo rfkill unblock wlan
Далее создадим конфиг hostpad ( /etc/hostapd/hostapd.conf) и пропишем в него настройки:

country_code=RU
interface=wlan0
ssid=NameOfNetwork
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=AardvarkBadgerHedgehog
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
Обратите внимание, что имя сети (параметр ssid) и пароль (параметр wpa_passphrase) не должны содержать кавычек. Пароль должен иметь длину от 6 до 64 символов

Указание кода страны позволяет Raspberry Pi использовать для передачи данных разрешённые в этой стране частоты.

Чтобы использовать для передачи данных диапазон 5 GHz, нужно поменять параметр hw_mode=g на hw_mode=a. Возможные значения параметра hw_mode:

a = IEEE 802.11a (5 GHz) (доступно начиная с модели Raspberry Pi 3B+)
b = IEEE 802.11b (2.4 GHz)&amp;amp;amp;amp;amp;lt;br&amp;amp;amp;amp;amp;gt;
g = IEEE 802.11b (2.4 GHz)
После смены режима hw_mode, возможно потребуется и смена номера канала (параметр channel)
