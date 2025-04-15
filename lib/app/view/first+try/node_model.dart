import 'package:experiment_catalogue/app/view/first+try/filter_model.dart';
import 'package:experiment_catalogue/app/view/first+try/keyword.dart'
    show
        certificationsKeywords,
        contactKeywords,
        educationKeywords,
        equalsKeyword,
        projectsKeywords,
        skillsKeywords,
        workExperienceKeywords;
import 'package:experiment_catalogue/app/view/first+try/local_image_n.dart';
import 'package:experiment_catalogue/app/view/first+try/metadata_model.dart';
import 'package:experiment_catalogue/app/view/first+try/spans_model.dart';
import 'package:super_editor/super_editor.dart';

enum NodeType { paragraph, image, localImage, listItem }

class Nodes {
  Nodes({required this.nodes});

  final List<NodeModel> nodes;

  Map<String, dynamic> toJson() {
    return {'nodes': nodes.map((node) => node.toJson()).toList()};
  }
}

abstract class NodeModel {
  NodeModel({required this.id, required this.node});

  final String id;
  final NodeType node;

  Map<String, dynamic> toJson();
}

class ParagraphNodeModel extends NodeModel {
  ParagraphNodeModel({
    required super.id,
    required this.spans,
    required this.text,
    required this.metaData,
    this.placeholders,
  }) : super(node: NodeType.paragraph);

  final String text;
  final List<SpanData> spans;
  final MetaDataModel metaData;
  final Map<String, dynamic>? placeholders;

  @override
  Map<String, dynamic> toJson() {
    return {
      'node': node.name,
      'id': id,
      'text': text,
      'spans': spans,
      'metaData': metaData,
      'placeHolders': <String, Object>{}, //node.text.placeholders
    };
  }

  @override
  String toString() => 'node($node):[$id; ${metaData.id};$spans]';
}

class ImageNodeModel extends NodeModel {
  ImageNodeModel({
    required super.id,
    required this.imageUrl,
    required this.altText,
    this.metaData,
    this.placeholders,
    this.expectedBitmapHeight,
    this.expectedBitmapWidth,
  }) : super(node: NodeType.image);

  final String imageUrl;
  final String altText;
  final int? expectedBitmapWidth;
  final int? expectedBitmapHeight;
  final Map<String, dynamic>? metaData;
  final Map<String, dynamic>? placeholders;

  @override
  Map<String, dynamic> toJson() {
    return {
      'node': node.name,
      'id': id,
      'imageUrl': imageUrl,
      'altText': altText,
      //expectedBitmapSize
      'expectedBitmapWidth': expectedBitmapWidth,
      'expectedBitmapHeight': expectedBitmapHeight,
      //  'metadata': metadata,
    };
  }

  @override
  String toString() => 'node($node):[$id]';
}

class LocalImageNodeModel extends NodeModel {
  LocalImageNodeModel({
    required super.id,
    required this.imageUrl,
    required this.altText,
    this.metaData,
    this.placeholders,
    this.expectedBitmapHeight,
    this.expectedBitmapWidth,
  }) : super(node: NodeType.localImage);

  final String imageUrl;
  final String altText;
  final int? expectedBitmapWidth;
  final int? expectedBitmapHeight;
  final Map<String, dynamic>? metaData;
  final Map<String, dynamic>? placeholders;

  @override
  Map<String, dynamic> toJson() {
    return {
      'node': node.name,
      'id': id,
      'imageUrl': imageUrl,
      'altText': altText,
      'expectedBitmapWidth': expectedBitmapWidth,
      'expectedBitmapHeight': expectedBitmapHeight,
      //  'metadata': metadata,
    };
  }

  @override
  String toString() => 'node($node):[$id]';
}

class ListItemNodeModel extends NodeModel {
  ListItemNodeModel({
    required super.id,
    required this.text,
    required this.type,
    required this.indent,
    required this.spans,
    this.metaData,
    this.placeholders,
  }) : super(node: NodeType.listItem);

