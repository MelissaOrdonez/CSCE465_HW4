#!/usr/bin/env bash
set -euo pipefail

# iptables filtering for traffic on the Docker bridge
modprobe br_netfilter
sysctl -w net.bridge.bridge-nf-call-iptables=1

agent=172.30.0.10
web=172.30.0.40
mock_c2=172.30.0.66

# one firewall update at a time
exec 9>/run/lock/hw4-egress.lock
flock -x 9

# DOCKER-USER required for the lab rules
iptables-nft -w -S DOCKER-USER >/dev/null

# one update for all rules in HW4-EGRESS
iptables-nft-restore --wait --noflush <<RULES
*filter
:HW4-EGRESS - [0:0]
# established or related traffic to and from agent-node -> allow
-A HW4-EGRESS -s $agent -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A HW4-EGRESS -d $agent -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# New connection from agent-node to web-lab:8000 -> allow either page
-A HW4-EGRESS -s $agent -d $web -p tcp --dport 8000 -m conntrack --ctstate NEW -j ACCEPT
# new connection from agent-node to mock-c2:8080 -> log first, then drop
-A HW4-EGRESS -s $agent -d $mock_c2 -p tcp --dport 8080 -m conntrack --ctstate NEW -j LOG --log-prefix "HW4-C2-DROP: "
-A HW4-EGRESS -s $agent -d $mock_c2 -p tcp --dport 8080 -m conntrack --ctstate NEW -j DROP
# any other new connection from agent-node -> drop, even the right IP on the wrong port
-A HW4-EGRESS -s $agent -m conntrack --ctstate NEW -j DROP
# unrelated traffic, including web-lab to mock-c2 -> back to Docker
-A HW4-EGRESS -j RETURN
COMMIT
RULES

# one jump from DOCKER-USER to the lab rules
if ! iptables-nft -w -C DOCKER-USER -j HW4-EGRESS 2>/dev/null; then
    iptables-nft -w -I DOCKER-USER 1 -j HW4-EGRESS
fi

