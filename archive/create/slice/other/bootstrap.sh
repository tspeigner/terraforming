#!/bin/bash

# add the puppet master host and IP to hosts.  a hack for non-dns smart enviromnets.
echo "192.168.0.51    master.inf.puppet.vm" >> /etc/hosts


#download and install te agent.  removed the "sudo" before the bash, since cloud-inint doesn't like sudo commands.
curl -k https://master.inf.puppet.vm:8140/packages/current/install.bash | bash

#kill the puppet processs
pkill puppet

#start a puppet agnt run
puppet agent -t
