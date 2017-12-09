#!/bin/bash

cd ~/
sudo luxd stop
sudo rm -fr lux/
sudo git clone https://github.com/216k155/lux
cd lux/src/leveldb
make clean && sudo chmod +x build_detect_platform && make libleveldb.a libmemenv.a
cd ..
make -f makefile.unix
./luxd
