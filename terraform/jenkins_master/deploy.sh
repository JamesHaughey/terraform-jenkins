#!/usr/bin/env bash
terraform apply -auto-approve

REMOTE_IP=$(terraform output ip)
SLAVE_IP=$(terraform output slave_ip)
SSH_PROFILE=$(terraform output project_name)
KEY_NAME=$(terraform output key_name)

SLAVE_PROFILE="jenkins_slave"
SSH_USER="ubuntu"
SSH_PORT=22

IDENTITY_FILE="~/.ssh/${KEY_NAME}.pem"

echo "Updating ${SSH_PROFILE} SSH Profile"
storm edit $SSH_PROFILE --id_file $IDENTITY_FILE "${SSH_USER}@${REMOTE_IP}:${SSH_PORT}"
storm edit $SLAVE_PROFILE --id_file $IDENTITY_FILE "${SSH_USER}@${SLAVE_IP}:${SSH_PORT}"