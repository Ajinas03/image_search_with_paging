import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_search_with_paging/model/image_search_response_model.dart';
import 'package:image_search_with_paging/screens/view_image_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Hit>? imageList = [];

  int pageNo = 1;

  ScrollController _scrollController = ScrollController();

  TextEditingController _searChTextController = TextEditingController();

  Future<void> getSearchImages(
      {required String searchTerm, required bool isPaging}) async {
    var url =
        "https://pixabay.com/api/?key=31949211-4cf14c9ec02c72ea39f147854&q=$searchTerm&image_type=photo&per_page=10&page=$pageNo";

    var response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      print(url);
      print(json.decode(response.body));
      var jsonData = json.decode(response.body);

      ImageSearchResponseModel imageSearchResponseModel =
          ImageSearchResponseModel.fromJson(jsonData);

      if (isPaging == false) {
        setState(() {
          imageList = imageSearchResponseModel.hits;
        });
      } else {
        setState(() {});
        imageList!.addAll(imageSearchResponseModel.hits!);
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: TextField(
                      controller: _searChTextController,
                      decoration: InputDecoration(
                        hintText: "Search",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (val) {
                        pageNo = 1;
                        getSearchImages(searchTerm: val, isPaging: false);
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollStartNotification) {
                          // _onStartScroll(scrollNotification.metrics);
                        } else if (scrollNotification
                            is ScrollUpdateNotification) {
                          // _onUpdateScroll(scrollNotification.metrics);
                        } else if (scrollNotification
                            is ScrollEndNotification) {
                          // _onEndScroll(scrollNotification.metrics);

                          pageNo++;
                          getSearchImages(
                              isPaging: true,
                              searchTerm: _searChTextController.text);

                          print("at scroll end");
                        }
                        return true;
                      },
                      child: GridView.builder(
                        controller: _scrollController,
                        itemCount: imageList!.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 3
                              : 2,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 8,
                          // childAspectRatio: (2 / 1),
                        ),
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ViewImageScreen(
                                          url: imageList![index]
                                              .webformatUrl
                                              .toString());
                                    },
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            imageList![index]
                                                .largeImageUrl
                                                .toString(),
                                          ),
                                          fit: BoxFit.cover),
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                  ),
                                  Positioned(
                                    top: 0,
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              25,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      color: Colors.white.withOpacity(0.3),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    imageList![index]
                                                        .userImageUrl
                                                        .toString()),
                                                radius: 10,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(imageList![index]
                                                  .user
                                                  .toString()),
                                            ],
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              25,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      color: Colors.white.withOpacity(0.3),
                                      child: Row(
                                        children: [
                                          // Expanded(
                                          //     child: Row(
                                          //   children: [
                                          //     CircleAvatar(
                                          //       radius: 10,
                                          //     ),
                                          //     Text(imageList![index]
                                          //         .user
                                          //         .toString()),
                                          //   ],
                                          // )),
                                          Expanded(
                                              child: Row(
                                            children: [
                                              Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                              ),
                                              Text(imageList![index]
                                                  .likes
                                                  .toString()),
                                            ],
                                          )),
                                          Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.chat,
                                                    color: Colors.black,
                                                  ),
                                                  Text(imageList![index]
                                                      .comments
                                                      .toString()),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
