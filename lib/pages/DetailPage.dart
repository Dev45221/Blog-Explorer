import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DetailPage extends StatelessWidget {
  final dynamic blogIndex;

  DetailPage({super.key, required this.blogIndex});
  String website = "https://subspace.money/";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/subspace.png', width: 160,),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.maxFinite,
            height: 250,
            color: Colors.teal.shade100.withOpacity(0.8),
            child: Hero(
                tag: 'image_url',
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CachedNetworkImage(
                    imageUrl: blogIndex['image_url'], fit: BoxFit.fill,
                    imageBuilder: (context, imageProvider) => SizedBox(
                      width: double.maxFinite,
                      height: 250,
                      child: Container(
                        width: double.maxFinite,
                        height: 250,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imageProvider
                            )
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const SizedBox(
                      width: double.maxFinite,
                      height: 250,
                      child: SpinKitThreeBounce(color: Colors.teal,),
                    ),
                  ),
                )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Id: ${blogIndex['id']}", style: const TextStyle( fontSize: 14, ),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(blogIndex['title'], style: const TextStyle( fontSize: 20, fontWeight: FontWeight.w700 ),),
          ),
          const Divider(thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: FaIcon(FontAwesomeIcons.solidHeart, size: 30, color: Colors.teal,),
                ),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Share"),
                        icon: const FaIcon(FontAwesomeIcons.share, size: 22,),
                        content: Text("Blog title:-\n${blogIndex['title']}"),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final uri = Uri.parse(blogIndex['image_url']);
                                final response = await http.get(uri);
                                final bytes = response.bodyBytes;
                                final temp = await getTemporaryDirectory();
                                final path = '${temp.path}/image.jpg';
                                File(path).writeAsBytes(bytes);

                                await Share.shareFiles([path],
                                    text: "\n${blogIndex['title']}\n\n$website");
                              },
                              child: const Text("Yes")
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("No")
                          )
                        ],
                      )
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: FaIcon(FontAwesomeIcons.share, size: 30, color: Colors.teal,),
                ),
              ),
            ],
          ),
          const Divider(thickness: 0.5),
        ],
      ),
    );
  }
}