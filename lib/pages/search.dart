import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:insta_clone/models/user.dart';
import 'package:insta_clone/pages/activity_feed.dart';
import 'package:insta_clone/pages/create_account.dart';
import 'package:insta_clone/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<QuerySnapshot> searchResultsFuture;
  TextEditingController searchController = TextEditingController();

  handleSearch(String query) {
    //need to save users in state.
    Future<QuerySnapshot> users = usersRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
      // enableInteractiveSelection: ,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search for a User...',
          hintStyle: TextStyle(height: 1.49),
          
          // filled: true,
          prefixIcon: Icon(Icons.search),
          suffixIcon: searchController.text.isEmpty ? null : IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => searchController.clear(),
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
          //ListView resizes itself
          child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/search.svg',
            height: orientation == Orientation.portrait ? 300 : 200,
          ),
          Text(
            "Find Users",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xffFF6346),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              fontSize: 60,
            ),
          )
        ],
      )),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);

  
  buildappBar(String isVer) {
    String image;
    if (isVer == '1') {
      image = 'assets/images/approval-blue.png';
    } else if (isVer == '2') {
      image = 'assets/images/approval-red.png';
    } else
      image = '';
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          
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


  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.green,
      child: Column(
        children: <Widget>[
          GestureDetector(
            // showProfile function from activity_feed.dart
            onTap: () {
              showProfile(context, profileId: user.id,profileusername: user.username,
              isVerified: user.isVerified
              );
              print('inside search ${user.displayName} id is: ${user.id} isVerified is ${user.isVerified}');
            },

            child: ListTile(
              leading: CircleAvatar(
                // backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.username,
                    style:
                        TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
                  ),
                  Text(' '),
                  buildappBar(user.isVerified),

                ],
              ),
              subtitle: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Divider(
            height: 2,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }
}
