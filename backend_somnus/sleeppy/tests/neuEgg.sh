#!/bin/bash

# remove all files and folders from result and fileUploads
cd results
rm -R *
cd ..
cd fileUploads
rm -R *
cd ..

cd ../..
sudo python setup.py install
cd sleeppy/tests
python demo2.py
