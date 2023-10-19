# PPTP-bruteforce
PPTP bruteforce tool 

Simple tool for bruteforcing pptp protocol written in bash

1)Requirments pptp client has to be installed on the system

sudo apt-get update;
sudo apt-get install pptp -y

2)You just need to supply a username file, a password file, and a target IP
username password file formats needs to be as follows

1)user1
2)user2
3)user3


1)pass1
2)pass2
3)pass3

Example usage.
./brute_script.sh user.txt pass.txt 127.0.0.1 


PS. 
Don't use this for illegal stuff. Happy hacking c:
