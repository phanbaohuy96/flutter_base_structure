import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'loading.dart';

class CachedNetworkImageWrapper extends CachedNetworkImage {
  CachedNetworkImageWrapper({
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
  }) : super(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => const Loading(
            brightness: Brightness.light,
            radius: 10,
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );

  CachedNetworkImageWrapper.avatar({
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
  }) : super(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => const Loading(
            brightness: Brightness.light,
            radius: 10,
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            size: width,
          ),
        );

  CachedNetworkImageWrapper.item({
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
  }) : super(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => const Loading(
            brightness: Brightness.light,
            radius: 10,
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );

  CachedNetworkImageWrapper.banner({
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
  }) : super(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => const Loading(
            brightness: Brightness.light,
            radius: 10,
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );

  CachedNetworkImageWrapper.background({
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
  }) : super(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => const Loading(
            brightness: Brightness.light,
            radius: 10,
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
}
