class Emoticon {
  Emoticon({
    required this.pictureUrl,
    required this.width,
    required this.height,
    required this.code,
    required this.title,
  });
  final String pictureUrl, code, title;
  final int width, height;
}

class EmoticonsResponse {
  EmoticonsResponse({required this.hasNextPage}) : emoticons = [], count = 0;
  final List<Emoticon> emoticons;
  final bool hasNextPage;
  int count;

  void addEmoticon({
    required String pictureUrl,
    required int width,
    required int height,
    required String code,
    required String title,
  }) {
    emoticons.add(
      Emoticon(
        pictureUrl: pictureUrl,
        width: width,
        height: height,
        code: code,
        title: title,
      ),
    );
    count++;
  }
}
