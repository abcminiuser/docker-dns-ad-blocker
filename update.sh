#!/bin/sh

# Download latest blocklist
curl -k -o /etc/hosts.dnsmasq.new "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

# Compare the remote blocklist to the local blocklist
cmp -s /etc/hosts.dnsmasq.new /etc/hosts.dnsmasq
if [[ $? != 0 ]] ; then
  # Replace hosts file with the updated list
  mv /etc/hosts.dnsmasq.new /etc/hosts.dnsmasq

  # Kill the main process. Docker will bring back up the container when restart=always is set.
  pkill dnsmasq
fi
