Log entry 1:

Used AI to understand what Docker was doing when I ran hello-world. I wanted to know the difference between the image Docker downloaded and the container it started, since our lab runs three containers inside one Ubuntu VM.

Log entry 2:

Used AI to understand how Suricata could find the fake token in a capture my partner had already recorded. It helped me connect the two tasks. The firewall decides whether the connection goes through, and Suricata reads the saved traffic to see which rules match.

Log entry 3:

I asked whether I had the order of events right. I had mixed up which part reads the adversarial page and which part sends the file. The page gives the instruction, I simulate the agent following it by running the mock skill, and the skill tries to connect to mock-c2. That connection attempt is where my firewall comes in.

Log entry 4:

Used AI to go over the basics of a Bash script. I wanted to understand what the first line does, how Bash treats comments, and how a script reads its first argument through `$1`.

Log entry 5:

I asked how to put terminal commands into a Bash script. The example showed me that I could write the commands in the order I wanted them to run and use `cd practice || exit 1` to stop the script if it couldn't enter the right folder.

Log entry 6:

I gave AI the firewall policy I had worked out and asked for help turning it into `iptables` rules for `firewall.sh`. I used its help with the syntax and rule order, especially allowing established replies, matching both the web-lab IP and port 8000, and logging the mock-c2 attempt before dropping it. I wanted other containers to keep their normal access.

Log entry 7:

After I ran `sudo bash firewall.sh`, I asked what to do with the `net.bridge.bridge-nf-call-iptables = 1` output. That told me bridge filtering was enabled. To check that my allow rule worked, I fetched `benign.html` from agent-node and got HTTP 200 back from web-lab.

Log entry 8:

I asked how to start Test 2 after the benign fetch passed. AI suggested checking `/data/received.bin` on mock-c2 before running the skill. I saved the `stat` output so I could tell whether the attempt actually created a file.

Log entry 9:

I asked how to run the mock skill inside agent-node. My first command used just `mock_skill.sh`, so it failed before it tested the firewall. I switched to `/app/mock_skill.sh`, ran it with a 15-second timeout, and checked the receiver again. The file was still absent.

Log entry 10:

I asked how to pull up the kernel log for the blocked attempt. I used `journalctl -k` and filtered for `HW4-C2-DROP:` so I could match the timeout to the repeated TCP SYNs from agent-node to mock-c2 on port 8080.

Log entry 11:

I asked for the command to test an unapproved port. I kept the web-lab IP the same and changed the port from 8000 to 8080. Port 8000 had returned HTTP 200, while 8080 timed out, which showed why both the IP and port mattered in my allow rule.

Log entry 12:

I asked how to test whether the agent could still reply when my VM opened the connection. I used `nc` to connect to port 9009 on agent-node. Once the listener was running, my VM received the banner, so I could see that the reply made it back through the firewall.

Log entry 13:

I asked how to check that the restriction was specific to agent-node. I used the same mock-c2 destination and port as Test 2, but this time I sent an empty POST from web-lab. It returned HTTP 204, so changing which container sent the request changed the result.

Log entry 14:

I asked how to check the three Suricata rules I had saved in `local.rules`. I used `sed` to display one rule at a time for my report. To verify what they matched, I ran Suricata on both captures. Each rule fired once on the malicious capture, and the clean capture had zero alerts.


