#!/bin/bash

# create a directory where TFE stores it's data
sudo mkdir /tfe_data

# create settings.json
cat >/etc/settings.json <<EOL
{
    "hostname": {
        "value": "${fqdn}"
    },
    "disk_path": {
        "value": "/tfe_data"
    },
    "enc_password": {
        "value": "${enc_password}"
    }
}
EOL

# create replicated.conf
cat >/etc/replicated.conf <<EOL
{
    "DaemonAuthenticationType":     "password",
    "DaemonAuthenticationPassword": "${replicated_password}",
    "TlsBootstrapType":             "server-path",
    "TlsBootstrapHostname":         "${fqdn}",
    "TlsBootstrapCert":             "/tmp/tfe_server.crt",
    "TlsBootstrapKey":              "/tmp/tfe_server.key",
    "BypassPreflightChecks":        true,
    "ImportSettingsFrom":           "/etc/settings.json",
    "LicenseFileLocation":          "/tmp/license.rli"
}
EOL

sleep 2m

# wait for internet connectivity
while ! curl -ksfS --connect-timeout 5 https://www.terraform.io; do
    sleep 5
done

# download and install the latest tfe
cd /tmp/
curl -o install.sh https://install.terraform.io/ptfe/stable
sudo bash ./install.sh

sleep 5m

# wait for TFE to become ready
while ! curl -ksfS --connect-timeout 5 https://${fqdn}/_health_check; do
    sleep 5
done

# create request payload for admin account
cat >/tmp/payload_admin.json <<EOL
{
  "username": "${admin_username}",
  "email": "${admin_email}",
  "password": "${admin_password}"
}
EOL


# get replicated token to create admin account
initial_token=$(replicated admin --tty=0 retrieve-iact | tr -d '\r')


# api call to create admin account
curl -k \
  --header "Content-Type: application/json" \
  --request POST \
  --data @/tmp/payload_admin.json \
  https://${fqdn}/admin/initial-admin-user?token=$initial_token
