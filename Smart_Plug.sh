#!/bin/bash

_BROKER=""
_TOPIC=""
_USERNAME=""
_PASSWORD=""
_TIMEOUT=""

trap cleanup 1 2 3 6 15

cleanup(){
    echo "Removing temporary files:"
    pkill -P "$(cat BASHPID)"
    cd "$XDG_RUNTIME_DIR"
    rm -rf "$WORKING_DIR"
    exit 0
}

usage() { echo -e "\nUsage: -u [USERNAME] -p [PASSWORD] -h [MQTT HOST] -t [TOPIC] -r [REFRESH INTERVAL]\n" 1>&2; exit 1; 
}

while getopts ":t:h:u:p:r:" opt; do
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
        _TIMEOUT="${OPTARG}"
        ;;
    *)
#        echo "Invalid option: -${OPTARG}."
        usage
        ;;
esac
done

if [ -z "$_TIMEOUT" ]; then
    _TIMEOUT=10
fi

mosquitto_sub -h "$_BROKER" -u "$_USERNAME" -P "$_PASSWORD" -t "$_TOPIC/#" -C 1 -W "$_TIMEOUT" || usage

WORKING_DIR=$( mktemp -d --tmpdir="$XDG_RUNTIME_DIR" )
cd "$WORKING_DIR"

(
echo "$BASHPID">BASHPID
mosquitto_sub -h "$_BROKER" -u "$_USERNAME" -P "$_PASSWORD" -v -t "$_TOPIC/#" | \

while read i;
do
    declare -a ARRAY=($i)
#    echo "length of array is: ${#ARRAY[@]}"
#    echo "line: " "$ARRAY"
    mkdir -p "${ARRAY[0]}"
    echo "${ARRAY[1]}">"${ARRAY[0]}/value"
done
) &

_mqtt(){
if [ -e "$_TOPIC/$1/get/value" ];then
    VALUE=$( cat "$_TOPIC/$1/get/value" )
    else
    VALUE="\e[0;37mWaiting\e[1;37m"
fi
echo "$1:$VALUE"
}

_status(){ 
STATUS=$( cat "$_TOPIC/$1/get/value" 2>&1 )
if [ "$STATUS" == "1" ]; then
    STATUS="\e[1;32mON\e[1;37m"
elif [ "$STATUS" == "0" ]; then
    STATUS="\e[0;31mOFF\e[1;37m"
else
    STATUS="\e[0;37mWaiting\e[1;37m"
fi
echo -e "status:$STATUS"
}

_date(){
if [ -e "$_TOPIC/$1/get/value" ];then
    VALUE=$( date -d $( cat "$_TOPIC/$1/get/value" ) "+%Y-%m-%d %H-%M-%S" )
    else
    VALUE="\e[0;37mWaiting\e[1;37m"
fi
echo "$1:$VALUE"
}

_report(){
echo -e "\e[0;37m"$(date)
echo -e "MQTT IP:$_BROKER\nMQTT TOPIC:$_TOPIC" | column -t -s ':'
echo -e "\e[1;37m"
echo -e "$( cat "$_TOPIC/connected/value" 2>/dev/null ) ... update interval "$_TIMEOUT sec"\n"
echo -e "$S::$ED\n$V::$E\n$C::$EH\n$P::$ET\n:::\n$PA::$EY\n$PR::$E2\n$PF::$E3\n" | column -t -s ':'
echo ""
}

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

while [ true ];do
    clear
    _get
    _report
    read -t "$_TIMEOUT" -p "Hit ENTER to toggle switch ON/OFF"
    ERROR=$?
    if [ "$ERROR" -eq "0" ];then
        if [ "$( cat "$_TOPIC/1/get/value" 2>&1 )" == "1" ];then
            echo -e "\nsending switch off ...."
            mosquitto_pub -h "$_BROKER" -u "$_USERNAME" -P "$_PASSWORD" -t "$_TOPIC/1/set" -m 0
        else
            echo -e "\nsending switch on ...."
            mosquitto_pub -h "$_BROKER" -u "$_USERNAME" -P "$_PASSWORD" -t "$_TOPIC/1/set" -m 1
        fi
        sleep "$_TIMEOUT"
    fi
done

exit 0

