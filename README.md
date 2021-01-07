# Social App

A Social Networking app built using Flutter and Firebase

[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/0ujjwalmishra0)

## Show some :heart: and star the repo to support the project.

## Features

 * Custom photo feed based on who you follow
 * Post photo posts from camera or gallery
   * Like posts
   * Comment on posts
        * View all comments on a post
 * Search for users
 * Profile Screen
   * Follow / Unfollow Users
   * Edit profile
 * Chat Screen
    * Chat with any user
 


## Screenshots


<p>

<img width="300" src="https://raw.githubusercontent.com/0ujjwalmishra0/social-app/master/screenshots/login.jpg" alt="login" >

<img width="300"  src="https://raw.githubusercontent.com/0ujjwalmishra0/social-app/master/screenshots/sign-up.jpg" alt="sign up"  >

<img width="300" src="https://raw.githubusercontent.com/0ujjwalmishra0/social-app/master/screenshots/timeline.jpg" alt="timeline" >

<img width="300" src="https://raw.githubusercontent.com/0ujjwalmishra0/social-app/master/screenshots/comment.jpg" alt="comment" >

<img width="300"  src="https://raw.githubusercontent.com/0ujjwalmishra0/social-app/master/screenshots/profile.jpg" alt="feed example"  >

<img width="300" src="https://raw.githubusercontent.com/0ujjwalmishra0/social-app/master/screenshots/other-profile2.jpg" alt="feed example"  >

<img width="300"  src="https://raw.githubusercontent.com/0ujjwalmishra0/social-app/master/screenshots/search.jpg" alt="search" >

<img width="300"  src="https://raw.githubusercontent.com/0ujjwalmishra0/social-app/master/screenshots/post.jpg" alt="post screen"  >

<img width="300"  src="https://raw.githubusercontent.com/0ujjwalmishra0/social-app/master/screenshots/post3.jpg" alt="post"  >

<img width="300"  src="https://raw.githubusercontent.com/0ujjwalmishra0/social-app/master/screenshots/message.jpg" alt="chat" >

</p>


## Getting started


#### 1. [Setup Flutter](https://flutter.io/setup/)

#### 2. Clone the repo



```sh
$ git clone https://github.com/0ujjwalmishra0/social-app
```

#### 3. Setup the firebase app

1. You'll need to create a Firebase instance. Follow the instructions at https://console.firebase.google.com.
2. Once your Firebase instance is created, you'll need to enable anonymous authentication.

* Go to the Firebase Console for your new instance.
* Click "Authentication" in the left-hand menu
* Click the "sign-in method" tab
* Click "Google" and enable it


4. Enable the Firebase Database
* Go to the Firebase Console
* Click "Database" in the left-hand menu
* Click the Cloudstore "Create Database" button
* Select "Start in test mode" and "Enable"

5. (skip if not running on Android)

* Create an app within your Firebase instance for Android, with package name com.mohak.instagram
* Run the following command to get your SHA-1 key:

```
keytool -exportcert -list -v \
-alias androiddebugkey -keystore ~/.android/debug.keystore
```

* In the Firebase console, in the settings of your Android app, add your SHA-1 key by clicking "Add Fingerprint".
* Follow instructions to download google-services.json
* place `google-services.json` into `/android/app/`.


6. (skip if not running on iOS)

* Create an app within your Firebase instance for iOS, with your app package name
* Follow instructions to download GoogleService-Info.plist
* Open XCode, right click the Runner folder, select the "Add Files to 'Runner'" menu, and select the GoogleService-Info.plist file to add it to /ios/Runner in XCode
* Open /ios/Runner/Info.plist in a text editor. Locate the CFBundleURLSchemes key. The second item in the array value of this key is specific to the Firebase instance. Replace it with the value for REVERSED_CLIENT_ID from GoogleService-Info.plist

Double check install instructions for both
   - Google Auth Plugin
     - https://pub.dartlang.org/packages/firebase_auth
   - Firestore Plugin
     -  https://pub.dartlang.org/packages/cloud_firestore
