Homework 4: Detect and Block Agent Exfiltration

This README has the setup, files and main commands used

Setup of VM and Required Tools:
- Start Oracle VirtualBox
- Go to HW4 folder: 
cd ~/csce465-agentsec/hw4
- Install the required tools:
Install Docker Engine and Docker Compose from Docker's Ubuntu repository:
sudo apt remove -y docker.io docker-compose docker-compose-v2 \
containerd runc 2>/dev/null || true
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF_DOCKER
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF_DOCKER
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"

Install the packet tools and Suricata:
sudo apt install -y nmap tcpdump tshark netcat-openbsd
sudo add-apt-repository -y ppa:oisf/suricata-stable
sudo apt update
sudo apt install -y suricata
sudo usermod -aG suricata "$USER"
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
    
    
Assignment Tasks
Task 1 - Build the local network lab
Task 2 - Scan, capture, and reconstruct the event
Task 3 - Default-deny egress for the agent container
Task 4 - Three Suricata rules
Task 5 - Incident Summary
