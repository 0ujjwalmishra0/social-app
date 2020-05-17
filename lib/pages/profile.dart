/**
 * During navigating from search, widget.profile id works
 * userId and profile id is different when we search diff user
 * and go to their profile page
 */

/**
 * When user goes to his own profile from bottomNavigation, profile id is null
 * When user goes to his own profile through search , profile id works fine
 */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/models/user.dart';
import 'package:insta_clone/pages/chats.dart';
import 'package:insta_clone/pages/create_account.dart';
import 'package:insta_clone/pages/edit_profile.dart';

import 'package:insta_clone/pages/login_screen.dart';
import 'package:insta_clone/pages/show_follow_screen.dart';
import 'package:insta_clone/pages/upload.dart';
import 'package:insta_clone/widgets/app_drawer.dart';
import 'package:insta_clone/widgets/post.dart';
import 'package:insta_clone/widgets/post_tile.dart';
import 'package:insta_clone/widgets/progress.dart';

import '../models/custom_route.dart';

String userId;
DocumentSnapshot users;
User user;

class Profile extends StatefulWidget {
  final String profileId;
  final String profileUsername;
  final String isProfileVerified;
  String appbarUsername;
  Profile({
    this.profileId,
    this.profileUsername,
    this.isProfileVerified,
  });

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  String postOrientation = 'grid';

  int followerCount = 0;
  int followingCount = 0;
  String isVerified;

  Map<String, String> currentUserData = {
    'photourl': '',
    'bio': '',
    'username': '',
    'displayName': '',
    'id': '',
    'email': '',
    'timestamp': '',
    'isVerified': ''
  };

  @override
  void initState() {
    getCurrentUser();
    getUsersById();
    getProfilePosts();

    getFollowers();
    getFollowing();
    checkIfFollowing();
    // handleFollowUjjwal();
    super.initState();
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();

    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  checkIfFollowing() async {
    //checking if we exists as a follower of them
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(userId)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  getUsersById() async {
    users = await usersRef.document(userId).get();

    currentUserData['email'] = users.data['email'];
    currentUserData['photourl'] = users.data['photourl'];
    currentUserData['username'] = users.data['username'];
    currentUserData['displayName'] = users.data['displayName'];
    currentUserData['bio'] = users.data['bio'];
    currentUserData['isVerified'] = users.data['isVerified'];
    currentUserData['id'] = users.data['id'];
  }

  getCurrentUser() async {
    await FirebaseAuth.instance.currentUser().then((user) {
      userId = user.uid;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    print('user id is: $userId');
    print('widget.profile id is: ${widget.profileId}');
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        // .document(userId)
        .collection('usersPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
      print(posts);
    });
  }

  buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            color: Color(0xff454647),
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 2.5),
          child: Text(
            label,
            style: TextStyle(
              color: Color(0xff808792),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.of(context)
        .push(CustomRoute(builder: (ctx) => EditProfile(userId)));
  }

  // Container buildButton({String text, Function function}) {
  //   return Container(
  //     padding: EdgeInsets.only(top: 2),
  //     child: FlatButton(
  //       onPressed: function,
  //       child: Container(
  //         width: 230,
  //         height: 22.5,
  //         child: Text(
  //           text,
  //           style: TextStyle(
  //             //if is following make text black(on white background)
  //             // else white text  (on blue background)
  //             color: isFollowing ? Colors.black : Colors.white,
  //             // fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //           color: isFollowing ? Colors.white : Colors.blue,
  //           border: Border.all(
  //             color: isFollowing ? Colors.grey : Colors.blue,
  //           ),
  //           borderRadius: BorderRadius.circular(5),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  buildButton({String text, Function function}) {
    return RaisedButton(
      elevation: 2.3,
      onPressed: function,
      child: Text(
        text,
        style: TextStyle(
          color: isFollowing ? Colors.black : Colors.white,
        ),
      ),
      color: isFollowing ? Color(0xfff8faf8) : Color(0xffE25E60),
    );
  }

  buildProfileBtn() {
    // if viewing your profile show profiel edit bttn
    // bool isProfileOwner = userId == currentUserData['id'];

    bool isProfileOwner = userId == widget.profileId;
    // return buildButton(text: 'Edit Profile', function: editProfile);
    if (isProfileOwner) {
      //if profile owner,dont show edit profile button
      return null;
      // buildButton(text: 'Edit Profile', function: editProfile);
    } else if (isFollowing) {
      return buildButton(text: 'Unfollow', function: handleUnfollowUser);
    } else if (!isFollowing) {
      return buildButton(text: 'Follow', function: handleFollowUser);
    }
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(userId)
        .setData({});
    //Put that user on your following collection (update your following collection)

    followingRef
        .document(userId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});

    //add activity feed item for that user to notify about new follower(us)
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(userId)
        .setData({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': users.data['username'],
      'userId': userId,
      'userProfileImg': users.data['photourl'],
      'timestamp': DateTime.now(),
    });
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });

