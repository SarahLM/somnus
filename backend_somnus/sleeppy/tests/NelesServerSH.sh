#!/bin/bash
cd ../..
sudo python2.7 setup.py install
cd sleeppy/tests
export FLASK_APP=server2.py
flask run