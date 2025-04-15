import 'dart:developer' as dev;
import 'dart:io' show File;
import 'dart:math' show max, min;

import 'package:experiment_catalogue/app/view/first+try/colors.dart'
    show ColorPickerType, defaultColors;
import 'package:experiment_catalogue/app/view/first+try/document_to_json.dart';
import 'package:experiment_catalogue/app/view/first+try/local_image_n.dart';
import 'package:experiment_catalogue/app/view/first+try/node_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:uuid/uuid.dart';

class FirstTryEditor extends StatefulWidget {
  const FirstTryEditor({super.key});

  @override
  _FirstTryEditorState createState() => _FirstTryEditorState();
}

class _FirstTryEditorState extends State<FirstTryEditor> {
  final GlobalKey _docLayoutKey = GlobalKey();

  late MutableDocument _doc;
  final _docChangeSignal = SignalNotifier();
  late Editor _docEditor;
  late MutableDocumentComposer _composer;
  late CommonEditorOperations _docOps;
  late MagnifierAndToolbarController _overlayController;

  FocusNode? _editorFocusNode;

  @override
  void initState() {
    super.initState();
    _doc = MutableDocument.empty()..addListener(_onDocumentChange);
    _composer = MutableDocumentComposer()..addListener(() {});
    _docEditor = Editor(
      editables: {
        Editor.documentKey: _doc,
        Editor.composerKey: _composer,
      },
      requestHandlers: List.from(defaultRequestHandlers),
      historyGroupingPolicy: defaultMergePolicy,
      reactionPipeline: List.from(defaultEditorReactions),
      // isHistoryEnabled: false,
    );
    _docOps = CommonEditorOperations(
      document: _doc,
      editor: _docEditor,
      composer: _composer,
      documentLayoutResolver: () =>
          _docLayoutKey.currentState! as DocumentLayout,
    );

    _editorFocusNode = FocusNode();
    _overlayController = MagnifierAndToolbarController();
  }

  @override
  void dispose() {
    _editorFocusNode!.dispose();
    _composer.dispose();
    _doc.removeListener(_onDocumentChange);
    super.dispose();
  }

  void _onDocumentChange(_) => _docChangeSignal.notifyListeners();

  //! --- toggle attribute
  void _toggleAttributions(Set<Attribution> attributions) {
    final selection = _composer.selection;
    if (selection == null) {
      return;
    }

    selection.isCollapsed
        ? _docOps.toggleComposerAttributions(attributions)
        : _docOps.toggleAttributionsOnSelection(attributions);
  }

  bool _doesSelectionHaveAttributions(Set<Attribution> attributions) {
    final selection = _composer.selection;
    if (selection == null) {
      return false;
    }

    if (selection.isCollapsed) {
      return _composer.preferences.currentAttributions
          .containsAll(attributions);
    }

    return _doc.doesSelectedTextContainAttributions(selection, attributions);
  }

  bool get isBoldActive => _doesSelectionHaveAttributions({boldAttribution});
  void toggleBold() => _toggleAttributions({boldAttribution});

  bool get isItalicsActive =>
      _doesSelectionHaveAttributions({italicsAttribution});
  void toggleItalics() => _toggleAttributions({italicsAttribution});

  bool get isUnderlineActive =>
      _doesSelectionHaveAttributions({underlineAttribution});
  void toggleUnderline() => _toggleAttributions({underlineAttribution});

  bool get isStrikethroughActive =>
      _doesSelectionHaveAttributions({strikethroughAttribution});
  void toggleStrikethrough() => _toggleAttributions({strikethroughAttribution});

  bool _isHeaderType(Set<NamedAttribution> attributions) {
    final selection = _composer.selection;
    if (selection == null) {
      return false;
    }

    final selectedNode = _doc.getNodeById(selection.extent.nodeId);
    return selectedNode?.getMetadataValue('blockType') != attributions.first;
  }

