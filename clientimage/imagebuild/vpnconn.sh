#$1 --> host ip 
#$2 --> username
#$3 --> host port

charon-cmd --ike-proposal aes256-sha1-modp1024 --esp-proposal aes256-sha1-modp1024 --host $1 --identity $2 --xauth-username $2 --cert ~/certs/server-root-ca.pem --profile ikev2-eap --remote-identity testvpn --remote-port $3
