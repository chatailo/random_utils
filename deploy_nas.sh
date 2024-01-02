#!/bin/bash

CRED_FILE=/etc/nas_creds.$(date +%s)
echo "---------------------"
echo "Welcome to NAS setter, auto mounting SMB shares for a single usr/pwd"

if [ $(id -u) -ne 0 ]
then
    echo "Must be executed as root, exiting..."
    exit 1
fi

echo "Installing required cifs-utils..."
apt update && apt install cifs-utils

echo "Fill in server hostname or IP"
read -e NAS_IP
echo "Space-separated list of shares e.g. //nas/mountpoint"
read -e NAS_LMOUNT
echo "NAS Username ?"
read -e NAS_USR
echo "NAS Password ?"
read -e NAS_PWD

ret=127
while [ ${ret} -ne 0 ]
do
    echo "Local machine user ?"
    read -e NAS_EUSR
    id ${NAS_EUSR} >/dev/null
    ret=$?
done

echo "username=${NAS_USR}
password=${NAS_PWD}" > "${CRED_FILE}"
chmod 400 "${CRED_FILE}"
chown root:root "${CRED_FILE}"

for l_entry in ${NAS_LMOUNT}
do
    l_mode="cifs"
    l_path="/mnt/nas/${l_entry}"
    l_opt="credentials=${CRED_FILE},uid=$(id -u ${NAS_EUSR}),gid=$(id -g ${NAS_EUSR})"
    mkdir -p "${l_path}"
    echo -e "//${NAS_IP}/${l_entry}\t${l_path}\t${l_mode}\t${l_opt}\t0\t0" >> /etc/fstab
done
echo "Entries have been added correctly, test with mount -a"
echo "---------------------"

exit 0
