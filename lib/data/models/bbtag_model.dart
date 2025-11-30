import 'package:flutter/material.dart';
import 'package:mchad/utils/document_util.dart';

enum BBTagType { image, url, other }

const supportedBbtags = [
  '[b]',
  '[i]',
  '[u]',
  '[quote]',
  '[code]',
  '[img]',
  '[url]',
  '[s]',
  '[pre]',
  '[sub]',
  '[fade]',
  '[sup]',
  '[spoil]',
  '[spoiler]',
  '[hidden]',
  '[offtopic]',
  '[soundcloud]',
  '[BBvideo]',
  '[image]',
  '[mimg]',
  '[g]',
  '[youtube]',
];

class BBTag {
  BBTag({required this.start, required this.end, required this.name});
  final String start, end, name;

  bool get isSupported {
    return supportedBbtags.contains(start);
  }

  List<String> get alternatives {
    switch (start) {
      case '[img]':
        return ['[image]', '[mimg]'];
      case '[spoil]':
        return ['[spoiler]'];
      case '[image]':
        return ['[mimg]'];
      default:
        return [];
    }
  }

  bool hasBetterAlternative(List<BBTag> otherBbTags) {
    for (final otherBbTag in otherBbTags) {
      if (alternatives.contains(otherBbTag.start)) {
        return true;
      }
    }
    return false;
  }

  bool supportsContent(String? content) {
    if (content == null) return false;
    if (type == BBTagType.image) return DocumentUtil.isImageUrl(content);
    if (type == BBTagType.url) return DocumentUtil.isValidUrl(content);
    return false;
  }

  BBTagType get type {
    switch (start) {
      case '[img]':
        return BBTagType.image;
      case '[image]':
        return BBTagType.image;
      case '[mimg]':
        return BBTagType.image;
      case '[url]':
        return BBTagType.url;
      default:
        return BBTagType.other;
    }
  }

  IconData get icon {
    switch (start) {
      case '[b]':
        return Icons.format_bold;
      case '[i]':
        return Icons.format_italic;
      case '[u]':
        return Icons.format_underlined;
      case '[quote]':
        return Icons.format_quote;
      case '[code]':
        return Icons.data_object;
      case '[img]':
        return Icons.image;
      case '[url]':
        return Icons.link;
      case '[s]':
        return Icons.format_strikethrough;
      case '[pre]':
        return Icons.format_size;
      case '[sub]':
        return Icons.subscript;
      case '[fade]':
        return Icons.gradient;
      case '[sup]':
        return Icons.superscript;
      case '[spoil]':
        return Icons.visibility_off;
      case '[spoiler]':
        return Icons.visibility_off;
      case '[hidden]':
        return Icons.lock;
      case '[offtopic]':
        return Icons.sms;
      case '[soundcloud]':
        return Icons.music_note;
      case '[BBvideo]':
        return Icons.movie;
      case '[image]':
        return Icons.image;
      case '[mimg]':
        return Icons.image;
      case '[g]':
        return Icons.keyboard_arrow_right;
      case '[youtube]':
        return Icons.youtube_searched_for;
      default:
        throw 'Unsupported bbtag';
    }
  }
}
