#!/bin/bash

cd ~/
sudo luxd stop
sudo rm -fr lux/
sudo git clone https://github.com/216k155/lux
cd lux
sudo dd if=/dev/zero of=/swapfile bs=1M count=2000
sudo mkswap /swapfile
sudo chown root:root /swapfile
sudo chmod 0600 /swapfile
sudo swapon /swapfile
cd src/leveldb
make clean & sudo chmod +x build_detect_platform && make libleveldb.a libmemenv.a
cd ..
make -f makefile.unix
./luxd
