import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupet/blocs/user_bloc.dart';
import 'package:cupet/helper/utils.dart';
import 'package:cupet/modules/TinderCard.dart';
import 'package:cupet/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final controller = CardController();
  bool hasMoreImages = true;
  int indexSwipe = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    final userData = Provider.of<UserBloc>(context);

    final queryList = List.from(userData.likedImages);
    queryList.addAll(List.from(userData.dislikedImages));
    queryList.add(userData.userID);
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getProportionateScreenHeight(20)),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Images')
                  .where('uid',
                      whereNotIn: queryList.isEmpty ? null : queryList)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return Container(
                    height: 0.8 * height,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final data = snapshot.data.docs;
                data.removeWhere((snap) => snap.data()['uid'] == null);
                if (data == null || data.isEmpty || !hasMoreImages) {
                  return Container(
                    height: 0.8 * height,
                    child: Center(
                      child: Text(
                        'No more images',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }
                return Container(
                  margin: EdgeInsets.only(top: 10),
                  height: size.height * 0.8,
                  child: TinderSwapCard(
                    orientation: AmassOrientation.BOTTOM,
                    totalNum: data.length,
                    currentIndex: 0,
                    stackNum: 3,
                    maxWidth: size.width * 0.99,
                    maxHeight: size.height * 0.95,
                    minWidth: size.width * 0.9,
                    minHeight: size.height * 0.8,
                    cardController: controller,
                    swipeDown: false,
                    swipeUp: false,
                    swipeUpdateCallback:
                        (DragUpdateDetails details, Alignment align) {
                      if (align.x < 0) {
                        // print('Left Swiping');
                        //  Card is LEFT swiping.
                      } else if (align.x > 0) {
                        // print('Right Swiping');
                        //  Card is RIGHT swiping.
                      }
                    },
                    swipeCompleteCallback:
                        (CardSwipeOrientation orientation, int index) {
                      if (orientation == CardSwipeOrientation.LEFT) {
                        // Right 2 Left
                        userData.dislikeImage(data[index].data()['uid']);
                        console('Hated!');
                      } else if (orientation == CardSwipeOrientation.RIGHT) {
                        // Left 2 Right
                        userData.likeImage(data[index].data()['uid']);

                        console('Liked !');
                      }

                      if ((index + 1) == data.length) {
                        setState(() {
                          hasMoreImages = false;
                        });
                      } else {
                        setState(() {
                          indexSwipe++;
                          // print(indexSwipe);
                        });
                      }
                    },
                    cardBuilder: (BuildContext context, int index) {
                      return Stack(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            width: 1 * width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(
                                image: Image(
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  // placeholder: Image.asset(
                                  //   'images/LikeButton/image/grey.jpg',
                                  // ).image,
                                  image: Image.network(
                                    data[index].data()['imageUrl'],
                                    // fit: BoxFit.cover,
                                  ).image,
                                ).image,
                                fit: BoxFit.cover,
                              ),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.bottomLeft,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            )

            // HomeHeader(),
            // SizedBox(height: getProportionateScreenWidth(10)),
            // DiscountBanner(),
            // Categories(),
            // SpecialOffers(),
            // SizedBox(height: getProportionateScreenWidth(30)),
            // PopularProducts(),
            // SizedBox(height: getProportionateScreenWidth(30)),
          ],
        ),
      ),
    );
  }
}
