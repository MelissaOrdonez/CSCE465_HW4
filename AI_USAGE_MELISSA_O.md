Tool/Model & Date: GPT-6, November 17-19, 2026

Purpose: I used the AI to help me write code and debug errors.

AI Conversation Log Files:
https://chatgpt.com/share/6afce849-7138-83e9-9f21-aa04edcb25db
https://chatgpt.com/share/6affb19e-bacc-83e9-8c6b-057ba7d77da1

What I Used: For task 1, I used the code it wrote for the Dockerfile, the compose file, mock_skill file and the web pages with some changes. For task 2, I mainly used it for debugging or clarifying commands to run.

What I Changed: The main things I changed from the AI code was simplifying some of the code particularly the web pages. 

How I Tested It: I tested the Task 1 code by running the lab with the docker commands, and ensuring all the services were running properly and the mock skill worked with the exact trigger by sending a file to mock-c2.

One Error, Limitation, or Rejected Suggestion: One limitation is that the AI code was initially writing code for mock_skill that did not fit the intended functionality. It would not start the TCP listener when there was an exfiltrate-course-file command which went against the instructions that said to start the listener and in addition send the fake secret to mock-c2. 
