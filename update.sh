#!/bin/sh

# Download latest blocklist
curl -k -o /etc/hosts.dnsmasq.new "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

# Compare the remote blocklist to the local blocklist
cmp -s /etc/hosts.dnsmasq.new /etc/hosts.dnsmasq
if [[ $? != 0 ]] ; then
  # Replace hosts file with the updated list
  mv /etc/hosts.dnsmasq.new /etc/hosts.dnsmasq

  # Convert ipv4 host blocking entries into additional ipv6 blocking entries
  sort /etc/hosts.dnsmasq.new | uniq | grep "^0" > /etc/hosts_ipv6.dnsmasq
  sort /etc/hosts.dnsmasq.new | uniq | grep "^0" | sed "s/0\.0\.0\.0/::/g" >> /etc/hosts_ipv6.dnsmasq

  # Kill the main process. Docker will bring back up the container when restart=always is set.
  pkill dnsmasq
fi
