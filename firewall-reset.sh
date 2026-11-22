#!/usr/bin/env bash
set -euo pipefail

# Same lock as firewall.sh
exec 9>/run/lock/hw4-egress.lock
flock -x 9

rules=$(iptables-nft -w -S)
if grep -Fxq -- '-N HW4-EGRESS' <<< "$rules"; then
    # Remove the jump before deleting the lab chain
    while iptables-nft -w -C DOCKER-USER -j HW4-EGRESS 2>/dev/null; do
        iptables-nft -w -D DOCKER-USER -j HW4-EGRESS
    done
    iptables-nft -w -F HW4-EGRESS
    iptables-nft -w -X HW4-EGRESS
fi
