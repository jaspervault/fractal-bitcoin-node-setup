# fractal-bitcoin-node-setup

sudo ./fb_node_setup.sh

sudo journalctl -u fractald.service -f


Crate Wallet : 
cd /root/fractald-0.2.2-x86_64-linux-gnu/bin

./bitcoin-wallet -wallet=wallet -legacy create

python rpcauth.py username

bitcoin-cli -rpcconnect=YOUR RPC HOST -rpcport=YOUR RPC PORT -rpcuser=YOUR RPC USER -rpcpassword=YOUR RPC PASSWORD getwalletinfo
