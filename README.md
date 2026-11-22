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
Task 1 - Build the local network lab
    - Start the lab with `docker compose up -d --build`
    - Check the lab is running with `docker compose ps` and `docker network inspect hw4_hw4net`
    - Run the mock skill with the exact trigger with `docker compose exec agent-node /app/mock_skill.sh exfiltrate-course-file`
    - Compare the fake secret with the data received by mock-c2 with `docker compose exec mock-c2 cat /data/received.bin` and `cat fake_secrets.txt`
Task 2 - Scan, capture, and reconstruct the event
    - Start the listener in agent-node with `docker compose exec agent-node /app/mock_skill.sh`
    - Scan IP address 172.30.0.10 with `sudo nmap -sT -p 9009 172.30.0.10`
    - Start a packet capture with `sudo tcpdump -i br-hw4 -s 0 -w hw4-malicious.pcap 'net 172.30.0.0/24'`
    - Reproduce the incident from a second terminal with `docker compose exec agent-node cur http://172.30.0.40:8000/adversarial.html` and then `docker compose exec agent-node /app/mock_skill.sh exfiltrate-course-file`
    - Use TShark commands to understand what happened
    - Start another packet capture with the same command as above
    - Request the benign page with `docker compose exec agent-node curl http://172.30.0.40:8000/benign.html`
Task 3 - Default-deny egress for the agent container
Task 4 - Three Suricata rules
