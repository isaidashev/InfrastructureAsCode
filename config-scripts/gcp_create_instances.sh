#!/bin/bash
#Создание basket и копирование в него скрипта автозапуска VM
set -e
gsutil mb gs://isaidashev-test
cat<<EOF > startup_script.sh
#./install_ruby.sh
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
EOF

gsutil cp startup_script.sh gs://isaidashev-test

#Создание VM инстанса
gcloud compute instances create reddit-app \
--zone=europe-west1-d \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--preemptible \
--restart-on-failure \
--metadata startup-script-url=gs://isaidashev-test/startup_script.sh

#Берем код локально с компа
#--metadata-from-file startup-script=./startup_script.sh
# Берем код с Gist
#--metadata startup-script='wget -O - https://path_to_script/raw/script.sh | bash'
#Код с URL и git, gs
#--metadata startup-script-url=gs://startup_script.sh

#Создание правила фаервола
gcloud compute firewall-rules create default-puma-server \
--allow=TCP:9292 \
--description=default-puma-server \
--network=default \
--target-tags puma-server \
--priority=1000 \
--direction=INGRESS
