import 'dart:convert';
import 'dart:math';

import 'package:kookout/config/default_config.dart';
import 'package:kookout/models/extract_hash_tag_details.dart';
import 'package:kookout/models/hash_tag.dart';
import 'package:kookout/models/responses/chat_api_get_profile_posts_response.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable/functions.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../post.dart';

class PostController {
  String authBaseUrl = "";

  List<Post> postsFuture = [];

  PostController.init() {
    authBaseUrl = DefaultConfig.theAuthBaseUrl;

    getPosts().then((thePosts) {
      postsFuture = thePosts;
    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (kDebugMode) {
          print('postController: User is currently signed out!');
        }
      } else {
        if (kDebugMode) {
          print('postController: User is signed in!');
        }
        postsFuture = await getPosts();
      }
    });
  }

  Future<Post?> fetchHighlightedPost() async {
    var thePosts = await getPosts();
    postsFuture = thePosts;

    if (thePosts.isNotEmpty) {
      thePosts.removeWhere((element) {
        if (element.mainImage == null) {
          return true;
        }
        return false;
      });

      if(thePosts.isNotEmpty) {
        var rng = Random();
        rng.nextInt(thePosts.length);
        if (kDebugMode) {
          print("Te posts are not empty ${thePosts.length}");
        }

          return thePosts[rng.nextInt(thePosts.length)];

      }
    }

    return null;
  }

  Future<List<Post>> getPosts() async {
    // if (kDebugMode) {
    //   print("Retrieving Posts $userId");
    // }
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null && authBaseUrl != "" && authBaseUrl != "") {
      final response = await http.get(Uri.parse("$authBaseUrl/get-all-posts"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse;
      try {
        processedResponse = jsonDecode(response.body);
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
      }

      // if (kDebugMode) {
      //   print(processedResponse);
      // }
      if (processedResponse['posts'] != null) {
        ChatApiGetProfilePostsResponse responseModel =
            ChatApiGetProfilePostsResponse.fromJson(processedResponse['posts']);
        // if (kDebugMode) {
        //   print("get posts api response ${responseModel.list}");
        // }

        // for (var element in responseModel.list) {
        //   if (kDebugMode) {
        //     print(element);
        //   }
        // }

        return responseModel.list;
      } else {
        return [];
      }
    }
    return [];
  }

  Future<String> createPost(
      String postBody, String filename, fileBytes, BuildContext context) async {
    var message = "Post request by ${FirebaseAuth.instance.currentUser?.uid}";
    if (kDebugMode) {
      print(message);
    }
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null) {
      var request =
          http.MultipartRequest('POST', Uri.parse("$authBaseUrl/create-post"));

      request.headers.addAll({"authorization": "Bearer $token"});

      if (filename != "") {
        request.files.add(http.MultipartFile.fromBytes('file', fileBytes,
            contentType: MediaType('application', 'octet-stream'),
            filename: filename));
      }

      // if (loggedInUser?.email != username) {
      request.fields['postBody'] = postBody;
      var hashtags = [];

      extractHashTags(postBody).forEach((element) {
        hashtags.add(element.replaceFirst("#", ''));
      });

      print("hashtags $hashtags ${jsonEncode(hashtags)}");

      request.fields['hashtags'] = jsonEncode(hashtags);

      // }

      await request.send();
      // if (kDebugMode) {
      //   print("post controller api response$response");
      // }

      return "SUCCESS";
    } else {
      if (kDebugMode) {
        print("Cannot update user no token present...");
      }
    }
    return "FAIL";
  }

  Future<Post?> getPost(String postId) async {
    // if (kDebugMode) {
    //   print("Retrieving Posts $userId");
    // }
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null && authBaseUrl != "" && authBaseUrl != "") {
      final response = await http.get(Uri.parse("$authBaseUrl/get-post/$postId"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse;
      try {
        processedResponse = jsonDecode(response.body);
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
        if (kDebugMode) {
          print(processedResponse);
        }
        if(processedResponse == null) {
          return null;
        }
      }

      // if (kDebugMode) {
      //   print(processedResponse);
      // }
      if (processedResponse['post'] != null) {
        // print("postResponse ${processedResponse['post']}");
        Post responseModel = Post.fromJson(processedResponse['post']);
        // if (kDebugMode) {
        //   print("get posts api response ${responseModel.list}");
        // }

        // for (var element in responseModel.list) {
        //   if (kDebugMode) {
        //     print(element);
        //   }
        // }

        return responseModel;
      } else {
        return null;
      }
    }
    return null;
  }
}
