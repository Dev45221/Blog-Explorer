import 'dart:async';
import 'dart:convert';

import 'package:blog_explorer/pages/DetailPage.dart';
import 'package:blog_explorer/pages/WebPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

class BlogPage extends StatefulWidget {
  static late Map mapResponse;
  static List<dynamic> listResponse = [];
  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {

  String title = "";
  bool visible = true;

  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    // TODO: implement initState
    getConnectivity();
    fetchBlogs();
    Timer(const Duration(seconds: 10), () {
      setState(() {
        visible = false;
      });
    });
    super.initState();
  }

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && isAlertSet == false) {
          showDialogBox();
          setState(() => isAlertSet = true);
        }
      });

  showDialogBox() => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('No Connection'),
      content: const Text('Please check your internet connectivity'),
      icon: const Icon(Icons.signal_wifi_connected_no_internet_4_outlined, size: 30,),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Cancel');
            setState(() => isAlertSet = false);
            isDeviceConnected = await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
              showDialogBox();
              setState(() => isAlertSet = true);
            }
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  @override
  void dispose() {
    // TODO: implement dispose
    subscription.cancel();
    super.dispose();
  }

  void fetchBlogs() async {
    const String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
    const String adminSecret = '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'x-hasura-admin-secret': adminSecret,
      });

      if (response.statusCode == 200) {
        // Request successful, handle the response data here
        // print('Response data: ${response.body}');
        BlogPage.mapResponse = jsonDecode(response.body);
        BlogPage.listResponse = BlogPage.mapResponse['blogs'];
        // listResponse = mapResponse!['blogs'];
      } else {
        // Request failed
        // print('Request failed with status code: ${response.statusCode}');
        // print('Response data: ${response.body}');
        Fluttertoast.showToast(
            gravity: ToastGravity.CENTER,
            textColor: Colors.white,
            backgroundColor: Colors.grey,
            toastLength: Toast.LENGTH_LONG,
            msg: "Request failed with status code: ${response.statusCode}\nResponse data: ${response.body}"
        );
      }
    } catch (e) {
      // Handle any errors that occurred during the request
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/subspace.png', width: 160,),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 30,),
            itemBuilder: (context) => [
              PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.open_in_new_rounded,),
                    title: const Text("Website"),
                    subtitle: const Text("Open in App"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => WebPage()));
                    },
                  )
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.teal.shade50,
      body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  width: double.maxFinite,
                  height: 75,
                  color: Colors.teal,
                  child: const Text("BLOGS", style: TextStyle( fontSize: 70, letterSpacing: 20.0, color: Colors.white, fontWeight: FontWeight.w900 ),),
                ),
                if (visible)
                  const SizedBox(width: double.maxFinite, height: 200,child: Center(child: SpinKitDualRing(color: Colors.teal,))),
                SizedBox(
                  width: 360,
                  height: double.maxFinite,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemExtent: 300,
                      itemCount: getItemCount(),
                      itemBuilder: (context, index) {
                        final blogIndex = BlogPage.listResponse[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Hero(
                            tag: blogIndex.toString(),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(blogIndex: blogIndex)));
                                Fluttertoast.showToast(
                                    textColor: Colors.white,
                                    backgroundColor: Colors.black54,
                                    gravity: ToastGravity.BOTTOM,
                                    toastLength: Toast.LENGTH_SHORT,
                                    msg: BlogPage.listResponse[index]['title']
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.teal.shade100.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                        color: Colors.teal,
                                        width: 1.0
                                    )
                                ),
                                child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          getImage(index),
                                          getTitle(index),
                                        ],
                                      ),
                                    )
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
    );
  }

  int getItemCount() {
    try {
      return BlogPage.listResponse.length;
    } catch(e) {
      print(e);
    }
    return 0;
  }

  Widget getImage(int index) {
    try {
      return SizedBox(
        width: 360,
        height: 180,
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CachedNetworkImage(
                imageUrl: BlogPage.listResponse[index]['image_url'], fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: imageProvider),
                  ),
                ),
                placeholder: (context, url) => const SizedBox(
                  width: 360,
                  height: 180,
                  child: SpinKitThreeBounce(color: Colors.teal,),
                ),
              )
          ),
        ),
      );
    }catch (e) {
      print(e);
    }
    return const SpinKitRipple(color: Colors.teal);
  }

  Widget getTitle(int index) {
    try {
      title = BlogPage.listResponse[index]['title'].toString();
      return Padding(
        padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
        child: Text(title, style: const TextStyle( fontSize: 16, fontWeight: FontWeight.w700 ),),
      );
    }catch (e) {
      print(e);
    }
    return const SpinKitDualRing(color: Colors.teal);
  }
  
}