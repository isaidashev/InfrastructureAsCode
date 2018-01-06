#!/bin/bash
#./install_ruby.sh
apt update >/dev/null 2>/dev/null

RubyVersion=$(ruby -v)
BundlerVersion=$(bundler -v)

if [[ $RubyVersion != "ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]" ]]; then
 apt install -y ruby-full>/dev/null
 echo "Version Ruby Checked"
fi

if [[ $BundlerVersion != "Bundler version 1.11.2" ]]; then
  apt install -y ruby-bundler build-essential>/dev/null
  echo "Version Bundler Checked"
fi

#./install_mongodb.sh
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list
apt update
apt install -y mongodb-org
systemctl start mongod
systemctl enable mongod

#./deploy.sh
cd ~
git clone https://github.com/Otus-DevOps-2017-11/reddit.git
cd ~/reddit
bundle install
puma -d
if ps aux | grep puma | grep -vq grep; then
  echo "Puma start"
else
  echo "Puma stop"
fi
