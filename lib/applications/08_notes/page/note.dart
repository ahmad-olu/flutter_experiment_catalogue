import 'dart:developer';

import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/app/router.gr.dart';
import 'package:experiment_catalogue/applications/08_notes/infrastructure/color_selector.dart';
import 'package:experiment_catalogue/applications/08_notes/infrastructure/icon_selector.dart';
import 'package:experiment_catalogue/applications/08_notes/infrastructure/text_item_selector.dart'
    show TextItem, TextItemSelector;
import 'package:experiment_catalogue/applications/08_notes/theme.dart'
    show popoverAligner;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:overlord/overlord.dart'
    show FunctionalPopoverAligner, PopoverGeometry;
import 'package:super_editor/super_editor.dart';

@RoutePage()
class Note08PageOne extends HookWidget {
  const Note08PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
            onPressed: () => context.router.push(const Note08RouteTwo()),
            child: Text('Go to 2nd page')),
      ),
    );
  }
}

@RoutePage()
class Note08PageTwo extends HookWidget {
  const Note08PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    final editorFocusNode = useMemoized(FocusNode.new, []);

    final zoomLevel = useState(100);
    final document = useMemoized(MutableDocument.empty);
    final composer = useMemoized(MutableDocumentComposer.new);
    final editor = useMemoized(() => createDefaultDocumentEditor(
          document: document,
          composer: composer,
        ));

