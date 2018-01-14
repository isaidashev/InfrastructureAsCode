#!/bin/bash

set -e

#Создание VM инстанса
gcloud compute instances create reddit-app-full \
--zone=europe-west1-d \
--boot-disk-size=10GB \
--image-family reddit-full \
--machine-type=g1-small \
--preemptible \
--tags puma-server \
--restart-on-failure \
--metadata startup-script="cd /home/appuser/reddit && puma -d"

#Создание правила фаервола
gcloud compute firewall-rules create default-puma-server \
--allow=TCP:9292 \
--description=default-puma-server \
--network=default \
--target-tags puma-server \
--priority=1000 \
--direction=INGRESS
