import 'dart:convert';

import 'package:experiment_catalogue/app/view/first+try/local_image_n.dart';
import 'package:experiment_catalogue/app/view/first+try/main.dart';
import 'package:super_editor/super_editor.dart';

String documentToJson(Document doc) {
  final nodes = <Map<String, dynamic>>[];

  for (var i = 0; i < doc.nodeCount; i++) {
    final node = doc.getNodeAt(i);
    final metadata = (node?.metadata ?? {}).map((k, v) {
      if (v is NamedAttribution) {
        return MapEntry(k, {
          'id': v.id,
          'name': v.name,
          'attribution': 'NamedAttribution',
        });
      }
      return MapEntry(k, v);
    });

    if (node is ParagraphNode) {
      final ph = node.text.placeholders;
      //  print('---------------> $ph');
      final spans = node.text.spans.markers.map((e) {
        if (e.attribution is NamedAttribution) {
          return {
            'id': e.attribution.id,
            'attribution': 'NamedAttribution',
            'offset': e.offset,
            'type': e.markerType.name,
            'isEnd': e.isEnd,
            'isStart': e.isStart,
          };
        } else if (e.attribution is UplAttribution) {
          final uplAttr = e.attribution as UplAttribution;
          return {
            'id': uplAttr.id,
            'attribution': 'UplAttribution',
            'attribution_type': uplAttr.type,
            'offset': e.offset,
            'type': e.markerType.name,
            'isEnd': e.isEnd,
            'isStart': e.isStart,
          };
        } else if (e.attribution is ScriptAttribution) {
          final scriptAttr = e.attribution as ScriptAttribution;
          return {
            'id': scriptAttr.id,
            'attribution': 'ScriptAttribution',
            'attribution_type': scriptAttr.type,
            'offset': e.offset,
            'type': e.markerType.name,
            'isEnd': e.isEnd,
            'isStart': e.isStart,
          };
        } else if (e.attribution is ColorAttribution) {
          final attr = e.attribution as ColorAttribution;
          return {
            'id': attr.id,
            'attribution': 'ColorAttribution',
            'attribution_color': {
              'r': attr.color.r,
              'g': attr.color.g,
              'b': attr.color.b,
              'a': attr.color.a,
            },
            'offset': e.offset,
            'type': e.markerType.name,
            'isEnd': e.isEnd,
            'isStart': e.isStart,
          };
        } else if (e.attribution is BackgroundColorAttribution) {
          final attr = e.attribution as BackgroundColorAttribution;
          return {
            'id': attr.id,
            'attribution': 'BackgroundColorAttribution',
            'attribution_color': {
              'r': attr.color.r,
              'g': attr.color.g,
              'b': attr.color.b,
              'a': attr.color.a,
            },
            'offset': e.offset,
            'type': e.markerType.name,
            'isEnd': e.isEnd,
            'isStart': e.isStart,
          };
        } else if (e.attribution is FontSizeAttribution) {
          final attr = e.attribution as FontSizeAttribution;
          return {
            'id': attr.id,
            'attribution': 'FontSizeAttribution',
            'attribution_font_size': attr.fontSize,
            'offset': e.offset,
            'type': e.markerType.name,
            'isEnd': e.isEnd,
            'isStart': e.isStart,
          };
        } else if (e.attribution is FontFamilyAttribution) {
          final attr = e.attribution as FontFamilyAttribution;
          return {
            'id': attr.id,
            'attribution': 'FontFamilyAttribution',
            'attribution_font_family': attr.fontFamily,
            'offset': e.offset,
            'type': e.markerType.name,
            'isEnd': e.isEnd,
            'isStart': e.isStart,
          };
        } else if (e.attribution is LinkAttribution) {
          final attr = e.attribution as LinkAttribution;
          return {
            'id': attr.id,
            'attribution': 'LinkAttribution',
            'attribution_uri': attr.uri,
            'attribution_plain_text_uri': attr.plainTextUri,
            'offset': e.offset,
            'type': e.markerType.name,
            'isEnd': e.isEnd,
            'isStart': e.isStart,
          };
        }
        return null;
      }).toList();
      nodes.add({
        'node': 'ParagraphNode',
        'id': node.id,
        'text': node.text.toPlainText(),
        'spans': spans,
        'metadata': metadata,
        'placeholders': {} //node.text.placeholders
      });
    } else if (node is ImageNode) {
      nodes.add({
        'node': 'ImageNode',
        'id': node.id,
        'imageUrl': node.imageUrl,
        'altText': node.altText,
        'expectedBitmapSize': {
          'width': node.expectedBitmapSize?.width,
          'height': node.expectedBitmapSize?.height,
        },
        //  'metadata': metadata,
      });
    } else if (node is LocalImageNode) {
      nodes.add({
        'node': 'ImageNode',
        'id': node.id,
        'imageUrl': node.imageUrl,
        'altText': node.altText,
        'expectedBitmapSize': {
          'width': node.expectedBitmapSize?.width,
          'height': node.expectedBitmapSize?.height,
        },
        //  'metadata': metadata,
      });
    } else if (node is ListItemNode) {
      nodes.add({
        'node': 'ImageNode',
        'id': node.id,
        'text': node.text,
        'type': node.type,
        'indent': node.indent,
        //'spans': spans,
        //'metadata': metadata,
      });
    }
  }

  return jsonEncode({'nodes': nodes});
}
