Homework 4: Detect and Block Agent Exfiltration

This README has the setup, files and main commands used

Setup of VM and Required Tools:
- Start Oracle VirtualBox
- Go to HW4 folder: 
cd ~/csce465-agentsec/hw4
- Install the required tools:
    - Install Docker Engine and Docker Compose from Docker's Ubuntu repository:
        - sudo apt remove -y docker.io docker-compose docker-compose-v2 containerd runc 2>/dev/null || true
        - sudo install -m 0755 -d /etc/apt/keyrings
        - sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        - sudo chmod a+r /etc/apt/keyrings/docker.asc
        - sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF_DOCKER
          Types: deb
          URIs: https://download.docker.com/linux/ubuntu
          Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
          Components: stable
          Architectures: $(dpkg --print-architecture)
          Signed-By: /etc/apt/keyrings/docker.asc
          EOF_DOCKER
        - sudo apt update
        - sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        - sudo usermod -aG docker "$USER"

    - Install the packet tools and Suricata:
        - sudo apt install -y nmap tcpdump tshark netcat-openbsd
        - sudo add-apt-repository -y ppa:oisf/suricata-stable
        - sudo apt update
        - sudo apt install -y suricata
        - sudo usermod -aG suricata "$USER"
- Verify the tools:
Log out and log back in for group membership to take effect
Run:
    -  docker run --rm hello-world
    -  docker compose version
    -  nmap --version
    -  tshark --version
    -  suricata -V

Assignment Files:
- HW4 folder contains
    - report.pdf
    - README.md
    - AI_USAGE_KARLA_S.md
    - AI_LOGS_KARLA_S.md
    - AI_LOGS_MELISSA_O.md
    - AI_USAGE_MELISSA_O.md
    - Dockerfile
    - c2.py
    - docker-compose.yml
    - fake_secrets.txt
    - firewall.sh
    - firewall-reset.sh
    - hw4-clean.pcap
    - hw4-malicious.pcap
    - local.rules
    - mock_skill.sh
    - web/
    - objs/
    - __pycache__/
- The web/ folder contains
    - adversarial.html
    - benign.html
- The objs/ folder contains
    - %2f
    - adversarial.html
- The __pycache__/ folder contains
    - c2.cpython-312.pyc
    
    
Assignment Task Commands
- Task 1: Build the local network lab
    - Start the lab with `docker compose up -d --build`
    - Check the lab is running with `docker compose ps` and `docker network inspect hw4_hw4net`
    - Run the mock skill with the exact trigger with `docker compose exec agent-node /app/mock_skill.sh exfiltrate-course-file`
    - Compare the fake secret with the data received by mock-c2 with `docker compose exec mock-c2 cat /data/received.bin` and `cat fake_secrets.txt`
- Task 2: Scan, capture, and reconstruct the event
    - Start the listener in agent-node with `docker compose exec agent-node /app/mock_skill.sh`
    - Scan IP address 172.30.0.10 with `sudo nmap -sT -p 9009 172.30.0.10`
    - Start a packet capture with `sudo tcpdump -i br-hw4 -s 0 -w hw4-malicious.pcap 'net 172.30.0.0/24'`
    - Reproduce the incident from a second terminal with `docker compose exec agent-node cur http://172.30.0.40:8000/adversarial.html` and then `docker compose exec agent-node /app/mock_skill.sh exfiltrate-course-file`
    - Use TShark commands to understand what happened
    - Start another packet capture with the same command as above
    - Request the benign page with `docker compose exec agent-node curl http://172.30.0.40:8000/benign.html`
