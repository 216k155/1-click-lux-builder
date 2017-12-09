#!/bin/sh
#Version 0.0.1
#Info: Installs luxd daemon, Masternode based on privkey.
#Luxcoin Version 2.2.3 or above
#Tested OS: Ubuntu 17.04, 16.04, and 14.04
#TODO: make script less "ubuntu" or add other linux flavors
#TODO: remove dependency on sudo user account to run script (i.e. run as root and specifiy luxcoin user so luxcoin user does not require sudo privileges)
#TODO: add specific dependencies depending on build option (i.e. gui requires QT4)

noflags() {
	echo "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
    echo "Usage: install-lux"
    echo "Example: install-lux"
    echo "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
    exit 1
}

message() {
	echo "╒════════════════════════════════════════════════════════════════════════════════>>"
	echo "| $1"
	echo "╘════════════════════════════════════════════<<<"
}

error() {
	message "An error occured, you must fix it to continue!"
	exit 1
}


prepdependencies() { #TODO: add error detection
	message "Installing dependencies..."
	sudo apt-get update
	sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
	sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git software-properties-common
	sudo add-apt-repository -y ppa:bitcoin/bitcoin
	sudo apt-get update
	sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
}

clonerepo() { #TODO: add error detection
	message "Cloning luxcoin source from lux-master repository..."
  	cd ~/
	git clone https://github.com/216k155/lux.git
}

compile() {
	cd lux #TODO: squash relative path
	message "Preparing to build luxd..."
	cd src/leveldb && make clean && make libleveldb.a libmemenv.a
	if [ $? -ne 0 ]; then error; fi
	cd ..
	if [ $? -ne 0 ]; then error; fi
	message "Building lux daemon...this may take a few minutes..."
	make -f makefile.unix
	if [ $? -ne 0 ]; then error; fi
        message "install luxd..."
        sudo ln -s luxd /usr/bin
        if [ $? -ne 0 ]; then error; fi
        
}

createconf() {
	#TODO: Can check for flag and skip this
	#TODO: Random generate the user and password

	message "Creating lux.conf..."
	MNPRIVKEY="6FBUPijSGWWDrhbVPDBEoRuJ67WjLDpTEiY1h4wAvexVZH3HnV6"
	CONFDIR=~/.lux
	CONFILE=$CONFDIR/lux.conf
	if [ ! -d "$CONFDIR" ]; then mkdir $CONFDIR; fi
	if [ $? -ne 0 ]; then error; fi
	
	mnip=$(curl -s https://api.ipify.org)
	rpcuser=$(date +%s | sha256sum | base64 | head -c 10 ; echo)
	rpcpass=$(openssl rand -base64 32)
	printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "port=28666" "listen=1" "server=1" "daemon=1" "maxconnections=256" "rpcport=9888" "externalip=$mnip" "bind=$mnip" "masternode=1" "masternodeprivkey=$MNPRIVKEY" "masternodeaddr=$mnip:28666" > $CONFILE

        luxd
        message "Wait 10 seconds for lux daemon to load..."
        sleep 20s
        MNPRIVKEY=$(luxd masternode genkey)
	luxd stop
	message "wait 10 seconds for lux deamon to stop..."
        sleep 10s
	sudo rm $CONFILE
	message "Updating lux.conf..."
        printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "port=28666" "listen=1" "server=1" "daemon=1" "maxconnections=256" "rpcport=9888" "externalip=$mnip" "bind=$mnip" "masternode=1" "masternodeprivkey=$MNPRIVKEY" "masternodeaddr=$mnip:28666" > $CONFILE

}


success() {
	luxd
	message "SUCCESS! Your luxcoin masternode has started. lux.conf setting below..."
	message "Luxcoin Masternode $mnip:28666 $MNPRIVKEY TXHASH INDEX"
	exit 0
}

install() {
	prepdependencies
	createswap
	clonerepo
	compile $1
	createconf
	success
}

#main
#default to --without-gui
install --without-gui
