#!/bin/bash

# remove all files and folders from result and fileUploads
cd results
rm -R *
cd ..
cd fileUploads
rm -R *
cd ..

#start server
python2.7 RESTserver2.py