import os
from flask import Flask, flash, request, redirect, url_for
import time
import os
from sleeppy.sleep import SleepPy

# pathToResultFolder = '/home/sarah/results'
pathToResultFolder = 'results'
pathToUploadFolder = 'fileUploads'
ALLOWED_EXTENSIONS = {'txt', 'csv'}

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = pathToUploadFolder



@app.route('/', methods=['GET', 'POST'])
def upload_csv_file():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        # if user does not select file, browser also
        # submit an empty part without filename
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = file.filename 
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            return redirect(url_for('uploaded_file', filename=filename))
    return '''
    <!doctype html>
    <title>Upload new file</title>
    <h1>Upload new accelerometer CSV file</h1>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    '''

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    # return send_from_directory(app.config['UPLOAD_FOLDER'], filename)
    run_sleepPrediction()
    return '''
        <!doctype html>
        <title>Uploaded new file</title>
        <h1>You uploaded a new file!</h1>
        '''


def run_sleepPrediction():
    src = "fileUploads/inputAccelero2.csv"
    st = time.time()
    try:
     SleepPy(input_file=src, results_directory=pathToResultFolder, sampling_frequency=100, verbose=False)
    except Exception as e:
        print("Error processing: {}\nError: {}".format(src, e))
    stp = time.time()
    print("total run time: {} minutes".format((stp - st) / 60.0))
    return 'done'


def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