- Task 3: Default-deny egress for the agent container
    - Apply the firewall from the VM with `sudo bash firewall.sh`. This filters traffic on the Docker bridge through `HW4-EGRESS`.
    - Test 1. Fetch the benign page with `docker compose exec agent-node curl --max-time 5 -sS -o /dev/null -w 'HTTP %{http_code}\n' http://172.30.0.40:8000/benign.html`. Expect HTTP 200.
    - Test 2. Save the receiver’s starting state with `docker compose exec mock-c2 stat /data/received.bin`. Run `docker compose exec -w /app agent-node timeout -v 15s /app/mock_skill.sh exfiltrate-course-file`, then repeat the same `stat` command. Save both outputs. The attempt should time out, and the file should stay absent or keep its earlier modification time.
    - Test 3. Try the unapproved web-lab port with `docker compose exec agent-node curl --max-time 5 -sS http://172.30.0.40:8080/`. Expect a connection timeout.
    - Test 4. Connect to the agent from the VM with `nc -nv -w 5 172.30.0.10 9009`. Expect `Mock listener connected`. If the listener has stopped, restart it with `docker compose exec -d -w /app agent-node /app/mock_skill.sh` and repeat the check.
    - Test 5. Send an empty POST from web-lab with `docker compose exec web-lab curl --max-time 5 -sS -o /dev/null -w 'HTTP %{http_code}\n' --data '' http://172.30.0.66:8080/`. Expect HTTP 204. Run this last because the POST writes to `/data/received.bin`.
    - Save the packet counters with `sudo iptables-nft -nvxL HW4-EGRESS --line-numbers` and the kernel log with `sudo journalctl -k -b --no-pager | grep 'HW4-C2-DROP:'`. The log should show the agent at `172.30.0.10` trying to reach `172.30.0.66` on TCP 8080.
    - Remove the lab firewall rules after saving the evidence with `sudo bash firewall-reset.sh`.
- Task 4: Three Suricata rules
    - Show the three rules and their SIDs with `cat -n local.rules`.
    - Create the two output folders with `mkdir -p suricata-malicious suricata-clean`. Start with empty output folders for each run so old alerts are not counted twice.
    - Check the malicious capture with `suricata -k none -r hw4-malicious.pcap -S local.rules -l suricata-malicious`. This runs only the three lab rules and skips checksum validation for the Docker bridge capture.
    - Check the clean capture with `suricata -k none -r hw4-clean.pcap -S local.rules -l suricata-clean` so the same rules are tested against benign traffic.
    - Save the malicious alerts with a screenshot of `cat suricata-malicious/fast.log`. Our run showed one alert each for the course marker (SID 1000002), the connection attempt (SID 1000003), and the fake token (SID 1000001).
    - Save the clean result with a screenshot of `wc -l suricata-clean/fast.log`. Our run returned 0 lines. That gives each rule a true positive on the malicious capture and a true negative on the clean capture.

## Task 1 and 2 command notes

Run the commands from the VM folder that contains `docker-compose.yml`. Before applying the firewall, compare the SHA-256 hashes of the original file and the file mock-c2 received. The two hashes should match.

```bash
sha256sum fake_secrets.txt
docker compose exec mock-c2 sha256sum /data/received.bin
```

In the Task 2 fetch command above, the command name is `curl`. If you are recording the clean capture again, save it under its own name. Start the command below, request `benign.html` from a second terminal, then press Ctrl+C in the capture terminal. The two `.pcap` files already in the repo can be used directly for Task 4.

```bash
sudo tcpdump -i br-hw4 -s 0 -w hw4-clean.pcap 'net 172.30.0.0/24'
```

To reconstruct the transfer from the saved capture, list the HTTP requests and identify the POST to `172.30.0.66:8080`. The last column is its TCP stream number.

```bash
tshark -r hw4-malicious.pcap -Y 'http.request' -T fields \
  -e ip.src -e tcp.srcport -e ip.dst -e tcp.dstport \
  -e http.request.method -e http.request.uri -e tcp.stream
```

Replace `N` below with that stream number. The first command shows the token in the POST. The first and last lines of the second command give the stream's start and end times. The last command converts TShark's hex output back to bytes before hashing the POST body.

```bash
tshark -r hw4-malicious.pcap -q -z follow,tcp,ascii,N
tshark -r hw4-malicious.pcap -Y 'tcp.stream == N' -T fields -e frame.time
tshark -r hw4-malicious.pcap -Y 'tcp.stream == N && http.request.method == "POST"' \
  -T fields -e http.file_data | xxd -r -p | sha256sum
```

## Task 5 — Incident summary

Task 5 uses the evidence already collected. In `report.pdf`, use the Task 2 packet timestamps and Task 4 alerts to trace the incident from trigger to POST. Use the Task 3 evidence to explain what changed once the firewall was active. Keep the summary to one page and identify the affected assets, trust boundaries crossed, which preventive controls worked or failed, which detections fired, and two improvements in priority order.
