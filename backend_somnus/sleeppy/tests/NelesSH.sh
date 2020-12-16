#!/bin/bash

# remove all files and folders from result
cd results
rm -R *
cd ..

# renew setup, get new EGG
cd ../..
sudo python2.7 setup.py install

# run run sleeppy
cd sleeppy/tests
python2.7 demo2.py
