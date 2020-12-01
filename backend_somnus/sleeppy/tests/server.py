import time
import os
from sleeppy.sleep import SleepPy
import pandas as pd
from flask import Flask
app = Flask(__name__)
#testvariable = 'hhh'

@app.route('/')
def hello_world():
    # if __name__ == "__main__":
    # run_demo('heyhohohoho')
    # return 'abgeschlossen' + str(testvariable)
    return run_demo('lalelu')


def run_demo(testvariable):
    # src = __file__.split(".py")[0] + ".bin"
    src = "inputAccelero.csv"

    st = time.time()
    try:
     SleepPy(input_file=src, results_directory='/home/sarah/results', sampling_frequency=100, run_config=4, verbose=False)
    except Exception as e:
        print("Error processing: {}\nError: {}".format(src, e))
    stp = time.time()
    print("total run time: {} minutes".format((stp - st) / 60.0))
    print("Test" + testvariable)
    return testvariable
    #return 'neuerReturn'
