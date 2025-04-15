import 'dart:ui';

import 'package:experiment_catalogue/app/view/first+try/main.dart';
import 'package:experiment_catalogue/app/view/first+try/spans_model.dart';
import 'package:super_editor/super_editor.dart';

abstract class MetaDataModel {
  MetaDataModel({
    required this.id,
    required this.metaData,
  });

  final String id;
  final AttributionType metaData;

  Map<String, dynamic> toJson();
  Attribution toAttribution();
}

class NamedMetaDataModel extends MetaDataModel {
  NamedMetaDataModel({required super.id})
      : super(metaData: AttributionType.namedSpan);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attribution': metaData.name,
    };
  }

  @override
  NamedAttribution toAttribution() {
    return NamedAttribution(id);
  }
}

class UplMetaDataModel extends MetaDataModel {
  UplMetaDataModel({
    required super.id,
    required this.type,
  }) : super(metaData: AttributionType.uplSpan);

  final String type;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'attribution': metaData.name,
    };
  }

  @override
  UplAttribution toAttribution() {
    return switch (type) {
      'name' => const UplAttribution.name(),
      'work_experience' => const UplAttribution.workExperience(),
      _ => throw Exception(),
    };
  }
}

class ScriptMetaDataModel extends MetaDataModel {
  ScriptMetaDataModel({
    required super.id,
    required this.type,
  }) : super(metaData: AttributionType.scriptSpan);

  final String type;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'attribution': metaData.name,
    };
  }

  @override
  Attribution toAttribution() {
    return switch (type) {
      'superscript' => const ScriptAttribution.superscript(),
      'subscript' => const ScriptAttribution.subscript(),
      _ => throw Exception(),
    };
  }
}

class ColorMetaDataModel extends MetaDataModel {
  ColorMetaDataModel({
    required super.id,
    required this.color,
  }) : super(metaData: AttributionType.colorSpan);

  final Color color;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': {
        'r': color.r,
        'g': color.g,
        'b': color.b,
        'a': color.a,
      },
      'attribution': metaData.name,
    };
  }

  @override
  Attribution toAttribution() {
    return ColorAttribution(color);
  }
}

class BackgroundColorMetaDatModel extends MetaDataModel {
  BackgroundColorMetaDatModel({
    required super.id,
    required this.color,
  }) : super(metaData: AttributionType.backgroundColorSpan);

  final Color color;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': {
        'r': color.r,
        'g': color.g,
        'b': color.b,
        'a': color.a,
      },
      'attribution': metaData.name,
    };
  }

  @override
  Attribution toAttribution() {
    return BackgroundColorAttribution(color);
  }
}

class FontSizeMetaDataModel extends MetaDataModel {
  FontSizeMetaDataModel({
    required super.id,
    required this.fontSize,
  }) : super(metaData: AttributionType.fontSizeSpan);

  final double fontSize;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fontSize': fontSize,
      'attribution': metaData.name,
    };
  }

  @override
  Attribution toAttribution() {
    return FontSizeAttribution(fontSize);
  }
}

class FontFamilyMetaDataModel extends MetaDataModel {
  FontFamilyMetaDataModel({
    required super.id,
    required this.fontFamily,
  }) : super(metaData: AttributionType.fontFamilySpan);

  final String fontFamily;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fontFamily': fontFamily,
      'attribution': metaData.name,
    };
  }

  @override
  Attribution toAttribution() {
    return FontFamilyAttribution(fontFamily);
  }
}

class LinkMetaDataModel extends MetaDataModel {
  LinkMetaDataModel({
    required super.id,
    required this.uri,
    required this.plainTextUrl,
  }) : super(metaData: AttributionType.linkSpan);

  final Uri? uri;
  final String plainTextUrl;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uri': uri,
      'plainTextUrl': plainTextUrl,
      'attribution': metaData.name,
    };
  }

  @override
  Attribution toAttribution() {
    return LinkAttribution(plainTextUrl, uri);
  }
}

MetaDataModel getNodeMetaData(Map<String, dynamic> metadata) {
  for (final entry in metadata.entries) {
    // final _key = entry.key;
    final value = entry.value;
    if (value is NamedAttribution) {
      return NamedMetaDataModel(id: value.id);
    } else if (value is UplAttribution) {
      return UplMetaDataModel(id: value.id, type: value.type);
    } else if (value is ScriptAttribution) {
      return ScriptMetaDataModel(id: value.id, type: value.type);
    } else if (value is ColorAttribution) {
      return ColorMetaDataModel(id: value.id, color: value.color);
    } else if (value is BackgroundColorAttribution) {
      return BackgroundColorMetaDatModel(id: value.id, color: value.color);
    } else if (value is FontSizeAttribution) {
      return FontSizeMetaDataModel(id: value.id, fontSize: value.fontSize);
    } else if (value is FontFamilyAttribution) {
      return FontFamilyMetaDataModel(
          id: value.id, fontFamily: value.fontFamily);
    } else if (value is LinkAttribution) {
      return LinkMetaDataModel(
          id: value.id, plainTextUrl: value.plainTextUri, uri: value.uri);
    }
  }

  throw Exception("No matching metadata type found");
}
