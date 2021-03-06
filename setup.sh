#!/bin/bash

# Install requirements (see README)

base_dir=`pwd`
virtualenv_directory=$base_dir/sandbox
if [[ ! -d $virtualenv_directory ]]; then
    virtualenv --python=python2 $virtualenv_directory
fi

virtualenv_bin=$virtualenv_directory/bin
PATH=$virtualenv_directory/bin:$PATH

buildbot_sources=buildbot-sources
if [[ -d buildbot-sources/.git ]]; then
    ./update.sh
    exit 0
else
    git clone --depth 1 git://github.com/buildbot/buildbot.git $buildbot_sources
fi

cd $buildbot_sources
pip install -e master
pip install -e slave
make prebuilt_frontend
cd -

buildbot create-master master
ln -s $base_dir/master.cfg master/
ln -s $base_dir/passwords.py master/
ln -s $base_dir/conf.cfg master/

slave_name="localhost_slave"
slave_password=`python2 -c "from passwords import *; print PASSWORDS['$slave_name']"`
echo $slave_password
buildslave create-slave slave localhost:9989 $slave_name $slave_password
echo -e "\tMove the slave to another user's home directory and execute from there"
