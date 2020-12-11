from flask import Flask
import os
import time
import somnus

app = Flask(__name__)
# testvariable = 'hhh'


@app.route('/')
def hello_world():
    # run_demo('heyhohohoho')
    # return 'abgeschlossen' + str(testvariable)
    return run_demo('lalelu')


def run_demo(testvariable):
    st = time.time()
    somnus.run_sleep_detection()
    stp = time.time()
    print("total run time: {} minutes".format((stp - st) / 60.0))
    print("Test" + testvariable)
    return testvariable


if __name__ == "__main__":
    app.run()
