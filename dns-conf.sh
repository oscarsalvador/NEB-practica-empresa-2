#!/bin/bash

RESOLV_CONF="nameserver 127.0.0.1\noptions edns0 trust-ad"
if ! grep -qzP "$RESOLV_CONF" /etc/resolv.conf; then
	echo -e $RESOLV_CONF | sudo tee -a /etc/resolv.conf
fi


NETWORK_MANAGER_CONF="[main]\ndns=dnsmasq"
echo -e $NETWORK_MANAGER_CONF
if ! grep -qzP "$NETWORK_MANAGER_CONF" /etc/NetworkManager/NetworkManager.conf; then
	echo -e "$NETWORK_MANAGER_CONF" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
fi

