import 'package:kookout/config/default_config.dart';
import 'package:flutter_sanity/flutter_sanity.dart';

sanityClient() {
  return SanityClient(
    dataset: DefaultConfig.theSanityDB,
    projectId: DefaultConfig.theSanityProjectID,
  );
}