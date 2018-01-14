#./install_ruby.sh
set -e
apt update
apt install -y ruby-full
apt install -y ruby-bundler build-essential

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
