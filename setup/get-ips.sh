#!/bin/sh
# Prints just the ip addresses for given interfaces.

usage()
{
    echo "$(basename $0): get the ip address of an interface"
    echo
    echo "OPTIONS:"
    echo "-h 	display help message"
    echo "-i 	display interface name with IP address"
}

get_ip()
{
    for int in $@
    do
        # Do not process the "-i" flag if present. There has to be a cleaner
        # way of handling this, but oh well.
        if [ $int != "-i" ]; then
            if [ "$show_interfaces" ]; then
                echo -n $int
                echo -n ': '
            fi
            
            ip addr show $int | grep -m 1 inet | awk '{print $2}' | cut -d / -f 1
        fi
    done
}

while getopts ":hi" opt; do
    case $opt in
        h)	usage
        exit;;
        i)  	show_interfaces=1;;
        ?) 	echo "Invalid option: -${OPTARG}"
            usage
        exit;;
    esac
done

# The option index (OPTIND) needs to be reset for "./get-ip.sh -i" to display
# eth0 as the default index
shift $(($OPTIND - 1))

if [ -z "$*" ]; then
    interface=eth0
else
    interface="$*"
fi

get_ip $interface
