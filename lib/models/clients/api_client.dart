import 'dart:convert';

import 'package:cookowt/models/hash_tag_collection.dart';
import 'package:cookowt/models/position.dart';
import 'package:cookowt/models/responses/chat_api_get_profile_posts_response.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hashtagable/functions.dart';
import 'package:http/http.dart' as http;

import '../../config/default_config.dart';
import '../app_user.dart';
import '../block.dart';
import '../comment.dart';
import '../extended_profile.dart';
import '../follow.dart';
import '../like.dart';
import '../post.dart';
import '../responses/auth_api_profile_list_response.dart';
import '../responses/chat_api_get_profile_block_response.dart';
import '../responses/chat_api_get_profile_comments_response.dart';
import '../responses/chat_api_get_profile_follows_response.dart';
import '../responses/chat_api_get_profile_likes_response.dart';
import '../responses/chat_api_get_timeline_events_response.dart';
import '../timeline_event.dart';

class ApiClient {
  String token = "";
  String apiVersion = "";
  String sanityDB = "";

  ApiClient(String endpointUrl) {
    FirebaseAuth.instance.currentUser?.getIdToken().then((theToken) {
      token = theToken;
    });
  }

  Future<String?> getIdToken() async {
    if (token != "") {
      if (kDebugMode) {
        print("Using cached Id Token");
      }
      return token;
    } else {
      if (kDebugMode) {
        print("Retrieving Id Token");
      }
      String? theToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (theToken != null) {
        token = theToken;
        return theToken;
      }
    }
    return null;
  }

  Future<dynamic> healthCheck() async {
    if (kDebugMode) {
      print("Api Health Check ${DefaultConfig.theAuthBaseUrl}");
    }
    final response = await http.get(
      Uri.parse("${DefaultConfig.theAuthBaseUrl}/health-endpoint"),
    );
    if (kDebugMode) {
      print("Api raw status ${response.body}");
    }
    dynamic processedResponse = jsonDecode(response.body);
    String theVersion = "";
    if (processedResponse['apiVersion'] != null &&
        processedResponse['apiVersion'] != "null") {
      theVersion = processedResponse['apiVersion'];
      apiVersion = theVersion;
    }
    String theSanityDB = "";
    if (processedResponse['sanityDB'] != null &&
        processedResponse['sanityDB'] != "null") {
      theSanityDB = processedResponse['sanityDB'];
      sanityDB = theSanityDB;
    }

    String theApiStatus = "";
    if (processedResponse['status'] != null &&
        processedResponse['status'] != "null") {
      if (processedResponse['status'] == "200") {
        theApiStatus = "UP";
      } else {
        theApiStatus = "DOWN";
      }
    }

    return {
      "apiVersion": theVersion,
      "sanityDB": theSanityDB,
      "status": theApiStatus
    };
  }