  final String text;
  final ListItemType type;
  final int indent;
  final List<SpanData> spans;
  final Map<String, dynamic>? metaData;
  final Map<String, dynamic>? placeholders;

  @override
  Map<String, dynamic> toJson() {
    return {
      'node': node.name,
      'id': id,
      'text': text,
      'type': type.name,
      'indent': indent,
      'spans': spans,
      //'metadata': metadata,
    };
  }

  @override
  String toString() => 'node($node):[$id]';
}

List<NodeModel> documentModelToJson(Document doc) {
  final nodes = <NodeModel>[];

  for (var i = 0; i < doc.nodeCount; i++) {
    final node = doc.getNodeAt(i);
    final metaData = getNodeMetaData(node?.metadata ?? {});
    if (node is ParagraphNode) {
      final spans = node.text.spans.markers.map(getNodeSpanMarkerData).toList();
      nodes.add(
        ParagraphNodeModel(
          id: node.id,
          spans: spans,
          text: node.text.toPlainText(),
          metaData: metaData,
        ),
      );
    } else if (node is ImageNode) {
      nodes.add(
        ImageNodeModel(
          id: node.id,
          imageUrl: node.imageUrl,
          altText: node.altText,
          expectedBitmapWidth: node.expectedBitmapSize?.width,
          expectedBitmapHeight: node.expectedBitmapSize?.height,
        ),
      );
    } else if (node is LocalImageNode) {
      nodes.add(
        LocalImageNodeModel(
          id: node.id,
          imageUrl: node.imageUrl,
          altText: node.altText,
          expectedBitmapWidth: node.expectedBitmapSize?.width,
          expectedBitmapHeight: node.expectedBitmapSize?.height,
        ),
      );
    } else if (node is ListItemNode) {
      final spans = node.text.spans.markers.map(getNodeSpanMarkerData).toList();
      nodes.add(
        ListItemNodeModel(
            id: node.id,
            text: node.text.toPlainText(),
            type: node.type,
            indent: node.indent,
            spans: spans),
      );
    }
  }

  return nodes;
}

Future<Nodes> prepareForUpload(Nodes nodes) async {
  final nodeList = await Future.wait(nodes.nodes.map((e) async {
    if (e is LocalImageNodeModel) {
      //TODO! actually upload and get the new image
      final filePath = e.imageUrl;
      final url = await Future.delayed(
        const Duration(milliseconds: 800),
        () => 'Yes.sir',
      );

      return ImageNodeModel(
        id: e.id,
        imageUrl: url,
        altText: e.altText,
        expectedBitmapWidth: e.expectedBitmapWidth,
        expectedBitmapHeight: e.expectedBitmapHeight,
      );
    }
    return e;
  }));

  return Nodes(nodes: nodeList);
}