    useEffect(() {
      return () {
        editor.dispose();
        composer.dispose();
        document.dispose();
        editorFocusNode.dispose();
      };
    }, []);

    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
              onPressed: () => log(editor.document.toString()),
              child: Text('save'))
        ],
      ),
      body: Column(
        children: [
          EditorToolBar(
            editorFocusNode: editorFocusNode,
            document: document,
            editor: editor,
            composer: composer,
            onZoomChange: (zoom) => zoomLevel.value = zoom,
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, thickness: 1, color: Color(0xFFc4c7c5)),
          Expanded(
            child: Transform.scale(
                scale: zoomLevel.value / 100.0,
                alignment: Alignment.topCenter,
                child: ListenableBuilder(
                  listenable: editorFocusNode,
                  builder: (context, child) {
                    return SuperEditor(
                      focusNode: editorFocusNode,
                      editor: editor,
                      autofocus: true,
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}

@RoutePage()
class Note08PageThree extends HookWidget {
  const Note08PageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

const tooltipDelay = Duration(milliseconds: 500);
const _tapRegionGroupId = 'docs_toolbar';
IconData _getTextAlignIcon(TextAlign align) {
  switch (align) {
    case TextAlign.left:
    case TextAlign.start:
      return Icons.format_align_left;
    case TextAlign.center:
      return Icons.format_align_center;
    case TextAlign.right:
    case TextAlign.end:
      return Icons.format_align_right;
    case TextAlign.justify:
      return Icons.format_align_justify;
  }
}

class EditorToolBar extends HookWidget {
  const EditorToolBar({
    required this.editorFocusNode,
    required this.document,
    required this.editor,
    required this.composer,
    required this.onZoomChange,
    super.key,
  });
  final FocusNode editorFocusNode;
  final MutableDocument document;
  final Editor editor;
  final MutableDocumentComposer composer;
  final void Function(int zoom) onZoomChange;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    Set<Attribution> _getAllAttributions() {
      final selection = composer.selection;
      if (selection == null) {
        return <Attribution>{};
      }

      if (selection.isCollapsed) {
        return composer.preferences.currentAttributions;
      }

      return document.getAllAttributions(selection);
    }

    final attributions = _getAllAttributions();

    final selectedZoom = useState(const TextItem(id: '100', label: '100%'));

    void toggleAttribution(Attribution attribution) {
      final selection = composer.selection;

      if (selection == null) return;
      final basePosition = selection.base.nodePosition;
      final extentPosition = selection.extent.nodePosition;
      if (basePosition is TextNodePosition &&
          extentPosition is TextNodePosition) {
        final start = basePosition.offset;
        final end = extentPosition.offset;
        if (start == end || start >= -1 && start > end) return;
        if (end == 0) return;
      }

      editor.execute([
        ToggleTextAttributionsRequest(
          documentRange: selection,
          attributions: {attribution},
        ),
      ]);
    }

    bool doesSelectionHaveAttributions(Set<Attribution> attributions) {
      final selection = composer.selection;
      if (selection == null) {
        return false;
      }

      if (selection.isCollapsed) {
        return composer.preferences.currentAttributions
            .containsAll(attributions);
      }

      return document.doesSelectedTextContainAttributions(
        selection,
        attributions,
      );
    }

    void _onChangeZoomLevelRequested(TextItem? zoomLevel) {
      if (zoomLevel == null) {
        return;
      }

      onZoomChange(int.parse(zoomLevel.id));

      selectedZoom.value = zoomLevel;
    }

    Widget buildZoomSelector() {
      return Tooltip(
        message: 'Zoom',
        waitDuration: tooltipDelay,
        child: TextItemSelector(
          parentFocusNode: editorFocusNode,
          selectedText: selectedZoom.value,
          buttonSize: const Size(77, 30),
          popoverGeometry: const PopoverGeometry(
            constraints: BoxConstraints.tightFor(width: 77),
            aligner: FunctionalPopoverAligner(popoverAligner),
          ),
          items: const [
            TextItem(id: '50', label: '50%'),
            TextItem(id: '75', label: '75%'),
            TextItem(id: '90', label: '90%'),
            TextItem(id: '100', label: '100%'),
            TextItem(id: '125', label: '125%'),
            TextItem(id: '150', label: '150%'),
            TextItem(id: '200', label: '200%'),
          ],
          onSelected: _onChangeZoomLevelRequested,
        ),
      );
    }

    void _onChangeTextColorRequested(Color? newColor) {
      final selection = composer.selection;
      if (selection == null) {
        return;
      }

      final colorAttributions =
          document.getAttributionsByType<ColorAttribution>(selection);

      editor.execute([
        for (final existingAttribution in colorAttributions) //
          RemoveTextAttributionsRequest(
              documentRange: selection, attributions: {existingAttribution}),
        if (newColor != null) //
          AddTextAttributionsRequest(
            documentRange: selection,
            attributions: {ColorAttribution(newColor)},
          ),
      ]);
    }

    Widget _buildTextColorIcon(Color? color) {
      return Stack(
        children: [
          const Icon(Icons.format_color_text),
          Positioned(
            bottom: 0,
            left: 1,
            child: Container(
              width: 16,
              height: 4,
              color: color ?? Colors.black,
            ),
          ),
        ],
      );
    }

    Widget _buildColorButton(Set<Attribution> attributions) {
      final colorAttribution =
          attributions.whereType<ColorAttribution>().firstOrNull;

      return Tooltip(
        message: 'Text color',
        waitDuration: tooltipDelay,
        child: ColorSelector(
          parentFocusNode: editorFocusNode,
          tapRegionGroupId: _tapRegionGroupId,
          onSelected: _onChangeTextColorRequested,
          selectedColor: colorAttribution?.color ?? Colors.black,
          colorButtonBuilder: (_, color) => _buildTextColorIcon(color),
        ),
      );
    }

    void _onChangeBackgroundColorRequested(Color? newColor) {
      final selection = composer.selection;
      if (selection == null) {
        return;
      }

      final colorAttributions =
          document.getAttributionsByType<BackgroundColorAttribution>(selection);

      editor.execute([
        for (final existingAttribution in colorAttributions) //
          RemoveTextAttributionsRequest(
              documentRange: selection, attributions: {existingAttribution}),
        if (newColor != null) //
          AddTextAttributionsRequest(
            documentRange: selection,
            attributions: {BackgroundColorAttribution(newColor)},
          ),
      ]);
    }

    Widget _buildBackgroundColorIcon(Color? color) {
      return Stack(
        children: [
          const Icon(Icons.format_color_fill),
          Positioned(
            bottom: 0,
            left: 1,
            child: Container(
              width: 16,
              height: 4,
              color: color ?? Colors.black,
            ),
          ),
        ],
      );
    }

    Widget _buildBackgroundColorButton(Set<Attribution> attributions) {
      final colorAttribution =
          attributions.whereType<BackgroundColorAttribution>().firstOrNull;

      return Tooltip(
        message: 'Highlight color',
        waitDuration: tooltipDelay,
        child: ColorSelector(
          parentFocusNode: editorFocusNode,
          tapRegionGroupId: _tapRegionGroupId,
          onSelected: _onChangeBackgroundColorRequested,
          showClearButton: true,
          selectedColor: colorAttribution?.color ?? Colors.black,
          colorButtonBuilder: (_, color) => _buildBackgroundColorIcon(color),
        ),
      );
    }

    void showNotImplementedAlert() {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Docs Demo'),
            content: const Text('Feature not implemented yet'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void _onToggleTaskNodeRequested() {
      final selection = composer.selection;
      if (selection == null) {
        return;
      }

      final node = document.getNodeById(selection.extent.nodeId);
      if (node is TaskNode) {
        editor.execute([
          DeleteUpstreamAtBeginningOfNodeRequest(node),
        ]);
      } else {
        editor.execute([
          ConvertParagraphToTaskRequest(nodeId: selection.extent.nodeId),
        ]);
      }
    }

    void _onToggleUnorderedListItemRequested() {
      final selection = composer.selection;
      if (selection == null) {
        return;
      }

      final node = document.getNodeById(selection.extent.nodeId);
      if (node is ListItemNode) {
        editor.execute([
          ConvertListItemToParagraphRequest(
              nodeId: node.id, paragraphMetadata: node.metadata),
        ]);
      } else {
        editor.execute([
          ConvertParagraphToListItemRequest(
            nodeId: selection.extent.nodeId,
            type: ListItemType.unordered,
          ),
        ]);
      }
    }

    void _onToggleOrderedListItemRequested() {
      final selection = composer.selection;
      if (selection == null) {
        return;
      }

      final node = document.getNodeById(selection.extent.nodeId);
      if (node is ListItemNode) {
        editor.execute([
          ConvertListItemToParagraphRequest(
              nodeId: node.id, paragraphMetadata: node.metadata),
        ]);
      } else {
        editor.execute([
          ConvertParagraphToListItemRequest(
            nodeId: selection.extent.nodeId,
            type: ListItemType.ordered,
          ),
        ]);
      }
    }

    void _onClearFormattingRequested() {
      final selection = composer.selection;
      if (selection == null) {
        return;
      }
    }

    TextAlign _getCurrentTextAlignment() {
      if (composer.selection == null) {
        return TextAlign.left;
      }
      final selectedNode =
          document.getNodeById(composer.selection!.extent.nodeId);
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
        throw Exception('Invalid node type: $selectedNode');
      }
    }

    void _changeAlignment(TextAlign? newAlignment) {
      if (composer.selection == null || newAlignment == null) {
        return;
      }

      editor.execute([
        ChangeParagraphAlignmentRequest(
          nodeId: composer.selection!.extent.nodeId,
          alignment: newAlignment,
        ),
      ]);
    }

    void _onChangeAlignmentRequested(IconItem? selectedItem) {
      if (selectedItem != null) {
        _changeAlignment(
            TextAlign.values.firstWhere((e) => e.name == selectedItem.id));
      }
    }

    Widget _buildAlignmentSelector() {
      final alignment = _getCurrentTextAlignment();
      return Tooltip(
        message: 'Alignment',
        waitDuration: tooltipDelay,
        child: IconSelector(
          parentFocusNode: editorFocusNode,
          tapRegionGroupId: _tapRegionGroupId,
          selectedIcon: IconItem(
            id: alignment.name,
            icon: _getTextAlignIcon(alignment),
          ),
          icons: const [
            TextAlign.left,
            TextAlign.center,
            TextAlign.right,
            TextAlign.justify
          ]
              .map(
                (alignment) => IconItem(
                  icon: _getTextAlignIcon(alignment),
                  id: alignment.name,
                ),
              )
              .toList(),
          onSelected: _onChangeAlignmentRequested,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: Colors.grey.shade300,
        //RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        //StadiumBorder()
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SizedBox(
          width: double.infinity,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 9.0),
            child: Row(
              children: [
                //! group 1
                ToolBarImageButton(
                  selected: false,
                  onPressed: showNotImplementedAlert,
                  hint: 'Undo',
                  child: const Icon(Icons.undo),
                ),
                const SizedBox(width: 1),
                ToolBarImageButton(
                  selected: false,
                  onPressed: showNotImplementedAlert,
                  hint: 'Redo',
                  child: const Icon(Icons.redo),
                ),
                const SizedBox(width: 1),
                ToolBarImageButton(
                  selected: false,
                  onPressed: showNotImplementedAlert,
                  hint: 'Spellcheck',
                  child: const Icon(Icons.spellcheck),
                ),
                const SizedBox(width: 1),
                ToolBarImageButton(
                  selected: false,
                  onPressed: showNotImplementedAlert,
                  hint: 'Paint Formating',
                  child: const Icon(Icons.format_paint_outlined),
                ),
                //! group 2
                buildZoomSelector(),
                // _buildBlockTypeSelector(),
                // _buildFontFamilySelector(attributions),
                // _buildFontSizeSelector(attributions),

                //! group 3
                ToolBarImageButton(
                  onPressed: () => toggleAttribution(boldAttribution),
                  selected: doesSelectionHaveAttributions({boldAttribution}),
                  hint: 'Bold',
                  child: const Icon(Icons.format_bold_outlined),
                ),
                ToolBarImageButton(
                  onPressed: () => toggleAttribution(italicsAttribution),
                  selected: doesSelectionHaveAttributions({italicsAttribution}),
                  hint: 'Italics',
                  child: const Icon(Icons.format_italic_outlined),
                ),
                ToolBarImageButton(
                  onPressed: () => toggleAttribution(underlineAttribution),
                  selected:
                      doesSelectionHaveAttributions({underlineAttribution}),
                  hint: 'Underline',
                  child: const Icon(Icons.format_underline_outlined),
                ),
                ToolBarImageButton(
                  selected: false,
                  onPressed: showNotImplementedAlert,
                  hint: 'Add photo',
                  child: const Icon(Icons.add_photo_alternate_outlined),
                ),
                const SizedBox(width: 2),
                _buildColorButton(attributions),
                //! group 4
                const SizedBox(width: 2),
                _buildBackgroundColorButton(attributions),
                //_buildLinkButton(),
                //! group 5
                _buildAlignmentSelector(),
                //! group 6
                const SizedBox(width: 2),
                ToolBarImageButton(
                  selected: false,
                  onPressed: showNotImplementedAlert,
                  hint: 'Line spacing',
                  child: const Icon(Icons.format_line_spacing),
                ),
                ToolBarImageButton(
                  selected: false,
                  onPressed: _onToggleTaskNodeRequested,
                  hint: 'Checklist',
                  child: const Icon(Icons.checklist),
                ),
                ToolBarImageButton(
                  selected: false,
                  onPressed: _onToggleUnorderedListItemRequested,
                  hint: 'Bulleted list',
                  child: const Icon(Icons.format_list_bulleted),
                ),
                ToolBarImageButton(
                  selected: false,
                  onPressed: _onToggleOrderedListItemRequested,
                  hint: 'Numbered list',
                  child: const Icon(Icons.format_list_numbered),
                ),
                ToolBarImageButton(
                  selected: false,
                  onPressed: showNotImplementedAlert,
                  hint: 'Decrease indent',
                  child: const Icon(Icons.format_indent_decrease),
                ),
                ToolBarImageButton(
                  selected: false,
                  onPressed: showNotImplementedAlert,
                  hint: 'Increase indent',
                  child: const Icon(Icons.format_indent_increase),
                ),
                ToolBarImageButton(
                  selected: false,
                  onPressed: _onClearFormattingRequested,
                  hint: 'Clear formatting',
                  child: const Icon(Icons.format_clear),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final defaultToolbarButtonStyle = ButtonStyle(
  // backgroundColor: WidgetStateProperty.resolveWith(Colors.amber),
  overlayColor: WidgetStateProperty.all(Colors.transparent),
  foregroundColor: WidgetStateProperty.all(Colors.black),
  fixedSize: WidgetStateProperty.all(const Size(30, 30)),
  minimumSize: WidgetStateProperty.all(const Size(30, 30)),
  maximumSize: WidgetStateProperty.all(const Size(30, 30)),
  iconSize: WidgetStateProperty.all(18),
  padding: WidgetStateProperty.all(EdgeInsets.zero),
  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
  ),
  shadowColor: WidgetStateProperty.all(Colors.transparent),
);

class ToolBarImageButton extends HookWidget {
  const ToolBarImageButton({
    this.onPressed,
    required this.selected,
    this.size = const Size(30, 30),
    required this.hint,
    required this.child,
    super.key,
  });

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether or not the internal button should contain the state
  /// `MaterialState.selected`.
  final bool selected;

  /// The desired size for the button.
  final Size? size;

  /// Hint text displayed when hovering the button.
  final String hint;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final statesController = useMemoized(WidgetStatesController.new, []);
    useEffect(() {
      statesController.update(WidgetState.selected, selected);
      return null;
    }, [selected]);

    useEffect(() {
      return statesController.dispose;
    }, []);

    return Tooltip(
      message: hint,
      waitDuration: tooltipDelay,
      child: TextButton(
        onPressed: onPressed,
        statesController: statesController,
        style: defaultToolbarButtonStyle.copyWith(
          fixedSize: WidgetStateProperty.all(size),
          minimumSize: WidgetStateProperty.all(size),
          maximumSize: WidgetStateProperty.all(size),
        ),
        child: child,
      ),
    );
  }
}
