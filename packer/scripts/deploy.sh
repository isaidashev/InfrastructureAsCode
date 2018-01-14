#!/bin/bash
set -e
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
