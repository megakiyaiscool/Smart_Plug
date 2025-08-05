## smartplug.sh
  command line smart plug monitor for Open BK7231N firmware with power monitoring. ( https://github.com/openshwprojects/OpenBK7231T_App/releases )
## SYNOPSIS:
smartplug.sh -u [USERNAME] -p [PASSWORD] -h [MQTT HOST] -t [TOPIC] -r [REFRESH INTERVAL] \
smartplug.sh -c [FILE] -t [TOPIC] -r [REFRESH INTERVAL] \
smartplug.sh -c [FILE]
## DESCRIPTION:
- smartplug.sh spawns a background shell that invokes `mosquitto_sub` and creates an in memory directory structure of the "$_BROKER" "$_TOPIC".
- The foreground process iterates over the directory structure and presents the current state of the smart plug. [enter] toggles the switch on/off. [ctrl+c} to exit
> [!NOTE]
> Later command line options will overide previous options. So you may connect to different topics by using the -t option after -c smartplug.conf. Or by leaving the $_TOPIC variable unset in the configuration file.
<img alt="Smart_Plug sh" src="Smart_Plug.sh.png" />

## OPTIONS:

-u [USERNAME] - Mosquitto server username. \

-p [PASSWORD] - Mosquitto server password. \

-h [MQTT HOST]- Mosquitto server hostname or IP address. \

-t [TOPIC]    - Mosquitto server topic to subscribe to. \

-r [REFRESH INTERVAL] - Number of seconds between updates to the frontend. Also \
 the interval between changing the switch state and updating the status ( round trip time ). \
If left unset will default to 10 seconds. \

-c [FILE] - Configuration file

### smartplug.conf.example

```
_BROKER="localhost"
_TOPIC="WH_AU_ME_01-Garage"
_USERNAME="roger"
_PASSWORD="RogersSuperSecretPassWord1234"
_REFRESH="2"
```
## EXAMPLES:

```
smartplug.sh -t WH_AU_ME_01-02 -c smartplug.conf
```
```
smartplug.sh -c WH_AU_ME_01.conf
```
```
for file in WH_AU_ME_01*.conf; do gnome-terminal --hide-menubar --geometry=80x24 \
        -t "$file" -- smartplug.sh -c "$file" & done
```
## DEPENDENCIES:

### A smart plug connected to a mosquitto server and mosquitto_sub.
- server ref : ( https://mosquitto.org/download/ )
- mqtt protocol ref: ( https://www.hivemq.com/blog/mqtt-essentials-part-1-introducing-mqtt/ )
- firmware ref : ( https://github.com/openshwprojects/OpenBK7231T_App )
```
  sudo apt install mosquitto mosquitto-clients
```
### A temporary file system in ram.

- $XDG_RUNTIME_DIR
```
  echo "$XDG_RUNTIME_DIR"
```
"/run/user/????" ... should be set up by systemd ?
## Tested with:

- Smart Plug
  - Model: Smart Plug 16A Model:WHDZ01 Board:WH_AU_ME_01
- Firmware: OpenBK7231N_QIO_1.18.141.bin
  - CB2S module removed from board to program with
  - Rpi-3b+ for Uart connection to CB2S module
  - uartprogram (https://zorruno.com/2022/zemismart-ks-811-with-openbk7231n-openbeken/)
  ```
  python uartprogram OpenBK7231N_QIO_1.18.141.bin -u -b 115200 -d /dev/serial0  -w -s 0x0
  ```
  - Connect to. (http://192.168.4.1/index) to configure and OTA flash to latest firmware
  - File: OpenBK7231N_1.18.144.rbl ( OTA ) Built on Jul 31 2025 06:25:31 version 1.18.144
  - forum thread (https://www.elektroda.com/rtvforum/topic3951016.html) with youtube tutorials.

- Smart Plug starup command
```
backlog startDriver NTP; SetupEnergyStats 1 60 60;addRepeatingEvent 60 -1 publishChannel 1;PowerSave 1;
```
> [!NOTE] 
> "addRepeatingEvent 60               -1         publishChannel 1" \
>repeat every 60sec forever send channel 1 to mqtt server
### Template:
[WH_AU_ME_01.json](WH_AU_ME_01.json)
```
{
  "vendor": "Tuya",
  "bDetailed": "0",
  "name": "Smart Plug 16A",
  "model": "WHDZ01",
  "chip": "BK7231N",
  "board": "WH_AU_ME_01",
  "flags": "1024",
  "keywords": [
    "BK7231N",
    "WH_AU_ME_01",
    "WHDZ01"
  ],
  "pins": {
    "6": "BL0937CF1;0",
    "7": "BL0937CF;0",
    "8": "WifiLED_n;0",
    "11": "Btn;1",
    "24": "BL0937SEL;0",
    "26": "Rel;1"
  },
  "command": "backlog startDriver NTP; SetupEnergyStats 1 60 60;addRepeatingEvent 60 -1 publishChannel 1;PowerSave 1;",
  "image": "https://obrazki.elektroda.pl/YOUR_IMAGE.jpg",
  "wiki": "https://www.elektroda.com/rtvforum/topic_YOUR_TOPIC.html"
}
```

