#!/bin/bash
gcloud compute instances create reddit-app \
--zone=europe-west1-d \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--preemptible \
--restart-on-failure \
--metadata-from-file startup-script=./startup_script.sh
# Берем код с Gist
#--metadata startup-script='wget -O -  https://path_to_gist/raw/run_app.sh | bash'
