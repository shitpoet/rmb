#!/bin/bash
echo 'listening'
nc -k -l -p 64727 -c 'echo -e "HTTP/1.1 200 OK\n\n $(date)"'
echo 'send rmb'
xdotool click 3
. $0
