#!/bin/zsh

INSTANCES=$(ps axo command | grep -v grep | grep fortiRepair.sh | wc -l)

if [ $INSTANCES -gt 3 ]
then
	echo "Exiting... Found running fortiRepair instance..."
	echo "!!! FINISHED !!!"
#	exit
fi


# ROUTES_FILE should be located next to this script
ROUTES_FILE="routes.list"

PURPLE="\x1b[1;35m"
NORMAL="\x1b[0m"

# FortiClient change hostname. Set the hostanme here, you wish to have after repair
#HOSTNAME="mbatet.local"

NETREQUIRED="APOLLO-TET"

echo "\nChecking if TET forticlient connected..."

# Exit on any error
set -e

MYIP=$(curl -s https://ifconfig.me)
MYNET=$(whois $MYIP | grep ^netname | awk '{ print $2 }')

IFACE=$(netstat -nr -f inet | grep "utun" | wc -l)

UTUNIPCOUNT=$(ifconfig | grep "inet " | grep "netmask 0xffffffff" | awk '{ print $2 }' | grep "^10.2.\|^10.23." | wc -l)

if [[ ("$MYNET" = "$NETREQUIRED") && ( $IFACE -gt 0 ) && ( $UTUNIPCOUNT -gt 0 ) ]]
then
else
	printf "$PURPLE""No connection detected or modifications not required!""$NORMAL\n\n"
	exit
fi

if [[ $(netstat -nr -f inet | grep "^default" | awk '{ print $2 }' | uniq | wc -l) -eq 1 ]]
then
	printf "$PURPLE""Modifications not required!""$NORMAL\n\n"
	exit
fi

#if [[ ( $(hostname -f) != "$HOSTNAME") ]]
#then
#	printf "$PURPLE""Setting hostname to \"$HOSTNAME\" ...""$NORMAL\n\n"
#	scutil --set HostName "$HOSTNAME"
#	exit
#fi

printf "$PURPLE""Your public IP before modifications: $MYIP ($MYNET)""$NORMAL\n"

INITIAL_GW=$(netstat -nr -f inet | grep "^default" | grep -v "utun" | awk '{ print $2 }')
CURRENT_GW=$(netstat -nr -f inet | grep "^default" | grep -v "$INITIAL_GW" | awk '{print $4}')

echo "Deleting default route through \"$CURRENT_GW\" ...\n"
route delete default > /dev/null
route add default $INITIAL_GW > /dev/null

# Adding routes
for r in $(cat $(dirname $0)/$ROUTES_FILE   | \
                awk NF | \
                awk '{ print $1 }' | \
                grep -v ^# | \
                sort)
do
        echo "Adding route $r ..."
        route add $r -interface $CURRENT_GW > /dev/null
done

MESSAGE="Your public IP before modifications:\n$MYIP\n$MYNET"
printf "\n$PURPLE""Your public IP before modifications: $MYIP ($MYNET)""$NORMAL\n"

MYIP=$(curl -s https://ifconfig.me)
MYNET=$(whois $MYIP | grep ^netname | awk '{ print $2 }')
MESSAGE="Your public IP after modifications:\n$MYIP\n$MYNET\n\n$MESSAGE"
printf "$PURPLE""Your public IP after modifications: $MYIP ($MYNET)""$NORMAL\n\n"

printf "$PURPLE""FINISHED! SUCCESS!""$NORMAL\n\n"

osascript -e "display alert \"Routings table was processed!\n\n$MESSAGE\" giving up after 30"