  void _convertHeader(NamedAttribution header) {
    final selectedNode = _doc.getNodeById(_composer.selection!.extent.nodeId);
    if (selectedNode is! TextNode &&
        _composer.selection?.extent.nodeId !=
            _composer.selection?.base.nodeId) {
      return;
    }

    if (selectedNode is ListItemNode) {
      _docOps.convertToParagraph(
        newMetadata: {
          'blockType': header,
        },
      );
    } else {
      _docEditor.execute([
        ChangeParagraphBlockTypeRequest(
          nodeId: selectedNode!.id,
          blockType: header,
        ),
        if (selectedNode.getMetadataValue('blockType') == header)
          ChangeParagraphBlockTypeRequest(
            nodeId: selectedNode.id,
            blockType: paragraphAttribution,
          ),
      ]);
    }
  }

  void _convertListItem(ListItemType type) {
    final selectedNode =
        _doc.getNodeById(_composer.selection!.extent.nodeId)! as TextNode;
    if (selectedNode.getMetadataValue('blockType') == listItemAttribution &&
        selectedNode is ListItemNode &&
        selectedNode.type == type) {
      _docOps.convertToParagraph();
      return;
    }

    _docOps.convertToListItem(type, selectedNode.text);
  }

  bool _isListItemType(ListItemType type) {
    final selection = _composer.selection;
    if (selection == null) {
      return false;
    }

    final selectedNode = _doc.getNodeById(selection.extent.nodeId);
    return selectedNode?.getMetadataValue('blockType') == listItemAttribution &&
        selectedNode is ListItemNode &&
        selectedNode.type == type;
  }

  void convertToBlockquote() {
    final selectedNode =
        _doc.getNodeById(_composer.selection!.extent.nodeId)! as TextNode;

    if (selectedNode.getMetadataValue('blockType') == blockquoteAttribution) {
      _docOps.convertToParagraph();
      return;
    }

    _docOps.convertToBlockquote(selectedNode.text);
  }

