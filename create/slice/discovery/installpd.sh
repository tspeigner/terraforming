#!/bin/bash

export NON_INTERACTIVE_BLOB="{\"password\":\"@Admin\",\"licensePath\":\"/home/centos/pd-license.json\",\"acceptEula\":\"y\"}"
export NON_INTERACTIVE=${NON_INTERACTIVE_BLOB}
sudo /bin/yum install -y yum-utils device-mapper-persistent-data lvm2
sudo /bin/yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo /bin/yum install -y docker-ce
sudo /usr/bin/systemctl start docker
sudo /usr/bin/docker ps
sudo /usr/bin/curl -O https://storage.googleapis.com/chvwcgv0lwrpc2nvdmvyes1jbgkk/production/latest/linux-amd64/puppet-discovery
sudo /usr/bin/chmod a+x ./puppet-discovery
sudo NON_INTERACTIVE=${NON_INTERACTIVE_BLOB} ./puppet-discovery start