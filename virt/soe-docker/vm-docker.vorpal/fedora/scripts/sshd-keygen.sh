#!/bin/sh
# sshd-key-gen.sh
# post-apply script that properly manages ssh authentication keys
# Install in /var/radmind/postapply

SSHKEYGEN=/usr/bin/ssh-keygen

if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    $SSHKEYGEN -q -t rsa  -f /etc/ssh/ssh_host_rsa_key -N "" \
        -C "" < /dev/null > /dev/null 2> /dev/null
    echo "Created /etc/ssh/ssh_host_rsa_key"
fi

if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
    $SSHKEYGEN -q -t dsa  -f /etc/ssh/ssh_host_dsa_key -N "" \
        -C "" < /dev/null > /dev/null 2> /dev/null
    echo "Created /etc/ssh/ssh_host_dsa_key"
fi

if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
    $SSHKEYGEN -q -t ecdsa  -f /etc/ssh/ssh_host_ecdsa_key -N "" \
        -C "" < /dev/null > /dev/null 2> /dev/null
    echo "Created /etc/ssh/ssh_host_ecdsa_key"
fi

if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    $SSHKEYGEN -q -t ed25519  -f /etc/ssh/ssh_host_ed25519_key -N "" \
        -C "" < /dev/null > /dev/null 2> /dev/null
    echo "Created /etc/ssh/ssh_host_ed25519_key"
fi

exit 0
