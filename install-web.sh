#!/bin/bash

cd ~/
mkdir web
cd web
wget 
wget 
(crontab -l 2>/dev/null; echo "* * * * * echo MN Count:  > ~/web/stats.txt; /usr/local/bin/luxd masternode count >> ~/web/stats.txt; /usr/local/bin/luxd getinfo >> ~/web/stats.txt") | crontab -
mnip=$(curl -s https://api.ipify.org)
python3 -m http.server 8000 --bind $mnip 2>/dev/null &
echo "Your Luxcoin Masternode Web Server Started!  You can now access your stats page at http://$mnip:8000"
