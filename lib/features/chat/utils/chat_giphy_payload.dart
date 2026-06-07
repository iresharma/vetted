import 'package:giphy_flutter_sdk/dto/giphy_media.dart';

class ChatGiphyPayload {
  const ChatGiphyPayload({
    required this.gifId,
    required this.gifUrl,
    this.gifPreviewUrl,
    this.gifTitle,
    this.gifAspectRatio = 1,
  });

  final String gifId;
  final String gifUrl;
  final String? gifPreviewUrl;
  final String? gifTitle;
  final double gifAspectRatio;

  factory ChatGiphyPayload.fromMedia(GiphyMedia media) {
    final images = media.images;
    final gifUrl = images.fixedWidth?.gifUrl ??
        images.fixedWidthDownsampled?.gifUrl ??
        images.downsized?.gifUrl ??
        images.original?.gifUrl ??
        '';

    final previewUrl = images.fixedWidthStill?.webPUrl ??
        images.fixedWidthStill?.gifUrl ??
        images.preview?.gifUrl;

    return ChatGiphyPayload(
      gifId: media.id,
      gifUrl: gifUrl,
      gifPreviewUrl: previewUrl,
      gifTitle: media.title,
      gifAspectRatio: media.aspectRatio > 0 ? media.aspectRatio : 1,
    );
  }

  bool get isValid => gifId.isNotEmpty && gifUrl.isNotEmpty;
}
