import 'package:cookowt/models/clients/api_client.dart';
import 'package:cookowt/models/hash_tag_collection.dart';
import 'package:cookowt/wrappers/hashtag_button.dart';
import 'package:flutter/material.dart';

import '../models/clients/api_client.dart';
import '../models/controllers/auth_inherited.dart';
import '../models/hash_tag_collection.dart';

class Hashtag_Collection_Block extends StatefulWidget {
  const Hashtag_Collection_Block({Key? key, this.collectionSlug})
      : super(key: key);

  final String? collectionSlug;

  @override
  State<Hashtag_Collection_Block> createState() =>
      _Hashtag_Collection_BlockState();
}

class _Hashtag_Collection_BlockState extends State<Hashtag_Collection_Block> {
  HashtagCollection? hashtagCollection;
  ApiClient? apiClient;

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;

    if (apiClient == null && theClient != null && hashtagCollection == null) {
      apiClient = theClient;
      hashtagCollection =
          await theClient.fetchHashtagCollection(widget.collectionSlug);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hashtagCollection?.name ?? "Unnamed Collection",
            style: Theme.of(context).textTheme.titleSmall),
        if (hashtagCollection?.description != null)
          Text(hashtagCollection?.description ?? "",
              style: Theme.of(context).textTheme.bodyMedium),
        Wrap(
          direction: Axis.horizontal,
          children: hashtagCollection?.theTags.map((element){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: HashtagButton(hashtag: element.tag??""),
            );
          }).toList()??[],
        ),
        SizedBox(height: 16,)
      ],
    );
  }
}
