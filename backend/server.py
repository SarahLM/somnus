import time
import os
import io
import csv
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


# testvariable = 'hhh'
# pathToResultFolder = '/home/sarah/results'
# pathToResultFolder = 'results'


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
            print('no file')
        file = request.files['file']
        # if user does not select file, browser also
        # submit an empty part without filename
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            # to make sure file is unique
            timestamp = str(time.time())
            newfilename = timestamp + 'fileUpload.csv'
        # function to secure a filename before storing it directly on the filesystem
            data = secure_filename(newfilename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], data))
            return run_data(data, timestamp)


def run_data(src, stamp):
    # def run_data():
    # src = __file__.split(".py")[0] + ".bin"
    src = PROJECT_ROOT + '/fileUploads/' + src
    st = time.time()
    try:
        somnus.Somnus(input_file=src, sampling_frequency=100, verbose=True)
    except Exception as e:
        print("Error processing: {}\nError: {}".format(src, e))
    # return send_file('results/25698fileUpload/result_sleep_prediction.csv')
    # return specific response
    return send_file('results/' + stamp +'fileUpload/result_sleep_prediction.csv')




