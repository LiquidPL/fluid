import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AlbumCover extends StatelessWidget {
  const AlbumCover({
    this.isSmall = false,
    this.image,
    Key? key,
  }) : super(key: key);

  /// Whether the widget will be of a small size (ie. in a list or a
  /// mini player). This mainly changes the border radius of the widget
  /// to not look comically large.
  final bool isSmall;

  /// The image to be displayed as the album cover.
  final Image? image;

  @override
  Widget build(BuildContext context) {
    final borderRadius = isSmall ? 4.0 : 8.0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: image ??
              SvgPicture.asset(
                'assets/placeholder-album-cover.svg',
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
        ),
      ),
    );
  }
}
