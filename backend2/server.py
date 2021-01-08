import time
import os
import somnus2
import pandas as pd
from flask import Flask

app = Flask(__name__)
# testvariable = 'hhh'
# pathToResultFolder = '/home/sarah/results'
#pathToResultFolder = 'results'


# noinspection PyInterpreter
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
        somnus2.Somnus(input_file=src, sampling_frequency=100, verbose=True)
    except Exception as e:
        print("Error processing: {}\nError: {}".format(src, e))
    stp = time.time()
    print("total run time: {} minutes".format((stp - st) / 60.0))
    print("Test" + testvariable)
    return testvariable
    # return 'neuerReturn'