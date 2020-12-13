#!/bin/bash

# remove all files and folders from result and fileUploads
cd results
rm -R *
cd ..
cd fileUploads
rm -R *
cd ..

# renew setup, get new EGG
cd ../..
sudo python2.7 setup.py install
cd sleeppy/tests

# set env-variable
export FLASK_APP=server2.py

#start server
flask run