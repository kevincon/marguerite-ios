# Marguerite for iOS [![Build Status](https://travis-ci.org/cardinaldevs/marguerite-ios.png?branch=master)](https://travis-ci.org/cardinaldevs/marguerite-ios)

Note: Marguerite is currently in development and therefore the following information and screenshots are likely to change before the app is submitted to the iOS App Store.

# Beta Test
Want to beta test the app? First make sure your device [supports iOS 6.1](http://en.wikipedia.org/wiki/List_of_iOS_devices#Highest_Version_of_iOS_Supported), then [register with our TestFlight team](http://tflig.ht/13qDQ8p).

# Description
Marguerite is an iPhone app that makes it easier for riders to use the free [Stanford Marguerite shuttle bus system](http://transportation.stanford.edu/marguerite/).

Marguerite is developed and maintained by the [upcoming Cardinal Devs club](http://sadevs.stanford.edu/) at Stanford. Cardinal Devs is an upcoming student organization that develops, maintains, and improves open-source, student-run technology at Stanford University. Cardinal Devs will be applying to be recognized as an official Stanford organization by October 25, 2013. If you are interested in joining as a developer, designer, or leader, please email Kevin Conley at kcon AT stanford DOT edu.

Marguerite is developed with the knowledge and gracious assistance of the [Stanford Parking & Transportation Services department](http://transportation.stanford.edu/). We are extremely grateful for their help.

### Features
* See what buses are arriving next at the Marguerite stop closest to your current location.*
* Plan a trip using the Marguerite shuttle.
* View the real-time locations of all shuttles on a Google map.
* View the schedules for all Marguerite routes.*

*No Internet connection required!

### Screenshots
![Alt text](http://www.static.kevintechnology.com/marguerite-ios/nextshuttle.png) ![Alt text](http://static.kevintechnology.com/marguerite-ios/livemap.png)

# Contributing
All pull requests and feedback are welcome! Report bugs and feature requests using the [Github issues system](https://github.com/cardinaldevs/marguerite-ios/issues).

### Getting started

#### Prerequisites
1. Download and install Xcode 4.6.3 from the Mac App Store. 
2. Install the command line tools by opening Xcode, clicking the Xcode menu -> Preferences, then click the Downloads tab, then click the Components tab below, then click "Install" next to "Command Line Tools."

#### Viewing the Code
1. Clone the git repository.
2. Open the Xcode workspace (not the project!) by double clicking on the "marguerite.xcworkspace" file.
3. At this point you should be able to run the project in the iPhone simulator by selecting "marguerite -> iPhone 6.1 simulator" in the dropdown menu at the top left and clicking the "Run" button. However, certain features of the app will not function until you update the secrets.h file.

#### Configure the secrets.h file
First, run the following command on the command line to prevent git from recognizing any changes to the secrets.h file:

    git update-index --assume-unchanged secrets.h
    
Then, before the app will fully function, you must complete the "secrets.h" file in the root directory of the project by filling in the following strings:
* MARGUERITE_REALTIME_XML_FEED: This is the URL of the real-time Marguerite shuttle bus location XML feed. Email Kevin Conley at kcon AT stanford DOT edu to ask for this value.
* MARGUERITE_VEHICLE_IDS_URL: This is the URL that the app sends POST requests to in order to query the mappings between Marguerite "vehicle IDs" (the numbers on the sides of the buses) and the "farebox IDs" that help identify which route a particular bus is driving on. Email Kevin Conley at kcon AT stanford DOT edu to ask for this value.
* GOOGLE_MAPS_API_KEY: This is the API key for the Google Maps iPhone SDK. Follow the instructions here ([https://developers.google.com/maps/documentation/ios/start#obtaining_an_api_key](https://developers.google.com/maps/documentation/ios/start#obtaining_an_api_key)) for "Obtaining an API Key" and then update this value.
* TESTFLIGHT_APPLICATION_TOKEN: This is the token for the TestFlight analytics SDK. You can leave this entry as the empty string; it won't affect you being able to build and run the app.

### Best practices
These are the practicies we currently follow, but feel free to propose better methodologies!

#### Git branching
We follow the methodology for creating/pushing branches as described here: 
[http://nvie.com/posts/a-successful-git-branching-model/](http://nvie.com/posts/a-successful-git-branching-model/)

#### Objective C style
We follow the style guide that Adium uses, as described here: 
[https://trac.adium.im/wiki/CodingStyle](https://trac.adium.im/wiki/CodingStyle)

# Attributions
This app would not have been possible without the following open-source libraries:
* [GTFSImporter](https://github.com/jvashishtha/GTFSImporter) for constructing an SQLite database using GTFS txt files.
* [TBXML](https://github.com/71squared/TBXML) for parsing the real-time Marguerite shuttle bus location XML feed.
* [ASIHTTPRequest](https://github.com/pokeb/asi-http-request) for simplifying GET and POST requests.
* [Default Icon](http://defaulticon.com/) by [interactivemania](http://www.interactivemania.com/) for the tab bar icons.
 
# MIT License
The MIT License (MIT)

Copyright (c) 2013 Cardinal Devs

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

A different license may apply to other software included in this package, 
including the libraries mentioned under "Attributions" above. Please consult their 
respective headers/websites for the terms of their individual licenses.
