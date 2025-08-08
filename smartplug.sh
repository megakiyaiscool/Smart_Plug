#!/bin/bash

trap cleanup 1 2 3 6 15

cleanup(){
    echo "Removing temporary files:"
    pkill -P "$(cat BASHPID)"
    cd "$XDG_RUNTIME_DIR"
    rm -rf "$WORKING_DIR"
    exit 0
}

usage(){
echo -e "smartplug.sh

    Usage:

    smartplug.sh -u [USERNAME] -p [PASSWORD] -h [MQTT HOST] -t [TOPIC] -r [REFRESH INTERVAL]
    smartplug.sh -c [FILE] -t [TOPIC] -r [REFRESH INTERVAL]
    smartplug.sh -c [FILE]

    -u  [USERNAME]
            Mosquitto server username.

    -p  [PASSWORD]

            Mosquitto server password.
    -h  [MQTT HOST]
            Mosquitto server hostname or IP address.

    -t  [TOPIC]
            Mosquitto server topic to subscribe to.

    -r  [REFRESH INTERVAL]
            Number of seconds between updates to the frontend. Also the interval
            between changing the switch state and updating the status ( round trip time ).
            If left unset will default to 10 seconds

    -c  [FILE]
            Configuration file
" 1>&2; exit 1;
}

while getopts ":c:h:u:p:r:t:" opt; do
    case ${opt} in
    t)
        _TOPIC="${OPTARG}"
        ;;
    h)
        _BROKER="${OPTARG}"
        ;;
    u)
        _USERNAME="${OPTARG}"
        ;;
    p)
        _PASSWORD="${OPTARG}"
        ;;
    r)
        _REFRESH="${OPTARG}"
        ;;
    c)
        . "${OPTARG}"
        ;;
    agt)
        _AGT="${OPTARG}"
        ;;
    alt)
        _ALT="${OPTARG}"
        ;;
    *)
        usage
        ;;
esac
done

if [ -z "$_REFRESH" ]; then
    _REFRESH=10
fi

mosquitto_sub -h "$_BROKER" -u "$_USERNAME" -P "$_PASSWORD" -t "$_TOPIC/#" -C 1 -W "$_REFRESH" || usage

WORKING_DIR=$( mktemp -d --tmpdir="$XDG_RUNTIME_DIR" )
cd "$WORKING_DIR"

# Spawn background process.
(
echo "$BASHPID">BASHPID
mosquitto_sub -h "$_BROKER" -u "$_USERNAME" -P "$_PASSWORD" -v -t "$_TOPIC/#" | \

while read i;
do
    declare -a ARRAY=($i)
    mkdir -p "${ARRAY[0]}"
    echo "${ARRAY[1]}">"${ARRAY[0]}/value"
done
) &

# Read a "normal" value from the subshe directory.
_mqtt(){
if [ -f "$_TOPIC/$1/get/value" ];then
    VALUE=$( cat "$_TOPIC/$1/get/value" )
    else
    VALUE="\e[0;37mWaiting\e[1;37m"
fi
echo "$1:$VALUE"
}

# Reports the actual switch status.
_status(){
if [ -f "$_TOPIC/$1/get/value" ];then
    STATUS=$( cat "$_TOPIC/$1/get/value" )
    if [ "$STATUS" == "1" ]; then
        STATUS="\e[1;32mON\e[1;37m"
    elif [ "$STATUS" == "0" ]; then
        STATUS="\e[0;31mOFF\e[1;37m"
    fi
else
    STATUS="\e[0;37mWaiting\e[1;37m"
fi
echo -e "status:$STATUS"
}

# Formats the date so that it doesnt get mangled by | column.
_date(){
if [ -f "$_TOPIC/$1/get/value" ];then
    VALUE=$( date -d $( cat "$_TOPIC/$1/get/value" ) )
    else
    VALUE="\e[0;37mWaiting\e[1;37m"
fi
echo "$1%$VALUE"
}

_check(){
if [ -f "$_TOPIC/current/get/value" ]; then
    CURRENT=$( cat "$_TOPIC/current/get/value" )
    if (( $( echo "$CURRENT > $_AGT" | bc ) )) ; then
        _alarm "\e[0;31m$CURRENT\e[1;37m"
    fi
    if (( $( echo "$CURRENT < $_ALT" | bc ) )) ; then
        _alarm "\e[0;31m$CURRENT\e[1;37m"
    fi   
else
    CURRENT="\e[0;37mWaiting\e[1;37m"
    ALARM="$_ALT > $CURRENT > $_AGT"
fi
}

_alarm(){
ALARM="$_ALT > \e[0;31m$CURRENT\e[1;37m > $_AGT"
}

# Construct and format the page.
_report(){
echo -e "\e[0;37m              "$(date)"\n"
echo -e "MQTT HOST%$_BROKER\nMQTT TOPIC%$_TOPIC\n$ED%%" | column -t -s '%'
echo -e "\e[1;37m"
echo -e "$( cat "$_TOPIC/connected/value" 2>/dev/null ) ... update interval "$_REFRESH sec"\n"
echo -e "$S::$ALARM\n$V::$E\n$C::$EH\n$P::$ET\n:::\n$PA::$EY\n$PR::$E2\n$PF::$E3\n" | column -t -s ':'
echo ""
}

# Call for the variables that we want in the page.
_get(){
O=$( _mqtt connected )
S=$( _status 1 )
V=$( _mqtt voltage )
C=$( _mqtt current )
P=$( _mqtt power )
PA=$( _mqtt power_apparent )
PR=$( _mqtt power_reactive )
PF=$( _mqtt power_factor )

ED=$( _date energycounter_clear_date )

E=$( _mqtt energycounter )
EH=$( _mqtt energycounter_last_hour )
ET=$( _mqtt energycounter_today )
EY=$( _mqtt energycounter_yesterday )
E2=$( _mqtt energycounter_2_days_ago )
E3=$( _mqtt energycounter_3_days_ago )
}

# Main loop
while [ true ];do
    clear
    _get
    _check
    _report
    echo -e -n " \e[0;37mHit \e[1;37m[ENTER]\e[0;37m to toggle switch ON/OFF    \e[1;37m[Ctrl+C]\e[0;37m to exit"
    read -t "$_REFRESH"
    ERROR=$?
    if [ "$ERROR" -eq "0" ];then
        if [ "$( cat "$_TOPIC/1/get/value" 2>&1 )" == "1" ];then
            echo -e "\nsending switch off ...."
            mosquitto_pub -h "$_BROKER" -u "$_USERNAME" -P "$_PASSWORD" -t "$_TOPIC/1/set" -m 0
        else
            echo -e "\nsending switch on ...."
            mosquitto_pub -h "$_BROKER" -u "$_USERNAME" -P "$_PASSWORD" -t "$_TOPIC/1/set" -m 1
        fi
        sleep "$_REFRESH"
    fi
    ALARM="$_ALT > $CURRENT > $_AGT"
done

exit 0

