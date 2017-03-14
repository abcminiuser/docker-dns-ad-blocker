#!/bin/sh

# Download latest blocklist
curl -k -o /etc/hosts.dnsmasq.new "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
sha256sum /etc/hosts.dnsmasq.new > /etc/hosts.dnsmasq.new.sha256

# Compare the remote checksum to the local file
sha256sum -c /etc/hosts.dnsmasq.new.sha256 /etc/hosts.dnsmasq
if [[ $? != 0 ]] ; then
  # Kill the main process. Docker will bring back up the container when restart=always is set.
  pkill dnsmasq
fi
