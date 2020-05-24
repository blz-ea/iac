#!/bin/sh
# Reference: https://gist.github.com/tavinus/08a63e7269e0f70d27b8fb86db596f0d

init_error() {
    local ret=1
    [ -z "$1" ] || printf "%s\n" "$1"
    [ -z "$2" ] || ret=$2
    exit $ret
}

# Command to restart PVE Proxy and apply changes
PVEPXYRESTART='systemctl restart pveproxy.service'

# File/folder to be changed
TGTPATH='/usr/share/perl5/PVE/API2'
TGTFILE='Subscription.pm'

# Check dependecies
SEDBIN="$(which sed)"

[ -x "$SEDBIN" ] || init_error "Could not find 'sed' binary, aborting..."

# This will also create a .bak file with the original file contents
sed -i.bak 's/NotFound/Active/g' "$TGTPATH/$TGTFILE" && $PVEPXYRESTART

r=$?
if [ $r -eq 0 ]; then
    printf "%s\n" "All done! Please refresh your browser and test the changes!"
    exit 0
fi

printf "%s\n" "An error was detected! Changes may not have been applied!"
exit 1