Future<CVFilters> getCvFilters(Nodes nodes) async {
  String? currentSection;
  var exData = CVFilters.empty();

  for (final node in nodes.nodes) {
    // print('<===================>  ' + node.node.name);
    if (node.node == NodeType.paragraph) {
      final n = node as ParagraphNodeModel;
      // print('<===================>  ' + n.
      final isHeader =
          ['header1', 'header2', 'header3'].contains(n.metaData.id);

      final isHeader2or3 =
          n.metaData.id == 'header2' || n.metaData.id == 'header3';
      final hasColorSpan = n.spans.any((span) => span is ColorSpanData);
      final hasUplSpan = n.spans.any((span) => span is UplSpanData);

      // final hasColorSpan = n.spans.whereType().first is ColorSpanData;

      if (isHeader && hasColorSpan && !hasUplSpan) {
        if (n.metaData.id == 'header1' || isHeader2or3) {
          if (n.metaData.id == 'header1') {
            currentSection = n.metaData.id;
            exData = exData.copyWith(name: n.text);
          }
          if (isHeader2or3 && equalsKeyword(n.text, workExperienceKeywords)) {
            currentSection = 'work_experience';
          }
          if (isHeader2or3 && equalsKeyword(n.text, educationKeywords)) {
            currentSection = 'education';
          }
          if (isHeader2or3 && equalsKeyword(n.text, skillsKeywords)) {
            currentSection = 'skills';
          }
          if (isHeader2or3 && equalsKeyword(n.text, projectsKeywords)) {
            currentSection = 'projects';
          }
          if (isHeader2or3 && equalsKeyword(n.text, certificationsKeywords)) {
            currentSection = 'certifications';
          }
        }
      } else {
        for (final span in n.spans) {
          if (span is UplSpanData) {
            final s = span;
            if (s.attType == 'name') {
              currentSection = s.attType;
              exData = exData.copyWith(name: n.text);
            } else if (s.attType == 'work_experience') {
              currentSection = 'work_experience';
            } else if (s.attType == 'education') {
              currentSection = 'education';
            } else if (s.attType == 'skills') {
              currentSection = 'skills';
            } else if (s.attType == 'projects') {
              currentSection = 'projects';
            } else if (s.attType == 'certifications') {
              currentSection = 'certifications';
            }
          }
        }
      }

      if (currentSection == 'header1' || currentSection == 'name') {}
      if (contactKeywords.any(n.text.startsWith)) {
        exData = exData.copyWith(contacts: [...exData.contacts, n.text]);
      }
      if (currentSection == 'work_experience') {
        exData =
            exData.copyWith(workExperience: [...exData.workExperience, n.text]);
      }
      if (currentSection == 'education') {
        exData = exData.copyWith(education: [...exData.education, n.text]);
      }
      if (currentSection == 'skills') {
        exData = exData.copyWith(skills: [...exData.skills, n.text]);
      }
      if (currentSection == 'projects') {
        exData = exData.copyWith(projects: [...exData.projects, n.text]);
      }
      if (currentSection == 'certifications') {
        exData =
            exData.copyWith(certifications: [...exData.certifications, n.text]);
      }
    }
    if (node.node == NodeType.listItem) {
      final n = node as ListItemNodeModel;
      // print('<===================>  ' + n.text);
      if (n.spans.isEmpty) {
      } else {
        for (final span in n.spans) {
          if (span is UplSpanData) {
            // final s = span as UplSpanData;
            if (span.attType == 'contact') {
              if (!exData.contacts.contains(n.text)) {
                exData =
                    exData.copyWith(contacts: [...exData.contacts, n.text]);
              }
              //  print('1===========> ${span.attType}');
            } else {
              //  print('2===========> ${span.attType}');
            }
          }
          // print('3===========> ${n.text}');
        }
      }
      if (contactKeywords.any(n.text.startsWith)) {
        exData = exData.copyWith(contacts: [...exData.contacts, n.text]);
      }
      if (currentSection == 'work_experience') {
        exData =
            exData.copyWith(workExperience: [...exData.workExperience, n.text]);
      }
      if (currentSection == 'education') {
        exData = exData.copyWith(education: [...exData.education, n.text]);
      }
      if (currentSection == 'skills') {
        exData = exData.copyWith(skills: [...exData.skills, n.text]);
      }
      if (currentSection == 'projects') {
        exData = exData.copyWith(projects: [...exData.projects, n.text]);
      }
      if (currentSection == 'certifications') {
        exData =
            exData.copyWith(certifications: [...exData.certifications, n.text]);
      }
    }
  }
  return exData;
}

