import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:insta_clone/models/user.dart';
import 'package:insta_clone/pages/create_account.dart';
import 'package:insta_clone/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import '../pages/upload.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile(this.currentUserId);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // scaffold key is of type ScaffoldState()
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  User user;
  bool _isdisplayNameValid = true;
  bool _bioValid = true;
  bool isProfileImageSelected;
  String currentPhotoUrl;

  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  File file;
  var photoUrl;
  bool isUploading = false;
  // unique id by using Uuid package
  String postId = Uuid().v4();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;

    setState(() {
      isLoading = false;
    });
  }

  buildTextField(
      TextEditingController textcontroller, String hintText, String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Padding(
        //   padding: EdgeInsets.only(top: 12),
        //   child: Text(
        //     'Full Name',
        //   ),
        // ),
        TextFormField(
          controller: textcontroller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(height: 1.72, fontSize: 15),
            labelText: labelText,
            errorText: _isdisplayNameValid ? null : 'Full Name too short!',
            labelStyle: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  buildTextField2(
      TextEditingController textcontroller, String hintText, String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          controller: textcontroller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(height: 1.72, fontSize: 15),
            labelText: labelText,
            errorText: _bioValid ? null : 'Bio too long!',
            labelStyle: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Future updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 2 ||
              displayNameController.text.isEmpty
          ? _isdisplayNameValid = false
          : _isdisplayNameValid = true;

      bioController.text.trim().length > 120
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_isdisplayNameValid && _bioValid) {
      usersRef.document(widget.currentUserId).updateData({
        'displayName': displayNameController.text,
        'bio': bioController.text,
      });
      // onSuccess show a SnackBar
      SnackBar snackBar = SnackBar(
        content: Text('Profile Updated'),
      );

      handleSubmit()
          .whenComplete(
        () {
          _scaffoldKey.currentState.showSnackBar(snackBar);
          // final doc2 = usersRef.document(widget.currentUserId).get().then((doc){
          //   setState(() {
          //     currentPhotoUrl =doc.data['photourl'];
          //   });
          // });
        }
    


      )
          .catchError((onError) {
        clearImage();
        snackBar = SnackBar(content: Text('Profile could not be Updated!'));

        _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    }
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    //ImagePicker is a dependency and it is an async operation
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    //ImagePicker is a dependency and it is an async operation
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      // maxHeight: 675,
      // maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  selectImage(BuildContext ctx) {
    setState(() {
      isProfileImageSelected = true;
    });
    return showDialog(
        context: ctx,
        builder: (ctx) {
          return SimpleDialog(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text('Image from Gallery'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: Navigator.of(ctx).pop,
              ),
            ],
          );
        });
  }

  clearImage() {
    setState(() {
      //making file null we will return to SplashScreen()
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());

    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imagefile) async {
    StorageUploadTask uploadTask =
        storageRef.child('post_$postId.jpg').putFile(imagefile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    //to get uploaded files url
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  updateProfilePic({String mediaUrl}) {
    usersRef.document(widget.currentUserId).updateData({
      'photourl': mediaUrl,
    });
    print('update profile pic executed');
  }

  Future handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    //take this mediaUrl and store in posts collection in firestore
    await updateProfilePic(
      mediaUrl: mediaUrl,
      // location: locationController.text,
      // description: captionController.text,
    );

    //reset file and isUploading
    setState(() {

      //earlier it is true

      // file = null;
      
      isUploading = false;
      postId = Uuid().v4();
    });
    print('submit button pressed');
  }

  @override
  buildImgSelectedScreen(isProfileImageSelected) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(fontFamily: 'OpenSans', color: Colors.black),
        ),
        backgroundColor: Color(0xfff8faf8),
        centerTitle: true,
        elevation: 1,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              size: 30,
              color: Colors.blue,
            ),
            onPressed: () {
              // updateProfileData().whenComplete(()=> clearImage());
              clearImage();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                isUploading ? linearProgress() : Text(''),
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: CircleAvatar(
                          backgroundColor: Color(0xfff8faf8),
                          radius: 80,
                          //if a new image is selected from gallery preview it in file
                          // otherwise show default profile image
                          backgroundImage: isProfileImageSelected
                              ? FileImage(file)
                              : CachedNetworkImageProvider(user.photoUrl),
                              // : CachedNetworkImageProvider(currentPhotoUrl),
                        ),
                      ),
                      OutlineButton(
                        onPressed: () {
                          selectImage(context);
                          // if(file!= null){
                          //   handleSubmit();
                          // }
                        },
                        borderSide: BorderSide.none,
                        child: Text(
                          'Change Profile Pic ',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            buildTextField(displayNameController,
                                'Update Full Name', 'Full Name'),
                            SizedBox(height: 7),
                            buildTextField2(bioController, 'Update Bio', 'Bio'),
                          ],
                        ),
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19)),
                        color: Colors.blue,
                        onPressed: () {
                          updateProfileData();
                          // handleSubmit();
                        },
                        child: Text(
                          'Update Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null
        ? buildImgSelectedScreen(false)
        : buildImgSelectedScreen(true);
  }
}
