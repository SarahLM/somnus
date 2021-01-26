import shutil
import time
import os
from flask_api import status
import io
import csv
import glob
from datetime import date

from werkzeug.utils import secure_filename

import somnus
import pandas as pd
from flask import Flask, send_file, request, redirect, url_for, make_response, flash


ALLOWED_EXTENSIONS = {'csv'}
PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = PROJECT_ROOT + '/fileUploads'
app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


# noinspection PyInterpreter
@app.route('/')
def hello_world():
    return 'success'


def transform(text_file_contents):
    return text_file_contents.replace("=", ",")


def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS



@app.route('/data', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            print(request.__dict__.items())
            return 'no selected file', status.HTTP_412_PRECONDITION_FAILED
        file = request.files['file']
        if not allowed_file(file.filename):
            return 'invalid data, expected csv', status.HTTP_415_UNSUPPORTED_MEDIA_TYPE
        # if user does not select file, browser also
        # submit an empty part without filename
        if file.filename == '':
            return 'expected file', status.HTTP_412_PRECONDITION_FAILED
        if file and allowed_file(file.filename):
            # to make sure file is unique
            timestamp = str(time.time())
            newfilename = timestamp + 'fileUpload.csv'
        # function to secure a filename before storing it directly on the filesystem
            data = secure_filename(newfilename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], data))
            return run_data(data, timestamp), clearbackend()


def run_data(src, stamp):
    src = PROJECT_ROOT + '/fileUploads/' + src
    try:
        somnus.Somnus(input_file=src, sampling_frequency=100, verbose=True)
    except Exception as e:
        print("Error processing: {}\nError: {}".format(src, e))
    # return specific response
    return send_file('results/' + stamp +'fileUpload.csv')


def clearbackend():
    upfiles = glob.glob('fileUploads/*.csv')
    for f in upfiles:
        print('löschen')
        os.remove(f)
    resultfiles = glob.glob('results/*.csv')
    for f in resultfiles:
        print('löschen results')
        os.remove(f)