  Future<List<AppUser>> fetchProfiles() async {
    if (kDebugMode) {
      print("Retrieving Profiles");
    }
    String? token = await getIdToken();
    if (DefaultConfig.theAuthBaseUrl == "") {
      if (kDebugMode) {
        print(
            "Retrieving Profiles authBaseUrl empty ${DefaultConfig.theAuthBaseUrl}");
      }
      return <AppUser>[];
    }

    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/get-all-profiles"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);
      // print("Profiles retrieved ${processedResponse}");
      if (processedResponse['profiles'] != null &&
          processedResponse['profiles'] != "null") {
        AuthApiProfileListResponse responseModelList =
            AuthApiProfileListResponse.fromJson(processedResponse['profiles']);

        return responseModelList.list;
      }
    }
    return <AppUser>[];
  }

  Future<List<AppUser>> fetchProfilesPaginated(
      String? lastId, int pageSize) async {
    if (kDebugMode) {
      print(
          "Retrieving paginated Profiles with lastid $lastId and pagesize $pageSize");
    }
    String? token = await getIdToken();
    if (DefaultConfig.theAuthBaseUrl == "") {
      if (kDebugMode) {
        print(
            "Retrieving paginated Profiles authBaseUrl empty ${DefaultConfig.theAuthBaseUrl}");
      }
      return <AppUser>[];
    }

    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse(
              "${DefaultConfig.theAuthBaseUrl}/get-all-profiles-paginated/$pageSize${lastId != null ? "/$lastId" : ""}"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);
      // print("Profiles retrieved ${processedResponse}");
      if (processedResponse['profiles'] != null &&
          processedResponse['profiles'] != "null") {
        AuthApiProfileListResponse responseModelList =
            AuthApiProfileListResponse.fromJson(processedResponse['profiles']);

        return responseModelList.list;
      }
    }
    return <AppUser>[];
  }

  Future<List<Post>> fetchPostsPaginated(String? lastId, int pageSize) async {
    if (kDebugMode) {
      print(
          "Retrieving paginated Posts with lastid $lastId and pagesize $pageSize");
    }
    String? token = await getIdToken();
    if (DefaultConfig.theAuthBaseUrl == "") {
      if (kDebugMode) {
        print(
            "Retrieving paginated Profiles authBaseUrl empty ${DefaultConfig.theAuthBaseUrl}");
      }
      return <Post>[];
    }

    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse(
              "${DefaultConfig.theAuthBaseUrl}/get-all-posts-paginated/$pageSize${lastId != null ? "/$lastId" : ""}"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);
      // print("Profiles retrieved ${processedResponse}");
      if (processedResponse['posts'] != null &&
          processedResponse['posts'] != "null") {
        ChatApiGetProfilePostsResponse responseModelList =
            ChatApiGetProfilePostsResponse.fromJson(processedResponse['posts']);

        return responseModelList.list;
      }
    }
    return <Post>[];
  }

  Future<List<Post>> fetchHashtaggedPosts(
      String? hashtagId, String? lastId, int pageSize) async {
    if (kDebugMode) {
      print(
          "Retrieving paginated hashtagged with ${hashtagId} Posts with lastid $lastId and pagesize $pageSize");
    }
    String? token = await getIdToken();
    if (DefaultConfig.theAuthBaseUrl == "") {
      if (kDebugMode) {
        print(
            "Retrieving paginated hashtagged posts authBaseUrl empty ${DefaultConfig.theAuthBaseUrl}");
      }
      return <Post>[];
    }

    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse(
              "${DefaultConfig.theAuthBaseUrl}/get-hashtagged-posts-paginated/$hashtagId/$pageSize${lastId != null ? "/$lastId" : ""}"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);
      // print("hashtagged posts retrieved ${processedResponse}");
      if (processedResponse['posts'] != null &&
          processedResponse['posts'] != "null") {
        ChatApiGetProfilePostsResponse responseModelList =
            ChatApiGetProfilePostsResponse.fromJson(processedResponse['posts']);

        return responseModelList.list;
      }
    }
    return <Post>[];
  }

  Future<HashtagCollection?> fetchHashtagCollection(
      String? hashtagCollectionSlug) async {
    if (kDebugMode) {
      print("Retrieving hashtag collection ${hashtagCollectionSlug}");
    }
    String? token = await getIdToken();
    if (DefaultConfig.theAuthBaseUrl == "") {
      if (kDebugMode) {
        print(
            "Retrieving paginated hashtag collection authBaseUrl empty ${DefaultConfig.theAuthBaseUrl}");
      }
      return null;
    }

    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse(
              "${DefaultConfig.theAuthBaseUrl}/get-hashtag-collection-by-slug/$hashtagCollectionSlug"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);
      // print("hashtagged posts retrieved ${processedResponse}");
      if (processedResponse['hashtagCollection'] != null &&
          processedResponse['hashtagCollection'] != "null") {
        HashtagCollection responseModelList =
            HashtagCollection.fromJson(processedResponse['hashtagCollection']);

        return responseModelList;
      }
    }
    return null;
  }

  Future<List<Comment>> fetchCommentThreadPaginatedForPost(
      String? postId, String? lastId, int pageSize) async {
    if (kDebugMode) {
      print(
          "Retrieving paginated Post's $postId comments with lastid $lastId and pagesize $pageSize");
    }
    String? token = await getIdToken();

    if (DefaultConfig.theAuthBaseUrl == "") {
      if (kDebugMode) {
        print(
            "Retrieving paginated comments for post $postId authBaseUrl empty ${DefaultConfig.theAuthBaseUrl}");
      }
      return <Comment>[];
    }

    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse(
              "${DefaultConfig.theAuthBaseUrl}/get-comment-thread-paginated/$postId/$pageSize${lastId != null ? "/$lastId" : ""}"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);
      // print("Profiles retrieved ${processedResponse}");
      if (processedResponse['comments'] != null &&
          processedResponse['comments'] != "null") {
        ChatApiGetProfileCommentsResponse responseModelList =
            ChatApiGetProfileCommentsResponse.fromJson(
                processedResponse['comments']);

        return responseModelList.list;
      }
    }
    return <Comment>[];
  }

  Future<List<TimelineEvent>> retrieveTimelineEvents() async {
    if (kDebugMode) {
      print("Retrieving Timeline Events");
    }
    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/get-timeline-events"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['profileTimelineEvents'] != null) {
        ChatApiGetTimelineEventsResponse responseModel =
            ChatApiGetTimelineEventsResponse.fromJson(
                processedResponse['profileTimelineEvents']);
        if (kDebugMode) {
          print(
              "get timeline events api response ${responseModel.list.length}");
        }

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

  Future<List<Block>> getMyBlockedProfiles() async {
    if (kDebugMode) {
      print("Retrieving My Profile Blocks(blocked profiles)");
    }
    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/get-my-profile-blocks"),
          headers: {"Authorization": ("Bearer $token")});

      if (kDebugMode) {
        print("getMyBlocks response ${response.body}");
      }
      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['profileBlocks'] != null) {
        if (kDebugMode) {
          print("from response ${processedResponse['profileBlocks']}");
        }
        ChatApiGetProfileBlocksResponse responseModel =
            ChatApiGetProfileBlocksResponse.fromJson(
                processedResponse['profileBlocks']);
        if (kDebugMode) {
          print("get my profile block api response ${responseModel.list}");
        }

        // responseModel.list.forEach((element) {
        //   print(element);
        // });

        return responseModel.list;
      } else {
        return [];
      }
    }
    return [];
  }

  Future<String> blockProfile(String userId) async {
    var message =
        "Block Profile $userId by ${FirebaseAuth.instance.currentUser?.uid}";
    if (kDebugMode) {
      print(message);
    }

    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.post(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/block-profile"),
          body: {"userId": userId},
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['blockStatus'] != null) {
        if (kDebugMode) {
          print(processedResponse['blockStatus']);
        }
        String responseModel = processedResponse['blockStatus'];
        if (kDebugMode) {
          print("$message status: $responseModel");
        }
        return responseModel;
      } else {
        return "FAIL";
      }
    }
    return "FAIL";
  }

  Future<String> followProfile(String userId) async {
    var message =
        "Follow Profile $userId by ${FirebaseAuth.instance.currentUser?.uid}";
    if (kDebugMode) {
      print(message);
    }

    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.post(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/follow-profile"),
          body: {"userId": userId},
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['followStatus'] != null) {
        if (kDebugMode) {
          print(processedResponse['followStatus']);
        }
        String responseModel = processedResponse['followStatus'];
        if (kDebugMode) {
          print("$message status: $responseModel");
        }
        return responseModel;
      } else {
        return "FAIL";
      }
    }
    return "FAIL";
  }

  Future<String> unfollowProfile(String userId, Follow currentFollow) async {
    var message =
        "UnFollow Profile $userId by ${FirebaseAuth.instance.currentUser?.uid}";
    if (kDebugMode) {
      print(message);
    }

    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.post(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/unfollow-profile"),
          body: {"followId": currentFollow.id},
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['unfollowStatus'] != null) {
        if (kDebugMode) {
          print(processedResponse['unfollowStatus']);
        }
        String responseModel = processedResponse['unfollowStatus'];
        if (kDebugMode) {
          print("$message status: $responseModel");
        }
        return responseModel;
      } else {
        return "FAIL";
      }
    }
    return "FAIL";
  }

  Future<String> commentDocument(
      String documentId, String commentBody, String? commentType) async {
    var message =
        "Comment Profile $documentId by ${FirebaseAuth.instance.currentUser?.uid}";
    if (kDebugMode) {
      print(message);
    }
    if (kDebugMode) {
      print(commentBody);
    }

    var hashtags = [];
    extractHashTags(commentBody).forEach((element) {
      hashtags.add(element.replaceFirst("#", ''));
    });

    print("hashtags $hashtags ${jsonEncode(hashtags)}");

    String? token = await getIdToken();

    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      print(
          "docId:$documentId type:$commentType body:$commentBody tags:$hashtags");
      final response = await http.post(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/comment-document"),
          body: {
            "documentId": documentId,
            "commentBody": commentBody,
            "commentType": commentType ?? 'profile-comment',
            "hashtags": jsonEncode(hashtags)
          },
          headers: {
            "Authorization": ("Bearer $token")
          });

      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['commentStatus'] != null) {
        if (kDebugMode) {
          print(processedResponse['commentStatus']);
        }
        String responseModel = processedResponse['commentStatus'];
        if (kDebugMode) {
          print("$message status: $responseModel");
        }
        return responseModel;
      } else {
        return "FAIL";
      }
    }
    return "FAIL";
  }

  Future<ChatApiGetProfileLikesResponse> getProfileLikes(String userId) async {
    if (kDebugMode) {
      print("Retrieving Profile Likes $userId");
    }
    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse(
              "${DefaultConfig.theAuthBaseUrl}/get-profile-likes/$userId"),
          headers: {"Authorization": ("Bearer $token")});
      try {
        dynamic processedResponse = jsonDecode(response.body);
        if (processedResponse['profileLikes'] != null) {
          ChatApiGetProfileLikesResponse responseModel =
              ChatApiGetProfileLikesResponse.fromJson(processedResponse);
          if (kDebugMode) {
            print(
                "get profile likes api response ${responseModel.list.length}");
          }

          return responseModel;
        } else {
          return ChatApiGetProfileLikesResponse(list: [], amIInThisList: null);
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    return ChatApiGetProfileLikesResponse(list: [], amIInThisList: null);
  }

  updateExtProfileChatUser(
      String userId, BuildContext context, ExtendedProfile newProfile) async {
    if (kDebugMode) {
      print("in updATE CREATE");
    }
    String? token = await getIdToken();
    if (kDebugMode) {
      print("token $token");
    }

    if (token != null) {
      var body = {};
      if (newProfile.shortBio != null && newProfile.shortBio != "null") {
        body = {...body, "shortBio": newProfile.shortBio};
      }
      if (newProfile.longBio != null && newProfile.longBio != "null") {
        body = {...body, "longBio": newProfile.longBio};
      }
      if (newProfile.age != null) {
        body = {...body, "age": newProfile.age.toString()};
      }
      if (newProfile.weight != null) {
        body = {...body, "weight": newProfile.weight.toString()};
      }
      if (newProfile.height != null) {
        body = {...body, "height": json.encode(newProfile.height)};
      }
      if (newProfile.facebook != null && newProfile.facebook != "null") {
        body = {...body, "facebook": newProfile.facebook};
      }
      if (newProfile.twitter != null && newProfile.twitter != "null") {
        body = {...body, "twitter": newProfile.twitter};
      }
      if (newProfile.instagram != null && newProfile.instagram != "null") {
        body = {...body, "instagram": newProfile.instagram};
      }
      if (newProfile.gender != null && newProfile.gender != "null") {
        body = {...body, "gender": newProfile.gender};
      }
      if (newProfile.partnerStatus != null &&
          newProfile.partnerStatus != "null") {
        body = {...body, "partnerStatus": newProfile.partnerStatus};
      }
      if (newProfile.ethnicity != null && newProfile.ethnicity != "null") {
        body = {...body, "ethnicity": newProfile.ethnicity};
      }
      if (newProfile.iAm != null && newProfile.iAm != "null") {
        body = {...body, "iAm": newProfile.iAm};
      }
      if (newProfile.imInto != null && newProfile.imInto != "null") {
        body = {...body, "imInto": newProfile.imInto};
      }
      if (newProfile.imOpenTo != null && newProfile.imOpenTo != "null") {
        body = {...body, "imOpenTo": newProfile.imOpenTo};
      }
      if (newProfile.whatIDo != null && newProfile.whatIDo != "null") {
        body = {...body, "whatIDo": newProfile.whatIDo};
      }
      if (newProfile.whatImLookingFor != null &&
          newProfile.whatImLookingFor != "null") {
        body = {...body, "whatImLookingFor": newProfile.whatImLookingFor};
      }
      if (newProfile.whatInterestsMe != null &&
          newProfile.whatInterestsMe != "null") {
        body = {...body, "whatInterestsMe": newProfile.whatInterestsMe};
      }
      if (newProfile.whereILive != null && newProfile.whereILive != "null") {
        body = {...body, "whereILive": newProfile.whereILive};
      }
      if (newProfile.sexPreferences != null &&
          newProfile.sexPreferences != "null") {
        body = {...body, "sexPreferences": newProfile.sexPreferences};
      }

      if (kDebugMode) {
        print("the update ext profile request $body");
      }

      final response = await http.post(
          Uri.parse(
              "${DefaultConfig.theAuthBaseUrl}/update-create-ext-profile"),
          headers: {"Authorization": ("Bearer $token")},
          body: {...body});

      if (kDebugMode) {
        print("response from update ext profile $response");
      }

      dynamic processedResponse = jsonDecode(response.body);
      if (kDebugMode) {
        print("processedResponse ${processedResponse['newExtProfile']}");
      }

      ExtendedProfile myExtProfile =
          ExtendedProfile.fromJson(processedResponse['newExtProfile']);

      if (kDebugMode) {
        print("Auth api response $myExtProfile");
      }
      return myExtProfile;
    }
  }

  Future<ExtendedProfile?> getExtendedProfile(String userId) async {
    if (kDebugMode) {
      // print("Retrieving Ext Profile $userId");
    }
    String? token = await getIdToken();
    if (token != null && userId != "" && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/get-ext-profile/$userId"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['extendedProfile'] != null) {
        ExtendedProfile responseModel =
            ExtendedProfile.fromJson(processedResponse['extendedProfile']);
        if (kDebugMode) {
          // print(
          //     "get extended profile api response ${responseModel.toString()}");
        }
        return responseModel;
      } else {
        return null;
      }
    }
    return null;
  }

  Future<SanityPosition?> getLastPosition(String userId) async {
    if (kDebugMode) {
      print("Retrieving Last position for $userId");
    }
    String? token = await getIdToken();
    if (token != null && userId != "" && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/get-position/$userId"),
          headers: {"Authorization": ("Bearer $token")});
      dynamic processedResponse;
      try {
        processedResponse = jsonDecode(response.body);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      if (processedResponse['lastPosition'] != null) {
        // print(processedResponse);
        SanityPosition responseModel =
            SanityPosition.fromJson(processedResponse['lastPosition']);
        if (kDebugMode) {
          print("get position api response ${responseModel.toString()}");
        }
        return responseModel;
      } else {
        return null;
      }
    }
    return null;
  }

  Future<List<Comment>> getProfileComments(String userId, String typeId) async {
    if (kDebugMode) {
      print("Retrieving $typeId Comments $userId");
    }
    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse(
              "${DefaultConfig.theAuthBaseUrl}/get-comments/${typeId != null ? '$typeId/' : 'profile-comment/'}$userId"),
          headers: {"Authorization": ("Bearer $token")});
      try {
        dynamic processedResponse = jsonDecode(response.body);
        if (processedResponse['profileComments'] != null) {
          ChatApiGetProfileCommentsResponse responseModel =
              ChatApiGetProfileCommentsResponse.fromJson(
                  processedResponse['profileComments']);
          if (kDebugMode) {
            print("get profile comments api response ${responseModel.list}");
          }

          return responseModel.list;
        } else {
          return [];
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    return [];
  }

  Future<String> unlike(String likeeId, Like currentLike) async {
    var message =
        "UnLike  $likeeId by ${FirebaseAuth.instance.currentUser?.uid}";
    if (kDebugMode) {
      print(message);
    }

    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.post(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/unlike"),
          body: {"likeId": currentLike.id},
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['unlikeStatus'] != null) {
        if (kDebugMode) {
          print(processedResponse['unlikeStatus']);
        }
        String responseModel = processedResponse['unlikeStatus'];
        if (kDebugMode) {
          print("$message status: $responseModel");
        }
        return responseModel;
      } else {
        return "FAIL";
      }
    }
    return "FAIL";
  }

  Future<String> unblockProfile(Block currentBlock) async {
    var message =
        "Unblock Profile by ${FirebaseAuth.instance.currentUser?.uid}";
    if (kDebugMode) {
      print(message);
    }

    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.post(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/unblock-profile"),
          body: {"blockId": currentBlock.id},
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['unblockStatus'] != null) {
        if (kDebugMode) {
          print(processedResponse['unblockStatus']);
        }
        String responseModel = processedResponse['unblockStatus'];
        if (kDebugMode) {
          print("$message status: $responseModel");
        }
        return responseModel;
      } else {
        return "FAIL";
      }
    }
    return "FAIL";
  }

  Future<ChatApiGetProfileFollowsResponse> getProfileFollows(
      String userId) async {
    if (kDebugMode) {
      print("Retrieving Profile Follows $userId");
    }
    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.get(
          Uri.parse(
              "${DefaultConfig.theAuthBaseUrl}/get-profile-follows/$userId"),
          headers: {"Authorization": ("Bearer $token")});
      dynamic processedResponse;
      try {
        processedResponse = jsonDecode(response.body);
        if (processedResponse['profileFollows'] != null) {
          ChatApiGetProfileFollowsResponse responseModel =
              ChatApiGetProfileFollowsResponse.fromJson(processedResponse);
          if (kDebugMode) {
            print("get profile follows api response ${responseModel.list}");
          }

          // for (var element in responseModel.list) {
          //   if (kDebugMode) {
          //     print(element);
          //   }
          // }

          return responseModel;
        } else {
          return ChatApiGetProfileFollowsResponse(list: []);
        }
      } catch (e) {
        if (kDebugMode) {
          print("ERROR: $e");
        }
      }
    }

    return ChatApiGetProfileFollowsResponse(list: []);
  }

  Future<String> like(String likeeId, String likeType) async {
    var message =
        "Like $likeType $likeeId by ${FirebaseAuth.instance.currentUser?.uid}";
    if (kDebugMode) {
      print(message);
    }

    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.post(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/like"),
          body: {"likeeId": likeeId, "likeType": likeType},
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['likeStatus'] != null) {
        if (kDebugMode) {
          print(processedResponse['likeStatus']);
        }
        String responseModel = processedResponse['likeStatus'];
        if (kDebugMode) {
          print("$message status: $responseModel");
        }
        return responseModel;
      } else {
        return "FAIL";
      }
    }
    return "FAIL";
  }

  Future<String> updatePosition(Position location) async {
    var message = "Location $location";
    if (kDebugMode) {
      print(message);
    }

    String? token = await getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != "") {
      final response = await http.post(
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/update-position"),
          body: {
            "longitude": location.longitude.toString(),
            "latitude": location.latitude.toString(),
            "timestamp": location.timestamp.toString(),
            "accuracy": location.accuracy.toString(),
            "altitude": location.altitude.toString(),
            "heading": location.heading.toString(),
            "speed": location.speed.toString(),
            "speedAccuracy": location.speedAccuracy.toString(),
            "floor": location.floor.toString()
          },
          headers: {
            "Authorization": ("Bearer $token")
          });

      dynamic processedResponse = jsonDecode(response.body);

      if (processedResponse['likeStatus'] != null) {
        if (kDebugMode) {
          print(processedResponse['likeStatus']);
        }
        String responseModel = processedResponse['likeStatus'];
        if (kDebugMode) {
          print("$message status: $responseModel");
        }
        return responseModel;
      } else {
        return "FAIL";
      }
    }
    return "FAIL";
  }
}
