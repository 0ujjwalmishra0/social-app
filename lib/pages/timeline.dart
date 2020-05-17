import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/models/user.dart';
import 'package:insta_clone/pages/chat_overview_screen.dart';
import 'package:insta_clone/pages/insta_screen.dart';
import 'package:insta_clone/widgets/post.dart';
import 'package:insta_clone/widgets/progress.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

final usersRef = Firestore.instance.collection('users');
final timelineRef = Firestore.instance.collection('timeline');
final pagecontroller = PageController(
  initialPage: 0,
);
String currUser;
class Timeline extends StatefulWidget {

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;

     getCurrentUser() async {
    await FirebaseAuth.instance.currentUser().then((user) {
      currUser = user.uid;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    getTimeline();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(currUser)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    print('current user id in timeline ${currUser}');

    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts  = posts;
    });
  
  }

  final pageView = PageView(
    controller: pagecontroller,
    children: [
      InstaScreen(),
      ChatOverview(),
    ],
  );
buildTimeline(){
  if(posts == null){
    return circularProgress();
  }
  return ListView(children: posts,);
}
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Color(0xfff8faf8),
        centerTitle: true,
        elevation: 1,
        leading: Icon(MdiIcons.camera),
        title: SizedBox(
          height: 35,
          child: Image.asset('assets/images/insta_appbar.png'),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
              icon: Icon(MdiIcons.send),
              onPressed: (){},
              // onPressed: () => Navigator.of(context)
              //     .push(CustomRouteRoute(builder: (ctx) => ChatOverview())),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(child: buildTimeline(), onRefresh: ()=> getTimeline()),
    );
  }
}
