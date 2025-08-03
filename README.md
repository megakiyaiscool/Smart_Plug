# Smart_Plug.sh
  cli smart plug monitor for Open BK7231N firmware with power monitoring. ( https://github.com/openshwprojects/OpenBK7231T_App/releases )
  ## Summary:

- The script spawns a background shell that invokes `mosquitto_sub` and creates an in memory directory structure of the "$_BROKER" "$_TOPIC".
- The foreground process iterates over the directory structure and presents the current state of the smart plug while waiting for input to toggle the switch on/off.
  
<img width="716" height="370" alt="Smart_Plug sh" src="https://github.com/user-attachments/assets/f712cab1-9abd-4ee3-904c-1e7e95b2315e" />

## Dependencys:
- A smart plug connected to a mosquitto server
  - server ref : ( https://mosquitto.org/download/ )
  - mqtt protocol ref: ( https://www.hivemq.com/blog/mqtt-essentials-part-1-introducing-mqtt/ )
  - firmware ref : ( https://github.com/openshwprojects/OpenBK7231T_App )
  ```
  sudo apt install mosquitto
  ```
- mosquitto client
  ```
  sudo apt install mosquitto-clients
  ```
- $XDG_RUNTIME_DIR
  ```
  echo "$XDG_RUNTIME_DIR"
  ```
  "/run/users/????" ... should be set up by systemd ?

## Usage:
Smart_Plug.sh -u [USERNAME] -p [PASSWORD] -h [MQTT HOST] -t [TOPIC] -r [REFRESH INTERVAL]

Or edit the variables at the top of the shell script and just call Smart_Plug.sh on its own.
```
_BROKER="MQTT server IP address"
_TOPIC="Sometimes called the client/base topic"
_USERNAME="MQTT server username"
_PASSWORD="MQTT server password"
_TIMEOUT="Seconds to wait between refreshes"
```

## Tested with:

- Smart Plug
    - Rpi-3b+ for Uart connection to CB2S module 
    - Model: WH_AU_ME_01
    - Firmware: Built on Jul 31 2025 06:25:31 version 1.18.144
        - File: OpenBK7231N_1.18.144.rbl ( OTA )
        - CB2S module removed from board to program with
        ```
        python uartprogram OpenBK7231N_QIO_1.18.141.bin -u -b 115200 -d /dev/serial0  -w -s 0x0
        ```
        - ref: (https://zorruno.com/2022/zemismart-ks-811-with-openbk7231n-openbeken/)
        - OTA flash to latest firmware then connect to. (http://192.168.4.1/index) to configure
        - https://www.elektroda.com/rtvforum/topic3951016.html

- Smart Plug starup command
  `backlog startDriver NTP; SetupEnergyStats 1 60 60;addRepeatingEvent 60 -1 publishChannel 1;PowerSave 1;`

  Template:
[WH_AU_ME_01.json](https://github.com/user-attachments/files/21564964/WH_AU_ME_01.json)
```
{
  "vendor": "Tuya",
  "bDetailed": "0",
  "name": "Smart Plug 16A",
  "model": "WH_AU_ME_01",
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