  void convertToHr() {
    final selectedNode =
        _doc.getNodeById(_composer.selection!.extent.nodeId)! as TextNode;

    _docEditor.execute([
      ReplaceNodeRequest(
        existingNodeId: selectedNode.id,
        newNode: ParagraphNode(
          id: selectedNode.id,
          text: AttributedText('---'),
        ),
      ),
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: selectedNode.id,
            nodePosition: const TextNodePosition(offset: 3),
          ),
        ),
        SelectionChangeType.insertContent,
        SelectionReason.userInteraction,
      ),
      InsertCharacterAtCaretRequest(character: ' '),
    ]);
  }

  Future<void> pickAndConvertToImage() async {
    final result = await FilePicker.platform.pickFiles(
      // allowedExtensions: ['jpg', 'png', 'jpeg', 'webp'],
      type: FileType.image,
    );
    if (result == null) return;

    final file = File(result.files.single.path!);

    // final selectedNode =
    //     _doc.getNodeById(_composer.selection!.extent.nodeId)! as TextNode;

    // final imageNode = ImageNode(
    //   id: 'selectedNode.id',
    //   imageUrl: file.path,
    //   altText: '00000000000000000',
    // );

    final imageNode = LocalImageNode(
      //   id: const Uuid().v4(),
      id: Editor.createNodeId(),
      imageUrl: file.path,
      altText: '00000000000000000',
    );

    _docEditor.execute([
      InsertNodeAtCaretRequest(
        node: imageNode,
      ),
    ]);
  }

  bool get isNameActive =>
      _doesSelectionHaveAttributions({const UplAttribution.name()});
  void toggleName() => _toggleAttributions({const UplAttribution.name()});

  bool get isContactActive =>
      _doesSelectionHaveAttributions({const UplAttribution.contact()});
  void toggleContact() => _toggleAttributions({const UplAttribution.contact()});
  bool get isWorkExperienceActive =>
      _doesSelectionHaveAttributions({const UplAttribution.workExperience()});
  void toggleWorkExperience() =>
      _toggleAttributions({const UplAttribution.workExperience()});

  bool get isEducationActive =>
      _doesSelectionHaveAttributions({const UplAttribution.education()});
  void toggleEducation() =>
      _toggleAttributions({const UplAttribution.education()});

  Future<void> _onLinkPressed() async {
    final selection = _composer.selection!;
    final baseOffset = (selection.base.nodePosition as TextPosition).offset;
    final extentOffset = (selection.extent.nodePosition as TextPosition).offset;
    final selectionStart = min(baseOffset, extentOffset);
    final selectionEnd = max(baseOffset, extentOffset);
    final selectionRange = SpanRange(selectionStart, selectionEnd - 1);

    final textNode = _doc.getNodeById(selection.extent.nodeId) as TextNode;
    final text = textNode.text;
//TODO: 1. update the inserted text.
    final urlController = TextEditingController(text: 'https://');
    final insertedUrl = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(canvasColor: Colors.orange),
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            title: const Text('Enter URL'),
            content: TextField(
              controller: urlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'Enter website URL',
                border: OutlineInputBorder(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop(urlController.text);
                },
              ),
            ],
          ),
        );
      },
    );
    if (insertedUrl != null && insertedUrl.isNotEmpty) {
      final linkAttribution = LinkAttribution.fromUri(Uri.parse(insertedUrl));
      SpanRange trimmedRange() {
        var startOffset = selectionRange.start;
        var endOffset = selectionRange.end;

        final plainText = text.toPlainText();
        while (
            startOffset < selectionRange.end && plainText[startOffset] == ' ') {
          startOffset += 1;
        }
        while (endOffset > startOffset && plainText[endOffset] == ' ') {
          endOffset -= 1;
        }

        // Add 1 to the end offset because SpanRange treats the end offset to be exclusive.
        return SpanRange(startOffset, endOffset + 1);
      }

      _docEditor.execute([
        AddTextAttributionsRequest(
          documentRange: DocumentRange(
            start: DocumentPosition(
              nodeId: textNode.id,
              nodePosition: TextNodePosition(offset: trimmedRange().start),
            ),
            end: DocumentPosition(
              nodeId: textNode.id,
              nodePosition: TextNodePosition(offset: trimmedRange().end),
            ),
          ),
          attributions: {linkAttribution},
        ),
      ]);
      urlController.clear();
      setState(() {});
    }
  }

  TextAlign _getCurrentTextAlignment() {
    final selectedNode = _doc.getNodeById(_composer.selection!.extent.nodeId);
    if (selectedNode is ParagraphNode) {
      final align = selectedNode.getMetadataValue('textAlign');
      switch (align) {
        case 'left':
          return TextAlign.left;
        case 'center':
          return TextAlign.center;
        case 'right':
          return TextAlign.right;
        case 'justify':
          return TextAlign.justify;
        default:
          return TextAlign.left;
      }
    } else {
      return TextAlign.left;
      // throw Exception('Invalid node type: $selectedNode');
    }
  }

  Future<void> _onColorPressed(ColorPickerType type) async {
    final selection = _composer.selection;
    //final selectedNode = _doc.getNodeById(_composer.selection!.extent.nodeId);
    print('-------- s => $selection ==');
    if (selection == null) {
      return;
    }

    final newColor = await showDialog<(Color?, String?)?>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(canvasColor: Colors.orange),
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            title: const Text('Pick Color'),
            content: SizedBox(
              height: 90,
              width: 90,
              child: GridView.builder(
                itemCount: defaultColors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                ),
                itemBuilder: (context, index) {
                  final color = defaultColors[index];
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop((color, null)),
                      child: SizedBox(
                        height: 0.2,
                        width: 0.2,
                        child: ColoredBox(color: color),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              //   if (type == ColorPickerType.highlight)
              TextButton(
                child: const Text('Reset'),
                onPressed: () {
                  Navigator.of(context).pop((null, 'reset'));
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );

    final basePosition = selection.base.nodePosition;
    final extentPosition = selection.extent.nodePosition;
    if (basePosition is TextNodePosition &&
        extentPosition is TextNodePosition) {
      final start = basePosition.offset;
      final end = extentPosition.offset;
      if (start == end || start >= -1 && start > end) {
        // _composer.preferences.clearStyles();
        // _composer.preferences.addStyle(ColorAttribution(newColor!));

        // defaultEdit.value =
        //     defaultEdit.value.copyWith(defaultColor: newColor);
      } else {
        if (type == ColorPickerType.text) {
          final colorAttributions =
              _doc.getAttributionsByType<ColorAttribution>(selection);
          _docEditor.execute([
            InsertTextRequest(
              documentPosition: selection.extent,
              textToInsert: ' ',
              attributions: {},
              //  attributions: {paragraphAttribution},
            ),
            for (final existingAttribution in colorAttributions) //
              RemoveTextAttributionsRequest(
                  documentRange: selection,
                  attributions: {existingAttribution}),
            if (newColor?.$1 != null) //
              AddTextAttributionsRequest(
                documentRange: selection,
                attributions: {ColorAttribution(newColor!.$1!)},
                autoMerge: false,
              ),
          ]);
        } else if (type == ColorPickerType.highlight) {
          final colorAttributions =
              _doc.getAttributionsByType<BackgroundColorAttribution>(selection);
          _docEditor.execute([
            InsertTextRequest(
              documentPosition: selection.extent,
              textToInsert: ' ',
              attributions: {},
              //  attributions: {paragraphAttribution},
            ),
            for (final existingAttribution in colorAttributions) //
              RemoveTextAttributionsRequest(
                  documentRange: selection,
                  attributions: {existingAttribution}),
            if (newColor?.$1 != null) //
              AddTextAttributionsRequest(
                documentRange: selection,
                attributions: {BackgroundColorAttribution(newColor!.$1!)},
              ),
          ]);
        }
        if (newColor?.$2 == 'reset') {
          final bkgColorAttributions =
              _doc.getAttributionsByType<BackgroundColorAttribution>(selection);
          final txtColorAttributions =
              _doc.getAttributionsByType<ColorAttribution>(selection);
          _docEditor.execute([
            InsertTextRequest(
              documentPosition: selection.extent,
              textToInsert: ' ',
              attributions: {},
            ),
            if (type == ColorPickerType.highlight)
              for (final existingAttribution in bkgColorAttributions) //
                RemoveTextAttributionsRequest(
                    documentRange: selection,
                    attributions: {existingAttribution}),
            if (type == ColorPickerType.text)
              for (final existingAttribution in txtColorAttributions) //
                RemoveTextAttributionsRequest(
                    documentRange: selection,
                    attributions: {existingAttribution}),
          ]);
        }
      }
    }
  }

  Color? currentTextColor() {
    if (_composer.selection == null) {
      return Colors.black;
    }
    final colorAttributions =
        _doc.getAttributionsByType<ColorAttribution>(_composer.selection!);
    if (colorAttributions.isEmpty) {
      return Colors.black;
    }
    return colorAttributions.first.color;
  }

  Color? currentHighlightColor() {
    if (_composer.selection == null) {
      return Colors.black;
    }
    final colorAttributions =
        _doc.getAttributionsByType<BackgroundColorAttribution>(
            _composer.selection!);
    if (colorAttributions.isEmpty) {
      return Colors.black;
    }
    return colorAttributions.first.color;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    final isLight = brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 22),
            child: ElevatedButton(
              onPressed: () async {
                dev.log('------------------>');
                // dev.log(serializeDocumentToMarkdown(_doc));
                //   dev.log(_doc.toString());
                //  dev.log(documentModelToJson(_doc).toString());
                final d = Nodes(nodes: documentModelToJson(_doc));
                final c = await getCvFilters(d);
                dev.log(c.toString());
                dev.log('------------------>');
              },
              child: const Text('Upload'),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          MultiListenableBuilder(
              listenables: <Listenable>{
                _docChangeSignal,
                _composer.selectionNotifier
              },
              builder: (_) {
                final selection = _composer.selection;
                final selectedNode = selection != null
                    ? _doc.getNodeById(selection.extent.nodeId)
                    : null;
                final isTextSelected =
                    selection != null && selectedNode is TextNode;
                // dev.log('=======>' + selection.toString());
                final isSingleNodeSelected = selection == null
                    ? false
                    : selection.extent.nodeId == selection.base.nodeId;

                final primaryColor = Theme.of(context).colorScheme.primary;

                if (selection == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  height: 70,
                  color: Colors.blueGrey[200],
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      IconButton(
                        onPressed: isTextSelected ? toggleBold : null,
                        icon: const Icon(Icons.format_bold),
                        color: isBoldActive ? primaryColor : null,
                      ),
                      IconButton(
                        onPressed: isTextSelected ? toggleItalics : null,
                        icon: const Icon(Icons.format_italic),
                        color: isItalicsActive ? primaryColor : null,
                      ),
                      IconButton(
                        onPressed: isTextSelected ? toggleUnderline : null,
                        icon: const Icon(Icons.format_underline),
                        color: isUnderlineActive ? primaryColor : null,
                      ),
                      IconButton(
                        onPressed: isTextSelected ? toggleStrikethrough : null,
                        icon: const Icon(Icons.strikethrough_s),
                        color: isStrikethroughActive ? primaryColor : null,
                      ),
                      IconButton(
                        onPressed: () => _onColorPressed(ColorPickerType.text),
                        icon: Icon(
                          Icons.format_color_text,
                          color: currentTextColor(),
                        ), //text color
                      ),
                      IconButton(
                        onPressed: () =>
                            _onColorPressed(ColorPickerType.highlight),
                        icon: Icon(
                          Icons.format_color_fill,
                          color: currentHighlightColor(),
                        ), //highlight
                      ),
                      IconButton(
                        onPressed: convertToBlockquote,
                        icon: const Icon(Icons.format_quote),
                        color: _isHeaderType({blockquoteAttribution})
                            ? Colors.black
                            : primaryColor,
                      ),
                      TextButton(
                        onPressed: () => _convertHeader(header1Attribution),
                        child: Text(
                          'H1',
                          style: TextStyle(
                            color: _isHeaderType({header1Attribution})
                                ? Colors.black
                                : primaryColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _convertHeader(header2Attribution),
                        child: Text(
                          'H2',
                          style: TextStyle(
                            color: _isHeaderType({header2Attribution})
                                ? Colors.black
                                : primaryColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _convertHeader(header3Attribution),
                        child: Text(
                          'H3',
                          style: TextStyle(
                            color: _isHeaderType({header3Attribution})
                                ? Colors.black
                                : primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _convertListItem(ListItemType.ordered),
                        icon: const Icon(Icons.looks_one_rounded),
                        color: _isListItemType(ListItemType.ordered)
                            ? primaryColor
                            : null,
                      ),
                      IconButton(
                        onPressed: () =>
                            _convertListItem(ListItemType.unordered),
                        icon: const Icon(Icons.list),
                        color: _isListItemType(ListItemType.unordered)
                            ? primaryColor
                            : null,
                      ),
                      Row(
                        children: [
                          Icons.format_align_left,
                          Icons.format_align_center,
                          Icons.format_align_right,
                          Icons.format_align_justify
                        ].map((e) {
                          final alignment = _getCurrentTextAlignment();
                          final current = switch (alignment) {
                            TextAlign.left => Icons.format_align_left,
                            TextAlign.right => Icons.format_align_right,
                            TextAlign.center => Icons.format_align_center,
                            TextAlign.justify => Icons.format_align_justify,
                            _ => throw UnimplementedError(),
                          };
                          final selected = switch (e) {
                            Icons.format_align_left => TextAlign.left,
                            Icons.format_align_right => TextAlign.right,
                            Icons.format_align_center => TextAlign.center,
                            Icons.format_align_justify => TextAlign.justify,
                            _ => throw UnimplementedError(),
                          };
                          return IconButton(
                            onPressed: () {
                              final selection = _composer.selection;
                              if (selection == null) {
                                return;
                              }

                              _docEditor.execute([
                                ChangeParagraphAlignmentRequest(
                                  nodeId: _composer.selection!.extent.nodeId,
                                  alignment: TextAlign.values.firstWhere(
                                      (e) => e.name == selected.name),
                                ),
                              ]);
                            },
                            icon: Icon(e),
                            isSelected: e == current,
                          );
                        }).toList(),
                      ),
                      IconButton(
                        onPressed: ((selection.base.nodePosition
                                        as TextPosition)
                                    .offset) ==
                                (selection.extent.nodePosition as TextPosition)
                                    .offset
                            ? null
                            : _onLinkPressed,
                        icon: const Icon(Icons.link),
                        color: isNameActive ? primaryColor : null,
                      ),
                      IconButton(
                        onPressed: isSingleNodeSelected &&
                                selectedNode is ParagraphNode &&
                                selectedNode.text.isEmpty
                            ? convertToHr
                            : null,
                        icon: const Icon(Icons.horizontal_rule),
                      ),
                      IconButton(
                        onPressed: isSingleNodeSelected &&
                                selectedNode is ParagraphNode &&
                                selectedNode.text.isEmpty
                            ? pickAndConvertToImage
                            : null,
                        icon: const Icon(Icons.print_outlined),
                      ),
                      //*
                      IconButton(
                        onPressed: toggleName,
                        icon: const Icon(Icons.person_2_outlined),
                        color: isNameActive ? primaryColor : null,
                      ),
                      IconButton(
                        onPressed: toggleContact,
                        icon: const Icon(Icons.phone_android_outlined),
                        color: isContactActive ? primaryColor : null,
                      ),
                      IconButton(
                        onPressed: toggleWorkExperience,
                        icon: const Icon(Icons.work_outline_outlined),
                        color: isWorkExperienceActive ? primaryColor : null,
                      ),
                      IconButton(
                        onPressed: toggleEducation,
                        icon: const Icon(Icons.school_outlined),
                        color: isEducationActive ? primaryColor : null,
                      ),
                    ],
                  ),
                );
              }),
          const Divider(
            color: Colors.black,
            thickness: 0.4,
          ),
          Expanded(
            child: ColoredBox(
              color: isLight ? _lightBackground : _darkBackground,
              child: SuperEditor(
                focusNode: _editorFocusNode,
                documentLayoutKey: _docLayoutKey,
                editor: _docEditor,
                overlayController: _overlayController,
                stylesheet: defaultStylesheet.copyWith(
                  inlineTextStyler: (attributions, existingStyle) {
                    return defaultInlineTextStyler(attributions, existingStyle)
                        .merge(
                      customStyleBuilder(
                        attributions,
                        existingStyle.color,
                      ),
                    );
                  },
                  addRulesAfter: [
                    if (!isLight) ..._darkModeStyles,
                    taskStyles,
                    // StyleRule(
                    //   const BlockSelector('header4'),
                    //   (doc, node) {
                    //     return {
                    //       Styles.textStyle:
                    //           const TextStyle(backgroundColor: Colors.green),
                    //     };
                    //   },
                    // ),
                  ],
                ),
                componentBuilders: [
                  ...defaultComponentBuilders,
                  TaskComponentBuilder(_docEditor),
                  const LocalImageComponentBuilder()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UplAttribution implements Attribution {
  const UplAttribution.name() : type = typeName;
  const UplAttribution.contact() : type = typeContact;
  const UplAttribution.workExperience() : type = typeWorkExperience;
  const UplAttribution.education() : type = typeEducation;
  const UplAttribution.skills() : type = typeSkills;
  const UplAttribution.projects() : type = typeProjects;
  const UplAttribution.certifications() : type = typeCertifications;

  const UplAttribution.title() : type = typeTitle;
  const UplAttribution.location() : type = typeLocation;
  const UplAttribution.salary() : type = typeSalary;
  const UplAttribution.jobType() : type = typeJobType;
  const UplAttribution.overview() : type = typeOverview;
  const UplAttribution.responsibilities() : type = typeResponsibilities;
  const UplAttribution.requirements() : type = typeRequirements;
  const UplAttribution.benefits() : type = typeBenefits;
  const UplAttribution.howToApply() : type = typeHowToApply;

  static const typeName = 'name';
  static const typeContact = 'contact';
  static const typeWorkExperience = 'work_experience';
  static const typeEducation = 'education';
  static const typeSkills = 'skills';
  static const typeProjects = 'projects';
  static const typeCertifications = 'certifications';

  static const typeTitle = 'title';
  static const typeLocation = 'location';
  static const typeSalary = 'salary';
  static const typeJobType = 'job_type';
  static const typeOverview = 'overview';
  static const typeResponsibilities = 'responsibilities';
  static const typeRequirements = 'requirements';
  static const typeBenefits = 'benefits';
  static const typeHowToApply = 'how_to_apply';

  @override
  String get id => 'upl';

  final String type;

  @override
  bool canMergeWith(Attribution other) {
    return other is UplAttribution && type == other.type;
  }

  @override
  String toString() {
    return '[UplAttribution]: $type';
  }
}

TextStyle customStyleBuilder(Set<Attribution> attribution, Color? color) {
  var newStyle = const TextStyle();
  for (final attribution in attribution) {
    if (attribution == const UplAttribution.name()) {
      newStyle = newStyle.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.amber,
              Colors.yellow,
              Colors.red,
              color ?? Colors.black,
            ],
            stops: const [0.4, 0.7, 0.9, 1.0],
          ).createShader(const Rect.fromLTWH(0, 0, 100, 20)),
      );
    }
    if (attribution == const UplAttribution.contact()) {
      newStyle = newStyle.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.blue,
              Colors.red,
              Colors.green,
              color ?? Colors.black,
            ],
            stops: const [0.4, 0.7, 0.9, 1.0],
          ).createShader(const Rect.fromLTWH(0, 0, 100, 20)),
      );
    }
    if (attribution == const UplAttribution.workExperience()) {
      newStyle = newStyle.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.limeAccent,
              Colors.pink,
              Colors.indigo,
              color ?? Colors.black,
            ],
            stops: const [0.4, 0.7, 0.9, 1.0],
          ).createShader(const Rect.fromLTWH(0, 0, 100, 20)),
      );
    }
    if (attribution == const UplAttribution.education()) {
      newStyle = newStyle.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.teal,
              Colors.pink,
              Colors.pink,
              color ?? Colors.black,
            ],
            stops: const [0.4, 0.7, 0.9, 1.0],
          ).createShader(const Rect.fromLTWH(0, 0, 100, 20)),
      );
    }
  }
  return newStyle;
}

const _darkBackground = Color(0xFF222222);
const _lightBackground = Colors.white;
final _darkModeStyles = [
  StyleRule(
    BlockSelector.all,
    (doc, docNode) {
      return {
        Styles.textStyle: const TextStyle(
          color: Color(0xFFCCCCCC),
        ),
      };
    },
  ),
  StyleRule(
    const BlockSelector('header1'),
    (doc, docNode) {
      return {
        Styles.textStyle: const TextStyle(
          color: Color(0xFF888888),
        ),
      };
    },
  ),
  StyleRule(
    const BlockSelector('header2'),
    (doc, docNode) {
      return {
        Styles.textStyle: const TextStyle(
          color: Color(0xFF888888),
        ),
      };
    },
  ),
];

// final Map<String, IconData> icons = {
//   'name': Icons.person, // Represents a person
//   'contact': Icons.phone, // Phone/contact details
//   'work_experience': Icons.work, // Work-related information
//   'education': Icons.school, // Education details
//   'skills': Icons.star, // Skills, expertise
//   'projects': Icons.build, // Projects, development
//   'certifications': Icons.verified, // Certifications, achievements
// };
