#!/bin/sh

# Install Ansible repository.
# apt-get update && apt-get upgrade --assume-yes
# apt-get install software-properties-common --assume-yes
# apt-add-repository ppa:ansible/ansible --assume-yes

# Update apt cache.
apt-get update
#apt-get install ansible --assume-yes

# Install expect, dos2unix, tree & unzip
sudo apt-get install --assume-yes expect
sudo apt-get install --assume-yes dos2unix
sudo apt-get install --assume-yes tree
sudo apt-get install --assume-yes unzip

# Install python 3.8
sudo apt-get install --assume-yes python3.8
sudo apt-get install --assume-yes python3-pip

# Cleanup unneded packages
apt-get autoremove --assume-yes

# Adjust timezone to be Paris
TIMEZONE='Europe/Paris'
#ln -sf /usr/share/zoneinfo/Asia/Singapore /etc/localtime
ln --verbose --force --symbolic "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime

# add user to sudo groups
# usermod -aG sudo vagrant

# lsb_release -a

# Add vagrant user to sudoers.
#echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed --in-place=".$(date "+%F").bak" "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Disable daily apt unattended updates.
#echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

# generating password configuration on ansible server to later access remote servers
echo vagrant | sudo -S su - vagrant -c "ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -P ''"

# python -m virtualenv ansible  # Create a virtualenv if one does not already exist
# source ansible/bin/activate   # Activate the virtual environment
python3.8 -m pip install ansible==2.10.7

if [ ! -d "/etc/ansible" ];
  then mkdir --verbose /etc/ansible;
fi
cp --verbose /vagrant/artefacts/scripts/ansible.cfg /etc/ansible/ansible.cfg
cp --verbose --force --recursive /vagrant/artefacts/ /home/vagrant/artefacts/
chown --recursive --verbose vagrant:vagrant /home/vagrant/artefacts/