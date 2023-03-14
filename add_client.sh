#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
    >&2 echo "USAGE: $0 CLIENT_NAME"
    exit 1
fi

wg_server_host="$(terraform output -raw wg_server_host)"
wg_server_user="$(terraform output -raw wg_server_user)"
wg_server_port="$(terraform output -raw wg_server_port)"
ssh "$wg_server_user"@"$wg_server_host" <<EOF
    set -eu
    cd wg-server/

    # tuning wg-server
    echo "$wg_server_port" > portno.txt
    echo "$wg_server_host" > extnetip.txt

    if [ -e "wgclient_$1.conf" ]; then
        >&2 echo "wgclient_$1" already exists
        cat "wgclient_$1.qrcode.txt"
        exit 0
    fi
    # remove old stuff
    rm -f "wgclient_$1*" "wghub*"
    ../easy-wg-quick "$1"
    sudo cp -f ./wghub.conf /etc/wireguard/wghub.conf
    sudo systemctl enable wg-quick@wghub
    sudo systemctl restart wg-quick@wghub
    sudo systemctl status wg-quick@wghub
EOF
