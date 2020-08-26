#!/usr/bin/env bash

declare -a adLists_enabled=(
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/facebook/all-but-whatsapp
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/facebook/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/microsoft/all
https://mirror1.malwaredomains.com/files/justdomains
https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://raw.githubusercontent.com/durablenapkin/scamblocklist/master/hosts.txt
https://gitlab.com/ookangzheng/dbl-oisd-nl/raw/master/dbl.txt
https://sysctl.org/cameleon/hosts
https://block.energized.pro/ultimate/formats/hosts.txt
)

declare -a adLists_disabled=(
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/google/localized
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/google/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/amazon/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/apple/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/cloudflare/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/mozilla/all
https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/pinterest/all
)

# Set empty password. Authentication will be provided by IDP
echo " " | pihole -a -p
# Clear all Ad lists
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist"

# Add Ad lists and mark them enabled
for i in ${adLists_enabled[@]}; do
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address,enabled) VALUES ('$i', 1)";
done

# Add Ad lists and mark them disabled
for i in ${adLists_disabled[@]}; do
    sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address,enabled) VALUES ('$i', 0)";
done

# Update blacklists
pihole -g

# Restart DNS Resolver
pihole restartdns

# Restart
service pihole-FTL restart