import time
import os
from sleeppy.sleep import SleepPy
import pandas as pd


def run_demo(binder_demo=False):
    # src = __file__.split(".py")[0] + ".bin"
    src = "output2.csv"
    """dst = raw_input("Please provide a path to a results Gulasch directory:    ")
    while not os.path.isdir(dst):
        if not binder_demo:
            dst = raw_input(
                "\nYour previous entry was not appropriate."
                "\nIt should follow a format similar to /Users/username/Desktop/Results"
                "\nPlease provide a path to a results directory:    "
            )
        else:
            dst = raw_input(
                "\nYour previous entry was not appropriate."
                "\nIt should follow a format similar to /home/jovyan/example_notebook"
                "\nPlease provide a path to a results directory:    "
            )"""

    st = time.time()
    try:
        if not binder_demo:
            # SleepPy(input_file=src, results_directory=dst, sampling_frequency=100, verbose=True)
            SleepPy(input_file=src, results_directory='/home/sarah/results', sampling_frequency=100, verbose=False)
        else:
            # SleepPy(input_file=src, results_directory=dst, sampling_frequency=100, run_config=4, verbose=True)
            SleepPy(input_file=src, results_directory='/home/sarah/results', sampling_frequency=100, run_config=4, verbose=False)
    except Exception as e:
        print("Error processing: {}\nError: {}".format(src, e))
    stp = time.time()
    print("total run time: {} minutes".format((stp - st) / 60.0))


if __name__ == "__main__":
    run_demo()
