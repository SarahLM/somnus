# Somnus

Project "Somnus"
- course: "Mobile Applications for Public Health" in AI Master HTW Berlin
- goal: Mobile Application in Flutter
- topic: Tracking sleep-awake-phases with wearable and monitoring in mobile app 

See documentation for detail instructions.

A project by Stephanie Scheibe, Sarah-Lee Mendenhall, Nele Herzog and Matthias Klassen

## Table of Contents
1. [Introduction](#general-info)
2. [Technologies](#technologies)
3. [Installation](#installation)

![Image text](https://github.com/SarahLM/somnus/blob/master/frontend_somnus/assets/images/somnus_logo.png)


### General Info
***
The Somnus app enables the user to use an activity tracker(MiBand 2 in this case) to get information about his sleep. 

The application is divided into different architectures. The real one
Logic that makes the analysis of the collected activity data is
currently outsourced to an external backend based on the project [Sleeppy](https://github.com/elyiorgos/sleeppy).

The interaction with the user and the results are visualized in the Android app.
In order for the analysis of the data to take place, the following steps are necessary
run through:
*  **Data collection** 
The miband is connected to the smartphone via Bluetooth
and the Somnus app. It collects data on the basis of activity
an accelerometer. These data are constantly being transmitted via the bluetooth connection
sent to the Somnusapp.
*  **Data storage** 
The data received from the miband are stored in a
local database written on the smartphone.
*  **Data transmission** 
The stored accelerometer data is collected
extracted from the database and once as a collected CSV file
Sent daily to the external backend for evaluation.
*  **Data processing** 
The backend receives the CSV file and evaluates it
received data by classifying them according to sleep and wake
takes place. This result is returned to the app as CSV.
Data display In the Somnus app, the data from the CSV
stored in the database. On the app's analysis screens, the
Evaluations can be viewed, changed or exported graphically.

*  **Data representation** In the Somnus app, the data from the CSV
stored in the database. On the app's analysis screens, the
Evaluations can be viewed, changed or exported graphically.


## Technologies
***
A list of technologies used within the project:
* [Flutter](https://flutter.dev/docs/get-started/install): Version 12.3 
* [Python](https://example.com): Version 3.8


## Installation
***
In order to be able to edit and run the app, the following steps are necessary
required:

* [Flutter](https://flutter.dev/docs/get-started/install)
* [Android Studio](https://developer.android.com/studio)
* [a code editor](https://code.visualstudio.com/)


#### Android Setup

Start Android Studio and follow the instructions of the setup wizard.
This will bring the latest Android SDK, Android
SDK command line tools and Android SDK build tools installed
Flutter needed in development for Android.
Set up an Android (physical) device or an Android Emulators
In order to be able to run the app, you must first have a corresponding
Set up and start the device. Information on how to proceed
you will find [here](https://flutter.dev/docs/get-started/install).



####  Download the Somnus app from Github

You can then look at the source code using:
```
$ git clone https://github.com/SarahLM/somnus.git
```
####  App start

Go to the directory *somnus/frontend_somnus/* and open your
Editor here. Open a terminal and execute the command flutter run,
to install the app and on the Android device that has been set up
to start. You can then make changes to the code
and see them directly on the device.

For more detailled Instructions and pictures of the App, please read the [documentation](https://github.com/SarahLM/somnus/blob/master/dokumentation_somnus.pdf).
