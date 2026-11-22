Homework 4: Detect and Block Agent Exfiltration

This README has the setup, files and main commands used

Setup of VM and Required Tools:
- Start Oracle VirtualBox
- Go to HW4 folder: 
cd ~/csce465-agentsec/hw4
- Install the required tools:


- Verify the tools:


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
