import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AlbumCover extends StatelessWidget {
  const AlbumCover({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SvgPicture.asset(
            'assets/placeholder-album-cover.svg',
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}
