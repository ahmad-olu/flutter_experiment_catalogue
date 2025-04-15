import 'dart:ui';

import 'package:experiment_catalogue/app/view/first+try/main.dart';
import 'package:super_editor/super_editor.dart';

enum AttributionType {
  namedSpan,
  uplSpan,
  scriptSpan,
  colorSpan,
  backgroundColorSpan,
  fontSizeSpan,
  fontFamilySpan,
  linkSpan,
}

abstract class SpanData {
  SpanData({
    required this.id,
    required this.span,
    required this.offset,
    required this.type,
    required this.isEnd,
    required this.isStart,
  });

  final String id;
  final AttributionType span;
  final int offset;
  final String type;
  final bool isEnd;
  final bool isStart;

  Map<String, dynamic> toJson();
}

class NamedSpanData extends SpanData {
  NamedSpanData({
    required super.id,
    required super.offset,
    required super.type,
    required super.isEnd,
    required super.isStart,
  }) : super(span: AttributionType.namedSpan);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'span': span.name,
      'offset': offset,
      'type': type,
      'isEnd': isEnd,
      'isStart': isStart,
    };
  }

  @override
  String toString() => 'span($span):[$id; $type]';
}

class UplSpanData extends SpanData {
  UplSpanData({
    required super.id,
    required this.attType,
    required super.offset,
    required super.type,
    required super.isEnd,
    required super.isStart,
  }) : super(span: AttributionType.uplSpan);

  final String attType;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'span': span.name,
      'attType': attType,
      'offset': offset,
      'type': type,
      'isEnd': isEnd,
      'isStart': isStart,
    };
  }

  @override
  String toString() => 'span($span):[$id; $attType;$type]';
}

class ScriptSpanData extends SpanData {
  ScriptSpanData({
    required super.id,
    required this.scriptType,
    required super.offset,
    required super.type,
    required super.isEnd,
    required super.isStart,
  }) : super(span: AttributionType.scriptSpan);

  final String scriptType;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'span': span.name,
      'scriptType': scriptType,
      'offset': offset,
      'type': type,
      'isEnd': isEnd,
      'isStart': isStart,
    };
  }
}

class ColorSpanData extends SpanData {
  ColorSpanData({
    required super.id,
    required this.color,
    required super.offset,
    required super.type,
    required super.isEnd,
    required super.isStart,
  }) : super(span: AttributionType.colorSpan);

  final Color color;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'span': span.name,
      'color': {
        'r': color.r,
        'g': color.g,
        'b': color.b,
        'a': color.a,
      },
      'offset': offset,
      'type': type,
      'isEnd': isEnd,
      'isStart': isStart,
    };
  }
}

class BackgroundColorSpanData extends SpanData {
  BackgroundColorSpanData({
    required super.id,
    required this.color,
    required super.offset,
    required super.type,
    required super.isEnd,
    required super.isStart,
  }) : super(span: AttributionType.backgroundColorSpan);

  final Color color;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'span': span.name,
      'color': {
        'r': color.r,
        'g': color.g,
        'b': color.b,
        'a': color.a,
      },
      'offset': offset,
      'type': type,
      'isEnd': isEnd,
      'isStart': isStart,
    };
  }
}

class FontSizeSpanData extends SpanData {
  FontSizeSpanData({
    required super.id,
    required this.fontSize,
    required super.offset,
    required super.type,
    required super.isEnd,
    required super.isStart,
  }) : super(span: AttributionType.fontSizeSpan);

  final double fontSize;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'span': span.name,
      'fontSize': fontSize,
      'offset': offset,
      'type': type,
      'isEnd': isEnd,
      'isStart': isStart,
    };
  }
}

class FontFamilySpanData extends SpanData {
  FontFamilySpanData({
    required super.id,
    required this.fontFamily,
    required super.offset,
    required super.type,
    required super.isEnd,
    required super.isStart,
  }) : super(span: AttributionType.fontFamilySpan);

  final String fontFamily;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'span': span.name,
      'fontFamily': fontFamily,
      'offset': offset,
      'type': type,
      'isEnd': isEnd,
      'isStart': isStart,
    };
  }
}

class LinkSpanData extends SpanData {
  LinkSpanData({
    required super.id,
    required this.url,
    required this.plainTextUrl,
    required super.offset,
    required super.type,
    required super.isEnd,
    required super.isStart,
  }) : super(span: AttributionType.linkSpan);

  final Uri? url;
  final String plainTextUrl;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'span': span.name,
      'url': url,
      'plainTextUrl': plainTextUrl,
      'offset': offset,
      'type': type,
      'isEnd': isEnd,
      'isStart': isStart,
    };
  }
}

SpanData getNodeSpanMarkerData(SpanMarker e) {
  final id = e.attribution.id;
  final offset = e.offset;
  final type = e.markerType.name;
  final isEnd = e.isEnd;
  final isStart = e.isStart;
  if (e.attribution is NamedAttribution) {
    return NamedSpanData(
        id: id, offset: offset, type: type, isEnd: isEnd, isStart: isStart);
  } else if (e.attribution is UplAttribution) {
    final attr = e.attribution as UplAttribution;
    return UplSpanData(
        id: id,
        attType: attr.type,
        offset: offset,
        type: type,
        isEnd: isEnd,
        isStart: isStart);
  } else if (e.attribution is ScriptAttribution) {
    final attr = e.attribution as ScriptAttribution;
    return ScriptSpanData(
        id: id,
        scriptType: attr.type,
        offset: offset,
        type: type,
        isEnd: isEnd,
        isStart: isStart);
  } else if (e.attribution is ColorAttribution) {
    final attr = e.attribution as ColorAttribution;
    return ColorSpanData(
        id: id,
        color: attr.color,
        offset: offset,
        type: type,
        isEnd: isEnd,
        isStart: isStart);
  } else if (e.attribution is BackgroundColorAttribution) {
    final attr = e.attribution as BackgroundColorAttribution;
    return BackgroundColorSpanData(
        id: id,
        color: attr.color,
        offset: offset,
        type: type,
        isEnd: isEnd,
        isStart: isStart);
  } else if (e.attribution is FontSizeAttribution) {
    final attr = e.attribution as FontSizeAttribution;
    return FontSizeSpanData(
        id: id,
        fontSize: attr.fontSize,
        offset: offset,
        type: type,
        isEnd: isEnd,
        isStart: isStart);
  } else if (e.attribution is FontFamilyAttribution) {
    final attr = e.attribution as FontFamilyAttribution;
    return FontFamilySpanData(
        id: id,
        fontFamily: attr.fontFamily,
        offset: offset,
        type: type,
        isEnd: isEnd,
        isStart: isStart);
  } else if (e.attribution is LinkAttribution) {
    final attr = e.attribution as LinkAttribution;
    return LinkSpanData(
        id: id,
        url: attr.uri,
        plainTextUrl: attr.plainTextUri,
        offset: offset,
        type: type,
        isEnd: isEnd,
        isStart: isStart);
  }

  throw Exception("No matching SpanData Marker type found");
}
