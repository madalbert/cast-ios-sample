Installing the Cast iOS Sample App (XCode)

The goal of this sample is to show iOS developers how to use Google Cast
technology, and not to demonstrate Objective-C programming best practices.

This readme does not cover XCode installation or Apple Developer registration.

***

Getting the Cast SDK:

1. Download the latest version of the iOS Cast framework from the below site:
developers.google.com/cast/downloads

2. Extract GCKFramework.framework to your working directory, or wherever you
can find it easily.

***

Getting Whitelisted: App IDs and receiver location

You will have to be whitelisted as a developer before you can specify your own
App ID and receiver URL, or test the included receiver. For whitelisting
instructions, see https://developers.google.com/cast/whitelisting.

***

Setting up the Sample App:

1. Open ChromecastDemo.xcodeproj with XCode. The project should load on its
own.

2. The project is missing GCKFramework.framework, which is displayed in red; 
right click on the Frameworks folder and select "Add Files to ChromecastDemo".

3. Navigate to where you extracted GCKFramework.framework and select it.

4. The sample app should now build. You can run it on the default iPad
simulator, and (if you're connected to the internet) test it by selecting one
of the included movies and playing it in the simulator.

NOTE: You will not be able to connect to your Chromecast device from the
simulator, even if your Mac and Cast device are on the same wifi network. You
will have to use an actual iOS device to do so.

***

Setting up the Receiver:

1. Assuming you have a receiver URL set up and whitelisted, rename the included
receiver/receiver.html to the name of your receiver, and upload it to your URL.

2. At line 40 of GCKAppDelegate.m, replace 

@"http://www.yourdomain.com/yourreceiver.html"

with the URL of your receiver.

3. At line 114 of GCKViewController.m, replace @"YOUR_APP_ID" with the AppID
you received from whitelisting.

4. Build and run the project on a connected iOS device. If the iOS device is on
the same wifi network as your Chromecast device, you should see the Cast icon
at the top right of the screen.

5. Connect to your Chromecast device and select a video. The video should begin
playing on the second screen.
