#!/bin/sh

REMOTE_BLOCKLIST_URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

BLOCKLIST_TEMP_FILE="/etc/hosts.dnsmasq.new"

BLOCKLIST_TARGET_FILE="/etc/hosts.dnsmasq"
BLOCKLIST_TARGET_FILE_IPV6="/etc/hosts_ipv6.dnsmasq"

# Download latest blocklist
echo "Fetching latest blocklist..."
curl -k -o $BLOCKLIST_TEMP_FILE $REMOTE_BLOCKLIST_URL
echo "Received blocklist, $(grep "^0" $BLOCKLIST_TEMP_FILE | wc -l) entries."

# Compare the remote blocklist to the local blocklist
cmp -s $BLOCKLIST_TEMP_FILE $BLOCKLIST_TARGET_FILE
if [[ $? != 0 ]] ; then
  echo "Local blocklist is out of date, updating local lists and restarting..."

  # Replace hosts file with the updated list
  mv $BLOCKLIST_TEMP_FILE $BLOCKLIST_TARGET_FILE

  # Convert ipv4 host blocking entries into additional ipv6 blocking entries
  sort $BLOCKLIST_TARGET_FILE | uniq | grep "^0" | sed "s/0\.0\.0\.0/::/g" > $BLOCKLIST_TARGET_FILE_IPV6

  # Kill the main process. Docker will bring back up the container when restart=always is set.
  pkill dnsmasq
else
  echo "Local blocklist is up to date."
fi