Future<WorkFilter> getJobFilters(Nodes nodes) async {
  String? currentSection;
  var exData = WorkFilter.empty();
  for (final node in nodes.nodes) {
    if (node.node == NodeType.paragraph) {
      final n = node as ParagraphNodeModel;
      final isHeader =
          ['header1', 'header2', 'header3'].contains(n.metaData.id);

      final isHeader2or3 =
          n.metaData.id == 'header2' || n.metaData.id == 'header3';
      final hasColorSpan = n.spans.any((span) => span is ColorSpanData);
      final hasUplSpan = n.spans.any((span) => span is UplSpanData);

      // final hasColorSpan = n.spans.whereType().first is ColorSpanData;

      if (isHeader && hasColorSpan && !hasUplSpan) {
        if (n.metaData.id == 'header1' || isHeader2or3) {
          if (n.metaData.id == 'header1') {
            currentSection = n.metaData.id;
            exData = exData.copyWith(title: n.text);
          }
          if (isHeader2or3 || n.text == 'location') {
            currentSection = 'location';
          }
          if (isHeader2or3 || n.text == 'salary') {
            currentSection = 'salary';
          }
          if (isHeader2or3 || n.text == 'job_type') {
            currentSection = 'job_type';
          }
          if (isHeader2or3 || n.text == 'overview') {
            currentSection = 'overview';
          }
          if (isHeader2or3 || n.text == 'responsibilities') {
            currentSection = 'responsibilities';
          }
          if (isHeader2or3 || n.text == 'requirements') {
            currentSection = 'requirements';
          }
          if (isHeader2or3 || n.text == 'benefits') {
            currentSection = 'benefits';
          }
          if (isHeader2or3 || n.text == 'how_to_apply') {
            currentSection = 'how_to_apply';
          }
        }
      } else {
        for (final span in n.spans) {
          if (span is UplSpanData) {
            final s = span;
            if (s.attType == 'title') {
              currentSection = s.attType;
              exData = exData.copyWith(title: n.text);
            } else if (s.attType == 'location') {
              currentSection = 'location';
            } else if (s.attType == 'salary') {
              currentSection = 'salary';
            } else if (s.attType == 'job_type') {
              currentSection = 'job_type';
            } else if (s.attType == 'overview') {
              currentSection = 'overview';
            } else if (s.attType == 'responsibilities') {
              currentSection = 'responsibilities';
            } else if (s.attType == 'requirements') {
              currentSection = 'requirements';
            } else if (s.attType == 'benefits') {
              currentSection = 'benefits';
            } else if (s.attType == 'how_to_apply') {
              currentSection = 'how_to_apply';
            }
          }
        }
      }

      if (currentSection == 'header1' || currentSection == 'title') {}
      if (currentSection == 'location') {
        exData = exData.copyWith(location: n.text);
      }
      if (currentSection == 'salary') {
        exData = exData.copyWith(salary: n.text);
      }
      if (currentSection == 'job_type') {
        exData = exData.copyWith(jobType: n.text);
      }
      if (currentSection == 'overview') {
        exData = exData.copyWith(overview: n.text);
      }
      if (currentSection == 'responsibilities') {
        exData =
            exData.copyWith(responsibility: [...exData.responsibility, n.text]);
      }
      if (currentSection == 'requirements') {
        exData =
            exData.copyWith(requirements: [...exData.requirements, n.text]);
      }
      if (currentSection == 'benefits') {
        exData = exData.copyWith(benefit: [...exData.benefit, n.text]);
      }
      if (currentSection == 'how_to_apply') {
        exData = exData.copyWith(howToApply: n.text);
      }
    }
    if (node.node == NodeType.listItem) {
      final n = node as ListItemNodeModel;
      if (n.spans.isEmpty) {
      } else {
        for (final span in n.spans) {
          if (span is UplSpanData) {}
        }
      }
      if (currentSection == 'header1' || currentSection == 'title') {}
      if (currentSection == 'location') {
        exData = exData.copyWith(location: n.text);
      }
      if (currentSection == 'salary') {
        exData = exData.copyWith(salary: n.text);
      }
      if (currentSection == 'job_type') {
        exData = exData.copyWith(jobType: n.text);
      }
      if (currentSection == 'overview') {
        exData = exData.copyWith(overview: n.text);
      }
      if (currentSection == 'responsibilities') {
        exData =
            exData.copyWith(responsibility: [...exData.responsibility, n.text]);
      }
      if (currentSection == 'requirements') {
        exData =
            exData.copyWith(requirements: [...exData.requirements, n.text]);
      }
      if (currentSection == 'benefits') {
        exData = exData.copyWith(benefit: [...exData.benefit, n.text]);
      }
      if (currentSection == 'how_to_apply') {
        exData = exData.copyWith(howToApply: n.text);
      }
    }
  }

  return exData;
}
