#!/bin/bash
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
