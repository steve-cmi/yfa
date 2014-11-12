#!/usr/bin/env bash

# Ubuntu
echo "Updating Ubuntu..."
apt-get update
echo "Updated Ubuntu."

# Apache
echo "Updating Apache..."
apt-get install -y apache2
rm -rf /var/www
ln -fs /vagrant /var/www
echo "Updated Apache."

# Rails
echo "Updating Rails..."
apt-get install -y libapache2-mod-passenger
echo "Updated Rails."

# MySQL
echo "Updating MySQL..."
apt-get install -y mysql-server mysql-client libmysql++-dev
echo "Updated MySQL."

# RVM and Ruby
echo "Updating Ruby..."
apt-get install -y curl
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source "$HOME/.rvm/scripts/rvm"
echo "rvm_install_on_use_flag=1" > "$HOME/.rvmrc"
cd /var/www
echo "Updated Ruby."

# Bundler & Gems
echo "Updating Gems..."
apt-get install -y git
bundle install
echo "Updated Gems."
