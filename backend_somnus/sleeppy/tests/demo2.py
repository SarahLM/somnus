import time
import os
from sleeppy.sleep import SleepPy
import pandas as pd

pathToResults = 'results'

def run_demo():
    src = "inputAccelero.csv"
    st = time.time()
    try:
        SleepPy(input_file=src, results_directory=pathToResults, sampling_frequency=100, verbose=False)
    except Exception as e:
        print("Error processing: {}\nError: {}".format(src, e))
    stp = time.time()
    print("total run time: {} minutes".format((stp - st) / 60.0))

if __name__ == "__main__":
    run_demo()