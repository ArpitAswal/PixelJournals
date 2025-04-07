import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CacheNetworkImage {
  // Factory constructor to return singleton instance
  factory CacheNetworkImage() => instance;

  // Make the class immutable and singleton
  const CacheNetworkImage._();

  static const instance = CacheNetworkImage._();

  Widget buildNetworkImage(
    BuildContext context, {
    required String imgUrl,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      imageBuilder:
          (context, imageProvider) => _buildImageContainer(
            context,
            imageProvider,
            height,
            fit,
            borderRadius,
          ),
      placeholder: _buildLoadingPlaceholder,
      errorWidget:
          (_, __, ___) =>
              const Center(child: Icon(Icons.error, color: Colors.red)),
    );
  }

  Widget _buildImageContainer(
    BuildContext context,
    ImageProvider imageProvider,
    double height,
    BoxFit fit,
    BorderRadius? borderRadius,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: fit,
          filterQuality: FilterQuality.high,
        ),
        borderRadius: borderRadius,
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context, String url) {
    final size = MediaQuery.of(context).size.width / 4;
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
