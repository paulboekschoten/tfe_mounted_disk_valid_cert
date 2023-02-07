#cloud-config
packages:
- git 
- jq 
- vim 
- language-pack-en
- wget
- curl
- zip
- unzip
write_files:
  - path: "/etc/replicated.conf"
    permissions: "0755"
    owner: "root:root"
    content: |
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
  - path: "/etc/settings.json"
    permissions: "0755"
    owner: "root:root"
    content: |
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
  - path: "/etc/tfe_initial_user.json"
    permissions: "0755"
    owner: "root:root"
    content: |
      {
        "username": "${admin_username}",
        "email": "${admin_email}",
        "password": "${admin_password}"
      }
  - path: "/tmp/install-tfe.sh"
    permissions: "0755"
    owner: "root:root"
    content: |
      #!/bin/bash -eux

      curl -sL https://install.terraform.io/ptfe/stable > /tmp/install.sh
      bash /tmp/install.sh release-sequence=${release_sequence}

      while ! curl -kLsfS --connect-timeout 5 https://${fqdn}/_health_check &>/dev/null ; do
        echo "INFO: TFE has not been yet fully started"
        echo "INFO: sleeping 60 seconds"
        sleep 60
      done

      echo "INFO: TFE is up and running"

      if [ ! -f /etc/iact.txt ]; then
        initial_token=$(replicated admin --tty=0 retrieve-iact | tr -d '\r')
        echo $initial_token > /etc/iact.txt
      fi

      curl -k \
        --header "Content-Type: application/json" \
        --request POST \
        --data @/etc/tfe_initial_user.json \
        https://${fqdn}/admin/initial-admin-user?token=$initial_token | tee /etc/tfe_initial_user_token.json
runcmd: 
  - mkdir -p /tfe_data
  - bash /tmp/install-tfe.sh



