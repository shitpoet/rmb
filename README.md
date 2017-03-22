# rmb

Open links in new foreground tab by right click, open context menu for a litle bit longer right click.

Chrome forbids programmatical opening of context menu, so this extension needs a workaround.

A workaround is to simulate user input to open the menu.

This is done by this bash script:

    #!/bin/bash
    #echo 'listening'
    nc -k -l -p 64727 -c 'echo -e "HTTP/1.1 200 OK\n\n $(date)"'
    #echo 'send rmb'
    xdotool click 3
    . $0

This script listens at 64727 and on any request sends RMB to the active window.

(In this way it is also possible to programmatically open Web console. This is forbidden by Chrome too.)

The extension does simple fetch `127.0.0.1:64727` and the script simulates user input for Chrome.
