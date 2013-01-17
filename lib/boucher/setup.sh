#! /bin/bash -

# usage:
# setup.sh <hostname>
# uses hostname to find IP information
# sets up all of networking
# reboots

INTERFACES_FILE="/etc/network/interfaces"
HOSTS_FILE="/etc/hosts"
HOSTNAME_FILE="/etc/hostname"
RESOLV_CONF_FILE="/etc/resolv.conf"

#ROLE=$1
HOSTNAME=$1
IP_ADDR=$( host "$HOSTNAME" | grep "has address" | sed -e 's%^.*has address \(\.*\)%\1%' )

if [[ $? != 0 || -z $IP_ADDR ]]; then
  echo "no way... got bad data and shit."
  exit 1
fi

# FIXME: these should be inserted dynamically by Souce from its config.
ROUTER_SUFFIX="1"
DNS_SERVER_SUFFIX="11"
DOMAIN="tedc.co"

# get environment from hostname
SHORT_HOSTNAME=$( echo $HOSTNAME | sed -e 's%^\(.\+\)\..\+$%\1%' )
ENVIRONMENT=$( echo $HOSTNAME | sed -e 's%^.*\.\(.\+\)%\1%' )

# get ROUTER_ADDR
# get DNS_SERVER_ADDR
BASE_ADDR=$( echo $IP_ADDR | sed -e 's%^\(.\+\)\..\+$%\1%' )
ROUTER_ADDR="${BASE_ADDR}.$ROUTER_SUFFIX"
DNS_SERVER_ADDR="${BASE_ADDR}.$DNS_SERVER_SUFFIX"

# configure network (build /etc/network/interfaces)
echo "# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
  address $IP_ADDR
  gateway $ROUTER_ADDR
  netmask 255.255.255.0
  dns-nameservers $DNS_SERVER_ADDR
  dns-search ${ENVIRONMENT}.${DOMAIN} $DOMAIN
" > $INTERFACES_FILE

# configure /etc/hostname
echo "$HOSTNAME" > $HOSTNAME_FILE

# configure /etc/hosts
echo "$IP_ADDR  ${HOSTNAME}.${DOMAIN} $HOSTNAME $SHORT_HOSTNAME" >> $HOSTS_FILE

# reboot
reboot