    //remove followers
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //remove following

    followingRef
        .document(userId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //delete activity feed item for them

    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: (userId == widget.profileId)
          ? usersRef.document(userId).get()
          : usersRef.document(widget.profileId).get(),
      // future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        user = User.fromDocument(snapshot.data);

        return
            // Center(
            // child:
            Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment(1.42, 0.8),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: CircularProfileAvatar(
                    '',
                    radius: 60,
                    elevation: 4,
                    child: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                    ),
                  ),
                ),
                Container(
                  height: 28,
                  child: FloatingActionButton(
                    elevation: 4,
                    backgroundColor: Color(0xffE25E60),
                    onPressed: editProfile,
                    child: Icon(
                      Icons.add,
                    ),
                  ),
                )
              ],
            ),
            // Text(
            //   '@${user.username}',
            //   style: TextStyle(fontSize: 25),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Text(
                  //   user.displayName,
                  //   style: TextStyle(
                  //       fontFamily: 'OpenSans',
                  //       color: Color(0xff454647),
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.w600),
                  // ),
                  VerticalDivider(
                    width: 1,
                  ),
                  widget.profileUsername != null
                      ? Text(
                          ' @${widget.profileUsername}',
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              color: Color(0xff454647),
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        )
                      : Text(
                          ' @${currentUserData['username']}',
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              color: Color(0xff454647),
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),

                  // Text(''),

                  buildappBar(
                    //  currentUserData['isVerified']
                    widget.isProfileVerified != null
                        ? widget.isProfileVerified
                        : currentUserData['isVerified'],
                  ),
                  // VerticalDivider(color: Colors.red,thickness: 21,width: 0,),
                ],
              ),
            ),

            //displaying username
            // Text(
            //   user.displayName,
            //   style: TextStyle(color: Color(0xff808792)),
            // ),
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 200,
                ),
                child: Text(
                  user.bio,
                  textAlign: TextAlign.center,
                )),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: buildProfileBtn(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child:
                      //if profile owner,then dont show message button
                      userId == widget.profileId
                          ? null
                          : RaisedButton(
                              elevation: 2.8,
                              onPressed: () => showmessage(context,
                                  senderId: userId,
                                  receiverId: widget.profileId,
                                  receiverPhotoUrl: user.photoUrl),
                              child: Text(
                                'Message',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Color(0xffE25E60),
                            ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical:15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  buildCountColumn('posts', postCount),
                  Container(
                      height: 21,
                      child: VerticalDivider(
                        color: Colors.grey,
                        width: 0,
                        thickness: 0.5,
                      )),
                  buildCountColumn('followers', followerCount),
                  Container(
                      height: 21,
                      child: VerticalDivider(
                        color: Colors.grey,
                        width: 0,
                        thickness: 0.5,
                      )),
                  buildCountColumn('following', followingCount),
                ],
              ),
            ),
          ],
        );

        // return Padding(
        //   padding: EdgeInsets.all(15),
        //   child: Column(
        //     children: <Widget>[
        //       Row(
        //         children: <Widget>[
        //           CircleAvatar(
        //             radius: 45,
        //             backgroundImage: CachedNetworkImageProvider(user.photoUrl),
        //           ),
        //           Expanded(
        //             flex: 1,
        //             child: Column(
        //               children: <Widget>[
        //                 Row(
        //                   mainAxisSize: MainAxisSize.max,
        //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //                   children: <Widget>[
        //                     buildCountColumn('posts', postCount),
        //                     // GestureDetector(child: buildCountColumn('followers', followerCount),
        //                     // onTap: (){
        //                     //   Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> ShowFollowers(userId)));
        //                     // },),
        //                     buildCountColumn('followers', followerCount),
        //                     buildCountColumn('following', followingCount),
        //                   ],
        //                 ),
        //                 SizedBox(
        //                   height: 12,
        //                 ),
        //                 Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //                   children: <Widget>[
        //                     buildProfileBtn(),
        //                   ],
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //       // Container(
        //       //   alignment: Alignment.centerLeft,
        //       //   padding: EdgeInsets.only(top: 13),
        //       //   child: Text(
        //       //     currentUserData['username'],
        //       //     style: TextStyle(
        //       //       fontWeight: FontWeight.bold,
        //       //       fontSize: 16,
        //       //     ),
        //       //   ),
        //       // ),
        //       Container(
        //         alignment: Alignment.centerLeft,
        //         padding: EdgeInsets.only(top: 4),
        //         child: Row(
        //           children: <Widget>[
        //             Text(
        //               // currentUserData['displayName'],
        //               user.displayName,
        //               style: TextStyle(
        //                 fontWeight: FontWeight.bold,
        //                 fontSize: 16,
        //               ),
        //             ),
        //             Text('  '),
        //             Container(
        //               height: 18,
        //               // child: Image.asset('assets/images/approval-blue.png'),
        //             ),
        //           ],
        //         ),
        //       ),
        //       Container(
        //         alignment: Alignment.centerLeft,
        //         padding: EdgeInsets.only(top: 2),
        //         child: Text(
        //           // currentUserData['bio'],
        //           user.bio,
        //         ),
        //       ),
        //     ],
        //   ),
        // );
      },
    );
  }

  buildProfilePost() {
    List<GridTile> gridTiles = [];

    posts.forEach((post) {
      gridTiles.add(GridTile(child: PostTile(post)));
    });

    if (isLoading) {
      return circularProgress();
    }
    // else if (posts.isEmpty) {
    //   return Container(
    //     child: Image.asset('assets/images/no_post'),
    //   );
    // }
    else if (postOrientation == 'grid') {
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  Row buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.grid_on,
            color: postOrientation == 'grid' ? Colors.black : Colors.grey,
          ),
          onPressed: () => setPostOrientation('grid'),
        ),
        IconButton(
          icon: Icon(
            Icons.list,
            size: 30,
            color: postOrientation == 'list' ? Colors.black : Colors.grey,
          ),
          onPressed: () => setPostOrientation('list'),
        ),
      ],
    );
  }

  buildappBar(String isVerified) {
    String image;

    if (isVerified == '1') {
      image = 'assets/images/approval-blue.png';
    } else if (isVerified == '2') {
      image = 'assets/images/approval-red.png';
    } else
      image = '';

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text('ujjwal kumarc  '),
          Column(
            children: <Widget>[
              Container(
                height: 16,
                child: Image.asset(image),
              ),
            ],
          ),
        ],
      ),
    );
  }

  showmessage(BuildContext context,
      {String senderId,
      String receiverId,
      String username,
      String receiverPhotoUrl}) {
    Navigator.of(context).push(
      CustomRoute(builder: (ctx) {
        return Chats(
          // postId: postId,
          // postOwnerId: ownerId,
          // postMediaUrl: mediaUrl,
          receiverPhotoUrl: receiverPhotoUrl,
          senderId: userId,
          receiverId: widget.profileId,
          username: username,
        );
      }),
    );
  }

  updateProfile() async{
       getCurrentUser();
        getUsersById();
        getProfilePosts();

        getFollowers();
        getFollowing();
        checkIfFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: AppDrawer(currentUserData['username']),
      appBar: AppBar(
        title: Text(
          '',
          // user.displayName,
          style: TextStyle(
              fontFamily: 'OpenSans',
              color: Color(0xff454647),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),


        backgroundColor: Colors.white,
        // Color(0xfff8faf8),
        brightness: Brightness.light,
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: ()=> updateProfile(),
              child: ListView(
          children: <Widget>[
            buildProfileHeader(),
            Divider(
              height: 0,
            ),
            buildTogglePostOrientation(),
            Divider(
              height: 0,
            ),
            isFollowing ? buildProfilePost(): Text('First follow user'),
          ],
        ),
      ),
    );
  }
}
