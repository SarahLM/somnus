import time
import os
import io
import csv

from werkzeug.utils import secure_filename

import somnus2
import pandas as pd
from flask import Flask, send_file, request, redirect, url_for, make_response, flash

UPLOAD_FOLDER = '/fileUploads'
ALLOWED_EXTENSIONS = {'csv'}

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


# testvariable = 'hhh'
# pathToResultFolder = '/home/sarah/results'
# pathToResultFolder = 'results'


# noinspection PyInterpreter
@app.route('/')
def hello_world():
    # if __name__ == "__main__":
    # run_demo('heyhohohoho')
    # return 'abgeschlossen' + str(testvariable)
    return run_demo('lalelu')


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
            print ('no file drin')
        file = request.files['file']
        # if user does not select file, browser also
        # submit an empty part without filename
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            # data = '/fileUploads'
            # file.save(data)
            data = csv.reader(file, delimiter=',')
            for row in data:
                print(', '.join(row))
            return run_data(data)
   # return run_data()
# def csvuebergabe():
#     print ('datei uebergeben')
#     # print (request.get_data(file.name))
#     # return send_file('result.csv')
#     # data = request.get_data(file)
#     # with open(request.files['File'], 'r') as data:
#         # spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
#         #dataread = data.csv.reader(data, delimiter=',')
#     dataread = request.files.read()
#     return run_data(dataread)
#     # return run_data()


def run_data(src):
    # def run_data():
    # src = __file__.split(".py")[0] + ".bin"
    # src = "inputAccelero.csv"
    #print (src)
    st = time.time()
    try:
        somnus2.Somnus(input_file=src, sampling_frequency=100, verbose=True)
    except Exception as e:
        print("Error processing: {}\nError: {}".format(src, e))
    # stp = time.time()
    print("Test")
    return 'endeneu'
    # return send_file('result.csv')


def run_demo(testvariable):
    # src = __file__.split(".py")[0] + ".bin"
    src = "inputAccelero.csv"

    st = time.time()
    try:
        somnus2.Somnus(input_file=src, sampling_frequency=100, verbose=True)
    except Exception as e:
        print("Error processing: {}\nError: {}".format(src, e))
    stp = time.time()
    print("total run time: {} minutes".format((stp - st) / 60.0))
    print("Test" + testvariable)
    # return testvariable
    return send_file('result.csv')
    # return 'neuerReturn'
